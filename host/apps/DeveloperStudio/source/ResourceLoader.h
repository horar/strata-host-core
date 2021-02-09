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
            const QString &version,
            const QString &gitTaggedVersion
            )
    {
        this->filepath = filepath;
        this->version = version;
        this->gitTaggedVersion = gitTaggedVersion;
    }

    QString filepath;
    QString version;
    QString gitTaggedVersion;
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
     * @brief requestUnregisterDeleteViewResource Asynchronously requests resource unregistration (and optionally deletion from disk) so that asynchronous QML item destruction can complete first.
     * @param class_id The class id of the platform.
     * @param rccPath The path of the .rcc file to be removed.
     * @param version The version of the rcc file.
     * @param parent The parent/container
     * @param removeFromSystem Whether to remove the resource from the system or not
     */
    Q_INVOKABLE void requestUnregisterDeleteViewResource(const QString class_id, const QString rccPath, const QString version, QObject *parent, const bool removeFromSystem = true);

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
     * @brief getVersionRegistered Gets the version of the class_id registered
     * @param class_id The class id of the platform
     * @return The version registered to that class_id
     */
    Q_INVOKABLE QString getVersionRegistered(const QString &class_id);

    /**
     * @brief getGitTaggedVersion Gets the built in version for the class_id
     * @param class_id The class_id of the platform
     * @return Returns the git tagged version for the class_id
     */

    Q_INVOKABLE QString returnQrcPath(const QString &filePath);

    Q_INVOKABLE QString getGitTaggedVersion(const QString &class_id);

    Q_INVOKABLE QUrl getStaticViewsPhysicalPathUrl();

    Q_INVOKABLE void unregisterAllViews(QObject *parent);

    Q_INVOKABLE void recompileControlViewQrc(QString qrcFilePath);

    Q_INVOKABLE QString getLastLoggedError();

signals:
    void finishedRecompiling(QString filepath);

private slots:
    /**
     * @brief unregisterDeleteViewResource Unregisters resource from qrc and optionally deletes it from disk.
     * @param class_id The class id of the platform.
     * @param rccPath The path of the .rcc file to be removed.
     * @param version The version of the rcc file.
     * @param parent The parent/container.
     * @param removeFromSystem Whether to remove the resource from the system or not
     * @return True if successful, false if unable to delete/unregister resource.
     */
    bool unregisterDeleteViewResource(const QString &class_id, const QString &rccPath, const QString &version, QObject *parent, const bool removeFromSystem = true);

    void onOutputRead();

    void recompileFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    void loadCoreResources();
    QString getQResourcePrefix(const QString &class_id, const QString &version);
    /**
     * @brief getVersionJson Gets the version of the control view according to the version.json
     * @param class_id The class_id of the platform
     * @param version The version of the control view from OTA. This can be left blank if the control view is a local one.
     * @return Returns the version from the version.json associated with this control view. If the file could not be found, then it returns an empty string.
     */
    QString getVersionJson(const QString &class_id, const QString &version = "");

    QHash<QString, ResourceItem*> viewsRegistered_;

    static const QStringList coreResources_;

    std::unique_ptr<QProcess> rccCompilerProcess_ = nullptr;

    QString lastLoggedError = "";

    QString lastCompiledRccResource = "";

    void clearLastLoggedError();

    void setLastLoggedError(QString &error_str);
};
