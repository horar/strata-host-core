/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
#pragma once

#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/sinks/stdout_color_sinks.h>

namespace strata::loggers
{
/**
 * @brief The spdlog logging setup
 */
class SpdLogger final
{
public:
    SpdLogger();
    ~SpdLogger();

    /**
     * @brief setup
     *
     * @param[in] fileName log file name with valid full path
     * @param[in] logPattern spdlog pattern for console logs
     * @param[in] logPattern4logFile spdlog pattern for log file
     * @param[in] logLevel logging level to setup
     * @param[in] maxFileSize maximum size of log file before log rotation
     * @param[in] maxNoFiles maximum number of files for rotation
     */
    void setup(const std::string& fileName, const std::string& logPattern, const std::string& logFilePattern,
               const std::string& logLevel = std::string("debug"), const size_t maxFileSize = 1024 * 1024 * 5,
               const size_t maxNoFiles = 5);

private:
    std::shared_ptr<spdlog::sinks::stdout_color_sink_mt> console_sink_;
    std::shared_ptr<spdlog::sinks::rotating_file_sink_mt> file_sink_;
    std::shared_ptr<spdlog::logger> logger_;
    std::string loggerCategory_{"strata.logger.spdlog"};
};

}  // namespace strata::loggers
