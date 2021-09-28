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
#include <Mock/MockDeviceConstants.h>

class SciMockResponseModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMockResponseModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    explicit SciMockResponseModel(QObject *parent = nullptr);
    virtual ~SciMockResponseModel() override;

    Q_INVOKABLE QVariantMap get(int row);
    Q_INVOKABLE int find(const QVariant& type) const;
    Q_INVOKABLE QVariant data(int row, const QByteArray &role) const;

    enum ModelRole {
        TypeRole = Qt::UserRole + 1,
        NameRole
    };

    struct ResponseData {
        strata::device::MockResponse type_;
        QString name_;
    };

    void updateModelData(const strata::device::MockVersion& version, const strata::device::MockCommand& command);
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;

signals:
    void countChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    void clear();
    void setModelRoles();

    QHash<int, QByteArray> roleByEnumHash_;
    QHash<QByteArray, int> roleByNameHash_;
    QList<ResponseData> responses_;
};
