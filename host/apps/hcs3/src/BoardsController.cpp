
#include "BoardsController.h"
#include "PlatformBoard.h"
#include "Dispatcher.h"
#include "LoggingAdapter.h"

#include <PlatformConnection.h>

#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>


BoardsController::BoardsController() : conn_handler_()
{
}

BoardsController::~BoardsController()
{
    platform_mgr_.Stop();
}

bool BoardsController::initialize(HCS_Dispatcher* dispatcher)
{
    if (!platform_mgr_.Init()) {
        return false;
    }

    dispatcher_ = dispatcher;
    conn_handler_.setReceiver(this);
    platform_mgr_.setPlatformHandler(&conn_handler_);
    platform_mgr_.StartLoop();
    return true;
}

void BoardsController::setLogAdapter(LoggingAdapter* adapter)
{
    logAdapter_ = adapter;
}

void BoardsController::sendMessage(const std::string& connectionId, const std::string& message)
{
    spyglass::PlatformConnectionShPtr conn = platform_mgr_.getConnection(connectionId);
    if (conn == nullptr) {
        return;
    }

    conn->addMessage(message);
}

PlatformBoard* BoardsController::getPlatformBoard(const std::string& connectionId)
{
    spyglass::PlatformConnectionShPtr conn = platform_mgr_.getConnection(connectionId);
    if (conn == nullptr) {
        return nullptr;
    }

    return conn_handler_.getBoard(conn);
}

PlatformBoard* BoardsController::findByPlatformId(const std::string& platformId)
{
    return conn_handler_.findByPlatformId(platformId);
}

PlatformBoard* BoardsController::getBoardByClientId(const std::string& clientId)
{
    std::vector<PlatformBoard*> connected = conn_handler_.getConnectedList();
    for(auto item : connected) {
        if (clientId == item->getClientId()) {
            return item;
        }
    }

    return nullptr;
}

PlatformBoard* BoardsController::getFirstBoardByClassId(const std::string& classId)
{
    std::vector<PlatformBoard*> connected = conn_handler_.getConnectedList();
    for(auto item : connected) {
        if (classId == item->getProperty("class_id")) {
            return item;
        }
    }

    return nullptr;
}

bool BoardsController::createPlatformsList(std::string& result)
{
    std::vector<PlatformBoard*> connected = conn_handler_.getConnectedList();

    // document is the root of a json message
    rapidjson::Document document;
    // define the document as an object rather than an array
    document.SetObject();
    rapidjson::Value array(rapidjson::kArrayType);
    rapidjson::Document::AllocatorType& allocator = document.GetAllocator();

    // traversing through the list
    for(const auto& item : connected)
    {
        rapidjson::Value json_verbose(item->getProperty("name").c_str(),allocator);
        rapidjson::Value json_uuid(item->getProperty("class_id").c_str(),allocator);
        rapidjson::Value array_object;
        array_object.SetObject();

        array_object.AddMember("name",json_verbose, allocator);
        array_object.AddMember("class_id",json_uuid, allocator);
        array_object.AddMember("connection", "connected", allocator);
        array.PushBack(array_object,allocator);
    }
    rapidjson::Value nested_object;
    nested_object.SetObject();
    nested_object.AddMember("list",array,allocator);
    document.AddMember("hcs::notification",nested_object,allocator);

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    document.Accept(writer);
    result = strbuf.GetString();
    return true;
}

void BoardsController::newConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformConnected;
    item.from_client = connection->getName();
    item.message = std::string();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    if (logAdapter_) {
        std::string logText = "New board connected on:" + connection->getName();
        logAdapter_->Log(LoggingAdapter::eLvlInfo, logText);
    }
}

