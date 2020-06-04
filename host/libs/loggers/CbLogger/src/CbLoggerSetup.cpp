#include "CbLoggerSetup.h"

#include "LoggingQtCategories.h"

#include <QHash>
#include <QString>
#include <litecore/c4Base.h>

using std::string;


QtMessageHandler g_qtLogCallback = nullptr;

void c4LogCallback(C4LogDomain domain, C4LogLevel level, const char *fmt, va_list args)
{
    static const QHash<int, QtMsgType> cb2qtLevels{
        {kC4LogDebug, QtDebugMsg},
        {kC4LogVerbose, QtInfoMsg},
        {kC4LogInfo, QtInfoMsg},
        {kC4LogWarning, QtWarningMsg},
        {kC4LogError, QtCriticalMsg}
    };

    string tag(logCategoryCbLogger);
    if (const string domainName (c4log_getDomainName(domain)); domainName.empty() == false) {
        tag += "." + domainName;
    }

    const QString msg = QString::vasprintf(fmt, args);
    QMessageLogContext context{nullptr, 0, "n/a", tag.c_str()};
    g_qtLogCallback(cb2qtLevels[level], context, msg);
}

void cbLoggerSetup(QtMessageHandler qtLogCallback)
{
    g_qtLogCallback = qtLogCallback;
    c4log_writeToCallback(kC4LogDebug, &c4LogCallback, false);
}
