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
#include <QFileInfoList>

class ConfigFileModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY onCountChanged)

public:
    explicit ConfigFileModel(QObject *parent = nullptr);
    enum ModelRole{
        FileNameRole = Qt::UserRole,
        FilePathRole
    };
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    int count() const;

    Q_INVOKABLE void reload();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void onCountChanged();

private slots:
    void addItem(const QString fileName);

private:
    QFileInfoList iniFiles_;
};
