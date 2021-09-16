/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    Q_PROPERTY(QString filename READ filename NOTIFY filenameChanged)
    Q_PROPERTY(QUrl filepath READ filepath)
    Q_PROPERTY(QString filetype READ filetype)
    Q_PROPERTY(bool inQrc READ inQrc)
    Q_PROPERTY(bool isDir READ isDir)
    Q_PROPERTY(SGQrcTreeNode* parentNode READ parentNode)
    Q_PROPERTY(QString uid READ uid)
    Q_PROPERTY(QVector<SGQrcTreeNode*> childNodes READ children)
    Q_PROPERTY(bool editing READ editing)
public:
    explicit SGQrcTreeNode(QObject *parent = nullptr);
    SGQrcTreeNode(SGQrcTreeNode *parentNode, QFileInfo info, bool isDir, bool inQrc, QString uid, QObject *parent = nullptr);
    SGQrcTreeNode(SGQrcTreeNode *parentNode, bool isDir, QString uid, QObject *parent = nullptr);
    ~SGQrcTreeNode();

    /***
     * NODE PROPERTIES
     ***/

    // GETTERS

    /**
     * @brief row Gets the index of this node in its parent
     * @return Returns the index of this nodes in its parent
     */
    int row() const;

    /**
     * @brief  Gets the children for the node
     * @return Returns the list of children
     */
    QVector<SGQrcTreeNode*> children() const;

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
     * @brief isDir
     * @return Returns `isDir`
     */
    bool isDir() const;

    /**
     * @brief inQrc
     * @return Returns `inQrc`
     */
    bool inQrc() const;

    /**
     * @brief uid Gets the unique id of the node
     * @return Returns the unique id of the node
     */
    QString uid() const;

    /**
     * @brief parent Gets the parent node
     * @return Returns the parent of this node
     */
    SGQrcTreeNode* parentNode() const;

    /**
     * @brief editing Returns the `editing` property
     * @return Returns true if the node is being edited, else false
     */
    bool editing() const;


    // SETTERS

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

    /**
     * @brief setEditing Sets if the node is currently being edited
     * @param editing Boolean, true if editing, false otherwise
     * @return Returns true if changed, false otherwise
     */
    bool setEditing(bool editing);


    /***
     * NODE UTILITIES
     ***/

    /**
     * @brief childNode Gets the child node at the index provided
     * @param index The index in the child array
     * @return Returns the node at the index in the child array
     */
    Q_INVOKABLE SGQrcTreeNode *childNode(int index);

    /**
     * @brief childCount Gets the number of children this node has
     * @return Returns the length of the children array
     */
    Q_INVOKABLE int childCount() const;

    /**
     * @brief insertChild Inserts a child in the children array at position provided
     * @param child The child to insert
     * @param position The position to insert the node at
     * @return Returns true if successful, false if not
     */
    bool insertChild(SGQrcTreeNode *child, int position);

    /**
     * @brief insertChildren Inserts blank children into the children array
     * @param position Position to start insertion
     * @param count Number of children to remove
     * @return Returns true if successful, false otherwise
     */
    bool insertChildren(int position, int count);

    /**
     * @brief removeChildren Removes child nodes starting at position and removes `count` elements
     * @param position The position to start removal
     * @param count The number of elements to remove
     * @return Returns true if successful, false otherwise
     */
    bool removeChildren(int position, int count);

    /**
     * @brief clear Clears the children list
     */
    void clear();

signals:
    void filenameChanged();

private:
    QVector<SGQrcTreeNode*> children_;
    SGQrcTreeNode *parent_;
    QString filename_;
    QUrl filepath_;
    QString filetype_;
    bool isDir_;
    bool inQrc_;
    QString uid_;
    bool editing_;
};

Q_DECLARE_METATYPE(SGQrcTreeNode*)
