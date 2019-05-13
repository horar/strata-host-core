
#include "BoardsController.h"
#include "PlatformBoard.h"

#include <PlatformConnection.h>
#include <QDebug>

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

    if (platform_mgr_.Init()) {
        platform_mgr_.setPlatformHandler(&conn_handler_);
        platform_mgr_.StartLoop();
    } else {
        //TODO: notify user
        qDebug() << "BoardsController::BoardsController() Initialization of platform manager failed.";
    }
}

void BoardsController::sendCommand(QString connection_id, QString message)
{
    spyglass::PlatformConnection* conn = conn_handler_.getConnection(connection_id.toStdString() );
    if (conn == nullptr) {
        return;
    }

    conn->addMessage(message.toStdString() );
}

QVariantMap BoardsController::getConnectionInfo(const QString &connectionId)
{
    QVariantMap result;

    spyglass::PlatformConnection* connection = conn_handler_.getConnection(connectionId.toStdString());
    if (connection == nullptr) {
        return result;
    }

    PlatformBoard* board = conn_handler_.getBoard(connection);
    if (board == nullptr) {
        return result;
    }

    result.insert("connectionId", connectionId);
    result.insert("platformId", QString::fromStdString(board->getPlatformId()));
    result.insert("verboseName", QString::fromStdString(board->getVerboseName()));
    result.insert("bootloaderVersion", QString::fromStdString(board->getBootloaderVersion()));
    result.insert("applicationVersion", QString::fromStdString(board->getApplicationVersion()));

    return result;
}

void BoardsController::reconnect(const QString &connectionId)
{
    spyglass::PlatformConnection* connection = conn_handler_.getConnection(connectionId.toStdString());
    if (connection == nullptr) {
        return;
    }

    PlatformBoard* board = conn_handler_.getBoard(connection);
    if (board == nullptr) {
        return;
    }

    closeConnection(connectionId);

    board->sendInitialMsg();
}

QStringList BoardsController::connectionIds() const
{
    return connectionIds_;
}

spyglass::PlatformConnection *BoardsController::getConnection(const QString &connectionId)
{
    return conn_handler_.getConnection(connectionId.toStdString());
}

void BoardsController::newConnection(spyglass::PlatformConnection* connection)
{
    if (connection == nullptr) {
        return;
    }

    QString connectionId = QString::fromStdString(connection->getName());

    if (connectionIds_.indexOf(connectionId) < 0) {
        connectionIds_.append(connectionId);
        emit connectionIdsChanged();
    } else {
        qDebug() << "ERROR: this board is already connected" << connectionId;
    }

    emit connectedBoard(connectionId);
}

void BoardsController::closeConnection(const QString &connectionId)
{
    int ret = connectionIds_.removeAll(connectionId);
    emit connectionIdsChanged();

    if (ret != 1) {
        qDebug() << "ERROR: suspicious number of boards removed" << connectionId << ret;
    }

    emit disconnectedBoard(connectionId);
}

void BoardsController::notifyMessageFromConnection(const QString &connectionId, const QString &message)
{
    emit notifyBoardMessage(connectionId, message);
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

void BoardsController::ConnectionHandler::onNewConnection(spyglass::PlatformConnection *connection)
{
    PlatformBoard* board = new PlatformBoard(connection);

    {
        std::lock_guard<std::mutex> lock(connectionsLock_);
        connections_.insert({connection, board});
    }

    board->sendInitialMsg();
}

void BoardsController::ConnectionHandler::onCloseConnection(spyglass::PlatformConnection *connection)
{
    PlatformBoard* board = getBoard(connection);
    if (board == nullptr) {
        return;
    }

    parent_->closeConnection(QString::fromStdString(connection->getName()));

    delete board;

    {
        std::lock_guard<std::mutex> lock(connectionsLock_);
        connections_.erase(connection);
    }
}

void BoardsController::ConnectionHandler::onNotifyReadConnection(spyglass::PlatformConnection* connection)
{
    PlatformBoard* board = getBoard(connection);
    if (board == nullptr) {
        return;
    }

    QString connId = QString::fromStdString(connection->getName());

    std::string message;
    while (connection->getMessage(message)) {

        PlatformBoard::ProcessResult status = board->handleMessage(message);
        switch(status)
        {
            case PlatformBoard::ProcessResult::eIgnored:
                if (board->isPlatformConnected()) {
                    parent_->notifyMessageFromConnection(connId, QString::fromStdString(message));
                }
                break;
            case PlatformBoard::ProcessResult::eProcessed:
                if (board->isPlatformConnected()) {
                    parent_->newConnection(connection);
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

spyglass::PlatformConnection* BoardsController::ConnectionHandler::getConnection(const std::string& conn_id)
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    for(auto item : connections_ ) {
        if (item.first->getName() == conn_id) {
            return item.first;
        }
    }

    return nullptr;
}

