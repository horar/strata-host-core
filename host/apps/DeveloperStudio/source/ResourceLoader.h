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

    /**
     * @brief registerResource Registers a resource into qrc
     * @param path The path to the .rcc file
     * @param root Optional* The root path to add to the qrc
     * @return True if successful, false if unable to register
     */
    Q_INVOKABLE bool registerResource(const QString &path, const QString &root = "");

    /**
     * @brief unregisterResource Unregisters a resource in qrc.
     * @param path The path of the .rcc file to unregister.
     * @param root Optional* The root path added to the qrc.
     * @return True if successful, false if unable to unregister.
     */
    Q_INVOKABLE bool unregisterResource(const QString &path, const QString &root = "");

    /**
     * @brief deleteViewResource Deletes a resource from disk and unregisters it from qrc.
     * @param class_id The class id of the platform.
     * @param version Optional* The version to delete. If left blank, it will delete all versions.
     * @return True if successful, false if unable to delete resource.
     */
    Q_INVOKABLE bool deleteViewResource(const QString &class_id, const QString &version = "");

    /**
     * @brief registerControlViewResources Registers a control view's resource file.
     * @param class_id The class id of the platform.
     * @param version Optional* The version to register. If left blank, it will register the latest version.
     */
    Q_INVOKABLE void registerControlViewResources(const QString &class_id, const QString &version = "");

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

private:
    void loadCoreResources();
    void loadViewResources();
    QString getLatestVersion(const QStringList &versions);
    QHash<QString, bool> viewsRegistered_;
    static inline QStringList coreResources_{
        QStringLiteral("component-fonts.rcc"), QStringLiteral("component-theme.rcc"),
        QStringLiteral("component-pdfjs.rcc"), QStringLiteral("component-common.rcc"),
        QStringLiteral("component-sgwidgets.rcc")};
};
