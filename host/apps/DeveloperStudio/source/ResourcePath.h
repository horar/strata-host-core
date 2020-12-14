#pragma once

#include <QString>

class ResourcePath final
{
public:
    ResourcePath();

    static QString& coreResourcePath();
    static QString& viewsPhysicalPath();

private:
    static QString coreResourcePath_;
    static QString viewsPhysicalPath_;
};
