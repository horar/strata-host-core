/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "QtLoggerSetup.h"

#include "moc_QtLoggerSetup.cpp"

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
    const auto logLevel{settings.value(QStringLiteral("log/level")).toString()};
    if (logLevel_ != logLevel) {
        qCDebug(logCategoryQtLogger, "...reconfiguring loggers...");

        setupSpdLog(*QCoreApplication::instance());
        setupQtLog();
    }
}

QtLoggerSetup::QtLoggerSetup(const QCoreApplication& app)
{
    generateDefaultSettings();

    setupSpdLog(app);
    setupQtLog();

    QSettings settings;
    if (watchdog_.addPath(settings.fileName()) == false) {
        qCCritical(logCategoryQtLogger, "Failed to register '%s' to system watcher",
                   qUtf8Printable(settings.fileName()));
        return;
    }

    QObject::connect(&watchdog_, &QFileSystemWatcher::fileChanged,
                     [this](const QString&) { this->reload(); });
}

QtLoggerSetup::~QtLoggerSetup()
{
    qCDebug(logCategoryQtLogger) << "...Qt logging finished";
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
        settings.setValue(QStringLiteral("maxFileSize"), 1024 * 1024 * 5);
    }
    if (settings.contains(QStringLiteral("maxNoFiles")) == false) {
        settings.setValue(QStringLiteral("maxNoFiles"), 5);
    }
    if (settings.contains(QStringLiteral("level-comment")) == false) {
        settings.setValue(
            QStringLiteral("level-comment"),
            QStringLiteral("log level is one of: debug, info, warning, error, critical, off"));
    }
    if (settings.contains(QStringLiteral("level")) == false) {
        settings.setValue(QStringLiteral("level"), QStringLiteral("info"));
    }
    if (settings.contains(QStringLiteral("spdlogMessagePattern")) == false) {
        settings.setValue(QStringLiteral("spdlogMessagePattern"),
                          QStringLiteral("%T.%e %^[%=7l]%$ %v"));
    }

    // Qt logging related settings
    if (settings.contains(QStringLiteral("qtFilterRules")) == false) {
        settings.setValue(QStringLiteral("qtFilterRules"), QStringLiteral("strata.*=true"));
    }
    if (settings.contains(QStringLiteral("qtMessagePattern")) == false) {
        settings.setValue(QStringLiteral("qtMessagePattern"),
                          QStringLiteral("%{if-category}%{category}: %{endif}"
                                         /*"%{file}:%{line}"*/
                                         "%{if-debug}%{function}%{endif}"
                                         "%{if-info}%{function}%{endif}"
                                         "%{if-warning}%{function}%{endif}"
                                         "%{if-critical}%{function}%{endif}"
                                         "%{if-fatal}%{function}%{endif}"
                                         " - %{message}"));
    }

    settings.endGroup();
}

void QtLoggerSetup::setupSpdLog(const QCoreApplication& app)
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));
    const auto maxFileSize{settings.value(QStringLiteral("maxFileSize")).toUInt()};
    const auto maxNoFiles{settings.value(QStringLiteral("maxNoFiles")).toUInt()};
    logLevel_ = {settings.value(QStringLiteral("level")).toString()};
    const auto messagePattern{settings.value(QStringLiteral("spdlogMessagePattern")).toString()};
    const auto messagePattern4file{
        settings
            .value(QStringLiteral("spdlogFileMessagePattern"),
                   QStringLiteral("%Y-%m-%dT%T.%e%z\tPID:%P\tTID:%t\t[%L]\t%v"))
            .toString()};
    settings.endGroup();

    const QString logPath{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (const QDir logDir{logPath}; logDir.exists() == false) {
        if (logDir.mkpath(logPath) == false) {
            spdlog::critical("Failed to create log file folder!!");
        }
    }

    logger_.setup(QStringLiteral("%1/%2.log").arg(logPath).arg(app.applicationName()).toStdString(),
                  messagePattern.toStdString(), messagePattern4file.toStdString(),
                  logLevel_.toStdString(), maxFileSize, maxNoFiles);
}

void QtLoggerSetup::setupQtLog()
{
    QSettings settings;
    settings.beginGroup(QStringLiteral("log"));
    const auto filterRules{settings.value(QStringLiteral("qtFilterRules")).toString()};
    const auto messagePattern{settings.value(QStringLiteral("qtMessagePattern")).toString()};
    settings.endGroup();

    qSetMessagePattern(messagePattern);
    QLoggingCategory::setFilterRules(filterRules);

    qInstallMessageHandler(QtLogger::MsgHandler);

    qCDebug(logCategoryQtLogger) << "Qt logging initiated...";

    qCDebug(logCategoryQtLogger) << "Application setup:";
    qCDebug(logCategoryQtLogger) << "\tini:" << settings.fileName();
    qCDebug(logCategoryQtLogger) << "\tformat:" << settings.format();
    qCDebug(logCategoryQtLogger) << "\taccess" << settings.status();
    qCDebug(logCategoryQtLogger) << "\tlogging category filte rules:" << filterRules;
    qCDebug(logCategoryQtLogger) << "\tlogger message pattern:" << messagePattern;
}

}  // namespace strata::loggers
