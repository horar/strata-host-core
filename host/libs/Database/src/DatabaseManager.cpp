#include "logging/LoggingQtCategories.h"
#include "DatabaseManager.h"
#include "DatabaseAccess.h"

#include <QDir>
#include <QDebug>
#include <QCoreApplication>

DatabaseManager::DatabaseManager(const QString &endpointURL, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener) {
    userAccessDb_ = getUserAccessMap();
    endpointURL_ = endpointURL;

    // Object valid if database open successful
    if (userAccessDb_ == nullptr) {
        qDebug() << "Error: Failed to open user_access_map.";
        return;
    }

    if (!userAccessDb_->startReplicator(endpointURL, "", "", "pushandpull", changeListener, documentListener, true)) {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL << "is valid.";
    }
}

DatabaseManager::~DatabaseManager() {
    delete userAccessDb_;
}

DatabaseAccess* DatabaseManager::login(const QString &name, const QString &channelsRequested, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener) {
    if (channelsRequested.isEmpty() || channelsRequested == "*" || channelsRequested == "all") {
        return login(name, QStringList(), changeListener, documentListener);
    } else {
        const QStringList ls = {channelsRequested};
        return login(name, ls, changeListener, documentListener);
    }
}

DatabaseAccess* DatabaseManager::login(const QString &name, const QStringList &channelsRequested, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener) {
    if (name.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: username cannot be empty.";
        return nullptr;
    }

    authenticate(name);

    QStringList channelAccess;
    const QStringList channelsGranted = getChannelsAccessGranted();

    if (channelsRequested.isEmpty()) {
        channelAccess = channelsGranted;
    } else {
        for (const auto& channel : channelsRequested) {
            if (channelsGranted.contains(channel)) {
                channelAccess << channel;
            } else {
                qCWarning(logCategoryCouchbaseDatabase) << "Login denied to channel" << channel;
            }
        }
    }

    dbAccess_ = new DatabaseAccess();
    dbAccess_->name_ = name;
    dbAccess_->channelAccess_ = channelAccess;

    auto userDir = manageUserDir(name, dbAccess_->channelAccess_);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    for (const auto& bucket : channelAccess) {
        auto db = std::make_unique<CouchbaseDatabase>(bucket.toStdString(), userDir.toStdString());
        dbAccess_->database_map_.push_back(std::move(db));

        if (dbAccess_->database_map_.back()->open()) {
            qCCritical(logCategoryCouchbaseDatabase) << "Opened bucket " << bucket;
        } else {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket " << bucket;
        }
    }

    // Start replicator (pull only for user DBs)
    if (!dbAccess_->startReplicator(endpointURL_, "", "", "pull", changeListener, documentListener, true)) {
        qDebug() << "Error: replicator failed to start. Verify endpoint URL" << endpointURL_ << "is valid.";
    }

    return dbAccess_;
}

bool DatabaseManager::authenticate(const QString &name) {
    if (name.isEmpty()) {
        return false;
    }

    channelsAccessGranted_.clear();
    channelsAccessDenied_.clear();
    loggedUsername_ = name;

    auto userAccessDb = userAccessDb_->getDatabaseAsJsonObj();
    auto userAccessMap = userAccessDb["user_access_map"];
    auto userAccessObj = userAccessMap.toObject();

    bool ok = true;
    foreach (const QString& key, userAccessObj.keys()) {
        auto value = userAccessObj.value(key);
        if (!value.isArray()) {
            qDebug() << "Error: user access map channel field must be array";
            ok = false;
            continue;
        }
        auto userArray = value.toArray();
        if (userArray.contains(name)) {
            channelsAccessGranted_.append(key);
        } else {
            channelsAccessDenied_.append(key);
        }
    }

    channelsAccessGranted_.removeDuplicates();
    channelsAccessDenied_.removeDuplicates();

    return ok;
}

DatabaseAccess* DatabaseManager::getUserAccessMap() {
    userAccessDb_ = new DatabaseAccess();
    userAccessDb_->name_ = "user_access_map";
    userAccessDb_->channelAccess_ << "user_access_map";

    auto userDir = manageUserDir(userAccessDb_->name_, userAccessDb_->channelAccess_);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    auto db = std::make_unique<CouchbaseDatabase>(userAccessDb_->name_.toStdString(), userDir.toStdString());
    userAccessDb_->database_map_.push_back(std::move(db));
    if (!userAccessDb_->database_map_.back()->open()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to open bucket" << userAccessDb_->name_;
        return nullptr;
    }

    return userAccessDb_;
}

