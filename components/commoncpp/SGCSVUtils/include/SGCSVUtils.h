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
#include <QVariantList>
#include <QDateTime>
#include <QJsonArray>

class SGCSVUtils: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString outputPath MEMBER outputPath_ NOTIFY outputPathChanged)
    Q_PROPERTY(QString fileName MEMBER fileName_ NOTIFY fileNameChanged)
public:
    explicit SGCSVUtils(QObject *parent = nullptr);
    virtual ~SGCSVUtils();

    Q_INVOKABLE QVariantList importFromFile(QString folderPath);
    Q_INVOKABLE void appendRow(QVariantList data);
    Q_INVOKABLE QVariantList getData();
    Q_INVOKABLE void setData(QVariantList data);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void writeToFile();

signals:
    void outputPathChanged();
    void fileNameChanged();

private:
    QVector<QVariant> data_;
    QString outputPath_ = "";
    QString fileName_ = QString("Output"+QDateTime::currentDateTime().toString("dd.MM.yyyy")+"-"+QDateTime::currentDateTime().toString("hh:mm:ss t") + ".csv");
};
