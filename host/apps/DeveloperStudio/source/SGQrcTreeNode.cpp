#include "SGQrcTreeNode.h"
#include "SGQrcTreeModel.h"
#include <QDebug>

/**************************************************************
 * Class SGQrcTreeNode
**************************************************************/

SGQrcTreeNode::SGQrcTreeNode(QObject *parent) : QObject(parent)
{
    open_ = false;
    visible_ = false;
    isDir_ = false;
    inQrc_ = false;
    parent_ = nullptr;
    children_ = QList<SGQrcTreeNode*>();
}

SGQrcTreeNode::SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, int uid, QObject *parent) :
    QObject(parent),
    parent_(parentNode),
    isDir_(isDir),
    inQrc_(inQrc),
    uid_(uid)
{
    open_ = false;
    visible_ = false;
    filename_ = info.fileName();
    filetype_ = info.suffix();

    filepath_.setScheme("file");
    filepath_.setPath(info.filePath());
    children_ = QList<SGQrcTreeNode*>();
}

SGQrcTreeNode::~SGQrcTreeNode()
{
    qDeleteAll(children_);
}

SGQrcTreeNode* SGQrcTreeNode::childNode(int index)
{
    if (index < 0 || index >= children_.size()) {
        return nullptr;
    }
    return children_.at(index);
}

int SGQrcTreeNode::row() const
{
    if (parent_) {
        for (int i = 0; i < parent_->childCount(); i++) {
            if (parent_->childNode(i)->filepath() == this->filepath()) {
                return i;
            }
        }
    }
    return 0;
}

int SGQrcTreeNode::childCount() const
{
    return children_.count();
}

bool SGQrcTreeNode::insertChild(SGQrcTreeNode *child, int position)
{
    if (position < 0 || position > children_.size()) {
        return false;
    }    
    if (position == children_.count()) {
        children_.append(child);
    } else {
        children_.insert(position, child);
    }
    return true;
}

bool SGQrcTreeNode::removeChildren(int position, int count)
{
    if (position < 0 || position + count > children_.size()) {
        return false;
    }

    for (int row = 0; row < count; row++) {
        delete children_.takeAt(position);
    }
    return true;
}

QList<SGQrcTreeNode*> SGQrcTreeNode::children() {
    qDebug() << "Children requested";
    qDebug() << children_.count();
    return children_;
}

SGQrcTreeNode* SGQrcTreeNode::parentNode()
{
    return parent_;
}

QString SGQrcTreeNode::filename() const
{
    return filename_;
}

QUrl SGQrcTreeNode::filepath() const
{
    return filepath_;
}

QString SGQrcTreeNode::filetype() const
{
    return filetype_;
}

bool SGQrcTreeNode::visible() const
{
    return visible_;
}

bool SGQrcTreeNode::open() const
{
    return open_;
}

bool SGQrcTreeNode::isDir() const
{
    return isDir_;
}

bool SGQrcTreeNode::inQrc() const
{
    return inQrc_;
}

SGQrcTreeNode* SGQrcTreeNode::parent() const
{
    return parent_;
}

int SGQrcTreeNode::uid() const
{
    return uid_;
}

bool SGQrcTreeNode::setFilename(QString filename) {
    if (filename_ != filename) {
        filename_ = filename;
        emit dataChanged(index_, SGQrcTreeModel::FilenameRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setFilepath(QUrl filepath) {
    if (filepath_ != filepath) {
        filepath_ = filepath;
        emit dataChanged(index_, SGQrcTreeModel::FilepathRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setFiletype(QString filetype) {
    if (filetype_ != filetype) {
        filetype_ = filetype;
        emit dataChanged(index_, SGQrcTreeModel::FileTypeRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setVisible(bool visible) {
    if (visible_ != visible) {
        visible_ = visible;
        emit dataChanged(index_, SGQrcTreeModel::VisibleRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setOpen(bool open) {
    if (open_ != open) {
        open_ = open;
        emit dataChanged(index_, SGQrcTreeModel::OpenRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setIsDir(bool isDir) {
    if (isDir_ != isDir) {
        isDir_ = isDir;
        emit dataChanged(index_, SGQrcTreeModel::IsDirRole);
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setInQrc(bool inQrc) {
    if (inQrc_ != inQrc) {
        inQrc_ = inQrc;
        emit dataChanged(index_, SGQrcTreeModel::InQrcRole);
        return true;
    }
    return false;
}

void SGQrcTreeNode::setParentNode(SGQrcTreeNode* parent)
{
    parent_ = parent;
}

void SGQrcTreeNode::setIndex(const QModelIndex &index)
{
    index_ = index;
}

void SGQrcTreeNode::clear()
{
    qDeleteAll(children_);
    children_.clear();
}
