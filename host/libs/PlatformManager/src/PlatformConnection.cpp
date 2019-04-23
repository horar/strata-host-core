
#include "PlatformConnection.h"
#include "PlatformManager.h"

#include <serial_port.h>
#include <EvEventBase.h>

#if defined(__linux__) || defined(__APPLE__)
#include <EvEventsMgr.h>
#elif defined(_WIN32)
#include "WinCommEvent.h"
#include "WinCommFakeEvent.h"
#endif

#include <assert.h>

namespace spyglass {

static const size_t g_readBufferSize = 4096;
static const size_t g_writeBufferSize = 4096;

static const int g_readTimeout = 200;
static const int g_writeTimeout = 200;

//////////////////////////////////////////////////////////////////////////////////////

PlatformConnection::PlatformConnection(PlatformManager* parent) : parent_(parent)
{
    readBuffer_.reserve(g_readBufferSize);
    writeBuffer_.reserve(g_writeBufferSize);
}

PlatformConnection::~PlatformConnection()
{
    close();
}

bool PlatformConnection::open(const std::string& portName)
{
    std::lock_guard<std::mutex> lock(readLock_);

    std::unique_ptr<serial_port> port(new serial_port);
    bool ret = port->open(portName);
    if (ret) {
        port_ = std::move(port);
    }
    return ret;
}

void PlatformConnection::close()
{
    if (event_) {
        event_->deactivate();
        event_.release();
    }

#if defined(_WIN32)
    if (write_event_) {
        write_event_->deactivate();
        write_event_.release();
    }
#endif

    std::lock_guard<std::mutex> rlock(readLock_);
    std::lock_guard<std::mutex> wlock(writeLock_);

    if (port_) {
        port_->close();

        port_.release();
    }
}

bool PlatformConnection::getMessage(std::string& result)
{
    assert(readBuffer_.size() >= readOffset_);

    std::lock_guard<std::mutex> lock(readLock_);
    if (readBuffer_.size() == readOffset_) {
        readBuffer_.clear();
        readOffset_ = 0;
        return false;
    }

    std::string::size_type off = readBuffer_.find('\n', readOffset_);
    if (off == std::string::npos)
        return false;

    while(off == readOffset_) {
        readOffset_++;
        off = readBuffer_.find('\n', readOffset_);
        if (off == std::string::npos)
            return false;
    }


    result = readBuffer_.substr(readOffset_, (off - readOffset_));
    readOffset_ = static_cast<unsigned int>(off + 1);
    if (readBuffer_.size() == readOffset_) {
        readBuffer_.clear();
        readOffset_ = 0;
    }
    return true;
}

void PlatformConnection::onDescriptorEvent(EvEventBase*, int flags)
{
    std::lock_guard<std::recursive_mutex> lock(event_lock_);

    if (flags & EvEventBase::eEvStateRead) {

        if (handleRead(g_readTimeout) < 0) {
            //TODO: [MF] add to log...

            event_->deactivate();

            if (parent_) {
                parent_->removeConnection(this);
            }
        }
        else if (isReadable() && parent_ != nullptr) {
            parent_->notifyConnectionReadable(this);
        }
    }
    if (flags & EvEventBase::eEvStateWrite) {

        if (handleWrite(g_writeTimeout) < 0) {
            //TODO: handle error...

        }

        bool isEmpty;
        {
            std::lock_guard<std::mutex> lock(writeLock_);
            isEmpty = isWriteBufferEmpty();
        }

        if (isEmpty) {
            updateEvent(true, false);
        }
    }
}

int PlatformConnection::handleRead(unsigned int timeout)
{
    unsigned char read_data[512];
    int ret = port_->read(read_data, sizeof(read_data), timeout);
    if (ret <= 0) {
        return ret;
    }

    //TODO: checking if we need allocate more space..

    std::lock_guard<std::mutex> lock(readLock_);
    readBuffer_.append(reinterpret_cast<char*>(read_data), static_cast<size_t>(ret));
    return ret;
}

int PlatformConnection::handleWrite(unsigned int timeout)
{
    std::lock_guard<std::mutex> lock(writeLock_);
    if (isWriteBufferEmpty()) {
        return 0;
    }

    assert(writeBuffer_.size() >= writeOffset_);
    size_t length = writeBuffer_.size() - writeOffset_;
    const unsigned char* data = reinterpret_cast<const unsigned char*>(writeBuffer_.data()) + writeOffset_;

    int ret = port_->write(const_cast<unsigned char*>(data), length, timeout);
    if (ret < 0) {
        return ret;
    }

    writeOffset_ += ret;
    if (writeBuffer_.size() == writeOffset_) {
        writeBuffer_.clear();
        writeOffset_ = 0;
    }
    return ret;
}

void PlatformConnection::addMessage(const std::string& message)
{
    assert(event_);
    bool isWrite = event_->isActive(EvEventBase::eEvStateWrite);

    //TODO: checking for too big messages...

    {
        std::lock_guard<std::mutex> lock(writeLock_);
        writeBuffer_.append(message);
        writeBuffer_.append("\n");
    }

    if (!isWrite) {
        std::lock_guard<std::recursive_mutex> lock(event_lock_);
        updateEvent(true, true);
    }
}

bool PlatformConnection::sendMessage(const std::string &message)
{
    assert(port_);
    if (!port_) {
        return false;
    }

    {
        std::lock_guard<std::mutex> lock(writeLock_);
        writeBuffer_.append(message);
        writeBuffer_.append("\n");
    }

    return (handleWrite(g_writeTimeout) > 0);
}

int PlatformConnection::waitForMessages(unsigned int timeout)
{
    assert(port_);
    return handleRead(timeout);
}

bool PlatformConnection::isReadable()
{
    assert(port_);
    std::lock_guard<std::mutex> lock(readLock_);
    if (readBuffer_.size() <= readOffset_)
        return false;

    std::string::size_type off = readBuffer_.find('\n', static_cast<size_t>(readOffset_));
    if (off == std::string::npos)
        return false;

    return true;
}

std::string PlatformConnection::getName() const
{
    assert(port_);
    return std::string(port_->getName());
}

#if defined(__linux__) || defined(__APPLE__)
bool PlatformConnection::attachEventMgr(EvEventsMgr* ev_manager)
{
    if (!port_ || ev_manager == nullptr) {
        return false;
    }

    std::lock_guard<std::recursive_mutex> lock(event_lock_);

    event_mgr_ = ev_manager;

    int fd = port_->getFileDescriptor();

    event_.reset(new EvEvent(EvEvent::EvType::eEvTypeHandle, fd, 0));
    event_->setCallback(std::bind(&PlatformConnection::onDescriptorEvent, this, std::placeholders::_1, std::placeholders::_2 ) );

    event_mgr_->registerEvent(event_.get());

    return updateEvent(true, false);
}

bool PlatformConnection::updateEvent(bool read, bool write)
{
    if (!event_ || event_mgr_ == nullptr) {
        return false;
    }

    int evFlags = (read ? EvEventBase::eEvStateRead : 0) | (write ? EvEventBase::eEvStateWrite : 0);
    return event_->activate(evFlags);  //event_mgr_
}
#elif defined(_WIN32)

EvEventBase* PlatformConnection::getEvent()
{
    if (!event_) {
        event_.reset(new WinCommEvent());

        HANDLE hCom = reinterpret_cast<HANDLE>(port_->getFileDescriptor());
        event_->create(hCom);
        event_->setCallback(std::bind(&PlatformConnection::onDescriptorEvent, this, std::placeholders::_1, std::placeholders::_2));
    }

    return event_.get();
}

EvEventBase* PlatformConnection::getWriteEvent()
{
    if (!write_event_) {

        write_event_.reset(new WinCommFakeEvent());
        write_event_->create();
        write_event_->setCallback(std::bind(&PlatformConnection::onDescriptorEvent, this, std::placeholders::_1, std::placeholders::_2));
    }

    return write_event_.get();
}

bool PlatformConnection::updateEvent(bool read, bool write)
{
    if (!event_) {
        return false;
    }

    int evFlags = (read ? EvEventBase::eEvStateRead : 0);
    event_->activate(evFlags);

    evFlags = (write ? EvEventBase::eEvStateWrite : 0);
    write_event_->activate(evFlags);

    return true;
}
#endif

void PlatformConnection::detachEventMgr()
{
    if (!port_) {
        return;
    }

    if (event_) {
        std::lock_guard<std::recursive_mutex> lock(event_lock_);
        event_->deactivate();
    }

#if defined(_WIN32)
    if (write_event_) {
        std::lock_guard<std::recursive_mutex> lock(event_lock_);
        write_event_->deactivate();
    }
#endif
}

bool PlatformConnection::stopListeningOnEvents(bool stop)
{
    if (!event_) {
        return false;
    }

#if defined(__linux__) || defined(__APPLE__)
    if (event_mgr_ == nullptr) {
        return false;
    }
#endif

    std::lock_guard<std::recursive_mutex> lock(event_lock_);
    if (stop) {
        event_->deactivate();
        return true;
    }

    //resume
    bool write;
    {
        std::lock_guard<std::mutex> lock(writeLock_);
        write = (isWriteBufferEmpty() == false);  //set write when write buffer isn't empty
    }
    return updateEvent(true, write);
}

bool PlatformConnection::isWriteBufferEmpty() const
{
    return (writeBuffer_.size() - writeOffset_) == 0;
}


} //end of namespace

