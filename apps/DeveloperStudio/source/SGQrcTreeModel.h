#pragma once

#include "SGQrcTreeNode.h"

#include <QAbstractItemModel>
#include <QVariant>
#include <QHash>
#include <QUrl>
#include <QDomDocument>
#include <QSet>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QPair>

class SGQrcTreeModel : public QAbstractItemModel
{
    Q_OBJECT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(SGQrcTreeNode* root READ root NOTIFY rootChanged)
    Q_PROPERTY(QUrl debugMenuSource READ debugMenuSource NOTIFY debugMenuSourceChanged)
    Q_PROPERTY(QUrl projectDirectory READ projectDirectory NOTIFY projectDirectoryChanged)
    Q_PROPERTY(QVector<SGQrcTreeNode*> childNodes READ childNodes)
    Q_PROPERTY(QModelIndex rootIndex READ rootIndex WRITE setRootIndex)
    Q_PROPERTY(bool needsCleaning READ needsCleaning NOTIFY needsCleaningChanged)
public:
    explicit SGQrcTreeModel(QObject *parent = nullptr);
    ~SGQrcTreeModel();

    enum RoleNames {
        FilenameRole = Qt::UserRole + 1,
        FilepathRole = Qt::UserRole + 2,
        FileTypeRole = Qt::UserRole + 3,
        InQrcRole = Qt::UserRole + 4,
        IsDirRole = Qt::UserRole + 5,
        ChildrenRole = Qt::UserRole + 6,
        ParentRole = Qt::UserRole + 7,
        UniqueIdRole = Qt::UserRole + 8,
        RowRole = Qt::UserRole + 9,
        EditingRole = Qt::UserRole + 10,
        Md5Role = Qt::UserRole + 11
    };
    Q_ENUM(RoleNames);

