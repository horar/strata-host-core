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
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

public:
    explicit ConfigFileModel(QObject *parent = nullptr);
    enum ModelRole{
        FileNameRole = Qt::UserRole,
        FilePathRole
    };
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    int count() const;
    int currentIndex() const;
    void setCurrentIndex(const int index);

    Q_INVOKABLE void reload();
    Q_INVOKABLE QVariantMap get(int index);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();
    void currentIndexChanged();

private slots:
    void addItem(const QFileInfo fileInfo);

private:
    QFileInfoList iniFiles_;
    int currentIndex_;
};
