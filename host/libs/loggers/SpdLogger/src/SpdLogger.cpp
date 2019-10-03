#include "SpdLogger.h"

#include <spdlog/spdlog.h>

SpdLogger::SpdLogger()
    :
#if defined(_WIN32)
      console_sink_
{
    std::make_shared<spdlog::sinks::msvc_sink_mt>()
}
#else
      console_sink_
{
    std::make_shared<spdlog::sinks::ansicolor_stdout_sink_mt>(spdlog::color_mode::always)
}
#endif

{
}

SpdLogger::~SpdLogger()
{
    spdlog::info("...spdlog logging finished");
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

    spdlog::info("spdlog logging initiated...");
    spdlog::info("Logger setup:");
    spdlog::info("\tfile: {}", fileName);
    spdlog::info("\tlevel: {}", logLevel);
    spdlog::debug("\tlogPattern: {}", logPattern);
    spdlog::debug("\tlogFilePattern: {}", logFilePattern);
    spdlog::debug("\tmaxFileSize: {}", maxFileSize);
    spdlog::debug("\tmaxNoFiles: {}", maxNoFiles);
}
