#include "QtLogger.h"

#include "moc_QtLogger.cpp"

#include <SpdLogger.h>

#include <QLoggingCategory>

#include <spdlog/spdlog.h>

namespace strata::loggers
{

bool QtLogger::visualEditorReloading = false;

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
    if (visualEditorReloading) {
        // While the Visual Editor loads, the loaded file can throw reference errors (and others) that should be ignored.
        // This actively suppresses ALL logs during the reload process.
        return;
    }

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
