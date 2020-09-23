#include "SGQrcTreeModel.h"
#include "SGUtilsCpp.h"

#include <QDir>
#include <QDebug>
#include <QDirIterator>
#include <QThread>
#include <QStack>
#include <QQmlEngine>

/**************************************************************
 * Class SGQrcTreeModel
**************************************************************/

SGQrcTreeModel::SGQrcTreeModel(QObject *parent) : QAbstractItemModel(parent)
{
    QQmlEngine::setObjectOwnership(root_, QQmlEngine::CppOwnership);
    connect(this, &SGQrcTreeModel::urlChanged, this, &SGQrcTreeModel::setupModelData);
}

SGQrcTreeModel::~SGQrcTreeModel()
{
    delete root_;
}

QHash<int, QByteArray> SGQrcTreeModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[FilenameRole] = QByteArray("filename");
    roles[FilepathRole] = QByteArray("filepath");
    roles[FileTypeRole] = QByteArray("filetype");
    roles[VisibleRole] = QByteArray("visible");
    roles[OpenRole] = QByteArray("open");
    roles[InQrcRole] = QByteArray("inQrc");
    roles[IsDirRole] = QByteArray("isDir");
    roles[ChildrenRole] = QByteArray("childNodes");
    roles[ParentRole] = QByteArray("parent");
    roles[UniqueIdRole] = QByteArray("uid");
    return roles;
}

QVariant SGQrcTreeModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    SGQrcTreeNode *node = getNode(index);
    switch (role) {
    case FilenameRole:
        return QVariant(node->filename());
    case FilepathRole:
        return QVariant(node->filepath());
    case FileTypeRole:
        return QVariant(node->filetype());
    case VisibleRole:
        return QVariant(node->visible());
    case OpenRole:
        return QVariant(node->open());
    case InQrcRole:
        return QVariant(node->inQrc());
    case IsDirRole:
        return QVariant(node->isDir());
    case ParentRole:
        return QVariant::fromValue(node->parentNode());
    case UniqueIdRole:
        return QVariant(node->uid());
    }

    if (role == ChildrenRole) {
        QVariantList list;
        for (SGQrcTreeNode* child : node->children()) {
            list.append(QVariant::fromValue(child));
        }
        return list;
    }
    return QVariant();
}


bool SGQrcTreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) {
        return false;
    }

    qDebug() << "MODEL" << index.row() << index.column();

    SGQrcTreeNode *node = getNode(index);
    bool changed;

    switch (role) {
    case FilenameRole:
        changed = node->setFilename(value.toString());
        break;
    case FilepathRole:
        changed = node->setFilepath(value.toUrl());
        break;
    case FileTypeRole:
        changed = node->setFiletype(value.toString());
        break;
    case VisibleRole:
        changed = node->setVisible(value.toBool());
        break;
    case OpenRole:
        changed = node->setOpen(value.toBool());
        break;
    case InQrcRole:
        changed = node->setInQrc(value.toBool());
        break;
    case IsDirRole:
        changed = node->setIsDir(value.toBool());
        break;
    default:
        return false;
    }
    return true;
}

Qt::ItemFlags SGQrcTreeModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) {
        return Qt::NoItemFlags;
    }
    return Qt::ItemIsEditable | Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QList<SGQrcTreeNode*> SGQrcTreeModel::childNodes()
{
    return root_->children();
}

SGQrcTreeNode* SGQrcTreeModel::get(int uid) const
{
    if (uid >= uidMap_.size() || uid < 0) {
        return nullptr;
    }
    return uidMap_.at(uid);
}

SGQrcTreeNode* SGQrcTreeModel::root() const
{
    return root_;
}

int SGQrcTreeModel::rowCount(const QModelIndex &index) const
{
    if (index.column() > 0)
        return 0;

    SGQrcTreeNode *parent = getNode(index);
    return parent ? parent->childCount() : 0;
}

int SGQrcTreeModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 1;
}

