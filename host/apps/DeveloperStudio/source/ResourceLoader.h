#pragma once

#include <QStringList>
#include <QObject>
#include <QString>
#include <QHash>

class ResourceLoader : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ResourceLoader)

public:
    ResourceLoader(QObject *parent=nullptr);
    virtual ~ResourceLoader();

    Q_INVOKABLE bool registerResource(const QString &path, const QString &root = "");
    Q_INVOKABLE bool unregisterResource(const QString &path, const QString &root = "");
    Q_INVOKABLE bool deleteViewResource(const QString &class_id, const QString &version);
    Q_INVOKABLE bool registerControlViewResources(const QString &class_id);
    Q_INVOKABLE bool isViewRegistered(const QString &class_id);

private:
    void loadCoreResources();
    void loadViewResources();
    QString getLatestVersion(const QStringList &versions);
    QHash<QString, bool> viewsRegistered;
    static inline QStringList coreResources_{
        QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
        QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};
};
