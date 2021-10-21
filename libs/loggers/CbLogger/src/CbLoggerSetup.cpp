/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "CbLoggerSetup.h"

#include "LoggingQtCategories.h"

#include <QHash>
#include <QString>

#include <unordered_map>

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

    if (const auto msgType{cb2qtLevels[level]}; lcCbLogger().isEnabled(msgType)) {
        static const std::unordered_map<CBLLogDomain, std::string> cbDomain2string{
            {kCBLLogDomainAll, "All"},
            {kCBLLogDomainDatabase, "Database"},
            {kCBLLogDomainQuery, "Query"},
            {kCBLLogDomainReplicator, "Replicator"},
            {kCBLLogDomainNetwork, "Network"}};

        using namespace std::string_literals;
        const std::string tag = lcCbLoggerName + "."s + cbDomain2string.at(domain);

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
