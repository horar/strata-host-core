#pragma once

#include <QString>

class ResourcePath final
{
public:
    ResourcePath() = default;

    static QString& coreResourcePath();

private:
    static QString coreResourcePath_;
};
