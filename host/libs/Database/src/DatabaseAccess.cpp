#include "logging/LoggingQtCategories.h"
#include "DatabaseManager.h"
#include "DatabaseAccess.h"

#include <QDir>
#include <QDebug>
#include <QCoreApplication>

DatabaseAccess::DatabaseAccess() {

}

DatabaseAccess::~DatabaseAccess() {
    close();
}

bool DatabaseAccess::close() {
    for (const auto& bucket : database_map_) {
        if (!bucket) {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to close bucket " << QString::fromStdString(bucket->getDatabaseName());
            return false;
        }
        bucket->stopReplicator();
        bucket->close();
    }

    return true;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QString &bucket) {
    // Bucket not provided - do not accept
    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- a valid bucket is required";
        return false;
    }
    // Bucket is "*" or "all": write to all buckets
    bool ok = true;
    if (bucket == "*" || bucket.toLower() == "all") {
        for (const auto& _bucket : database_map_) {
            std::vector<std::string> channels;
            for (const auto& channel : channelAccess_) {
                channels.push_back(channel.toStdString());
            }
            doc->tagChannelField(channels);
            if (!_bucket->save(doc)) {
                qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket " << QString::fromStdString(_bucket->getDatabaseName());
                ok = false;
            }
        }
    }
    // A single bucket was provided
    else {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket" << bucket << "not found in map";
            return false;
        }
        return bucketObj->save(doc);
    }
    return ok;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QStringList &buckets) {
    // Array of buckets is empty - do not accept
    if (buckets.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- a valid array of buckets is required";
        return false;
    }
    // A valid array of buckets was provided
    bool ok = true;
    for (const auto& bucket : buckets) {
        if (!write(doc, bucket)) {
            ok = false;
        }
    }
    return ok;
}

bool DatabaseAccess::deleteDoc(const QString &id, const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
            return false;
        }
        return bucketObj->deleteDoc(id.toStdString());
    }

    qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
    return false;
}

QString DatabaseAccess::getDocumentAsStr(const QString &id, const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
            return QString();
        }
        return QString::fromStdString(bucketObj->getDocumentAsStr(id.toStdString()));
    }

    qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
    return QString();
}

QJsonObject DatabaseAccess::getDocumentAsJsonObj(const QString &id, const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channelAccess_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return QJsonObject();
    }

    return bucketObj->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject DatabaseAccess::getDatabaseAsJsonObj(const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qDebug() << "Error: a valid bucket must be provided";
            return QJsonObject();
        }
        return bucketObj->getDatabaseAsJsonObj();
    }

    QJsonObject combinedObj;
    for (const auto& _bucket : database_map_) {
        auto this_obj = _bucket->getDatabaseAsJsonObj();
        for (auto it = this_obj.constBegin(); it != this_obj.constEnd(); it++) {
            combinedObj.insert(it.key(), it.value());
        }
    }

    return combinedObj;
}

QStringList DatabaseAccess::getAllDocumentKeys(const QString &bucket) {
    if (!bucket.isEmpty()) {
        auto bucketObj = getBucket(bucket);
        if (!bucketObj) {
            qDebug() << "Error: a valid bucket must be provided";
            return QStringList();
        }

        auto key_vector = bucketObj->getAllDocumentKeys();
        QStringList list;
        for (const auto key : key_vector) {
            list << QString::fromStdString(key);
        }
        return list;
    }

    qDebug() << "Error: a valid bucket must be provided";
    return QStringList();
}

bool DatabaseAccess::startSessionReplicator(const QString &url, const QString &token, const QString cookie_name, const QString &replicator_type,
                               std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
                               std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
                               bool continuous) {

    CouchbaseDatabase::ReplicatorType _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    if (replicator_type.isEmpty() || replicator_type == "pull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    } else if (replicator_type == "push") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
    } else if (replicator_type == "pushandpull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    } else {
        qDebug() << "Error: empty or invalid replicator type provided, defaulting to Pull.";
    }

    if (changeListener) {
        change_listener_callback = changeListener;
    } else {
        change_listener_callback = std::bind(&DatabaseAccess::default_changeListener, this, std::placeholders::_1, std::placeholders::_2);
    }

    if (documentListener) {
        document_listener_callback = documentListener;
    } else {
        document_listener_callback = std::bind(&DatabaseAccess::default_documentListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
    }

    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (!bucket->startSessionReplicator(url.toStdString(), token.toStdString(), cookie_name.toStdString(), single_DB_channel, _replicator_type, nullptr, nullptr, continuous)) {
            qDebug() << "Error: Failed to start replicator on bucket/channel " << QString::fromStdString(bucket->getDatabaseName());
        }
    }

    return true;
}

