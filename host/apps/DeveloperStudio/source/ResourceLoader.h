#pragma once

#include <QStringList>
#include <QObject>

class ResourceLoader : public QObject
{
    Q_OBJECT

public:
    ResourceLoader();
    ~ResourceLoader();

    Q_INVOKABLE bool registerResource(const QString &fileName, const QString &root = "");
    Q_INVOKABLE bool unregisterResource(const QString &filename, const QString &root = "");

    Q_INVOKABLE bool registerControlViewResources(const QString &class_id);


private:
    void loadCoreResources();
    void loadViewResources();

    static inline QStringList coreResources_{
        QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
        QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};
};
