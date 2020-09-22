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
    roles[ExpandedRole] = QByteArray("expanded");
    roles[DepthRole] = QByteArray("depth");
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
    case ChildrenRole:
        return QVariant::fromValue(node->children());
    case ParentRole:
        return QVariant::fromValue(node->parentNode());
    case ExpandedRole:
        return QVariant(node->expanded());
    case DepthRole:
        return QVariant(node->depth());
    default:
        return false;
    }
}


bool SGQrcTreeModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid()) {
        return false;
    }

    SGQrcTreeNode *node = getNode(index);

    switch (role) {
    case FilenameRole:
        node->setFilename(value.toString());
        break;
    case FilepathRole:
        node->setFilepath(value.toUrl());
        break;
    case FileTypeRole:
        node->setFiletype(value.toString());
        break;
    case VisibleRole:
        node->setVisible(value.toBool());
        break;
    case OpenRole:
        node->setOpen(value.toBool());
        break;
    case InQrcRole:
        node->setInQrc(value.toBool());
        break;
    case IsDirRole:
        node->setIsDir(value.toBool());
        break;
    case ExpandedRole:
        node->setExpanded(value.toBool());
        break;
    case DepthRole:
        node->setDepth(value.toInt());
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
    return root_->childNodes();
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
        return QModelIndex();
    }

    SGQrcTreeNode *child = parentNode->childNode(row);

    if (child) {
        return createIndex(row, column, child);
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

void SGQrcTreeModel::childrenChanged(int row, int col, int role) {
    QModelIndex idx = index(row, col);
    if (idx.isValid()) {
        if (role != Qt::UserRole) {
            QVector<int> roleChanged = { role };
            emit dataChanged(index(row, col), index(row, col), roleChanged);
        } else {
            emit dataChanged(index(row, col), index(row, col));
        }
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
    root_ = new SGQrcTreeNode(nullptr, rootFi, true, false);
    QQmlEngine::setObjectOwnership(root_, QQmlEngine::CppOwnership);

    QSet<QString> qrcItems;
    readQrcFile(qrcItems);

    recursiveDirSearch(root_, QDir(SGUtilsCpp::urlToLocalFile(projectDir_)), qrcItems, 0);
    qDebug() << root_->childCount();
    endResetModel();
    emit dataReady();
}

void SGQrcTreeModel::recursiveDirSearch(SGQrcTreeNode* parentNode, QDir currentDir, QSet<QString> qrcItems, int depth)
{
    QString indent;
    for (int i = 0; i < depth; i++) {
        indent.append(' ');
    }
    indent += parentNode->filename();
    qDebug() << indent;
    for (QFileInfo info : currentDir.entryInfoList(QDir::NoDotAndDotDot | QDir::NoSymLinks | QDir::Files | QDir::Dirs)) {
        if (info.isDir()) {
            SGQrcTreeNode *dirNode = new SGQrcTreeNode(parentNode, info, true, false);
            QQmlEngine::setObjectOwnership(dirNode, QQmlEngine::CppOwnership);
            parentNode->insertChild(dirNode, parentNode->childCount());
            recursiveDirSearch(dirNode, QDir(info.filePath()), qrcItems, depth + 1);
        } else {
            SGQrcTreeNode *node = new SGQrcTreeNode(parentNode, info, false, qrcItems.contains(info.filePath()));
            QString dbg;
            for (int i = 0; i < depth * 2; i++) {
                dbg.append(' ');
            }
            dbg += node->filename();
            qDebug() << dbg;
            QQmlEngine::setObjectOwnership(node, QQmlEngine::CppOwnership);
            parentNode->insertChild(node, parentNode->childCount());
        }
    }
}


