/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QAbstractListModel>
#include <QString>
#include <QVariant>
#include <QHash>
#include <QSet>
#include <QUrl>

class SGFileTabItem
{
public:
    SGFileTabItem();
    SGFileTabItem(const QString &filename, const QUrl &filepath, const QString &filetype, const QString id);

    QString filename() const;
    QUrl filepath() const;
    QString filetype() const;
    bool unsavedChanges() const;
    bool exists() const;
    QString id() const;

    bool setFilename(const QString &filename);
    bool setFilepath(const QUrl &filepath);
    bool setFiletype(const QString &filetype);
    bool setId(const QString &id);
    bool setUnsavedChanges(const bool &unsaved);
    bool setExists(const bool &exists);
private:
    QString id_;
    QString filename_;
    QUrl filepath_;
    QString filetype_;
    bool unsavedChanges_;
    bool exists_;
};
Q_DECLARE_METATYPE(SGFileTabItem*);

class SGFileTabModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)
    Q_PROPERTY(QString currentId READ currentId WRITE setCurrentId NOTIFY currentIndexChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
public:
    explicit SGFileTabModel(QObject *parent = nullptr);
    ~SGFileTabModel();

    enum RoleNames {
        FilenameRole = Qt::UserRole + 1,
        FilepathRole = Qt::UserRole + 2,
        FiletypeRole = Qt::UserRole + 3,
        UIdRole = Qt::UserRole + 4,
        UnsavedChangesRole = Qt::UserRole + 5,
        ExistsRole = Qt::UserRole + 6
    };
    Q_ENUMS(RoleNames);

    // OVERRIDES
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;

    // CUSTOM FUNCTIONS
    Q_INVOKABLE bool addTab(const QString &filename, const QUrl &filepath, const QString &filetype, const QString &id);
    Q_INVOKABLE bool closeTab(const QString &id);
    Q_INVOKABLE bool closeTabAt(const int index);
    Q_INVOKABLE void closeAll();
    Q_INVOKABLE void saveFileAt(const int index, bool close);
    Q_INVOKABLE void saveAll(bool close);
    Q_INVOKABLE bool hasTab(const QString &id) const;
    Q_INVOKABLE void clear(bool emitSignals = true);
    Q_INVOKABLE int getUnsavedCount() const;
    Q_INVOKABLE int getIndexById(const QString &id) const;
    Q_INVOKABLE void setExists(const QString &id, const bool &exists);
    Q_INVOKABLE int findTabByFilepath(const QUrl &filepath);

    /**
     * @brief updateTab Updates the filename, filepath, and filetype of the tab with id equal to `id`
     * @param id The tab to change
     * @param filename The filename
     * @param filepath The filepath
     * @param filetype The filetype
     * @return Returns true if the tab was found, else false
     */
    Q_INVOKABLE bool updateTab(const QString &id, const QString &filename, const QUrl &filepath, const QString &filetype);

    int count() const;
    int currentIndex() const;
    QString currentId() const;
    void setCurrentIndex(const int index);
    void setCurrentId(const QString &id);

signals:
    void currentIndexChanged();
    void tabClosed(const QUrl filepath);
    void tabOpened(const QUrl filepath);
    void countChanged();
    void saveRequested(const int index, bool close);
    void saveAllRequested(bool close);

private:
    QList<SGFileTabItem*> data_;
    int currentIndex_;
    QString currentId_;
    QSet<QString> tabIds_;
};

