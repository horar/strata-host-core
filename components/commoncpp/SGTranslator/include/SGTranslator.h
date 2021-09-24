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
#include <QApplication>
#include <QTranslator>
#include <QQmlEngine>
#include <QQuickItem>
#include <QDebug>

class SGTranslator : public QQuickItem
{
    Q_OBJECT
    Q_DISABLE_COPY(SGTranslator)

public:
    SGTranslator(QQuickItem* parent = nullptr);
    virtual ~SGTranslator() {}

    Q_INVOKABLE bool loadLanguageFile(QString languageFileName = "");

private:
    QTranslator translator_;
};
