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
        QStringLiteral("fonts.rcc"), QStringLiteral("theme.rcc"), QStringLiteral("pdfjs.rcc"),
        QStringLiteral("sgwidgets.rcc")};
};
