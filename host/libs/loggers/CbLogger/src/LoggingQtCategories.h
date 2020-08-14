#pragma once

#include <QLoggingCategory>

namespace strata::loggers
{
constexpr const char* logCategoryCbLoggerName = "strata.couchbase-lite";

Q_DECLARE_LOGGING_CATEGORY(logCategoryCbLogger)
}  // namespace strata::loggers
