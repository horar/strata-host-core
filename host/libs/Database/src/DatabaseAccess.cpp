#include "logging/LoggingQtCategories.h"
#include "Database/DatabaseAccess.h"
#include "Database/CouchbaseDocument.h"
#include "CouchbaseDatabase.h"

#include <QDir>
#include <QCoreApplication>

using namespace strata::Database;

DatabaseAccess::DatabaseAccess() {

}

DatabaseAccess::~DatabaseAccess() {
    close();
}

bool DatabaseAccess::open(const QString &userDir, const QStringList &channelList) {
    if (channelList.isEmpty()) {
        auto db = std::make_unique<CouchbaseDatabase>(name_.toStdString(), userDir.toStdString());
        database_map_.push_back(std::move(db));

        if (database_map_.back()->open()) {
            qCInfo(logCategoryCouchbaseDatabase) << "Opened bucket" << name_;
            return true;
        } else {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket" << name_;
            return false;
        }
    }

    bool ok = true;
    for (const auto& bucket : channelList) {
        auto db = std::make_unique<CouchbaseDatabase>(bucket.toStdString(), userDir.toStdString());
        database_map_.push_back(std::move(db));

        if (database_map_.back()->open()) {
            qCInfo(logCategoryCouchbaseDatabase) << "Opened bucket" << bucket;
        } else {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to open bucket" << bucket;
            ok = false;
        }
    }

    return ok;
}

bool DatabaseAccess::close() {
    bool ok = true;
    for (const auto& bucket : database_map_) {
        if (bucket == nullptr) {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to close bucket" << QString::fromStdString(bucket->getDatabaseName());
            return false;
        }
        bucket->stopReplicator();

        if (bucket->close() == false) {
            qCCritical(logCategoryCouchbaseDatabase) << "Failed to close bucket" << QString::fromStdString(bucket->getDatabaseName());
            ok = false;
        }
    }

    return ok;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QString &bucket) {
    if (doc == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- invalid document received";
        return false;
    }

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
                qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket" << QString::fromStdString(_bucket->getDatabaseName());
                ok = false;
            }
        }
    }
    // A single bucket was provided
    else {
        auto bucketObj = getBucket(bucket);
        if (bucketObj == nullptr) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- bucket" << bucket << "not found in map";
            return false;
        }
        return bucketObj->save(doc);
    }
    return ok;
}

bool DatabaseAccess::write(CouchbaseDocument *doc, const QStringList &buckets) {
    if (doc == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- invalid document received";
        return false;
    }

    // Array of buckets is empty - do not accept
    if (buckets.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed write operation -- a valid array of buckets is required";
        return false;
    }
    // A valid array of buckets was provided
    bool ok = true;
    for (const auto& bucket : buckets) {
        if (write(doc, bucket) == false) {
            ok = false;
        }
    }
    return ok;
}

bool DatabaseAccess::deleteDoc(const QString &id, const QString &bucket) {
    if (id.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to delete document -- a valid id is required";
        return false;
    }

    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to delete document -- a valid bucket must be provided";
        return false;
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to delete document -- a valid bucket must be provided";
        return false;
    }
    return bucketObj->deleteDoc(id.toStdString());
}

QString DatabaseAccess::getDocumentAsStr(const QString &id, const QString &bucket) {
    if (id.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get document contents -- a valid id is required";
        return QString();
    }

    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get document contents -- a valid bucket must be provided";
        return QString();
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get document contents -- a valid bucket must be provided";
        return QString();
    }
    return QString::fromStdString(bucketObj->getDocumentAsStr(id.toStdString()));
}

QJsonObject DatabaseAccess::getDocumentAsJsonObj(const QString &id, const QString &bucket) {
    if (id.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get document contents -- a valid id is required";
        return QJsonObject();
    }

    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get document contents -- a valid bucket must be provided";
        return QJsonObject();
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return QJsonObject();
    }

    return bucketObj->getDocumentAsJsonObj(id.toStdString());
}

