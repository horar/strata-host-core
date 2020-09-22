#pragma once

#include <QObject>
#include <QUrl>
#include <QList>
#include <QFileInfo>
#include <QQmlListProperty>
#include <QModelIndex>

class SGQrcTreeNode : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString filename READ filename WRITE setFilename NOTIFY dataChanged)
    Q_PROPERTY(QUrl filepath READ filepath WRITE setFilepath NOTIFY dataChanged)
    Q_PROPERTY(QString filetype READ filetype NOTIFY dataChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY dataChanged)
    Q_PROPERTY(bool open READ open WRITE setOpen NOTIFY dataChanged)
    Q_PROPERTY(bool inQrc READ inQrc WRITE setInQrc NOTIFY dataChanged)
    Q_PROPERTY(bool isDir READ isDir NOTIFY dataChanged)
    Q_PROPERTY(SGQrcTreeNode* parent READ parent NOTIFY dataChanged)
    Q_PROPERTY(int uid READ uid)
    Q_PROPERTY(QList<SGQrcTreeNode*> childNodes READ children NOTIFY dataChanged)
public:
    explicit SGQrcTreeNode(QObject *parent = nullptr);
    SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, int uid, QObject *parent = nullptr);
    ~SGQrcTreeNode();

    Q_INVOKABLE SGQrcTreeNode *childNode(int index);
    SGQrcTreeNode *parentNode();
    int row() const;
    Q_INVOKABLE int childCount() const;
    Q_INVOKABLE bool insertChild(SGQrcTreeNode *child, int position);
    Q_INVOKABLE bool removeChildren(int position, int count);

    /**
     * @brief  Gets the children for the node
     * @return Returns the list of children
     */
    QList<SGQrcTreeNode*> children();

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

    int uid() const;

    SGQrcTreeNode* parent() const;

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

    /**
     * @brief setParentNode Sets the parent node
     * @param parent The parent node to set
     */
    void setParentNode(SGQrcTreeNode* parent);

    void setIndex(const QModelIndex &index);

    void clear();

signals:
    void dataChanged(QModelIndex index, int role);

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
    int uid_;
    QModelIndex index_;
};

Q_DECLARE_METATYPE(SGQrcTreeNode*)
