#pragma once

#include <QStringList>
#include <QObject>
#include <QString>
#include <QHash>
#include <QDir>
#include <QUrl>
#include <QQmlEngine>
#include <QQuickItem>
#include <QProcess>

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

    /**
     * @brief registerResource Registers a resource file.
     * @param path The path to the RCC file to be registered.
     * @param prefix The virtual directory prefix of the RCC file once registered.
     * @return True if successfully registered, false if unsucessful.
     */
    Q_INVOKABLE bool registerResource(const QString &path, const QString &prefix);

    /**
     * @brief requestDeleteViewResource Asynchronously requests resource cleanup so that asynchronous QML item destruction can complete first.
     * @param class_id The class id of the platform.
     * @param rccPath The path of the .rcc file to be removed.
     * @param version The version of the rcc file.
     * @param parent The parent/container.
     */
    Q_INVOKABLE void requestDeleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent);

    /**
     * @brief registerControlViewResource Registers a control view's resource file.
     * @param rccPath The path to the RCC file to be registered.
     * @param class_id The class_id to be associated with this RCC file/control view.
     * @param version The version of the RCC file/control view.
     * @return True if successfully registered, false if unsucessful.
     */
    Q_INVOKABLE bool registerControlViewResource(const QString &rccPath, const QString &class_id, const QString &version);

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

    Q_INVOKABLE QString getStaticResourcesString();

    Q_INVOKABLE QUrl getStaticResourcesUrl();

    Q_INVOKABLE QString recompileControlViewQrc(QString qrcFilePath);

    Q_INVOKABLE QString getLastLoggedError();

private slots:
    /**
     * @brief deleteViewResource Deletes a resource from disk and unregisters it from qrc.
     * @param class_id The class id of the platform.
     * @param rccPath The path of the .rcc file to be removed.
     * @param version The version of the rcc file.
     * @param parent The parent/container.
     * @return True if successful, false if unable to delete/unregister resource.
     */
    bool deleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent);

    void onOutputRead();

private:
    void loadCoreResources();
    QString getQResourcePrefix(const QString &class_id, const QString &version);

    QHash<QString, ResourceItem*> viewsRegistered_;

    static const QStringList coreResources_;

    QProcess rccCompilerProcess_;

    QString lastLoggedError = "";
    void clearLastLoggedError();
    void setLastLoggedError(QString &error_str);
};
