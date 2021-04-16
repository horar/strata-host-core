#include "CbLoggerSetup.h"

#include "LoggingQtCategories.h"

#include <QHash>
#include <QString>

#include <couchbase-lite-C/CouchbaseLite.hh>

using std::string;

namespace strata::loggers
{
QtMessageHandler g_qtLogCallback = nullptr;

#ifdef Q_OS_MACOS
// this __attribute__ flag is used for removing "format string is not a string literal" warning
__attribute__((__format__ (__printf__, 3, 0)))
#endif
void c4LogCallback(CBLLogDomain domain, CBLLogLevel level, const char *message)
{
    if (g_qtLogCallback == nullptr) {
        return;
    }

    static const QHash<int, QtMsgType> cb2qtLevels{{CBLLogDebug, QtDebugMsg},
                                                   {CBLLogVerbose, QtInfoMsg},
                                                   {CBLLogInfo, QtInfoMsg},
                                                   {CBLLogWarning, QtWarningMsg},
                                                   {CBLLogError, QtCriticalMsg}};

    if (const auto msgType{cb2qtLevels[level]}; logCategoryCbLogger().isEnabled(msgType)) {
        string tag(logCategoryCbLoggerName);

        switch (domain) {
            case kCBLLogDomainAll:
                tag += ".All";
                break;
            case kCBLLogDomainDatabase:
                tag += ".Database";
                break;
            case kCBLLogDomainQuery:
                tag += ".Query";
                break;
            case kCBLLogDomainReplicator:
                tag += ".Replicator";
                break;
            case kCBLLogDomainNetwork:
                tag += ".Network";
                break;
        }

        const QMessageLogContext context{nullptr, 0, "n/a", tag.c_str()};

        g_qtLogCallback(msgType, context, message);
    }
}

void cbLoggerSetup(QtMessageHandler qtLogCallback)
{
    g_qtLogCallback = qtLogCallback;

    // TODO: [LC] this could be probably related to our Qt log levels in config file

    CBLLog_SetConsoleLevel(CBLLogDebug);

    CBLLog_SetCallback(&c4LogCallback);

    qDebug() << "LiteCore logging callback registered...";
}

}  // namespace strata::loggers
