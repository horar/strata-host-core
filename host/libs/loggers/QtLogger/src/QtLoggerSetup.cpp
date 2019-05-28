#include "QtLoggerSetup.h"

#include "LoggingQtCategories.h"

#include <SpdLogger.h>

#include <QDebug>
#include <QDir>
#include <QLoggingCategory>
#include <QSettings>
#include <QStandardPaths>

#include <spdlog/spdlog.h>

void qtLogCallback(const QtMsgType type, const QMessageLogContext& context, const QString& msg)
{
    const QString formattedMsg{qFormatLogMessage(type, context, msg)};

    switch (type) {
        case QtDebugMsg:
            spdlog::debug(formattedMsg.toStdString());
            break;
        case QtInfoMsg:
            spdlog::info(formattedMsg.toStdString());
            break;
        case QtWarningMsg:
            spdlog::warn(formattedMsg.toStdString());
            break;
        case QtCriticalMsg:
            spdlog::error(formattedMsg.toStdString());
            break;
        case QtFatalMsg:
            spdlog::critical(formattedMsg.toStdString());
            break;
    }
    // XXX: Qt doesn't have macro like qTrace() ...
    // spdlog::trace(formattedMsg.toStdString());
}

QtLoggerSetup::QtLoggerSetup(const QCoreApplication& app)
{
    generateDefaultSettings();

    setupSpdLog(app);
    setupQtLog();
}

QtLoggerSetup::~QtLoggerSetup()
{
    qCInfo(logCategoryQtLogger) << "...Qt logging finished";
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
                          QStringLiteral("%Y-%m-%d %T.%e PID:%P TID:%t [%L] %v"));
    }

    // Qt logging related settings
    if (settings.contains(QStringLiteral("qtFilterRules")) == false) {
        settings.setValue(QStringLiteral("qtFilterRules"), QStringLiteral("strata.*=true"));
    }
    if (settings.contains(QStringLiteral("qtMessagePattern")) == false) {
        settings.setValue(QStringLiteral("qtMessagePattern"),
                          QStringLiteral("%{if-category}\033[32m%{category}: %{endif}"
                                         "%{if-debug}\033[0m(%{function})%{endif}"
                                         "%{if-info}\033[34m(%{function})%{endif}"
                                         "%{if-warning}\033[33m(%{function})%{endif}"
                                         "%{if-critical}\033[31m(%{function})%{endif}"
                                         "%{if-fatal}\033[31m(%{function})%{endif}"
                                         "\033[0m"
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
    const auto level{settings.value(QStringLiteral("level")).toString()};
    const auto messagePattern{settings.value(QStringLiteral("spdlogMessagePattern")).toString()};
    settings.endGroup();

    const QString logPath{QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)};
    if (const QDir logDir{logPath}; logDir.exists() == false) {
        if (logDir.mkpath(logPath) == false) {
            spdlog::critical("Failed to create log file folder!!");
        }
    }

    static const SpdLogger logger(
        QStringLiteral("%1/%2.log").arg(logPath).arg(app.applicationName()).toStdString(),
        messagePattern.toStdString(), level.toStdString(), maxFileSize, maxNoFiles);
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

    qInstallMessageHandler(qtLogCallback);

    qCInfo(logCategoryQtLogger) << "Qt logging initiated...";

    qCDebug(logCategoryQtLogger) << "Application setup:";
    qCDebug(logCategoryQtLogger) << "\tfile:" << settings.fileName();
    qCDebug(logCategoryQtLogger) << "\tformat:" << settings.format();
    qCDebug(logCategoryQtLogger) << "\taccess" << settings.status();
    qCDebug(logCategoryQtLogger) << "\tlogging category filte rules:" << filterRules;
    qCDebug(logCategoryQtLogger) << "\tlogger message pattern:" << messagePattern;
}
