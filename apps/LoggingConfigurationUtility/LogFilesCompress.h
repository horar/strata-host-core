/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#ifndef LOGFILESCOMPRESS_H
#define LOGFILESCOMPRESS_H

#include <QObject>

class LogFilesCompress : public QObject
{
    Q_OBJECT
public:
    explicit LogFilesCompress(QObject *parent = nullptr);

    Q_INVOKABLE void compress();

signals:

};

#endif // LOGFILESCOMPRESS_H
