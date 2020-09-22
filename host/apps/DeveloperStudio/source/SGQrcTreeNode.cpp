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
    depth_ = 0;
}

SGQrcTreeNode::SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, QObject *parent) :
    QObject(parent),
    parent_(parentNode),
    isDir_(isDir),
    inQrc_(inQrc)
{
    open_ = false;
    visible_ = false;
    filename_ = info.fileName();
    filetype_ = info.suffix();

    filepath_.setScheme("file");
    filepath_.setPath(info.filePath());
    children_ = QList<SGQrcTreeNode*>();
    depth_ = parent_ ? parent_->depth() + 1 : 0;
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

QList<SGQrcTreeNode*> SGQrcTreeNode::childNodes()
{
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

int SGQrcTreeNode::depth() const
{
    return depth_;
}

bool SGQrcTreeNode::expanded() const
{
    return expanded_;
}

SGQrcTreeNode* SGQrcTreeNode::parent() const
{
    return parent_;
}

bool SGQrcTreeNode::setFilename(QString filename) {
    if (filename_ != filename) {
        filename_ = filename;
        emit filenameChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setFilepath(QUrl filepath) {
    if (filepath_ != filepath) {
        filepath_ = filepath;
        emit filepathChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setFiletype(QString filetype) {
    if (filetype_ != filetype) {
        filetype_ = filetype;
        emit filetypeChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setVisible(bool visible) {
    if (visible_ != visible) {
        visible_ = visible;
        emit visibleChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setOpen(bool open) {
    if (open_ != open) {
        open_ = open;
        emit openChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setIsDir(bool isDir) {
    if (isDir_ != isDir) {
        isDir_ = isDir;
        emit isDirChanged();
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setInQrc(bool inQrc) {
    if (inQrc_ != inQrc) {
        inQrc_ = inQrc;
        emit inQrcChanged();
        return true;
    }
    return false;
}

void SGQrcTreeNode::setDepth(int depth) {
    if (depth_ != depth) {
        depth_ = depth;
        emit depthChanged();
    }
}

void SGQrcTreeNode::setExpanded(bool expanded) {
    if (expanded_ != expanded) {
        expanded_ = expanded;
        emit expandedChanged();
    }
}

void SGQrcTreeNode::setParentNode(SGQrcTreeNode* parent)
{
    parent_ = parent;
}

void SGQrcTreeNode::clear()
{
    qDeleteAll(children_);
    children_.clear();
}
