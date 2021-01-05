#include "logging/LoggingQtCategories.h"
#include "DatabaseManager.h"
#include "DatabaseAccess.h"

#include <QDir>
#include <QDebug>
#include <QCoreApplication>

DatabaseAccess* DatabaseManager::open(const QString &name, const QString &channel_access) {
    dbAccess_ = new DatabaseAccess();
    dbAccess_->name_ = name;

    QString channel_access_str;
    if (channel_access.isEmpty()) {
        dbAccess_->channel_access_ << name;
        channel_access_str = name;
    } else {
        dbAccess_->channel_access_ << channel_access;
        channel_access_str = channel_access;
    }

    auto userDir = manageUserDir(name, dbAccess_->channel_access_);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    auto db = std::make_unique<CouchbaseDatabase>(channel_access_str.toStdString(), userDir.toStdString());
    dbAccess_->database_map_.push_back(std::move(db));
    if (dbAccess_->database_map_.back()->open()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Opened bucket " << channel_access_str;
    } else {
        qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket " << channel_access_str;
    }

    return dbAccess_;
}

DatabaseAccess* DatabaseManager::open(const QString &name, const QStringList &channel_access) {
    dbAccess_ = new DatabaseAccess();
    dbAccess_->name_ = name;
    dbAccess_->channel_access_ = channel_access;

    auto userDir = manageUserDir(name, dbAccess_->channel_access_);
    if (userDir.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to create database directory.";
        return nullptr;
    }

    for (const auto& bucket : channel_access) {
        auto db = std::make_unique<CouchbaseDatabase>(bucket.toStdString(), userDir.toStdString());
        dbAccess_->database_map_.push_back(std::move(db));

        if (dbAccess_->database_map_.back()->open()) {
            qCCritical(logCategoryCouchbaseDatabase) << "Opened bucket " << bucket;
        } else {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket " << bucket;
        }
    }

    return dbAccess_;
}

QString DatabaseManager::manageUserDir(const QString &name, const QStringList &channel_access) {
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
        dbAccess_->user_directory_ = userDir;
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
        if (channel_access.indexOf(subDir) < 0) {
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

QString DatabaseManager::getDbDirName() {
    return dbDirName_;
}
