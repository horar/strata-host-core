/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef LCUMODEL_H
#define LCUMODEL_H

#include <QObject>

class LcuModel : public QObject
{
    Q_OBJECT
public:
    explicit LcuModel(QObject *parent = nullptr);
    virtual ~LcuModel();
    Q_INVOKABLE void configFileSelectionChanged(QString fileName);
    Q_INVOKABLE void reload();
    Q_INVOKABLE QStringList getIniFiles();

signals:

};

#endif // LCUMODEL_H
