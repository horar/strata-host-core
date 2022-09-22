#pragma once

#include <QObject>

class LogLevel
{
    Q_GADGET
public:
    enum Value {
        LevelUnknown,
        LevelDebug,
        LevelInfo,
        LevelWarning,
        LevelError
    };
    Q_ENUM(Value)

private:
    explicit LogLevel();
};
