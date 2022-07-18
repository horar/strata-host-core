/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SciPlatformModel.h"
#include "logging/LoggingQtCategories.h"

SciPlatformModel::SciPlatformModel(strata::PlatformManager *platformManager, QObject *parent)
    : QAbstractListModel(parent),
      platformManager_(platformManager)
{
    connect(platformManager_, &strata::PlatformManager::platformOpened, this, &SciPlatformModel::boardConnectedHandler);
    connect(platformManager_, &strata::PlatformManager::platformRecognized, this, &SciPlatformModel::boardReadyHandler);
    connect(platformManager_, &strata::PlatformManager::platformAboutToClose, this, &SciPlatformModel::boardDisconnectedHandler);
}

SciPlatformModel::~SciPlatformModel()
{
    clear();
}

void SciPlatformModel::clear()
{
    if (platformList_.empty() == false) {
        beginResetModel();

        foreach(SciPlatform *item, platformList_) {
            item->setPlatform(nullptr); // erase platform references
            item->deleteLater();
        }

        platformList_.clear();

        endResetModel();
        emit countChanged();
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

        for (auto *platform : qAsConst(platformList_)) {
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

        for (auto *platform : qAsConst(platformList_)) {
            platform->commandHistoryModel()->setMaximumCount(maxCmdInHistoryCount_);
        }
    }
}

void SciPlatformModel::setCondensedAtStartup(bool condensedAtStartup)
{
    if (condensedAtStartup_ != condensedAtStartup) {
        condensedAtStartup_ = condensedAtStartup;
        emit condensedAtStartupChanged();
    }
}

bool SciPlatformModel::condensedAtStartup() const
{
    return condensedAtStartup_;
}

void SciPlatformModel::releasePort(int index, int disconnectDuration)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(lcSci) << "index out of range";
        return;
    }

    if (platformList_.at(index)->status() == SciPlatform::PlatformStatus::Disconnected) {
        return;
    }

    platformManager_->disconnectPlatform(
                platformList_.at(index)->deviceId(),
                std::chrono::milliseconds(disconnectDuration));
}

bool SciPlatformModel::acquirePort(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(lcSci) << "index out of range";
        return false;
    }

    return platformList_.at(index)->acquirePort();
}

void SciPlatformModel::removePlatform(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(lcSci) << "index out of range";
        return;
    }

    SciPlatform *item = platformList_.at(index);

    beginRemoveRows(QModelIndex(), index, index);

    item->deleteLater();
    platformList_.removeAt(index);

    endRemoveRows();

    emit countChanged();

    platformManager_->disconnectPlatform(item->deviceId());
}

void SciPlatformModel::reconnect(int index)
{
    if (index < 0 || index >= platformList_.count()) {
        qCCritical(lcSci) << "index out of range";
    }

    platformManager_->reconnectPlatform(platformList_.at(index)->deviceId());
}

QHash<int, QByteArray> SciPlatformModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[PlatformRole] = "platform";
    roles[BugFixRole] = "bugFixRole";
    return roles;
}

void SciPlatformModel::boardConnectedHandler(const QByteArray& deviceId)
{
    int index = findPlatform(deviceId);
    if (index < 0) {
        appendNewPlatform(deviceId);
    } else {
        platformList_.at(index)->setErrorString("");
        platformList_.at(index)->setPlatform(platformManager_->getPlatform(deviceId));
        platformList_.at(index)->setStatus(SciPlatform::PlatformStatus::Connected);
        platformList_.at(index)->resetPropertiesFromDevice();

        emit platformConnected(index);
    }
}

void SciPlatformModel::boardReadyHandler(const QByteArray& deviceId, bool recognized, bool inBootloader)
{
    Q_UNUSED(inBootloader)

    int index = findPlatform(deviceId);
    if (index < 0) {
        qCCritical(lcSci) << "unknown board" << deviceId;
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

    emit platformReady(index, recognized);
}

void SciPlatformModel::boardDisconnectedHandler(const QByteArray& deviceId)
{
    int index = findPlatform(deviceId);
    if (index < 0) {
        // platform might have been disconnected from UI
        return;
    }

    platformList_.at(index)->setPlatform(nullptr);
}

int SciPlatformModel::findPlatform(const QByteArray& deviceId) const
{
    for (int i = 0; i < platformList_.length(); ++i) {
        if (platformList_.at(i)->deviceId() == deviceId) {
            return i;
        }
    }

    return -1;
}

void SciPlatformModel::appendNewPlatform(const QByteArray& deviceId)
{
    strata::platform::PlatformPtr platform = platformManager_->getPlatform(deviceId);
    if (platform == nullptr) {
        qCWarning(lcSci).noquote() << "Platform not found by its id" << deviceId;
        return;
    }

    beginInsertRows(QModelIndex(), platformList_.length(), platformList_.length());

    SciPlatform *item = new SciPlatform(&sciSettings_, platformManager_, this);
    item->setPlatform(platform);
    item->setStatus(SciPlatform::PlatformStatus::Connected);
    item->scrollbackModel()->setMaximumCount(maxScrollbackCount_);
    item->commandHistoryModel()->setMaximumCount(maxCmdInHistoryCount_);
    item->scrollbackModel()->setCondensedMode(condensedAtStartup_);
    item->setDeviceName(platform->deviceName());
    platformList_.append(item);

    endInsertRows();

    emit countChanged();

    emit platformConnected(platformList_.length() - 1);
}
