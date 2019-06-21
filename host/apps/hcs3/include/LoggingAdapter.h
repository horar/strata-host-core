#ifndef HOST_LOGGINGINTERFACE_H
#define HOST_LOGGINGINTERFACE_H

#include <string>

class LoggingAdapter final
{
public:
    enum LogLevel {
        eLvlDebug = 0,      //QtDebugMsg
        eLvlInfo,           //QtInfoMsg
        eLvlWarning,        //QtWarningMsg
        eLvlCritical,       //QtCriticalMsg
        eLvlFatal           //QtFatalMsg
    };

public:
    LoggingAdapter() = default;

    /**
     * Logging function for pure C++ code (without QT)
     * @param level log level see enum LogLevel
     * @param log_text logging text
     */
    void Log(LogLevel level, const std::string& log_text);

};

#endif //HOST_LOGGINGINTERFACE_H
