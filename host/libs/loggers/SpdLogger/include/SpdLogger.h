#pragma once

#if defined(_WIN32)
#include <spdlog/sinks/msvc_sink.h>
#else
#include <spdlog/sinks/stdout_color_sinks.h>
#endif
#include <spdlog/sinks/rotating_file_sink.h>

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
    void setup(const std::string& fileName, const std::string& logPattern,
               const std::string& logPattern4logFile,
               const std::string& logLevel = std::string("debug"),
               const size_t maxFileSize = 1024 * 1024 * 5, const size_t maxNoFiles = 5);

private:
#if defined(_WIN32)
    std::shared_ptr<spdlog::sinks::msvc_sink_mt> console_sink_;
#else
    std::shared_ptr<spdlog::sinks::ansicolor_stdout_sink_mt> console_sink_;
#endif
    std::shared_ptr<spdlog::sinks::rotating_file_sink_mt> file_sink_;
    std::shared_ptr<spdlog::logger> logger_;
};
