#include "SpdLogger.h"

SpdLogger::SpdLogger(const std::string& fileName, const std::string& logPattern,
                     const std::string& logLevel, const size_t maxFileSize, const size_t maxNoFiles)
    :
#if defined(_WIN32)
      console_sink_{std::make_shared<spdlog::sinks::msvc_sink_mt>()},
#else
      console_sink_{std::make_shared<spdlog::sinks::stdout_color_sink_mt>()},
#endif
      file_sink_{std::make_shared<spdlog::sinks::rotating_file_sink_mt>(fileName, maxFileSize,
                                                                        maxNoFiles)},
      logger_{std::make_shared<spdlog::logger>(
          std::string{"appLogger"},
          std::initializer_list<spdlog::sink_ptr>{file_sink_, console_sink_})}
{
    spdlog::set_default_logger(logger_);

}

SpdLogger::~SpdLogger()
{
    spdlog::info("...spdlog logging finished");
}

void SpdLogger::setup(const std::string& fileName, const std::string& logPattern,
                      const std::string& logLevel, const size_t maxFileSize,
                      const size_t maxNoFiles)
{
    spdlog::set_pattern(logPattern);

    spdlog::flush_on(spdlog::level::info);
    spdlog::flush_every(std::chrono::seconds(5));
    spdlog::set_level(spdlog::level::from_str(logLevel));

    spdlog::info("spdlog logging initiated...");
    spdlog::debug("Logger setup:");
    spdlog::debug("\tfile: {}", fileName);
    spdlog::debug("\tlevel: {}", logLevel);
    spdlog::debug("\tmaxFileSize: {}", maxFileSize);
    spdlog::debug("\tmaxNoFiles: {}", maxNoFiles);
}
