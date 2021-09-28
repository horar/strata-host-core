/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QString>
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
     * @return True if successfully registered, false if unsuccessful.
     */
    Q_INVOKABLE bool registerResource(const QString &path, const QString &prefix);

    /**
     * @brief registerControlViewResource Registers a control view's resource file.
     * @param rccPath The path to the RCC file to be registered.
     * @param class_id The class_id to be associated with this RCC file/control view.
     * @param version The version of the RCC file/control view.
     * @return True if successfully registered, false if unsuccessful.
     */
    Q_INVOKABLE bool registerControlViewResource(const QString &rccPath, const QString &class_id, const QString &version);

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
     * @brief requestUnregisterResource Asynchronously requests resource unregistration (and optionally deletion from disk) so that asynchronous QML item destruction can complete first.
     * @param path The path to the RCC file to be unregistered.
     * @param prefix The virtual directory prefix of the RCC file to be unregistered.
     * @param parent The parent/container
     * @param removeFromSystem Whether to remove the resource from the system or not
     */
    Q_INVOKABLE void requestUnregisterResource(const QString &path, const QString &prefix, QObject *parent, const bool removeFromSystem = true);

    /**
     * @brief unregisterResource Unregisters a resource file.
     * @param path The path to the RCC file to be registered.
     * @param prefix The virtual directory prefix of the RCC file once registered.
     * @param parent The parent/container
     * @param removeFromSystem Whether to remove the resource from the system or not
     */
    Q_INVOKABLE bool unregisterResource(const QString &path, const QString &prefix, QObject *parent, const bool removeFromSystem = true);

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
    Q_INVOKABLE QString getGitTaggedVersion(const QString &class_id);

    Q_INVOKABLE QString getStaticResourcesString();

    Q_INVOKABLE QUrl getStaticResourcesUrl();

    Q_INVOKABLE void unregisterAllViews(QObject *parent);

    Q_INVOKABLE void recompileControlViewQrc(QString qrcFilePath);

    Q_INVOKABLE QString getLastLoggedError();

    Q_INVOKABLE void trimComponentCache(QObject *parent);

    /**
     * @brief getQrcPaths Returns list of paths found under a QRC resource path, including subdirectories
     * @param path The path to the QRC directory to find children.
     * @return QList List of child paths.
     */
    Q_INVOKABLE QList<QString> getQrcPaths(const QString &path);

    /**
     * @brief getProjectNameFromCmake capture project name from project's CMakeLists.txt file
     * @param qrcPath The path to the project's QRC file
     * @return QString project name, or empty if failed
     */
    Q_INVOKABLE QString getProjectNameFromCmake(const QString &qrcPath);

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
    static void loadCoreResources();

    void loadPluginResources();

    QString getQResourcePrefix(const QString &class_id, const QString &version);

    /**
     * @brief getVersionJson Gets the version of the control view according to the version.json
     * @param class_id The class_id of the platform
     * @param version The version of the control view from OTA. This can be left blank if the control view is a local one.
     * @return Returns the version from the version.json associated with this control view. If the file could not be found, then it returns an empty string.
     */
    QString getVersionJson(const QString &class_id, const QString &version = "");

    /**
     * @brief findRccCompiler attempts to find a valid RCC compiler in the current application directory
     * @return true if a valid RCC compiler was found
     */
    bool findRccCompiler();

    QHash<QString, ResourceItem*> viewsRegistered_;

    static const QStringList coreResources_;

    std::unique_ptr<QProcess> rccCompilerProcess_ = nullptr;

    QString lastLoggedError_ = "";

    QString lastCompiledRccResource_ = "";

    QString rccCompilerPath_ = "";

    void clearLastLoggedError();

    void setLastLoggedError(const QString &error_str);
};