bool SGQrcTreeModel::insertChild(SGQrcTreeNode *child, const QModelIndex &parent, int position)
{
    SGQrcTreeNode *parentNode = getNode(parent);
    if (position > parentNode->childCount()) {
        return false;
    }
    if (position < 0) {
        position = parentNode->childCount();
    }

    child->setParentNode(parentNode);
    beginInsertRows(parent, position, position);
    bool success = parentNode->insertChild(child, position);
    endInsertRows();
    return success;
}

bool SGQrcTreeModel::removeRows(int row, int count, const QModelIndex &parent)
{
    SGQrcTreeNode *parentItem = getNode(parent);
    if (!parentItem)
        return false;

    beginRemoveRows(parent, row, row + count - 1);
    const bool success = parentItem->removeChildren(row, count);
    endRemoveRows();

    return success;
}

QModelIndex SGQrcTreeModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent)) {
        return QModelIndex();
    }

    SGQrcTreeNode *parentNode = getNode(parent);
    if (!parentNode) {
        root_->setIndex(QModelIndex());
        return QModelIndex();
    }

    SGQrcTreeNode *child = parentNode->childNode(row);

    if (child) {
        QModelIndex index = createIndex(row, column, child);
        child->setIndex(index);
        return index;
    }

    return QModelIndex();
}

QModelIndex SGQrcTreeModel::parent(const QModelIndex &child) const
{
    if (!child.isValid()) {
        return QModelIndex();
    }

    SGQrcTreeNode *childNode = getNode(child);
    SGQrcTreeNode *parent = childNode ? childNode->parentNode() : nullptr;

    if (!parent || parent == root_) {
        return QModelIndex();
    }
    return createIndex(parent->row(), 0, parent);
}

bool SGQrcTreeModel::hasChildren(const QModelIndex &parent) const
{
    if (!parent.isValid()) {
        return false;
    }
    SGQrcTreeNode *node = getNode(parent);
    if (node) {
        return node->childCount() > 0;
    }
    return false;
}

QUrl SGQrcTreeModel::url() const
{
    return url_;
}

QUrl SGQrcTreeModel::projectDirectory() const
{
    return projectDir_;
}

void SGQrcTreeModel::setUrl(QUrl url)
{
    if (url_ != url) {
        url_ = url;
        QDir dir(QFileInfo(SGUtilsCpp::urlToLocalFile(url)).dir());
        projectDir_ = SGUtilsCpp::pathToUrl(dir.path());
        emit urlChanged();
        emit projectDirectoryChanged();
    }
}

void SGQrcTreeModel::childrenChanged(const QModelIndex &index, int role) {
    if (index.isValid()) {
        emit dataChanged(index, index, {role});
    } else {
        qWarning() << "Index is not valid";
    }
}

QList<SGQrcTreeNode *> SGQrcTreeModel::openFiles() const
{
    return openFiles_;
}

void SGQrcTreeModel::addOpenFile(SGQrcTreeNode *item)
{
    openFiles_.append(item);
    emit addedOpenFile(item);
    emit openFilesChanged();
}

void SGQrcTreeModel::removeOpenFile(SGQrcTreeNode *item)
{
    int i = 0;
    for (; i < openFiles_.size(); ++i) {
        if (openFiles_.at(i)->uid() == item->uid()) {
            break;
        }
    }
    if (i < openFiles_.size()) {
        openFiles_.at(i)->setOpen(false);
        openFiles_.removeAt(i);
        emit removedOpenFile(i);
        emit openFilesChanged();
    }
}

int SGQrcTreeModel::findOpenFile(int uid)
{
    int i = 0;
    for (; i < openFiles_.size(); i++) {
        if (openFiles_.at(i)->uid() == uid) {
            break;
        }
    }
    if (i < openFiles_.size()) {
        return i;
    } else {
        return -1;
    }
}

SGQrcTreeNode* SGQrcTreeModel::getNode(const QModelIndex &index) const
{
    if (index.isValid()) {
        return static_cast<SGQrcTreeNode*>(index.internalPointer());
    }
    return root_;
}

