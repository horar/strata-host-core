/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <QSettings>
#include <QFileInfo>

class ConfigFileSettings : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ConfigFileSettings)

    Q_PROPERTY(QString logLevel READ logLevel WRITE setLogLevel NOTIFY logLevelChanged)
    Q_PROPERTY(int maxFileSize READ maxFileSize WRITE setMaxFileSize NOTIFY maxFileSizeChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)

public:
    explicit ConfigFileSettings(QObject *parent = 0);

    QString logLevel() const;
    int maxFileSize() const;
    QString filePath() const;
    void setLogLevel(const QString& logLevel);
    void setMaxFileSize(const int& maxFileSize);
    void setFilePath(const QString& filePath);

signals:
    void logLevelChanged();
    void maxFileSizeChanged();
    void filePathChanged();

private:
    QScopedPointer<QSettings> settings_;
    static constexpr const char* const LOG_LEVEL_SETTING = "log/level";
    static constexpr const char* const LOG_MAXSIZE_SETTING = "log/maxFileSize";
};
