#pragma once

#include <QString>

class ResourcePath final
{
public:
    ResourcePath() = default;

    static QString& coreResourcePath();
    static QString& viewsResourcePath();

private:
    static QString coreResourcePath_;
    static QString viewsResourcePath_;
};
