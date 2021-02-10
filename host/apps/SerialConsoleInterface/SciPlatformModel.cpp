#include "SciPlatformModel.h"
#include "logging/LoggingQtCategories.h"

SciPlatformModel::SciPlatformModel(strata::BoardManager *boardManager, QObject *parent)
    : QAbstractListModel(parent),
      boardManager_(boardManager)
{
    connect(boardManager_, &strata::BoardManager::boardConnected, this, &SciPlatformModel::boardConnectedHandler);
    connect(boardManager_, &strata::BoardManager::boardInfoChanged, this, &SciPlatformModel::boardReadyHandler);
    connect(boardManager_, &strata::BoardManager::boardDisconnected, this, &SciPlatformModel::boardDisconnectedHandler);
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

    switch (role) {
    case Qt::DisplayRole:
    case PlatformRole:
        return QVariant::fromValue(platformList_.at(row));
        break;
    }

    return QVariant();
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
            platform->scrollbackModel()->setMaximumCount(maxScrollbackCount_);
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
            platform->commandHistoryModel()->setMaximumCount(maxCmdInHistoryCount_);
        }
    }
}

void SciPlatformModel::setCondensedInScrollback(bool condensedInScrollback)
{
    if (condensedInScrollback_ != condensedInScrollback) {
        condensedInScrollback_ = condensedInScrollback;
    }
    emit condensedInScrollbackChanged();
}

bool SciPlatformModel::condensedInScrollback() const
{
    return condensedInScrollback_;
}

void SciPlatformModel::disconnectPlatformFromSci(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return;
    }

    if (platformList_.at(index)->status() == SciPlatform::PlatformStatus::Disconnected) {
        return;
    }

    boardManager_->disconnectDevice(platformList_.at(index)->deviceId());

    platformList_.at(index)->setStatus(SciPlatform::PlatformStatus::Disconnected);
}

void SciPlatformModel::removePlatform(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
        return;
    }

    SciPlatform *item = platformList_.at(index);

    beginRemoveRows(QModelIndex(), index, index);

    item->deleteLater();
    platformList_.removeAt(index);

    endRemoveRows();

    emit countChanged();
}

void SciPlatformModel::reconnect(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(logCategorySci) << "index out of range";
    }

    boardManager_->reconnectDevice(platformList_.at(index)->deviceId());
}

QHash<int, QByteArray> SciPlatformModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PlatformRole] = "platform";
    roles[BugFixRole] = "bugFixRole";
    return roles;
}

void SciPlatformModel::boardConnectedHandler(int deviceId)
{
    int index = findPlatform(deviceId);
    if (index < 0) {
        appendNewPlatform(deviceId);
    } else {
        platformList_.at(index)->setErrorString("");
        platformList_.at(index)->setDevice(boardManager_->device(deviceId));
        platformList_.at(index)->setStatus(SciPlatform::PlatformStatus::Connected);
        platformList_.at(index)->resetPropertiesFromDevice();

        emit platformConnected(index);
    }
}

void SciPlatformModel::boardReadyHandler(int deviceId, bool recognized)
{
    int index = findPlatform(deviceId);
    if (index < 0) {
        qCCritical(logCategorySci) << "unknown board" << deviceId;
        return;
    }

    SciPlatform *platform = platformList_[index];

    platform->resetPropertiesFromDevice();

    if (recognized) {
        SciPlatformSettingsItem *settingsItem = sciSettings_.getBoardData(platform->verboseName());
        if (settingsItem != nullptr) {
            platform->commandHistoryModel()->populate(settingsItem->commandHistoryList);
            platform->scrollbackModel()->setExportFilePath(settingsItem->exportPath);
            platform->scrollbackModel()->setAutoExportFilePath(settingsItem->autoExportPath);

        }
        platform->setStatus(SciPlatform::PlatformStatus::Ready);
    } else {
        platform->setStatus(SciPlatform::PlatformStatus::NotRecognized);
    }

    emit platformReady(index);
}

void SciPlatformModel::boardDisconnectedHandler(int deviceId)
{
    int index = findPlatform(deviceId);
    if (index < 0) {
        //device might have been disconnected from UI
        return;
    }

    platformList_.at(index)->setDevice(nullptr);
}

int SciPlatformModel::findPlatform(int deviceId) const
{
    for (int i = 0; i < platformList_.length(); ++i) {
        if (platformList_.at(i)->deviceId() == deviceId) {
            return i;
        }
    }

    return -1;
}

void SciPlatformModel::appendNewPlatform(int deviceId)
{
    strata::device::DevicePtr device = boardManager_->device(deviceId);
    if (device == nullptr) {
        qCCritical(logCategorySci) << "device not found by its id";
        return;
    }

    beginInsertRows(QModelIndex(), platformList_.length(), platformList_.length());

    SciPlatform *item = new SciPlatform(&sciSettings_, this);
    item->setDevice(device);
    item->setStatus(SciPlatform::PlatformStatus::Connected);
    item->scrollbackModel()->setMaximumCount(maxScrollbackCount_);
    item->commandHistoryModel()->setMaximumCount(maxCmdInHistoryCount_);
    item->scrollbackModel()->setCondensedMode(condensedInScrollback_);
    item->setDeviceName(device->deviceName());
    platformList_.append(item);

    endInsertRows();

    emit countChanged();

    emit platformConnected(platformList_.length() - 1);
}
