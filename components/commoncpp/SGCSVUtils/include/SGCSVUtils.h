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
#include <QVariant>
#include <QVector>
#include <QDateTime>

class SGCSVUtils: public QObject
{
    Q_OBJECT
public:
    explicit SGCSVUtils(QObject *parent = nullptr);
    virtual ~SGCSVUtils();

    Q_INVOKABLE QVariantList importFromFile(const QString &filePath);
    Q_INVOKABLE void appendRow(const QVariantList data);
    Q_INVOKABLE QVariantList getData();
    Q_INVOKABLE void setData(const QVariantList data);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void writeToFile(const QString &filePath);

signals:
    void outputPathChanged();
    void fileNameChanged();

private:
    QVector<QVariant> data_;
    const QString defaultFileName_ = QString(QDateTime::currentDateTime().toString("yyyy.MM.dd") + " at " + QDateTime::currentDateTime().toString("hh.mm.ss") + ".csv");
};
