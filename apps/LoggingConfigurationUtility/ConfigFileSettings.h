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
    Q_PROPERTY(int maxNoFiles READ maxNoFiles WRITE setMaxNoFiles NOTIFY maxNoFilesChanged)
    Q_PROPERTY(QString qtFilterRules READ qtFilterRules WRITE setQtFilterRules NOTIFY qtFilterRulesChanged)
    Q_PROPERTY(QString qtMsgPattern READ qtMsgPattern WRITE setQtMsgPattern NOTIFY qtMsgPatternChanged)
    Q_PROPERTY(QString spdlogMsgPattern READ spdlogMsgPattern WRITE setSpdlogMsgPattern NOTIFY spdlogMsgPatternChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)

    Q_PROPERTY(int maxSizeDefault READ maxSizeDefault)
    Q_PROPERTY(int maxCountDefault READ maxCountDefault )
    Q_PROPERTY(QString filterRulesDefault READ filterRulesDefault)
    Q_PROPERTY(QString qtMsgDefault READ qtMsgDefault )
    Q_PROPERTY(QString spdMsgDefault READ spdMsgDefault )

public:
    explicit ConfigFileSettings(QObject *parent = 0);

    QString logLevel() const;
    int maxFileSize() const;
    int maxNoFiles() const;
    QString qtFilterRules() const;
    QString qtMsgPattern() const;
    QString spdlogMsgPattern() const;
    QString filePath() const;
    int maxSizeDefault() const;
    int maxCountDefault() const;
    QString filterRulesDefault() const;
    QString qtMsgDefault() const;
    QString spdMsgDefault() const;


    void setLogLevel(const QString& logLevel);
    void setMaxFileSize(const int& maxFileSize);
    void setMaxNoFiles(const int& maxNoFiles);
    void setQtFilterRules(const QString& qtFilterRules);
    void setQtMsgPattern(const QString& qtMessagePattern);
    void setSpdlogMsgPattern(const QString& spdlogMessagePattern);
    void setFilePath(const QString& filePath);

signals:
    void logLevelChanged();
    void maxFileSizeChanged();
    void maxNoFilesChanged();
    void qtFilterRulesChanged();
    void qtMsgPatternChanged();
    void spdlogMsgPatternChanged();
    void filePathChanged();
    void corruptedFile(QString errorString) const;

private:
    QScopedPointer<QSettings> settings_;
    static constexpr const char* const LOG_LEVEL_SETTING = "log/level";
    static constexpr const char* const LOG_MAXSIZE_SETTING = "log/maxFileSize";
    static constexpr const char* const LOG_MAXNOFILES_SETTING = "log/maxNoFiles";
    static constexpr const char* const LOG_FILTERRULES_SETTING = "log/qtFilterRules";
    static constexpr const char* const LOG_QT_MSGPATTERN_SETTING = "log/qtMessagePattern";
    static constexpr const char* const LOG_SPD_MSGPATTERN_SETTING = "log/spdlogMessagePattern";
    static constexpr int MIN_LOGFILE_SIZE = 1000; //1KB
    static constexpr int MAX_LOGFILE_SIZE = 2147483647; //over 2GB
    static constexpr int MIN_NOFILES = 1;
    static constexpr int MAX_NOFILES = 100000;
};
