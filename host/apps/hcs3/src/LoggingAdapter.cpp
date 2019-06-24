
#include "LoggingAdapter.h"

#include "logging/LoggingQtCategories.h"
#include <QString>

void LoggingAdapter::Log(LogLevel level, const std::string& log_text)
{
    switch(level)
    {
        case eLvlDebug:
            qCDebug(logCategoryHcs) << QString::fromStdString(log_text);
            break;

        case eLvlInfo:
            qCInfo(logCategoryHcs) << QString::fromStdString(log_text);
            break;

        case eLvlWarning:
            qCWarning(logCategoryHcs) << QString::fromStdString(log_text);
            break;

        case eLvlCritical:
            qCCritical(logCategoryHcs) << QString::fromStdString(log_text);
            break;

        default:
            Q_ASSERT(false);
            break;
    }
}

