#pragma once

#include <QObject>

class QSocketNotifier;


class SignalHandlers final : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(SignalHandlers)

public:
    explicit SignalHandlers(QObject *parent = nullptr);
    ~SignalHandlers() = default;

    static void intSignalHandler(int);
    static void termSignalHandler(int);

public slots:
    void handleSigInt();
    void handleSigTerm();

signals:

private:
    static int sigintFd[2];
    static int sigtermFd[2];

    QSocketNotifier *snInt_;
    QSocketNotifier *snTerm_;
};
