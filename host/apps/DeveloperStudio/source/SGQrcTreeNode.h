#pragma once

#include <QObject>
#include <QUrl>
#include <QList>
#include <QFileInfo>
#include <QQmlListProperty>

class SGQrcTreeNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY filenameChanged)
    Q_PROPERTY(QUrl filepath READ filepath WRITE setFilepath NOTIFY filepathChanged)
    Q_PROPERTY(QString filetype READ filetype NOTIFY filetypeChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool open READ open WRITE setOpen NOTIFY openChanged)
    Q_PROPERTY(bool inQrc READ inQrc WRITE setInQrc NOTIFY inQrcChanged)
    Q_PROPERTY(bool isDir READ isDir NOTIFY isDirChanged)
    Q_PROPERTY(int depth READ depth WRITE setDepth NOTIFY depthChanged)
    Q_PROPERTY(SGQrcTreeNode* parent READ parent NOTIFY parentChanged)
    Q_PROPERTY(bool expanded READ expanded WRITE setExpanded NOTIFY expandedChanged)
    Q_PROPERTY(QList<SGQrcTreeNode*> childNodes READ children NOTIFY childNodesChanged)
public:
    explicit SGQrcTreeNode(QObject *parent = nullptr);
    SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, QObject *parent = nullptr);
    ~SGQrcTreeNode();

    Q_INVOKABLE SGQrcTreeNode *childNode(int index);
    SGQrcTreeNode *parentNode();
    int row() const;
    Q_INVOKABLE int childCount() const;
    Q_INVOKABLE bool insertChild(SGQrcTreeNode *child, int position);
    Q_INVOKABLE bool removeChildren(int position, int count);
    QList<SGQrcTreeNode*> children();

    /**
     * @brief  Gets the children for the node
     * @return Returns the list of children
     */
    QQmlListProperty<SGQrcTreeNode> childNodes();
    static int qmlCount(QQmlListProperty<SGQrcTreeNode> *property) {
        SGQrcTreeNode *node = qobject_cast<SGQrcTreeNode*>(property->object);
        return node->childCount();
    }
    static SGQrcTreeNode* qmlAt(QQmlListProperty<SGQrcTreeNode> *property, int index) {
        SGQrcTreeNode *node = qobject_cast<SGQrcTreeNode*>(property->object);
        return node->children_[index];
    }
    static void qmlAppend(QQmlListProperty<SGQrcTreeNode> *property, SGQrcTreeNode* item) {
        SGQrcTreeNode *parent = qobject_cast<SGQrcTreeNode*>(property->object);
        parent->children_.append(item);
    }
    static void qmlClear(QQmlListProperty<SGQrcTreeNode> *property) {
        SGQrcTreeNode *node = qobject_cast<SGQrcTreeNode*>(property->object);
        return node->clear();
    }

    /**
     * @brief filename
     * @return Returns the `filename`
     */
    QString filename() const;

    /**
     * @brief filepath
     * @return Returns the `filepath`
     */
    QUrl filepath() const;

    /**
     * @brief filetype
     * @return Returns the `filetype`
     */
    QString filetype() const;

    /**
     * @brief visible
     * @return Returns `visible`
     */
    bool visible() const;

    /**
     * @brief open
     * @return Returns `open`
     */
    bool open() const;

    /**
     * @brief isDir
     * @return Returns `isDir`
     */
    bool isDir() const;

    /**
     * @brief inQrc
     * @return Returns `inQrc`
     */
    bool inQrc() const;

    int depth() const;


    SGQrcTreeNode* parent() const;

    bool expanded() const;
    /**
     * @brief setFilename Sets the `filename` property
     * @param filename The filename to set
     */
    bool setFilename(QString filename);

    /**
     * @brief setFilepath Sets the `filepath` property
     * @param filepath The filepath to set
     */
    bool setFilepath(QUrl filepath);

    /**
     * @brief setFiletype Sets the `filetype` property
     * @param filetype The filetype to set
     */
    bool setFiletype(QString filetype);

    /**
     * @brief setVisible Sets the `visible` property
     * @param visible The value to set `visible` to
     */
    bool setVisible(bool visible);

    /**
     * @brief setOpen Sets the `open` property
     * @param open The value to set `open` to
     */
    bool setOpen(bool open);

    /**
     * @brief setIsDir Sets the `isDir` property
     * @param isDir The value to set `isDir` to
     */
    bool setIsDir(bool isDir);

    /**
     * @brief setInQrc Sets the `inQrc` property
     * @param inQrc The value to set `inQrc` to
     */
    bool setInQrc(bool inQrc);

    void setDepth(int depth);

    /**
     * @brief setParentNode Sets the parent node
     * @param parent The parent node to set
     */
    void setParentNode(SGQrcTreeNode* parent);

    void setExpanded(bool expanded);

    void clear();

signals:
    void filenameChanged();
    void filepathChanged();
    void filetypeChanged();
    void openChanged();
    void visibleChanged();
    void isDirChanged();
    void inQrcChanged();
    void parentChanged();
    void expandedChanged();
    void depthChanged();
    void childNodesChanged();

private:
    QList<SGQrcTreeNode*> children_;
    SGQrcTreeNode *parent_;
    QString filename_;
    QUrl filepath_;
    QString filetype_;
    bool visible_;
    bool open_;
    bool isDir_;
    bool inQrc_;
    bool expanded_;
    int depth_;
};

Q_DECLARE_METATYPE(SGQrcTreeNode*)
