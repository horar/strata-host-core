#pragma once

#include <QTest>
#include <QJsonObject>

class PlatformController;

class TestPlatformController : public QObject {
    Q_OBJECT
  public:
    TestPlatformController() {}

private slots:
    void initPlatformController();
    void testWaterHeaterAtributes();
    void testCommunication();
    void stressPlatform();

private:
    PlatformController* platformController_;
    QJsonObject payload_;
};
