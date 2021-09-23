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
#include <QString>
#include <QDir>

class StorageInfo final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(StorageInfo)

public:
    StorageInfo(QObject* = nullptr, QString cacheDir = "");
    ~StorageInfo() = default;

    void calculateSize() const;

    using FolderSize = std::tuple<QString, quint64>;

private:
    const QDir cacheDir_;
};
