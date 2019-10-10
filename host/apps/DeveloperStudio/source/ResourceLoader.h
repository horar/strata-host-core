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

    static inline QStringList coreResources_{
        QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
        QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};
};
