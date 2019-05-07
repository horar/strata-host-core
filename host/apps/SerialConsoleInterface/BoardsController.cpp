
#include "BoardsController.h"
#include "PlatformBoard.h"

#include <PlatformConnection.h>

BoardsController::BoardsController(QObject *parent) : QObject(parent), conn_handler_()
{
}

BoardsController::~BoardsController()
{
    platform_mgr_.Stop();
}

void BoardsController::initialize()
{
    conn_handler_.setParent(this);

    platform_mgr_.Init();
    platform_mgr_.setPlatformHandler(&conn_handler_);

    platform_mgr_.StartLoop();
}

void BoardsController::sendCommand(QString connection_id, QString message)
{
    spyglass::PlatformConnectionShPtr conn = platform_mgr_.getConnection(connection_id.toStdString() );
    if (!conn) {
        return;
    }

    conn->addMessage(message.toStdString() );
}

void BoardsController::newConnection(const std::string& connection_id, const std::string& verbose_name)
{
    emit connectedBoard(QString::fromStdString(connection_id), QString::fromStdString(verbose_name));
}

void BoardsController::removeConnection(const std::string& connection_id)
{
    emit disconnectedBoard(QString::fromStdString(connection_id));
}

void BoardsController::notifyMessageFromConnection(const std::string& connection_id, const std::string& message)
{
    emit notifyBoardMessage(QString::fromStdString(connection_id), QString::fromStdString(message) );
}


///////////////////////////////////////////////////////////////////////////////////////////////////

BoardsController::ConnectionHandler::ConnectionHandler() : parent_(nullptr)
{
}

BoardsController::ConnectionHandler::~ConnectionHandler()
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    for(auto item : connections_) {
        delete item.second;
    }
}

void BoardsController::ConnectionHandler::setParent(BoardsController *parent)
{
    parent_ = parent;
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
    PlatformBoard* board = getBoard(connection.get());
    if (board == nullptr) {
        return;
    }

    parent_->removeConnection( connection->getName() );

    delete board;

    {
        std::lock_guard<std::mutex> lock(connectionsLock_);
        connections_.erase(connection.get());
    }
}

void BoardsController::ConnectionHandler::onNotifyReadConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformBoard* board = getBoard(connection.get());
    if (board == nullptr) {
        return;
    }

    std::string conn_id = connection->getName();

    std::string message;
    while( connection->getMessage(message)) {

        PlatformBoard::ProcessResult status = board->handleMessage(message);
        switch(status)
        {
            case PlatformBoard::ProcessResult::eIgnored:
                parent_->notifyMessageFromConnection( conn_id, message );
                break;
            case PlatformBoard::ProcessResult::eProcessed:
                if (board->isPlatformConnected() && false == board->getPlatformId().empty()) {
                    parent_->newConnection(conn_id, board->getVerboseName() );
                }
                break;
            case PlatformBoard::ProcessResult::eParseError:
            case PlatformBoard::ProcessResult::eValidationError:
                //TODO: add some error to log file...
                break;
        }
    }
}

PlatformBoard* BoardsController::ConnectionHandler::getBoard(spyglass::PlatformConnection* connection)
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    auto findIt = connections_.find(connection);
    if (findIt == connections_.end()) {
        return nullptr;
    }

    return findIt->second;
}