QJsonObject DatabaseAccess::getDatabaseAsJsonObj(const QString &bucket) {
    if (bucket.isEmpty() == false) {
        auto bucketObj = getBucket(bucket);
        if (bucketObj == nullptr) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
            return QJsonObject();
        }
        return bucketObj->getDatabaseAsJsonObj();
    }

    QJsonObject combinedObj;
    for (const auto& _bucket : database_map_) {
        auto dbPartialObject = _bucket->getDatabaseAsJsonObj();
        for (auto dbElement = dbPartialObject.constBegin(); dbElement != dbPartialObject.constEnd(); dbElement++) {
            combinedObj.insert(dbElement.key(), dbElement.value());
        }
    }

    return combinedObj;
}

QStringList DatabaseAccess::getAllDocumentKeys(const QString &bucket) {
    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return QStringList();
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return QStringList();
    }

    auto keyList = bucketObj->getAllDocumentKeys();
    QStringList keyStrList;
    for (const auto& key : keyList) {
        keyStrList << QString::fromStdString(key);
    }
    return keyStrList;
}

bool DatabaseAccess::startBasicReplicator(const QString &url, const QString &username, const QString &password, const ReplicatorType &replicatorType,
    std::function<void(cbl::Replicator rep, const ActivityLevel &status)> changeListener,
    std::function<void(cbl::Replicator rep, bool isPush, const std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> documents)> documentListener,
    bool continuous) {

    if (url.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error starting replicator: url may not be empty";
        return false;
    }

    std::vector<std::string> channels;
    for (const auto& channel : channelAccess_) {
        channels.push_back(channel.toStdString());
    }

    CouchbaseDatabase::ReplicatorType _replicator_type;
    switch (replicatorType) {
        case ReplicatorType::Pull:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
        case ReplicatorType::Push:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
        default:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    }

    if (changeListener) {
        change_listener_callback_ = changeListener;
    }

    if (documentListener) {
        document_listener_callback_ = documentListener;
    }

    auto change_listener_callback = [this] (cbl::Replicator rep, const CouchbaseDatabase::SGActivityLevel &status) -> void {
        ActivityLevel activityLevel;
        QString activityLevelStr;

        switch ((CouchbaseDatabase::SGActivityLevel)status) {
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorStopped:
                activityLevelStr = "Stopped";
                activityLevel = ActivityLevel::ReplicatorStopped;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorOffline:
                activityLevelStr = "Offline";
                activityLevel = ActivityLevel::ReplicatorOffline;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorConnecting:
                activityLevelStr = "Connecting";
                activityLevel = ActivityLevel::ReplicatorConnecting;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorIdle:
                activityLevelStr = "Idle";
                activityLevel = ActivityLevel::ReplicatorIdle;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorBusy:
                activityLevelStr = "Busy";
                activityLevel = ActivityLevel::ReplicatorBusy;
                break;
        }

        if (change_listener_callback_) {
            change_listener_callback_(rep, activityLevel);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- PROGRESS: status=" << activityLevelStr;
        }
    };

    auto document_listener_callback = [this] (cbl::Replicator rep, bool isPush, const std::vector<CouchbaseDatabase::SGReplicatedDocument, std::allocator<CouchbaseDatabase::SGReplicatedDocument>> documents) {
        if (document_listener_callback_) {
            std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> SGDocuments;
            for (const auto &doc : documents) {
                DatabaseAccess::ReplicatedDocument SGDocument;
                SGDocument.id = QString::fromStdString(doc.id);
                SGDocument.error = doc.error;
                SGDocuments.push_back(SGDocument);
            }

            document_listener_callback_(rep, isPush, SGDocuments);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- " << documents.size() << " docs " << (isPush ? "pushed." : "pulled.");
        }
    };

    bool ok = true;
    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (bucket->startBasicReplicator(url.toStdString(), username.toStdString(), password.toStdString(), single_DB_channel, _replicator_type, change_listener_callback, document_listener_callback, continuous) == false) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator on bucket/channel" << QString::fromStdString(bucket->getDatabaseName());
            ok = false;
        }
    }

    return ok;
}