bool DatabaseAccess::startBasicReplicator(const QString &url, const QString &username, const QString &password, const QString &replicator_type,
                               std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener,
                               std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener,
                               bool continuous) {

    std::vector<std::string> channels;
    for (const auto& channel : channelAccess_) {
        channels.push_back(channel.toStdString());
    }

    CouchbaseDatabase::ReplicatorType _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    if (replicator_type.isEmpty() || replicator_type == "pull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
    } else if (replicator_type == "push") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
    } else if (replicator_type == "pushandpull") {
        _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    } else {
        qDebug() << "Error: empty or invalid replicator type provided, defaulting to Pull.";
    }

    if (changeListener) {
        change_listener_callback = changeListener;
    } else {
        change_listener_callback = std::bind(&DatabaseAccess::default_changeListener, this, std::placeholders::_1, std::placeholders::_2);
    }

    if (documentListener) {
        document_listener_callback = documentListener;
    } else {
        document_listener_callback = std::bind(&DatabaseAccess::default_documentListener, this, std::placeholders::_1, std::placeholders::_2, std::placeholders::_3);
    }

    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (!bucket->startBasicReplicator(url.toStdString(), username.toStdString(), password.toStdString(), single_DB_channel, _replicator_type, change_listener_callback, document_listener_callback, continuous)) {
            qDebug() << "Error: Failed to start replicator on bucket/channel " << QString::fromStdString(bucket->getDatabaseName());
        }
    }

    return true;
}

void DatabaseAccess::stopReplicator() {
    for (const auto& bucket : database_map_) {
        bucket->stopReplicator();
    }
}

CouchbaseDatabase* DatabaseAccess::getBucket(const QString &bucketName) {
    for (const auto& bucket : database_map_) {
        if (QString::fromStdString(bucket->getDatabaseName()) == bucketName) {
            return bucket.get();
        }
    }

    return nullptr;
}

void DatabaseAccess::clearUserDir(const QString &userName, const QString &dbDirName) {
    QDir applicationDir(QCoreApplication::applicationDirPath());
    #ifdef Q_OS_MACOS
        applicationDir.cdUp();
    #endif
    if (applicationDir.cd(dbDirName)) {
        if (applicationDir.cd(userName)) {
            auto subDirectories = applicationDir.entryList();
            for (auto& subDir : subDirectories) {
                if (subDir.startsWith(".")) {
                    continue;
                }

                auto dir = QDir(applicationDir.path() + QDir::separator() + subDir);
                if (dir.removeRecursively()) {
                    qInfo() << "Channel/directory " << subDir << "found locally but not in access list, deleted: " << dir.path();
                } else {
                    qInfo() << "Error: channel/directory " << subDir<< "found locally but not in access list, failed to delete: " << dir.path();
                }
            }
        }
    }
}

bool DatabaseAccess::joinChannel(const QString &loginUsername, const QString &channel) {
    if (loginUsername.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid username must be provided";
        return false;
    }

    if (channel.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid channel must be provided";
        return false;
    }

    auto bucketObj = getBucket(getDatabaseName());
    if (!bucketObj) {
        qCCritical(logCategoryCouchbaseDatabase) << "DB name is " << getDatabaseName();
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return false;
    }

    bucketObj->joinChannel(loginUsername, channel);
    return true;
}

bool DatabaseAccess::leaveChannel(const QString &loginUsername, const QString &channel) {
    if (loginUsername.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid username must be provided";
        return false;
    }

    if (channel.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid channel must be provided";
        return false;
    }

    auto bucketObj = getBucket(getDatabaseName());
    if (!bucketObj) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return false;
    }

    bucketObj->leaveChannel(loginUsername, channel);
    return true;
}

QString DatabaseAccess::getReplicatorStatus(const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channelAccess_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return QString();
    }

    return QString::fromStdString(bucketObj->getReplicatorStatus());
}

int DatabaseAccess::getReplicatorError(const QString &bucket) {
    QString bucketName;
    if (bucket.isEmpty()) {
        bucketName = channelAccess_.at(0);
    } else {
        bucketName = bucket;
    }

    auto bucketObj = getBucket(bucketName);
    if (!bucketObj) {
        qDebug() << "Error: a valid bucket must be provided";
        return -1;
    }

    return bucketObj->getReplicatorError();
}

void DatabaseAccess::default_changeListener(cbl::Replicator, const CBLReplicatorStatus &status) {
    qDebug() << "--- PROGRESS: status=" << status.activity << ", fraction=" << status.progress.fractionComplete << ", err=" << status.error.domain << "/" << status.error.code;
}

void DatabaseAccess::default_documentListener(cbl::Replicator, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents) {
    qDebug() << "--- " << documents.size() << " docs " << (isPush ? "pushed." : "pulled.");
}

QString DatabaseAccess::getDatabaseName() {
    return name_;
}

QString DatabaseAccess::getDatabasePath() {
    return user_directory_;
}
