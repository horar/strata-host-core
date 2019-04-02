
#include "serial_port.h"
#include "serial_port_config.h"

#include <libserialport.h>
#include <vector>
#include <string>
#include <assert.h>

#if defined(__unix__) || defined(__APPLE__)
  #include <sys/file.h>
#endif
#if defined(_WIN32)
  #include <windows.h>
#endif

serial_port::serial_port() : portHandle_(nullptr), event_(nullptr)
{
}

serial_port::~serial_port()
{

}

void serial_port::setupSGFormat()
{
    serial_port_settings serialport;
    sp_set_stopbits(portHandle_, (int)SERIAL_PORT_CONFIGURATION::STOP_BIT);
    sp_set_bits(portHandle_, (int)SERIAL_PORT_CONFIGURATION::DATA_BIT);
    sp_set_baudrate(portHandle_, (int)SERIAL_PORT_CONFIGURATION::BAUD_RATE);
    sp_set_rts(portHandle_, serialport.rts_);
    sp_set_dtr(portHandle_, serialport.dtr_);
    sp_set_parity(portHandle_, serialport.parity_);
    sp_set_cts(portHandle_, serialport.cts_);
}

bool serial_port::open(const std::string& port_name)
{
    sp_return error = sp_get_port_by_name(port_name.c_str(), &portHandle_);
    if (error != SP_OK) {
        return false;
    }

    error = sp_open(portHandle_, SP_MODE_READ_WRITE);

#if defined(__unix__) || defined(__APPLE__)
    if (error == SP_OK) {
        if (flock(getFileDescriptor(), LOCK_EX | LOCK_NB) < 0) {
            error = SP_ERR_FAIL;
        }
    }
#endif

    if (error != SP_OK) {
        return false;
    }

    setupSGFormat();

    flush();
    return true;
}

void serial_port::close()
{
    if (!portHandle_)
        return;

#if defined(__unix__) || defined(__APPLE__)
    flock(getFileDescriptor(), LOCK_UN);
#endif

    if (sp_close(portHandle_) != SP_OK) {
        return;
    }
    portHandle_ = nullptr;
}

int serial_port::read(unsigned char* data_buffer, size_t buffer_size, unsigned int timeout)
{
    if (event_ == nullptr) {
        sp_new_event_set(&event_);
        sp_add_port_events(event_, portHandle_, SP_EVENT_RX_READY);
    }

    if (timeout > 0) {
        sp_wait(event_, timeout);
    }
    assert(portHandle_);
    int ret = sp_nonblocking_read(portHandle_, data_buffer, buffer_size);
    if (ret < 0) {
        //TODO: log error...
        return ret;
    }
    return ret;     //number of data read
}

int serial_port::write(unsigned char* data_buffer, size_t buffer_size, unsigned int timeout)
{
    assert(portHandle_);
    sp_return error = sp_blocking_write(portHandle_, data_buffer, buffer_size, timeout);
    return static_cast<int>(error);
}

bool serial_port::flush()
{
    assert(portHandle_);
    return (sp_flush(portHandle_, SP_BUF_BOTH) == SP_OK) ? true : false;
}

sp_handle_t serial_port::getFileDescriptor()
{
    if (!portHandle_) {
        return -1;
    }

    sp_handle_t fd;
    if (sp_get_port_handle(portHandle_, &fd) != SP_OK) {
        return static_cast<sp_handle_t>(-1);
    }
    return fd;
}

const char* serial_port::getName() const
{
    if (!portHandle_) {
        return nullptr;
    }

    return sp_get_port_name(portHandle_);
}

///////////////////////////////////////////////////////////////////////////////////

#ifdef __APPLE__
static const char* g_usb_keyword = "usb";
#elif __linux__
static const char* g_usb_keyword = "USB";
#elif _WIN32
static const char* g_usb_keyword = "COM";
#endif

bool getListOfSerialPorts(std::vector<std::string>& result_list)
{
    struct sp_port **ports;
    sp_return ret = sp_list_ports(&ports);
    if (ret != SP_OK) {
        return false;
    }

    std::string port_name;
    result_list.clear();
    for (int i = 0; ports[i] != nullptr; i++) {

        port_name = std::string( sp_get_port_name(ports[i]) );
        std::string::size_type idx = port_name.find(g_usb_keyword);
        if (idx != std::string::npos) {
            result_list.push_back(port_name);
        }
    }
    sp_free_port_list(ports);
    return true;
}

