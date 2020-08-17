#include "CbLoggerSetup.h"

#include "LoggingQtCategories.h"

#include <QHash>
#include <QString>

#include <litecore/c4Base.h>

using std::string;

namespace strata::loggers
{
QtMessageHandler g_qtLogCallback = nullptr;

void c4LogCallback(C4LogDomain domain, C4LogLevel level, const char *fmt, va_list args)
{
    if (g_qtLogCallback == nullptr) {
        return;
    }

    static const QHash<int, QtMsgType> cb2qtLevels{{kC4LogDebug, QtDebugMsg},
                                                   {kC4LogVerbose, QtInfoMsg},
                                                   {kC4LogInfo, QtInfoMsg},
                                                   {kC4LogWarning, QtWarningMsg},
                                                   {kC4LogError, QtCriticalMsg}};

    if (const auto msgType{cb2qtLevels[level]}; logCategoryCbLogger().isEnabled(msgType)) {
        string tag(logCategoryCbLoggerName);
        if (const string domainName(c4log_getDomainName(domain)); domainName.empty() == false) {
            tag += "." + domainName;
        }

        const QString msg{QString::vasprintf(fmt, args)};
        const QMessageLogContext context{nullptr, 0, "n/a", tag.c_str()};

        g_qtLogCallback(msgType, context, msg);
    }
}

void cbLoggerSetup(QtMessageHandler qtLogCallback)
{
    g_qtLogCallback = qtLogCallback;

    // TODO: [LC] this could be probably related to our Qt log levels in config file
    c4log_setLevel(kC4DefaultLog, kC4LogDebug);
    c4log_setLevel(kC4DatabaseLog, kC4LogDebug);
    c4log_setLevel(kC4QueryLog, kC4LogDebug);
    c4log_setLevel(kC4SyncLog, kC4LogDebug);
    c4log_setLevel(kC4WebSocketLog, kC4LogDebug);

    c4log_writeToCallback(kC4LogDebug, &c4LogCallback, false);
}

}  // namespace strata::loggers
