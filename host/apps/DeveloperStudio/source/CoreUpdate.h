#pragma once

#include <QObject>
#include <QDir>

class CoreUpdate : public QObject
{
    Q_OBJECT

public:
    Q_INVOKABLE void requestUpdateApplication();

private:
    QString locateMaintenanceTool(const QDir &applicationDir);

    void performCoreUpdate(const QString &absPathMaintenanceTool, const QDir &applicationDir);
};
