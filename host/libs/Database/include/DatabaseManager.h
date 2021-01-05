#pragma once

#include "CouchbaseDatabase.h"

class DatabaseAccess;
class DatabaseManager
{
public:
    DatabaseAccess* open(const QString &name, const QString &channel_access = "");

    DatabaseAccess* open(const QString &name, const QStringList &channel_access);

    QString getDbDirName();

private:
    const QString dbDirName_ = "databases";

    DatabaseAccess *dbAccess_ = nullptr;

    QString manageUserDir(const QString &name, const QStringList &channel_access);
};
