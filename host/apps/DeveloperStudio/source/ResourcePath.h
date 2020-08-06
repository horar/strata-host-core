#pragma once

#include <QString>

class ResourcePath final
{
public:
    ResourcePath();

    static QString& coreResourcePath();
    static QString& viewsResourcePath();
    static QString& hcsDocumentsCachePath();

private:
    static QString coreResourcePath_;
    static QString viewsResourcePath_;
    static QString hcsDocumentsCachePath_;
};