    /***
     * OVERRIDES
     ***/
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::UserRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    int rowCount(const QModelIndex &index = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    Q_INVOKABLE bool removeRows(int row, int count = 1, const QModelIndex &parent = QModelIndex()) override;
    Q_INVOKABLE QModelIndex index(int row, int column = 0, const QModelIndex &parent = QModelIndex()) const override;
    Q_INVOKABLE QModelIndex parent(const QModelIndex &child) const override;
    Q_INVOKABLE bool hasChildren(const QModelIndex &parent = QModelIndex()) const override;

    /***
     * CUSTOM FUNCTIONS
     ***/

    // Node Operations

    /**
     * @brief root Gets the root node
     * @return Returns the root node
     */
    SGQrcTreeNode* root() const;

    /**
     * @brief debugMenuSource Gets the debug menu source
     * @return Returns the path to the debug menu platformInterface.json source. If it doesn't exist, it returns "".
     */
    QUrl debugMenuSource() const;

    /**
     * @brief childNodes Gets the children for the root node
     * @return QList<SGQrcTreeNode*> containing the children of the root node
     */
    QVector<SGQrcTreeNode*> childNodes();

    /**
     * @brief get Get a node by its unique id
     * @param uid The unique id of the node
     * @return Returns the SGQrcTreeNode* that contains the uid
     */
    Q_INVOKABLE SGQrcTreeNode* get(const QString &uid) const;

    /**
     * @brief getNode Gets a node using the QModelIndex
     * @param index
     * @return
     */
    Q_INVOKABLE SGQrcTreeNode* getNode(const QModelIndex &index) const;

    /**
     * @brief getNodeByUrl Gets a node by its url
     * @param url The url to look for
     * @return Returns the node if it finds it, otherwise returns a nullptr
     */
    Q_INVOKABLE SGQrcTreeNode* getNodeByUrl(const QUrl &url) const;

    // Tree Operations

    /**
     * @brief insertChild Inserts a child node into the parent
     * @param fileUrl The url of the file/dir to insert
     * @param position Position in the parent's child array to insert (-1 is to append)
     * @param inQrc Boolean dictating whether or not to add the file to the qrc. True by default.
     * @param parent Parent index to insert the child into
     * @return true if successful, otherwise false
     */
    Q_INVOKABLE bool insertChild(const QUrl &fileUrl, int position = -1, const bool inQrc = true, const QModelIndex &parent = QModelIndex());

    /**
     * @brief insertChild Inserts a blank child node into the parent
     * @param isDir If the node is a directory or a file
     * @param position The position to insert the child at
     * @param parent The parent to insert the node into
     * @return Returns true if sucessful otherwise false
     */
    Q_INVOKABLE bool insertChild(bool isDir, int position = -1, const QModelIndex &parent = QModelIndex());


    // Model Utilities

    /**
     * @brief rootIndex Gets the root index
     * @return Returns the QModelIndex for the root
     */
    QModelIndex rootIndex() const;

    /**
     * @brief setRootIndex Sets the root index
     * @param index The root index to set
     */
    void setRootIndex(const QModelIndex &index);

    /**
     * @brief url Returns the url to the .qrc file
     * @return The url to the .qrc file
     */
    QUrl url() const;

    /**
     * @brief setUrl Sets the url of the .qrc file
     * @param url The url to set
     */
    void setUrl(QUrl url);

    /**
     * @brief needsCleaning Returns whether or not the qrc needs cleaning
     * @return Returns true if the qrc needs cleaning, otherwise false
     */
    bool needsCleaning() const;

    /**
     * @brief projectDirectory Returns the url to the project root directory
     * @return The url to the project root directory
     */
    QUrl projectDirectory() const;

    /**
     * @brief addToQrc Adds an item to the qrc file
     * @param index The node to add to the qrc
     * @param save If the changes should be saved or not. Default is true
     */
    Q_INVOKABLE void addToQrc(const QModelIndex &index, bool save = true);

    /**
     * @brief removeFromQrc Removes an item from the qrc file
     * @param index The node to remove from the qrc
     * @param save If the changes should be saved or not. Default is true
     */
    Q_INVOKABLE void removeFromQrc(const QModelIndex &index, bool save = true);

    /**
     * @brief removeDeletedFilesFromQrc Removes all files in the Qrc that have been deleted from the filesystem
     */
    Q_INVOKABLE void removeDeletedFilesFromQrc();

    /**
     * @brief getMissingFiles Gets the list of missing files in the qrc
     * @return Returns a list of filepaths for missing files
     */
    Q_INVOKABLE QList<QString> getMissingFiles();

    /**
     * @brief removeEmptyChildren Removes any children that don't have a filename
     * @param parent The QModelIndex of the parent
     */
    Q_INVOKABLE void removeEmptyChildren(const QModelIndex &parent);

    /**
     * @brief createQmlFile creates a QML file
     * @param filepath full filepath for file
     * @param isVisualEditorEnabled create a base QML file or a Visual Editor enabled QML file
     * @return true if successfully created file
     */
    Q_INVOKABLE bool createQmlFile(const QString &filepath, const bool isVisualEditorEnabled);

    /**
     * @brief createEmptyFile creates an empty file
     * @param filepath full filepath for file
     * @return true if successfully created file
     */
    Q_INVOKABLE bool createEmptyFile(const QString &filepath);

    /**
     * @brief renameFile Renames a file or a folder
     * @param index The index in the model
     * @param newFilename The new file/folder name
     * @return Returns true if successful, false otherwise
     */
    Q_INVOKABLE bool renameFile(const QModelIndex &index, const QString &newFilename);

    /**
     * @brief deleteFile Deletes a file from the local filesystem and removes it from the qrc
     * @param row Row in parent
     * @param parent QModelIndex of the parent
     * @return Returns true if successful, false otherwise
     */
    Q_INVOKABLE bool deleteFile(const int row, const QModelIndex &parent = QModelIndex());

    /**
     * @brief stopWatchingPath Removes the `path` from internal QFileSystemWatcher
     * @param path The path to the file or directory
     */
    Q_INVOKABLE void stopWatchingPath(const QString &path);

    /**
     * @brief stopWatchingAll Removes all file/dir paths from internal QFileSystemWatcher
     */
    Q_INVOKABLE void stopWatchingAll();

    /**
     * @brief startWatchingPath Adds the `path` to internal QFileSystemWatcher
     * @param path The path to the file or directory
     */
    Q_INVOKABLE void startWatchingPath(const QString &path);

    /**
     * @brief addPathToTree Adds a path to the pathsInTree private member
     * @param path The QUrl to the file
     * @return Returns true if successful, false if it already exists
     */
    Q_INVOKABLE bool addPathToTree(const QUrl &path);

    /**
     * @brief startSave Starts a thread to save the qrc file.
     */
    Q_INVOKABLE void startSave();

    /**
     * @brief parentDirectoryUrl will return a parent directory of a url - like SGUtils.parentDirectoryPath, but for Urls
     * @param url QUrl of file to find parent directory of
     * @return Returns Qurl of parent directory
     */
    Q_INVOKABLE QUrl parentDirectoryUrl(QUrl url);

    /**
     * @brief containsPath check if file is in pathsInTree_
     * @param url The path to the file or directory
     * @return true if file is in pathsInTree_
     */
    Q_INVOKABLE bool containsPath(const QString url);

    /***
     * SIGNALS
     ***/
signals:
    void urlChanged();
    void projectDirectoryChanged();
    void rootChanged();
    void debugMenuSourceChanged();
    void needsCleaningChanged();
    void errorParsing(const QString error);
    void finishedReadingQrc(const QByteArray &fileText);

    // This signal is emitted when the file at the specified path is modified
    void fileChanged(const QUrl path);
    // This signal is emitted when the file with the specified uid is deleted
    void fileDeleted(const QString uid, const QUrl path);
    // This signal is emitted when a file is added to the project.
    void fileAdded(const QUrl path, const QUrl parentPath);
    // This signal is emitted when a file is created
    void fileCreated(const QModelIndex index, const QString filename, const QUrl filepath, const QString filetype, const QString uid);

    /***
     * SLOTS
     ***/
public slots:
    void childrenChanged(const QModelIndex &index, int role);

    /***
     * PRIVATE MEMBERS
     ***/
private slots:
    void startPopulating(const QByteArray &fileText);
    /**
     * @brief projectFilesModified This slot is connected to the QFileSystemWatcher::fileChanged signal
     * @details This slot only deals with files (not directories). It handles individual files
     * being deleted, renamed or modified.
     * @param path The path of the file modified.
     */
    void projectFilesModified(const QString &path);

    /**
     * @brief directoryStructureChanged This slot is connected to the QFileSystemWatcher::directoryChanged signal
     * @details This slot deals with changes to directories that are being tracked. For example,
     * it handles directories being deleted, files being added to tracked directories and directories being added to directories.
     * @param path The path of the directory that changed.
     */
    void directoryStructureChanged(const QString &path);

private:
    void clear(bool emitSignals = true);
    void readQrcFile();
    bool createQrcXmlDocument(const QByteArray &fileText);
    void createModel();
    void recursiveDirSearch(SGQrcTreeNode *parentNode, QDir currentDir, QSet<QString> qrcItems, int depth);
    void setDebugMenuSource(const QUrl &path);
    void renameAllChildren(const QModelIndex &parentIndex, const QString &newPath);
    QModelIndex findNodeInTree(const QModelIndex &index, const QUrl &path);

    /**
     * @brief handleExternalFileAdded Handles the situation when a file is added externally to the program
     * @param path The path of the file/directory added
     * @param parentPath The path of the parent that is added
     */
    void handleExternalFileAdded(const QUrl path, const QUrl parentPath);

    /**
     * @brief handleExternalFileDeleted Handles the situation when a file is deleted externally to the program
     * @param uid The UID of the file deleted
     */
    void handleExternalFileDeleted(const QString uid);
    void save();
    void setNeedsCleaning(const bool needsCleaning);

    SGQrcTreeNode *root_ = nullptr;
    QUrl url_;
    QUrl projectDir_;
    QDomDocument qrcDoc_;
    QHash<QString, SGQrcTreeNode*> uidMap_;
    QSet<QUrl> pathsInTree_;
    QSet<QString> qrcItems_;
    std::unique_ptr<QFileSystemWatcher> fsWatcher_;
    QModelIndex rootIndex_;
    QUrl debugMenuSource_;
    bool needsCleaning_;

    // String literal for creating a base QML file
    const QString baseQMLFile_ = R"baseQMLFile(import QtQuick 2.12

Item {

}
)baseQMLFile";

    // String literal for creating a VE-enabled QML file
    const QString veQMLFile_ = R"veQMLFile(import QtQuick 2.12

import tech.strata.sglayout 1.0

UIBase { // start_uibase
    columnCount: 20
    rowCount: 20

} // end_uibase
)veQMLFile";

};
