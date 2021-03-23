#pragma once

#include "../src/CouchbaseDatabase.h"

namespace strata::Database
{

class DatabaseAccess;

class DatabaseManager
{
public:
    DatabaseManager();

    ~DatabaseManager();

    DatabaseManager& operator=(const DatabaseManager&) = delete;

    DatabaseManager(const DatabaseManager&) = delete;

    bool init(const QString &path, const QString &endpointURL, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr);

    DatabaseAccess* login(const QString &name, const QString &channelsRequested, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr);

    DatabaseAccess* login(const QString &name, const QStringList &channelsRequested, std::function<void(cbl::Replicator rep, const CBLReplicatorStatus &status)> changeListener = nullptr, std::function<void(cbl::Replicator rep, bool isPush, const std::vector<CBLReplicatedDocument, std::allocator<CBLReplicatedDocument>> documents)> documentListener = nullptr);

    bool joinChannel(const QString &strataLoginUsername, const QString &channel);

    bool leaveChannel(const QString &strataLoginUsername, const QString &channel);

    DatabaseAccess* getUserAccessMap();

    QStringList readChannelsAccessGrantedOfUser(const QString &loginUsername);

    QStringList readChannelsAccessDeniedOfUser(const QString &loginUsername);

    QString getDbDirName();

    QString getUserAccessReplicatorStatus();

    int getUserAccessReplicatorError();

private:
    const QString dbDirName_ = "databases";

    QString path_;

    QString endpointURL_;

    QString loggedUsername_;

    QStringList channelsAccessGranted_;

    QStringList channelsAccessDenied_;

    DatabaseAccess* dbAccess_ = nullptr;

    DatabaseAccess* userAccessDb_ = nullptr;

    bool authenticate(const QString &name);

    QStringList getChannelsAccessGranted();

    QStringList getChannelsAccessDenied();

    QString manageUserDir(const QString &path, const QString &name, const QStringList &channelAccess);
};

} // namespace strata::Database
