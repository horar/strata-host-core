/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#include "SpdLogger.h"

#include <spdlog/spdlog.h>

namespace strata::loggers
{
SpdLogger::SpdLogger()
    : console_sink_{std::make_shared<spdlog::sinks::stdout_color_sink_mt>(spdlog::color_mode::always)}
{
}

SpdLogger::~SpdLogger()
{
    spdlog::debug("{}: SpdLogger::~SpdLogger - ...spdlog logging finished", loggerCategory_);
    spdlog::shutdown();
}

void SpdLogger::setup(const std::string& fileName, const std::string& logPattern, const std::string& logFilePattern,
                      const std::string& logLevel, const size_t maxFileSize, const size_t maxNoFiles)
{
    if (logger_ && spdlog::level::to_string_view(logger_->level()) == logLevel) {
        return;
    }

    file_sink_ = std::make_shared<spdlog::sinks::rotating_file_sink_mt>(fileName, maxFileSize, maxNoFiles);
    logger_ = std::make_shared<spdlog::logger>(std::string{"appLogger"},
                                               std::initializer_list<spdlog::sink_ptr>{file_sink_, console_sink_});
    spdlog::set_default_logger(logger_);

    console_sink_->set_pattern(logPattern);
    file_sink_->set_pattern(logFilePattern);

    spdlog::flush_on(spdlog::level::info);
    spdlog::flush_every(std::chrono::seconds(5));
    spdlog::set_level(spdlog::level::from_str(logLevel));

    spdlog::debug("{}: SpdLogger::setup - logging initiated... (spdlog v{}.{}.{})", loggerCategory_, SPDLOG_VER_MAJOR,
                  SPDLOG_VER_MINOR, SPDLOG_VER_PATCH);
    spdlog::debug("{}: SpdLogger::setup - spdlog logging initiated...", loggerCategory_);
    spdlog::debug("{}: SpdLogger::setup - Logger setup:", loggerCategory_);
    spdlog::debug("{}: SpdLogger::setup - \tfile: {}", loggerCategory_, fileName);
    spdlog::debug("{}: SpdLogger::setup - \tlevel: {}", loggerCategory_, logLevel);
    spdlog::debug("{}: SpdLogger::setup - \tlogPattern: {}", loggerCategory_, logPattern);
    spdlog::debug("{}: SpdLogger::setup - \tlogFilePattern: {}", loggerCategory_, logFilePattern);
    spdlog::debug("{}: SpdLogger::setup - \tmaxFileSize: {}", loggerCategory_, maxFileSize);
    spdlog::debug("{}: SpdLogger::setup - \tmaxNoFiles: {}", loggerCategory_, maxNoFiles);
}

}  // namespace strata::loggers
