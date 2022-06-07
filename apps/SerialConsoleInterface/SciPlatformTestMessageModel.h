/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */

#pragma once

#include <QObject>
#include <QAbstractListModel>

class SciPlatformTestMessageModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciPlatformTestMessageModel)

public:
    enum MessageType {
        Plain,
        Info,
        Warning,
        Error,
        Success
    };
    Q_ENUM(MessageType)

    enum ModelRole {
        TextRole = Qt::UserRole + 1,
        TypeRole,
    };

    SciPlatformTestMessageModel(QObject *parent = nullptr);
    virtual ~SciPlatformTestMessageModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    void clear();
    void addMessage(MessageType type, QString text);

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

private:
    struct TestMessageItem {
        MessageType type;
        QString text;
    };

    QList<TestMessageItem> data_;

};

Q_DECLARE_METATYPE(SciPlatformTestMessageModel::MessageType)
