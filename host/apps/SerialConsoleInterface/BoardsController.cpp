
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
    conn_handler_.setReceiver(this);

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
    spyglass::PlatformConnectionShPtr conn = platform_mgr_.getConnection(connection_id.toStdString() );
    if (!conn) {
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

    result.insert(QStringLiteral("connectionId"), connectionId);
    result.insert(QStringLiteral("platformId"), QString::fromStdString(board->getPlatformId()));
    result.insert(QStringLiteral("verboseName"), QString::fromStdString(board->getVerboseName()));
    result.insert(QStringLiteral("bootloaderVersion"), QString::fromStdString(board->getBootloaderVersion()));
    result.insert(QStringLiteral("applicationVersion"), QString::fromStdString(board->getApplicationVersion()));

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

BoardsController::ConnectionHandler::ConnectionHandler() : receiver_(nullptr)
{
}

BoardsController::ConnectionHandler::~ConnectionHandler()
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    for(auto item : connections_) {
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
    PlatformBoard* board = getBoard(connection.get());
    if (board == nullptr) {
        return;
    }

    receiver_->closeConnection(QString::fromStdString(connection->getName()));

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

    QString connId = QString::fromStdString(connection->getName());

    std::string message;
    while (connection->getMessage(message)) {

        PlatformBoard::ProcessResult status = board->handleMessage(message);
        switch(status)
        {
            case PlatformBoard::ProcessResult::eIgnored:
                if (board->isPlatformConnected()) {
                    receiver_->notifyMessageFromConnection(connId, QString::fromStdString(message));
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

PlatformBoard* BoardsController::ConnectionHandler::getBoard(spyglass::PlatformConnection* connection)
{
    std::lock_guard<std::mutex> lock(connectionsLock_);
    auto findIt = connections_.find(connection);
    if (findIt == connections_.end()) {
        return nullptr;
    }

    return findIt->second;
}

