#pragma once

#include <QObject>
#include <QProcess>
#include <QCoreApplication>

class UpdateWatchdog : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString output READ output WRITE setOutput NOTIFY outputChanged)

public:
    explicit UpdateWatchdog(QObject *parent = nullptr);

    Q_INVOKABLE
    void checkForUpdate();
    Q_INVOKABLE
    void silentUpdate();
    Q_INVOKABLE
    void installComponent();

    QString output() const;

signals:
    void outputChanged(QString output);

public slots:

    void setOutput(QString output);

private:
    const QString maintenanceAppPath_{QString("%1/../../../maintenancetool.app/Contents/MacOS/maintenancetool").arg(QCoreApplication::applicationDirPath())};
    QString m_output;

    QProcess process_;
};