QString DatabaseManager::manageUserDir(const QString &name, const QStringList &channelAccess) {
    QDir applicationDir(QCoreApplication::applicationDirPath());
    #ifdef Q_OS_MACOS
        applicationDir.cdUp();
    #endif
    const QString dbDir = applicationDir.filePath(dbDirName_);
    QDir().mkdir(dbDir);

    QString userDir;
    if (applicationDir.cd(dbDirName_)) {
        userDir = applicationDir.filePath(name);
        QDir().mkdir(userDir);
        userAccessDb_->user_directory_ = userDir;
    } else {
        return QString();
    }

    applicationDir.cd(userDir);
    auto subDirectories = applicationDir.entryList();
    for (auto& subDir : subDirectories) {
        if (subDir.startsWith(".")) {
            continue;
        }

        subDir.replace(".cblite2", "");
        if (channelAccess.indexOf(subDir) < 0) {
            auto dir = QDir(userDir + QDir::separator() + subDir + ".cblite2");
            if (dir.removeRecursively()) {
                qInfo() << "Channel/directory " << subDir << "found locally but not in access list, deleted: " << dir.path();
            } else {
                qInfo() << "Error: channel/directory " << subDir<< "found locally but not in access list, failed to delete: " << dir.path();
            }
        }
    }

    return userDir;
}

bool DatabaseManager::joinChannel(const QString &loginUsername, const QString &channel) {
    authenticate(loginUsername);
    return userAccessDb_->joinChannel(loginUsername, channel);
}

bool DatabaseManager::leaveChannel(const QString &loginUsername, const QString &channel) {
    authenticate(loginUsername);
    return userAccessDb_->leaveChannel(loginUsername, channel);
}

QStringList DatabaseManager::getChannelsAccessGranted() {
    authenticate(loggedUsername_);
    return channelsAccessGranted_;
}

QStringList DatabaseManager::getChannelsAccessDenied() {
    authenticate(loggedUsername_);
    return channelsAccessDenied_;
}

QStringList DatabaseManager::readChannelsAccessGrantedOfUser(const QString &loginUsername) {
    QStringList retChannelsGranted;

    auto userAccessDb = userAccessDb_->getDatabaseAsJsonObj();
    auto userAccessMap = userAccessDb["user_access_map"];
    auto userAccessObj = userAccessMap.toObject();

    foreach (const QString& key, userAccessObj.keys()) {
        auto value = userAccessObj.value(key);
        if (!value.isArray()) {
            qDebug() << "Error: user access map channel field must be array";
            continue;
        }
        auto userArray = value.toArray();
        if (userArray.contains(loginUsername)) {
            retChannelsGranted.append(key);
        }
    }

    retChannelsGranted.removeDuplicates();
    return retChannelsGranted;
}

QStringList DatabaseManager::readChannelsAccessDeniedOfUser(const QString &loginUsername) {
    QStringList retChannelsDenied;

    auto userAccessDb = userAccessDb_->getDatabaseAsJsonObj();
    auto userAccessMap = userAccessDb["user_access_map"];
    auto userAccessObj = userAccessMap.toObject();

    foreach (const QString& key, userAccessObj.keys()) {
        auto value = userAccessObj.value(key);
        if (!value.isArray()) {
            qDebug() << "Error: user access map channel field must be array";
            continue;
        }
        auto userArray = value.toArray();
        if (!userArray.contains(loginUsername)) {
            retChannelsDenied.append(key);
        }
    }

    retChannelsDenied.removeDuplicates();
    return retChannelsDenied;
}

QString DatabaseManager::getDbDirName() {
    return dbDirName_;
}

QString DatabaseManager::getReplicatorStatus() {
    if (userAccessDb_) {
        return userAccessDb_->getReplicatorStatus();
    }
    return QString();
}

int DatabaseManager::getReplicatorError() {
    if (userAccessDb_) {
        return userAccessDb_->getReplicatorError();
    }
    return -1;
}
