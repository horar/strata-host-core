#pragma once

#include <QObject>
#include <QDir>

class CoreUpdate : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE QString requestUpdateApplication();

Q_SIGNALS:
    void applicationTerminationRequested();

private:
    QString locateMaintenanceTool(const QDir &applicationDir, QString &absPathMaintenanceTool);

    void performCoreUpdate(const QString &absPathMaintenanceTool, const QDir &applicationDir);
};
