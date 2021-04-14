#pragma once

#include <QObject>

namespace strata::loggers
{
class QtLogger final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(QtLogger)

    explicit QtLogger(QObject* parent = nullptr);

public:
    static QtLogger& instance();

    static void MsgHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg);

signals:
    void logMsg(QtMsgType type, const QString& msg);
};

}  // namespace strata::loggers
