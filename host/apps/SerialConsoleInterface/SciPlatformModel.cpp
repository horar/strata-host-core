#include "SciPlatformModel.h"
#include "logging/LoggingQtCategories.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QStandardPaths>
#include <QDir>
#include <QSaveFile>


SciPlatformModel::SciPlatformModel(spyglass::BoardManager *boardManager, QObject *parent)
    : QAbstractListModel(parent),
      boardManager_(boardManager)
{
    setModelRoles();

    connect(boardManager_, &spyglass::BoardManager::boardConnected, this, &SciPlatformModel::boardConnectedHandler);
    connect(boardManager_, &spyglass::BoardManager::boardReady, this, &SciPlatformModel::boardReadyHandler);
    connect(boardManager_, &spyglass::BoardManager::boardDisconnected, this, &SciPlatformModel::boardDisconnectedHandler);
    connect(boardManager_, &spyglass::BoardManager::newMessage, this, &SciPlatformModel::newMessageHandler);
}

SciPlatformModel::~SciPlatformModel()
{
    for (int i = platformList_.length() - 1; i >= 0 ; --i) {
        removePlatform(i);
    }
}

QVariant SciPlatformModel::data(const QModelIndex &index, int role) const
{
    int row = index.row();
    if (row < 0 || row >= platformList_.count()) {
        return QVariant();
    }

    SciPlatformModelItem *item = platformList_.at(row);

    switch (role) {
    case VerboseNameRole:
        return item->verboseName;
    case AppVersionRole:
        return item->appVersion;
    case BootloaderVersionRole:
        return item->bootloaderVersion;
    case StatusRole:
        return item->status;
    case ScrollbackModelRole:
        return QVariant::fromValue(item->scrollbackModel);
    case ConnectionIdRole:
        return item->connectionId;
    case CommandHistoryModelRole:
        return QVariant::fromValue(item->commandHistoryModel);
    }

    return QVariant();
}

QVariant SciPlatformModel::data(int row, const QByteArray &role) const
{
    int enumRole = roleByNameHash_.value(role, -1);
    return data(this->index(row), enumRole);
}

bool SciPlatformModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    int row = index.row();
    if (row < 0 || row >= platformList_.count()) {
        return false;
    }

    QVariant oldValue = data(this->index(row), role);
    if (oldValue == value) {
        return false;
    }

    SciPlatformModelItem *item = platformList_[row];

    switch (role) {
    case VerboseNameRole:
        item->verboseName = value.toString();
        break;
    case AppVersionRole:
        item->appVersion = value.toString();
        break;
    case BootloaderVersionRole:
        item->bootloaderVersion = value.toString();
        break;
    case StatusRole:
        item->status = static_cast<SciPlatformModel::PlatformStatus>(value.toInt());
        break;
    case ScrollbackModelRole:
    case ConnectionIdRole:
    case CommandHistoryModelRole:
        qCCritical(logCategorySci) << "this role cannot be changed" << role;
        return false;
    }

    emit dataChanged(
                createIndex(row, 0),
                createIndex(row, 0),
                QVector<int>() << role);

    return true;
}

bool SciPlatformModel::setData(int row, const QVariant &value, int role)
{
    return setData(index(row, 0), value, role);
}

int SciPlatformModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent)
    return platformList_.length();
}

int SciPlatformModel::count() const
{
    return platformList_.length();
}

int SciPlatformModel::maxScrollbackCount() const
{
    return maxScrollbackCount_;
}

void SciPlatformModel::setMaxScrollbackCount(int maxScrollbackCount)
{
    if (maxScrollbackCount_ != maxScrollbackCount) {
        maxScrollbackCount_ = maxScrollbackCount;
        emit maxScrollbackCountChanged();

        for (auto *platform : platformList_) {
            platform->scrollbackModel->setMaximumCount(maxScrollbackCount_);
        }
    }
}

int SciPlatformModel::maxCmdInHistoryCount() const
{
    return maxCmdInHistoryCount_;
}

