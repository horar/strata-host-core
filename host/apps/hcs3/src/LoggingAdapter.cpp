
#include "LoggingAdapter.h"

#include "logging/LoggingQtCategories.h"
#include <QString>

void LoggingAdapter::Log(LogLevel level, const std::string& log_text)
{
    qCDebug(logCategoryHcs) << QString::fromStdString(log_text);
}

