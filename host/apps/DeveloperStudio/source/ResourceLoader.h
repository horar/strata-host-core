#pragma once

#include <QStringList>

class ResourceLoader final
{
public:
    ResourceLoader();
    ~ResourceLoader();

private:
    void loadCoreResources();
    void loadViewResources();

    static const QStringList coreResources_;
};