void SciPlatformModel::setMaxCmdInHistoryCount(int maxCmdInHistoryCount)
{
    if (maxCmdInHistoryCount_ != maxCmdInHistoryCount) {
        maxCmdInHistoryCount_ = maxCmdInHistoryCount;
        emit maxCmdInHistoryCountChanged();

        for (auto *platform : platformList_) {
            platform->commandHistoryModel->setMaximumCount(maxCmdInHistoryCount_);
        }
    }
}

bool SciPlatformModel::ignoreNewConnections() const
{
    return ignoreNewConnections_;
}

void SciPlatformModel::setIgnoreNewConnections(bool ignoreNewConnections)
{
    if (ignoreNewConnections_ != ignoreNewConnections) {
        ignoreNewConnections_ = ignoreNewConnections;
        emit ignoreNewConnectionsChanged();
    }
}

void SciPlatformModel::disconnectPlatformFromSci(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return;
    }

    boardManager_->disconnect(platformList_.at(index)->connectionId);

    setData(index, PlatformStatus::Disconnected, StatusRole);
}

void SciPlatformModel::removePlatform(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return;
    }

    SciPlatformModelItem *item = platformList_.at(index);

    beginRemoveRows(QModelIndex(), index, index);

    item->deleteLater();
    platformList_.removeAt(index);

    endRemoveRows();

    emit countChanged();
}

bool SciPlatformModel::sendMessage(int index, QString message)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return false;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(message.toUtf8(), &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qCWarning(logCategorySci) << "cannot parse JSON"
                   << "offset=" << parseError.offset
                   << "error=" << parseError.error
                   << parseError.errorString();
        return false;
    }

    SciPlatformModelItem *item = platformList_.at(index);
    QString compactMessage = doc.toJson(QJsonDocument::Compact);

    item->scrollbackModel->append(compactMessage, SciScrollbackModel::MessageType::Request);
    item->commandHistoryModel->add(compactMessage);

    if (item->status != PlatformStatus::NotRecognized) {
        sciSettings_.setCommandHistory(item->verboseName, item->commandHistoryModel->getCommandList());
    }

    boardManager_->sendMessage(item->connectionId, compactMessage);

    return true;
}

void SciPlatformModel::reconectAll()
{
    QVector<int> ids = boardManager_->readyConnectionIds();
    for (int id : ids) {
        int index = findPlatfrom(id);
        if (index >= 0) {
            setData(index, PlatformStatus::Connected, StatusRole);
        }

        boardManager_->reconnect(id);
    }
}

bool SciPlatformModel::exportScrollback(int index, QString filePath) const
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return false;
    }

    QSaveFile file(filePath);
    bool ret = file.open(QIODevice::WriteOnly | QIODevice::Text);
    if (ret == false) {
        qCCritical(logCategorySci) << "cannot open file" << filePath << file.errorString();
        return false;
    }

    QTextStream out(&file);

    out << platformList_.at(index)->scrollbackModel->getTextForExport();

    return file.commit();
}

QHash<int, QByteArray> SciPlatformModel::roleNames() const
{
    return roleByEnumHash_;
}

void SciPlatformModel::boardConnectedHandler(int connectionId)
{
    if (ignoreNewConnections_) {
        return;
    }

    int index = findPlatfrom(connectionId);
    if (index < 0) {
        appendNewPlatform(connectionId);
    } else {
        setData(index, PlatformStatus::Connected, StatusRole);
    }
}