void BoardsController::closeConnection(const std::string& connectionId)
{
    PlatformBoard* board = getPlatformBoard(connectionId);
    assert(board);

    rapidjson::Document document;
    document.SetObject();
    document.AddMember("platform_id", rapidjson::Value( board->getProperty("platform_id").c_str(), document.GetAllocator() ), document.GetAllocator() );
    document.AddMember("class_id", rapidjson::Value( board->getProperty("class_id").c_str(), document.GetAllocator() ), document.GetAllocator() );

    rapidjson::StringBuffer strbuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strbuf);
    document.Accept(writer);

    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformDisconnected;
    item.from_client = connectionId;
    item.message = strbuf.GetString();
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    if (logAdapter_) {
        std::string logText = "Board disconnected on:" + connectionId;
        logAdapter_->Log(LoggingAdapter::eLvlInfo, logText);
    }
}

void BoardsController::notifyMessageFromConnection(const std::string& connectionId, const std::string& message)
{
    PlatformMessage item;
    item.msg_type = PlatformMessage::eMsgPlatformMessage;
    item.from_client = connectionId;
    item.message     = message;
    item.msg_document = nullptr;

    dispatcher_->addMessage(item);

    if (logAdapter_) {
        std::string logText = "Board msg on:" + connectionId;
        logAdapter_->Log(LoggingAdapter::eLvlDebug, logText);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////

BoardsController::ConnectionHandler::ConnectionHandler() : receiver_(nullptr)
{
}

BoardsController::ConnectionHandler::~ConnectionHandler()
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    for (auto item : connections_) {
        delete item.second;
    }
}

void BoardsController::ConnectionHandler::setReceiver(BoardsController *receiver)
{
    receiver_ = receiver;
}

void BoardsController::ConnectionHandler::onNewConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformBoard* board = new PlatformBoard(connection);

    {
        std::lock_guard<std::mutex> lock(connectionsLock_);
        connections_.insert({connection.get(), board});
    }

    board->sendInitialMsg();
}

void BoardsController::ConnectionHandler::onCloseConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformBoard* board = getBoard(connection);
    if (board == nullptr) {
        return;
    }

    receiver_->closeConnection(connection->getName());

    delete board;

    {
        std::lock_guard<std::mutex> lock(connectionsLock_);
        connections_.erase(connection.get());
    }
}

void BoardsController::ConnectionHandler::onNotifyReadConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformBoard* board = getBoard(connection);
    if (board == nullptr) {
        return;
    }

    std::string message;
    while (connection->getMessage(message)) {

        PlatformBoard::ProcessResult status = board->handleMessage(message);
        switch(status)
        {
            case PlatformBoard::ProcessResult::eIgnored:
                if (board->isPlatformConnected()) {
                    receiver_->notifyMessageFromConnection(connection->getName(), message);
                }
                break;
            case PlatformBoard::ProcessResult::eProcessed:
                if (board->isPlatformConnected()) {
                    receiver_->newConnection(connection);
                }
                break;
            case PlatformBoard::ProcessResult::eParseError:
            case PlatformBoard::ProcessResult::eValidationError:
                //TODO: add some error to log file...
                break;
        }
    }
}

PlatformBoard* BoardsController::ConnectionHandler::getBoard(spyglass::PlatformConnectionShPtr connection)
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    auto findIt = connections_.find(connection.get());
    if (findIt == connections_.end()) {
        return nullptr;
    }

    return findIt->second;
}

PlatformBoard* BoardsController::ConnectionHandler::findByPlatformId(const std::string& platformId)
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    for(auto item : connections_) {
        if (item.second->getProperty("platform_id") == platformId) {
            return item.second;
        }
    }
    return nullptr;
}

std::vector<PlatformBoard*> BoardsController::ConnectionHandler::getConnectedList()
{
    std::vector<PlatformBoard*> result;

    std::lock_guard<std::mutex> lock(connectionsLock_);
    for(auto item : connections_) {
        if (item.second->isPlatformConnected() == false  /* TODO: || item.second->getPlatformId().empty() == true */ ) {
            continue;
        }

        result.push_back(item.second);
    }

    return result;
}