bool DatabaseAccess::startBasicReplicator(const QString &url, const QString &username, const QString &password, const ReplicatorType &replicatorType,
    std::function<void(const ActivityLevel &status)> changeListener,
    std::function<void(bool isPush, const std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> documents)> documentListener,
    bool continuous) {

    if (url.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error starting replicator: url may not be empty";
        return false;
    }

    std::vector<std::string> channels;
    for (const auto& channel : channelAccess_) {
        channels.push_back(channel.toStdString());
    }

    CouchbaseDatabase::ReplicatorType _replicator_type;
    switch (replicatorType) {
        case ReplicatorType::Pull:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
        case ReplicatorType::Push:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
        default:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    }

    if (changeListener) {
        change_listener_callback_NoRep_ = changeListener;
    }

    if (documentListener) {
        document_listener_callback_NoRep_ = documentListener;
    }

    auto change_listener_callback = [this] (cbl::Replicator /*rep*/, const CouchbaseDatabase::SGActivityLevel &status) -> void {
        ActivityLevel activityLevel;
        QString activityLevelStr;

        switch ((CouchbaseDatabase::SGActivityLevel)status) {
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorStopped:
                activityLevelStr = "Stopped";
                activityLevel = ActivityLevel::ReplicatorStopped;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorOffline:
                activityLevelStr = "Offline";
                activityLevel = ActivityLevel::ReplicatorOffline;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorConnecting:
                activityLevelStr = "Connecting";
                activityLevel = ActivityLevel::ReplicatorConnecting;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorIdle:
                activityLevelStr = "Idle";
                activityLevel = ActivityLevel::ReplicatorIdle;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorBusy:
                activityLevelStr = "Busy";
                activityLevel = ActivityLevel::ReplicatorBusy;
                break;
        }

        if (change_listener_callback_NoRep_) {
            change_listener_callback_NoRep_(activityLevel);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- PROGRESS: status=" << activityLevelStr;
        }
    };

    auto document_listener_callback = [this] (cbl::Replicator /*rep*/, bool isPush, const std::vector<CouchbaseDatabase::SGReplicatedDocument, std::allocator<CouchbaseDatabase::SGReplicatedDocument>> documents) {
        if (document_listener_callback_NoRep_) {
            std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> SGDocuments;
            for (const auto &doc : documents) {
                DatabaseAccess::ReplicatedDocument SGDocument;
                SGDocument.id = QString::fromStdString(doc.id);
                SGDocument.error = doc.error;
                SGDocuments.push_back(SGDocument);
            }
            document_listener_callback_NoRep_(isPush, SGDocuments);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- " << documents.size() << " docs " << (isPush ? "pushed." : "pulled.");
        }
    };

    bool ok = true;
    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (bucket->startBasicReplicator(url.toStdString(), username.toStdString(), password.toStdString(), single_DB_channel, _replicator_type, change_listener_callback, document_listener_callback, continuous) == false) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator on bucket/channel" << QString::fromStdString(bucket->getDatabaseName());
            ok = false;
        }
    }

    return ok;
}

