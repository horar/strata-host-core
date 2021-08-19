/*
 * Copyright (c) 2018-2021 onsemi.
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
    : console_sink_{
          std::make_shared<spdlog::sinks::stdout_color_sink_mt>(spdlog::color_mode::always)}
{
}

SpdLogger::~SpdLogger()
{
    spdlog::debug("{}: SpdLogger::~SpdLogger - ...spdlog logging finished", logCategory_);
    spdlog::shutdown();
}

void SpdLogger::setup(const std::string& fileName, const std::string& logPattern,
                      const std::string& logFilePattern, const std::string& logLevel,
                      const size_t maxFileSize, const size_t maxNoFiles)
{
    if (logger_ && spdlog::level::to_string_view(logger_->level()) == logLevel) {
        return;
    }

    file_sink_ =
        std::make_shared<spdlog::sinks::rotating_file_sink_mt>(fileName, maxFileSize, maxNoFiles);
    logger_ = std::make_shared<spdlog::logger>(
        std::string{"appLogger"},
        std::initializer_list<spdlog::sink_ptr>{file_sink_, console_sink_});
    spdlog::set_default_logger(logger_);

    console_sink_->set_pattern(logPattern);
    file_sink_->set_pattern(logFilePattern);

    spdlog::flush_on(spdlog::level::info);
    spdlog::flush_every(std::chrono::seconds(5));
    spdlog::set_level(spdlog::level::from_str(logLevel));

    spdlog::debug("{}: SpdLogger::setup - logging initiated... (spdlog v{}.{}.{})", logCategory_,
                  SPDLOG_VER_MAJOR, SPDLOG_VER_MINOR, SPDLOG_VER_PATCH);
    spdlog::debug("{}: SpdLogger::setup - spdlog logging initiated...", logCategory_);
    spdlog::debug("{}: SpdLogger::setup - Logger setup:", logCategory_);
    spdlog::debug("{}: SpdLogger::setup - \tfile: {}", logCategory_, fileName);
    spdlog::debug("{}: SpdLogger::setup - \tlevel: {}", logCategory_, logLevel);
    spdlog::debug("{}: SpdLogger::setup - \tlogPattern: {}", logCategory_, logPattern);
    spdlog::debug("{}: SpdLogger::setup - \tlogFilePattern: {}", logCategory_, logFilePattern);
    spdlog::debug("{}: SpdLogger::setup - \tmaxFileSize: {}", logCategory_, maxFileSize);
    spdlog::debug("{}: SpdLogger::setup - \tmaxNoFiles: {}", logCategory_, maxNoFiles);
}

}  // namespace strata::loggers
