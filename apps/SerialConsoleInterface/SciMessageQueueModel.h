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

struct QueueItem {
    QString rawMessage;
};

class SciMessageQueueModel: public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(SciMessageQueueModel)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum ModelRole {
        RawMessageRole = Qt::UserRole,
    };

    enum ErrorCode {
        NoError,
        ErrorQueueSizeLimitExceeded,
    };

    explicit SciMessageQueueModel(QObject *parent = nullptr);
    virtual ~SciMessageQueueModel() override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int count() const;
    QString errorString(ErrorCode code) const;
    ErrorCode append(const QString &message);
    QString first();
    void removeFirst();
    bool isEmpty();

protected:
    virtual QHash<int, QByteArray> roleNames() const override;

signals:
    void countChanged();

private:
    void setModelRoles();

    QHash<int, QByteArray> roleByEnumHash_;
    QList<QueueItem> data_;
    int queueSizeLimit_ = 100;
};

