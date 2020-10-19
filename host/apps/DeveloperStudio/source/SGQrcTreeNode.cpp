#include "SGQrcTreeNode.h"
#include "SGQrcTreeModel.h"
#include <QDebug>

/**************************************************************
 * Class SGQrcTreeNode
**************************************************************/

SGQrcTreeNode::SGQrcTreeNode(QObject *parent) : QObject(parent)
{
    isDir_ = false;
    inQrc_ = false;
    parent_ = nullptr;
    editing_ = false;
    children_ = QVector<SGQrcTreeNode*>();
    md5_ = QByteArray();
    filename_ = QString();
    filepath_ = QUrl();
}

SGQrcTreeNode::SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, QString uid, QObject *parent) :
    QObject(parent),
    parent_(parentNode),
    isDir_(isDir),
    inQrc_(inQrc),
    uid_(uid)
{
    filename_ = info.fileName();
    filetype_ = info.suffix();

    filepath_.setScheme("file");
    filepath_.setPath(info.filePath());
    children_ = QVector<SGQrcTreeNode*>();
    editing_ = false;
    md5_ = QByteArray();
}

SGQrcTreeNode::SGQrcTreeNode(SGQrcTreeNode *parentNode, bool isDir, QString uid, QObject *parent) : QObject(parent), parent_(parentNode), isDir_(isDir), uid_(uid)
{
    inQrc_ = false;
    children_ = QVector<SGQrcTreeNode*>();
    md5_ = QByteArray();
    filename_ = QString();
    filepath_ = QUrl();
}

SGQrcTreeNode::~SGQrcTreeNode()
{
    clear();
}

/***
 * NODE PROPERTIES
 ***/

// GETTERS

int SGQrcTreeNode::row() const
{
    if (parent_) {
        for (int i = 0; i < parent_->childCount(); i++) {
            if (parent_->childNode(i) == this) {
                return i;
            }
        }
    }
    return 0;
}

QVector<SGQrcTreeNode*> SGQrcTreeNode::children() const
{
    return children_;
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

bool SGQrcTreeNode::isDir() const
{
    return isDir_;
}

bool SGQrcTreeNode::inQrc() const
{
    return inQrc_;
}

SGQrcTreeNode* SGQrcTreeNode::parentNode() const
{
    return parent_;
}

bool SGQrcTreeNode::editing() const
{
    return editing_;
}

QByteArray SGQrcTreeNode::md5() const
{
    return md5_;
}

QString SGQrcTreeNode::uid() const
{
    return uid_;
}

// SETTERS

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
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setFiletype(QString filetype) {
    if (filetype_ != filetype) {
        filetype_ = filetype;
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setIsDir(bool isDir) {
    if (isDir_ != isDir) {
        isDir_ = isDir;
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setInQrc(bool inQrc) {
    if (inQrc_ != inQrc) {
        inQrc_ = inQrc;
        return true;
    }
    return false;
}

void SGQrcTreeNode::setParentNode(SGQrcTreeNode* parent)
{
    parent_ = parent;
}

bool SGQrcTreeNode::setEditing(bool editing)
{
    if (editing_ != editing) {
        editing_ = editing;
        return true;
    }
    return false;
}

bool SGQrcTreeNode::setMd5(QByteArray md5)
{
    if (md5_ != md5) {
        md5_ = md5;
        return true;
    }
    return false;
}


/***
 * NODE UTILITIES
 ***/

SGQrcTreeNode* SGQrcTreeNode::childNode(int index)
{
    if (index < 0 || index >= children_.size()) {
        return nullptr;
    }
    return children_.at(index);
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

bool SGQrcTreeNode::insertChildren(int position, int count)
{
    if (position < 0 || position > children_.size()) {
        return false;
    }

    for (int row = 0; row < count; row++) {
        SGQrcTreeNode* emptyNode = new SGQrcTreeNode();
        emptyNode->parent_ = this;
        children_.insert(position, emptyNode);
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

void SGQrcTreeNode::clear()
{
    qDeleteAll(children_);
    children_.clear();
}
