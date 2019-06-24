#ifndef HOST_LOGGINGINTERFACE_H
#define HOST_LOGGINGINTERFACE_H

#include <string>

class QLoggingCategory;

class LoggingAdapter final
{
public:
    enum LogLevel {
        eLvlDebug = 0,      //QtDebugMsg
        eLvlInfo,           //QtInfoMsg
        eLvlWarning,        //QtWarningMsg
        eLvlCritical,       //QtCriticalMsg
    };

public:
    LoggingAdapter(const char* log_category);
    ~LoggingAdapter();

    /**
     * Logging function for pure C++ code (without QT)
     * @param level log level see enum LogLevel
     * @param log_text logging text
     */
    void Log(LogLevel level, const std::string& log_text);

private:
    QLoggingCategory* category_;

};

#endif //HOST_LOGGINGINTERFACE_H
