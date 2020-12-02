#include "QtLogger.h"

#include <SpdLogger.h>

#include <QLoggingCategory>

#include <spdlog/spdlog.h>

namespace strata::loggers
{
QtLogger::QtLogger(QObject *parent) : QObject(parent)
{
    qRegisterMetaType<QtMsgType>("QtMsgType");
}

QtLogger &QtLogger::instance()
{
    static QtLogger obj;
    return obj;
}

void QtLogger::MsgHandler(QtMsgType type, const QMessageLogContext &context, const QString &msg)
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

    emit instance().logMsg(type, formattedMsg);
}

}  // namespace strata::loggers