void SciPlatformModel::boardReadyHandler(int connectionId, bool recognized)
{
    if (ignoreNewConnections_) {
        return;
    }

    int index = findPlatfrom(connectionId);
    if (index < 0) {
        qCCritical(logCategorySci) << "unknown board" << connectionId;
        return;
    }

    if (recognized) {
        QString verboseName = boardManager_->getDeviceProperty(connectionId, spyglass::DeviceProperties::verboseName);
        QString appVersion = boardManager_->getDeviceProperty(connectionId, spyglass::DeviceProperties::applicationVer);
        QString bootloaderVersion = boardManager_->getDeviceProperty(connectionId, spyglass::DeviceProperties::applicationVer);

        if (verboseName.isEmpty()) {
            if (appVersion.isEmpty() == false) {
                verboseName = "Application v" + appVersion;
            } else if (bootloaderVersion.isEmpty() == false) {
                verboseName = "Bootloader v" + bootloaderVersion;
            } else {
                verboseName = "Unknown Board";
            }
        }

        SciPlatformSettingsItem *settingsItem = sciSettings_.getBoardData(verboseName);
        if (settingsItem != nullptr) {
            platformList_.at(index)->commandHistoryModel->populate(settingsItem->commandHistoryList);
        }

        setData(index, verboseName, VerboseNameRole);
        setData(index, appVersion, AppVersionRole);
        setData(index, bootloaderVersion, BootloaderVersionRole);
        setData(index, PlatformStatus::Ready, StatusRole);
    } else {
        setData(index, PlatformStatus::NotRecognized, StatusRole);
    }

    emit platformReady(index);
}

void SciPlatformModel::boardDisconnectedHandler(int connectionId)
{
    int index = findPlatfrom(connectionId);
    if (index < 0) {
        qCCritical(logCategorySci) << "unknown board" << connectionId;
        return;
    }

    setData(index, PlatformStatus::Disconnected, StatusRole);
}

void SciPlatformModel::newMessageHandler(int connectionId, QString message)
{
    int index = findPlatfrom(connectionId);
    if (index < 0) {
        qCCritical(logCategorySci) << "message from unknown platfrom" << connectionId;
        return;
    }

    platformList_.at(index)->scrollbackModel->append(message, SciScrollbackModel::MessageType::Response);
}

void SciPlatformModel::setModelRoles()
{
    roleByEnumHash_.clear();
    roleByEnumHash_.insert(VerboseNameRole, "verboseName");
    roleByEnumHash_.insert(AppVersionRole, "appVersion");
    roleByEnumHash_.insert(BootloaderVersionRole, "bootloaderVersion");
    roleByEnumHash_.insert(StatusRole, "status");
    roleByEnumHash_.insert(ScrollbackModelRole, "scrollbackModel");
    roleByEnumHash_.insert(ConnectionIdRole, "connectionId");
    roleByEnumHash_.insert(CommandHistoryModelRole, "commandHistoryModel");

    QHash<int, QByteArray>::const_iterator i = roleByEnumHash_.constBegin();
    while (i != roleByEnumHash_.constEnd()) {
        roleByNameHash_.insert(i.value(), i.key());
        ++i;
    }
}

int SciPlatformModel::findPlatfrom(int connectionId) const
{
    for (int i = 0; i < platformList_.length(); ++i) {
        if (platformList_.at(i)->connectionId == connectionId) {
            return i;
        }
    }

    return -1;
}

void SciPlatformModel::appendNewPlatform(int connectionId)
{
    beginInsertRows(QModelIndex(), platformList_.length(), platformList_.length());

    SciPlatformModelItem *item = new SciPlatformModelItem(maxScrollbackCount_, maxCmdInHistoryCount_, this);
    item->verboseName = "Unknown Board";
    item->connectionId = connectionId;
    item->status = PlatformStatus::Connected;

    platformList_.append(item);

    endInsertRows();

    emit countChanged();
}

SciPlatformModelItem::SciPlatformModelItem(int maxScrollbackCount, int maxCmdInHistoryCount, QObject *parent)
    : QObject(parent)
{
    scrollbackModel = new SciScrollbackModel(this);
    scrollbackModel->setMaximumCount(maxScrollbackCount);

    commandHistoryModel = new SciCommandHistoryModel(this);
    commandHistoryModel->setMaximumCount(maxCmdInHistoryCount);

    status = SciPlatformModel::PlatformStatus::Disconnected;
}

SciPlatformModelItem::~SciPlatformModelItem()
{
    scrollbackModel->deleteLater();
    commandHistoryModel->deleteLater();
}
