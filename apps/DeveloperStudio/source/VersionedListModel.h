/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef VERSIONED_LIST_MODEL_H
#define VERSIONED_LIST_MODEL_H

#include <QAbstractListModel>
#include <QJsonArray>
#include <PlatformInterface/core/CoreInterface.h>
#include <QUrl>
#include <QList>

struct VersionedItem {
    VersionedItem(
            const QString &uri,
            const QString &md5,
            const QString &name,
            const QString &controller_class_id,
            const QString &timestamp,
            const QString &version,
            const QString &filepath = "")
    {
        this->uri = uri;
        this->md5 = md5;
        this->name = name;
        this->controller_class_id = controller_class_id;
        this->timestamp = timestamp;
        this->version = version;
        this->filepath = filepath;
        this->installed = !filepath.isEmpty();
    }

    QString uri;
    QString md5;
    QString name;
    QString controller_class_id;
    QString timestamp;
    QString version;
    QString filepath;
    bool installed;
};

class VersionedListModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(VersionedListModel)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    VersionedListModel(QObject *parent = nullptr);
    virtual ~VersionedListModel() override;

    Q_INVOKABLE void setInstalled(int index, bool installed);
    Q_INVOKABLE void setFilepath(int index, QString path);
    Q_INVOKABLE QString version(int index);
    Q_INVOKABLE QString uri(int index);
    Q_INVOKABLE QString md5(int index);
    Q_INVOKABLE QString name(int index);
    Q_INVOKABLE QString controller_class_id(int index);
    Q_INVOKABLE QString timestamp(int index);
    Q_INVOKABLE QString filepath(int index);
    Q_INVOKABLE bool installed(int index);
    Q_INVOKABLE int getLatestVersionIndex();
    Q_INVOKABLE int getInstalledVersionIndex();

    enum {
        UriRole = Qt::UserRole,
        VersionRole,
        NameRole,
        ControllerClassIdRole,
        TimestampRole,
        Md5Role,
        InstalledRole,
        FilepathRole
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int count() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    void populateModel(const QList<VersionedItem*> &list);
    void clear(bool emitSignals=true);
    Q_INVOKABLE QVariantMap get(int index);

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QList<VersionedItem*>data_;
};


#endif //VERSIONED_LIST_MODEL_H
