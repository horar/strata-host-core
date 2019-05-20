#pragma once

#include <QString>

class ResourcePath final
{
public:
    ResourcePath();

    static QString& viewsResourcePath();

private:
    static QString viewsResourcePath_;
};
