#pragma once

#include <QStringList>
#include <QObject>
#include <QString>
#include <QHash>
#include <QDir>
#include <QUrl>
#include <QQmlEngine>
#include <QQuickItem>

struct ResourceItem {
    ResourceItem(
            const QString &filepath,
            const QString &version
            )
    {
        this->filepath = filepath;
        this->version = version;
    }

    QString filepath;
    QString version;
};

class ResourceLoader : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ResourceLoader)

public:
    ResourceLoader(QObject *parent=nullptr);
    virtual ~ResourceLoader();

    static enum ControlViewType {
        LOCAL_VIEW,
        OTA_VIEW
    };
    Q_ENUM(ControlViewType)

    Q_INVOKABLE void requestDeleteViewResource(const ControlViewType type, const QString &class_id, const QString &path, const QString &version, QObject *loader);

    /**
     * @brief registerControlViewResources Registers a control view's resource file.
     * @param class_id The class id of the platform.
     * @param path The path the .rcc file was downloaded to
     * @param version The version of the rcc file
     */
    Q_INVOKABLE void registerControlViewResources(const QString &class_id, const QString &path, const QString &version);

    /**
     * @brief registerStaticControlViewResources Registers a local control view's resource file. This is for non OTA.
     * @param class_id The class id of the platform.
     * @param displayName The display name for the control view. This is the value for a class_id key in uuid_map.js.
     * @return True if successfully registered, false if unsucessful.
     */
    Q_INVOKABLE bool registerStaticControlViewResources(const QString &class_id, const QString &displayName);

    /**
     * @brief isViewRegistered Checks if a view is registed in viewsRegistered_.
     * @param class_id The class id of the platform.
     * @return True if registered, false if not registered into qrc.
     */
    Q_INVOKABLE bool isViewRegistered(const QString &class_id);

    /**
     * @brief createViewObject Creates a QML object and attaches it to parent
     * @param path The path to the QML file
     * @param parent The parent to append this object to
     * @return The created QQuickItem*
     */
    Q_INVOKABLE QQuickItem* createViewObject(const QString &path, QQuickItem *parent, QVariantMap initialProperties = QVariantMap());

    /**
     * @brief getVersionRegistered Gets the version of the class_id registered
     * @param class_id The class id of the platform
     * @return The version registered to that class_id
     */
    Q_INVOKABLE QString getVersionRegistered(const QString &class_id);

    Q_INVOKABLE QUrl getStaticResourcesUrl();

signals:
    /**
     * @brief resourceRegistered Signal for when a resource is successfully registered.
     * @param class_id The class id of the resource file.
     */
    void resourceRegistered(const QString &class_id);

    /**
     * @brief resourceRegisterFailed Signal for when a resource registration fails.
     * @param class_id The class id of the resource file.
     */
    void resourceRegisterFailed(const QString &class_id);

private slots:
    /**
     * @brief deleteViewResource Deletes a resource from disk and unregisters it from qrc.
     * @param class_id The class id of the platform.
     * @param path The path the .rcc file was downloaded to
     * @param version The version of the rcc file
     * @param loader The QML Loader object
     * @return True if successful, false if unable to delete resource.
     */
    bool deleteViewResource(const QString &class_id, const QString &path, const QString &version, QObject *loader);

    /**
     * @brief deleteStaticViewResource Deletes a static view from the bin directory and unregisters it.
     * @param class_id The class id of the platform.
     * @param displayName The name of the platform.
     * @param loader The QML Loader object
     * @return True if successful, false if unable to delete resource.
     */
    bool deleteStaticViewResource(const QString &class_id, const QString &displayName, QObject *loader);

private:
    void loadCoreResources();
    void loadViewResources();
    QString getQResourcePrefix(const QString &class_id, const QString &version);

    QHash<QString, ResourceItem*> viewsRegistered_;

    static inline QStringList coreResources_{
        QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
        QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};
};