void SGQrcTreeModel::clear(bool emitSignals)
{
    if (emitSignals) {
        beginResetModel();
    }

    delete root_;

    if (emitSignals) {
        endResetModel();
    }
}

void SGQrcTreeModel::readQrcFile(QSet<QString> &qrcItems)
{
    QFile qrcFile(SGUtilsCpp::urlToLocalFile(url_));

    if (!qrcDoc_.isNull()) {
        qrcDoc_.clear();
    }

    if (!qrcFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qCritical() << "Failed to open qrc file";
        return;
    }

    if (!qrcDoc_.setContent(&qrcFile)) {
        qCritical() << "Failed to parse qrc file";
    }

    QDomNode qresource = qrcDoc_.elementsByTagName("qresource").at(0);
    if (qresource.hasAttributes() && qresource.attributes().contains("prefix") && qresource.attributes().namedItem("prefix").nodeValue() != "/" ) {
        qCritical() << "Unexpected prefix for qresource";
        return;
    }

    QDomNodeList files = qrcDoc_.elementsByTagName("file");

    // generate the
    for (int i = 0; i < files.count(); i++) {
        QDomElement element = files.at(i).toElement();
        QString absolutePath = SGUtilsCpp::joinFilePath(SGUtilsCpp::urlToLocalFile(projectDir_), element.text());
        qrcItems.insert(absolutePath);
    }

    qDebug() << "Successfully parsed qrc file";
    qrcFile.close();
}

void SGQrcTreeModel::setupModelData()
{
    // Create a thread to write data to disk
//    QThread *thread = QThread::create(std::bind(&SGQrcTreeModel::createModel, this));
//    thread->setObjectName("SGQrcTreeModel - FileIO Thread");
//    // Delete the thread when it is finished saving
//    connect(thread, &QThread::finished, thread, &QObject::deleteLater);
//    thread->setParent(this);
//    thread->start();
    createModel();
}

void SGQrcTreeModel::createModel()
{
    QFileInfo rootFi(SGUtilsCpp::urlToLocalFile(url_));
    beginResetModel();
    clear(false);
    root_ = new SGQrcTreeNode(nullptr, rootFi, true, false, 0);
    connect(root_, &SGQrcTreeNode::dataChanged, this, &SGQrcTreeModel::childrenChanged);
    uidMap_.append(root_);
    QQmlEngine::setObjectOwnership(root_, QQmlEngine::CppOwnership);

    QSet<QString> qrcItems;
    readQrcFile(qrcItems);

    recursiveDirSearch(root_, QDir(SGUtilsCpp::urlToLocalFile(projectDir_)), qrcItems, 0);
    endResetModel();
    emit dataReady();
}

void SGQrcTreeModel::recursiveDirSearch(SGQrcTreeNode* parentNode, QDir currentDir, QSet<QString> qrcItems, int depth)
{
    for (QFileInfo info : currentDir.entryInfoList(QDir::NoDotAndDotDot | QDir::NoSymLinks | QDir::Files | QDir::Dirs)) {
        if (info.isDir()) {
            SGQrcTreeNode *dirNode = new SGQrcTreeNode(parentNode, info, true, false, uidMap_.size());
            connect(dirNode, &SGQrcTreeNode::dataChanged, this, &SGQrcTreeModel::childrenChanged);
            QQmlEngine::setObjectOwnership(dirNode, QQmlEngine::CppOwnership);
            parentNode->insertChild(dirNode, parentNode->childCount());
            uidMap_.append(dirNode);
            recursiveDirSearch(dirNode, QDir(info.filePath()), qrcItems, depth + 1);
        } else {
            SGQrcTreeNode *node = new SGQrcTreeNode(parentNode, info, false, qrcItems.contains(info.filePath()), uidMap_.size());
            connect(node, &SGQrcTreeNode::dataChanged, this, &SGQrcTreeModel::childrenChanged);
            QQmlEngine::setObjectOwnership(node, QQmlEngine::CppOwnership);
            parentNode->insertChild(node, parentNode->childCount());
            uidMap_.append(node);
        }
    }
}


