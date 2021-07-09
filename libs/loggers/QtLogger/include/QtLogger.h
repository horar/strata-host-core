#pragma once

#include <QObject>

namespace strata::loggers
{
class QtLogger final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(QtLogger)
    Q_PROPERTY(bool visualEditorReloading MEMBER visualEditorReloading NOTIFY visualEditorReloadingChanged)

    explicit QtLogger(QObject* parent = nullptr);

public:
    static QtLogger& instance();

    static void MsgHandler(QtMsgType type, const QMessageLogContext& context, const QString& msg);

private:
    static bool visualEditorReloading;

signals:
    void logMsg(QtMsgType type, const QString& msg);
    void visualEditorReloadingChanged();
};

}  // namespace strata::loggers
