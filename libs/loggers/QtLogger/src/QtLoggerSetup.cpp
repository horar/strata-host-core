/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "QtLoggerSetup.h"
#include "QtLoggerDefaults.h"

#include "LoggingQtCategories.h"
#include "QtLogger.h"

#include <SpdLogger.h>

#include <QDebug>
#include <QDir>
#include <QLoggingCategory>
#include <QSettings>
#include <QStandardPaths>

#include <spdlog/spdlog.h>

namespace strata::loggers
{
void QtLoggerSetup::reload()
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));

    QMapIterator<QString, QString> iter(logParams_);
    while (iter.hasNext()) {
        iter.next();
        if(iter.value() != settings.value(iter.key()).toString()) {
            qCDebug(lcQtLogger, "...reconfiguring loggers...");

            setupSpdLog(*QCoreApplication::instance());
            setupQtLog();
        }
    }
    settings.endGroup();
}

QtLoggerSetup::QtLoggerSetup(const QCoreApplication& app)
{
    generateDefaultSettings();

    setupSpdLog(app);
    setupQtLog();

    QSettings settings;
    if (watchdog_.addPath(settings.fileName()) == false) {
        qCCritical(lcQtLogger, "Failed to register '%s' to system watcher",
                   qUtf8Printable(settings.fileName()));
        return;
    }

    QObject::connect(&watchdog_, &QFileSystemWatcher::fileChanged,
                     [this](const QString&) { this->reload(); });
}

QtLoggerSetup::~QtLoggerSetup()
{
    qCDebug(lcQtLogger) << "...Qt logging finished";
}

QtMessageHandler QtLoggerSetup::getQtLogCallback() const
{
    return &QtLogger::MsgHandler;
}

void QtLoggerSetup::generateDefaultSettings() const
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));

    // spdlog related settings
    if (settings.contains(QStringLiteral("maxFileSize")) == false) {
        settings.setValue(QStringLiteral("maxFileSize"), defaults::LOGFILE_MAX_SIZE);
    }
    if (settings.contains(QStringLiteral("maxNoFiles")) == false) {
        settings.setValue(QStringLiteral("maxNoFiles"), defaults::LOGFILE_MAX_COUNT);
    }
    if (settings.contains(QStringLiteral("level-comment")) == false) {
        settings.setValue(
            QStringLiteral("level-comment"),
            QStringLiteral("log level is one of: debug, info, warning, error, critical, off"));
    }
    if (settings.contains(QStringLiteral("level")) == false) {
        settings.setValue(QStringLiteral("level"), defaults::LOGLEVEL);
    }
    if (settings.contains(QStringLiteral("spdlogMessagePattern")) == false) {
        settings.setValue(QStringLiteral("spdlogMessagePattern"),
                          defaults::SPDLOG_MESSAGE_PATTERN_4CONSOLE);
    }

    // Qt logging related settings
    if (settings.contains(QStringLiteral("qtFilterRules")) == false) {
        settings.setValue(QStringLiteral("qtFilterRules"), defaults::QT_FILTER_RULES);
    }
    if (settings.contains(QStringLiteral("qtMessagePattern")) == false) {
        settings.setValue(QStringLiteral("qtMessagePattern"), defaults::QT_MESSAGE_PATTERN);
    }

    settings.endGroup();
}

void QtLoggerSetup::setupSpdLog(const QCoreApplication& app)
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));
    logParams_.insert("level", {settings.value(QStringLiteral("level")).toString()});
    const auto maxFileSize{settings.value(QStringLiteral("maxFileSize")).toUInt()};
    logParams_.insert("maxFileSize", {settings.value(QStringLiteral("maxFileSize")).toString()});
    const auto maxNoFiles{settings.value(QStringLiteral("maxNoFiles")).toUInt()};
    logParams_.insert("maxNoFiles", {settings.value(QStringLiteral("maxNoFiles")).toString()});
    const auto messagePattern{settings.value(QStringLiteral("spdlogMessagePattern")).toString()};
    logParams_.insert("spdlogMessagePattern", messagePattern);
    const auto messagePattern4file{settings
                                       .value(QStringLiteral("spdlogFileMessagePattern"),
                                              defaults::SPDLOG_MESSAGE_PATTERN_4FILE)
                                       .toString()};
    settings.endGroup();

    const QString logPath{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (const QDir logDir{logPath}; logDir.exists() == false) {
        if (logDir.mkpath(logPath) == false) {
            spdlog::critical("Failed to create log file folder!!");
        }
    }

    logger_.setup(QStringLiteral("%1/%2.log").arg(logPath, app.applicationName()).toStdString(),
                  messagePattern.toStdString(), messagePattern4file.toStdString(),
                  logParams_.value("level").toStdString(), maxFileSize, maxNoFiles);
}

void QtLoggerSetup::setupQtLog()
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));
    const auto filterRules{settings.value(QStringLiteral("qtFilterRules")).toString()};
    logParams_.insert("qtFilterRules", filterRules);
    const auto messagePattern{settings.value(QStringLiteral("qtMessagePattern")).toString()};
    logParams_.insert("qtMessagePattern", messagePattern);
    settings.endGroup();

    qSetMessagePattern(messagePattern);
    QLoggingCategory::setFilterRules(filterRules);

    qInstallMessageHandler(QtLogger::MsgHandler);

    qCDebug(lcQtLogger) << "Qt logging initiated...";

    qCDebug(lcQtLogger) << "Application setup:";
    qCDebug(lcQtLogger) << "\tini:" << settings.fileName();
    qCDebug(lcQtLogger) << "\tformat:" << settings.format();
    qCDebug(lcQtLogger) << "\taccess" << settings.status();
    qCDebug(lcQtLogger) << "\tlogging category filter rules:" << filterRules;
    qCDebug(lcQtLogger) << "\tlogger message pattern:" << messagePattern;
}

}  // namespace strata::loggers
