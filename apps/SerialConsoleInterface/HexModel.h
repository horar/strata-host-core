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

class HexModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(HexModel)

    Q_PROPERTY(QByteArray content READ content WRITE setContent NOTIFY contentChanged)

public:
    explicit HexModel(QObject *parent = nullptr);
    virtual ~HexModel() override;

    enum ModelRole {
        CharValueRole = Qt::UserRole,
        OctValueRole,
        DecValueRole,
        HexValueRole,
    };

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QByteArray content();
    void setContent(const QByteArray &content);

signals:
    void contentChanged();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    QByteArray content_;
};