bool DatabaseAccess::startSessionReplicator(const QString &url, const QString &token, const QString &cookieName, const ReplicatorType &replicatorType,
    std::function<void(cbl::Replicator rep, const ActivityLevel &status)> changeListener,
    std::function<void(cbl::Replicator rep, bool isPush, const std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> documents)> documentListener,
    bool continuous) {

    if (url.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error starting replicator: url may not be empty";
        return false;
    }

    if (token.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error starting replicator: token may not be empty";
        return false;
    }

    if (cookieName.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error starting replicator: cookie name may not be empty";
        return false;
    }

    CouchbaseDatabase::ReplicatorType _replicator_type;
    switch (replicatorType) {
        case ReplicatorType::Pull:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPull;
        case ReplicatorType::Push:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPush;
        default:
            _replicator_type = CouchbaseDatabase::ReplicatorType::kPushAndPull;
    }

    if (changeListener) {
        change_listener_callback_ = changeListener;
    }

    if (documentListener) {
        document_listener_callback_ = documentListener;
    }

    auto change_listener_callback = [this] (cbl::Replicator rep, const CouchbaseDatabase::SGActivityLevel &status) -> void {
        ActivityLevel activityLevel;
        QString activityLevelStr;

        switch ((CouchbaseDatabase::SGActivityLevel)status) {
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorStopped:
                activityLevelStr = "Stopped";
                activityLevel = ActivityLevel::ReplicatorStopped;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorOffline:
                activityLevelStr = "Offline";
                activityLevel = ActivityLevel::ReplicatorOffline;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorConnecting:
                activityLevelStr = "Connecting";
                activityLevel = ActivityLevel::ReplicatorConnecting;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorIdle:
                activityLevelStr = "Idle";
                activityLevel = ActivityLevel::ReplicatorIdle;
                break;
            case CouchbaseDatabase::SGActivityLevel::CBLReplicatorBusy:
                activityLevelStr = "Busy";
                activityLevel = ActivityLevel::ReplicatorBusy;
                break;
        }

        if (change_listener_callback_) {
            change_listener_callback_(rep, activityLevel);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- PROGRESS: status=" << activityLevelStr;
        }
    };

    auto document_listener_callback = [this] (cbl::Replicator rep, bool isPush, const std::vector<CouchbaseDatabase::SGReplicatedDocument, std::allocator<CouchbaseDatabase::SGReplicatedDocument>> documents) {
        if (document_listener_callback_) {
            std::vector<ReplicatedDocument, std::allocator<ReplicatedDocument>> SGDocuments;
            for (const auto &doc : documents) {
                DatabaseAccess::ReplicatedDocument SGDocument;
                SGDocument.id = QString::fromStdString(doc.id);
                SGDocument.error = doc.error;
                SGDocuments.push_back(SGDocument);
            }

            document_listener_callback_(rep, isPush, SGDocuments);
        } else {
            qCInfo(logCategoryCouchbaseDatabase) << "--- " << documents.size() << " docs " << (isPush ? "pushed." : "pulled.");
        }
    };

    bool ok = true;
    for (const auto& bucket : database_map_) {
        std::vector<std::string> single_DB_channel;
        single_DB_channel.push_back(bucket->getDatabaseName());
        if (bucket->startSessionReplicator(url.toStdString(), token.toStdString(), cookieName.toStdString(), single_DB_channel, _replicator_type, change_listener_callback, document_listener_callback, continuous) == false) {
            qCCritical(logCategoryCouchbaseDatabase) << "Error: Failed to start replicator on bucket/channel" << QString::fromStdString(bucket->getDatabaseName());
            ok = false;
        }
    }

    return ok;
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
                    qCInfo(logCategoryCouchbaseDatabase) << "Channel/directory" << subDir << "found locally but not in access list, deleted:" << dir.path();
                } else {
                    qCCritical(logCategoryCouchbaseDatabase) << "Error: channel/directory" << subDir<< "found locally but not in access list, failed to delete:" << dir.path();
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
    if (bucketObj == nullptr) {
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
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return false;
    }

    bucketObj->leaveChannel(loginUsername, channel);
    return true;
}

QString DatabaseAccess::getReplicatorStatus(const QString &bucket) {
    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get replicator status -- a valid bucket must be provided";
        return QString();
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return QString();
    }

    return QString::fromStdString(bucketObj->getReplicatorStatusString());
}

int DatabaseAccess::getReplicatorError(const QString &bucket) {
    if (bucket.isEmpty()) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: failed to get replicator error -- a valid bucket must be provided";
        return -1;
    }

    auto bucketObj = getBucket(bucket);
    if (bucketObj == nullptr) {
        qCCritical(logCategoryCouchbaseDatabase) << "Error: a valid bucket must be provided";
        return -1;
    }

    return bucketObj->getReplicatorError();
}

QString DatabaseAccess::getDatabaseName() {
    return name_;
}

QString DatabaseAccess::getDatabasePath() {
    return user_directory_;
}
