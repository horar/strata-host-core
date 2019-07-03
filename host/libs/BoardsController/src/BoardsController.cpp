
#include "BoardsController.h"
#include "PlatformBoard.h"

#include <PlatformConnection.h>
#include "logging/LoggingQtCategories.h"
#include <QJsonDocument>

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
        qCCritical(logCategoryBoardsController) << "Initialization of platform manager failed";
    }

    connect(&flasherConnector_, &FlasherConnector::taskDone,
            this, &BoardsController::programDeviceDoneHandler);

    connect(&flasherConnector_, &FlasherConnector::notify,
            this, &BoardsController::notify);
}

void BoardsController::sendCommand(QString connection_id, QString message)
{
    spyglass::PlatformConnectionShPtr conn = platform_mgr_.getConnection(connection_id.toStdString() );
    if (!conn) {
        return;
    }

    qCInfo(logCategoryBoardsController) << "message to send" << connection_id << message;

    conn->addMessage(message.toStdString() );
}

QVariantMap BoardsController::getConnectionInfo(const QString &connectionId)
{
    QVariantMap result;

    spyglass::PlatformConnectionShPtr connection = platform_mgr_.getConnection(connectionId.toStdString());
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
    spyglass::PlatformConnectionShPtr connection = platform_mgr_.getConnection(connectionId.toStdString());
    if (!connection) {
        return;
    }

    PlatformBoard* board = conn_handler_.getBoard(connection);
    if (board == nullptr) {
        return;
    }

    closeConnection(connectionId);

    newConnection(QString::fromStdString(connection->getName()));

    board->sendInitialMsg();
}

bool BoardsController::disconnect(const QString &connectionId)
{
    bool isRemoved = platform_mgr_.removeConnection(connectionId.toStdString());
    if (isRemoved == false) {
        qCWarning(logCategoryBoardsController) << "board could not be disconnected" << connectionId;
        return false;
    }

    closeConnection(connectionId);
    return true;
}

void BoardsController::programDevice(const QString &connectionId, const QString &firmwarePath)
{
    qCInfo(logCategoryBoardsController) << connectionId << firmwarePath;

    spyglass::PlatformConnectionShPtr connection = getConnection(connectionId);
    if (connection == nullptr) {
        qCWarning(logCategoryBoardsController) << "unknown connection id" << connectionId;
        notify(connectionId, "Connection Id not valid.");
        programDeviceDone(connectionId, false);
        return;
    }

    flasherConnector_.start(connection, firmwarePath);
}

QStringList BoardsController::connectionIds() const
{
    return connectionIds_;
}

spyglass::PlatformConnectionShPtr BoardsController::getConnection(const QString &connectionId)
{
    return platform_mgr_.getConnection(connectionId.toStdString());
}

void BoardsController::newConnection(const QString &connectionId)
{
    qCInfo(logCategoryBoardsController) << "new connection" << connectionId;

    if (connectionIds_.indexOf(connectionId) < 0) {
        connectionIds_.append(connectionId);
        emit connectionIdsChanged();
    }
    else {
        qCWarning(logCategoryBoardsController) << "board is already connected" << connectionId;
    }

    emit connectedBoard(connectionId);
}

void BoardsController::activeConnection(const QString &connectionId)
{
    qCInfo(logCategoryBoardsController).noquote()
            << "active connection"
            << QJsonDocument::fromVariant(getConnectionInfo(connectionId)).toJson(QJsonDocument::Compact);

    emit activeBoard(connectionId);
}

void BoardsController::closeConnection(const QString &connectionId)
{
    qCInfo(logCategoryBoardsController) << "close connection" << connectionId;

    int ret = connectionIds_.removeAll(connectionId);
    emit connectionIdsChanged();

    if (ret != 1) {
        qCWarning(logCategoryBoardsController) << "suspicious number of boards removed" << connectionId << ret;
    }

    emit disconnectedBoard(connectionId);
}

void BoardsController::notifyMessageFromConnection(const QString &connectionId, const QString &message)
{
    QJsonParseError error;
    QJsonDocument::fromJson(message.toUtf8(), &error);
    if (error.error != QJsonParseError::NoError) {
        qCWarning(logCategoryBoardsController).noquote()
                << "received message"
                << "connectionId=" << connectionId
                << "error=" << error.errorString()
                << "message=" << message;
    }

    emit notifyBoardMessage(connectionId, message);
}

void BoardsController::programDeviceDoneHandler(const QString& connectionId, bool status)
{
    emit programDeviceDone(connectionId, status);
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

    receiver_->newConnection(QString::fromStdString(connection->getName()));

    board->sendInitialMsg();
}

void BoardsController::ConnectionHandler::onCloseConnection(spyglass::PlatformConnectionShPtr connection)
{
    PlatformBoard* board = getBoard(connection);
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
                if (board->isPlatformActive()) {
                    receiver_->notifyMessageFromConnection(connId, QString::fromStdString(message));
                }
                break;
            case PlatformBoard::ProcessResult::eProcessed:
                if (board->isPlatformActive()) {
                    receiver_->activeConnection(QString::fromStdString(connection->getName()));
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

