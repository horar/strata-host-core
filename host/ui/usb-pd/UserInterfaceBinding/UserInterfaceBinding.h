#ifndef UserInterfaceBinding_H
#define UserInterfaceBinding_H

#include <QObject>
#include <QString>
#include <QKeyEvent>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>
#include <QStringList>
#include <sys/socket.h>
#include <QString>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
#include <HostControllerClient.h>

//aPort = Variable to store current
//vPort = Variable to store voltage

struct platform_Ports {

    float v_iport[2];
    float v_oport[2];
    float a_oport[2];
    float time[2];
    float power[2];
};

void *notificationsThreadHandle(void *);
//void *simulateVoltageNotificationsThread(void *);

class UserInterfaceBinding : public QObject
{
    Q_OBJECT
    //QProperty : Port 0 Voltage, Current, Time and Power properties
    Q_PROPERTY(float outputVoltagePort0 READ getoutputVoltagePort0 NOTIFY outputVoltagePort0Changed)
    Q_PROPERTY(float inputVoltagePort0 READ getinputVoltagePort0 NOTIFY inputVoltagePort0Changed)
    Q_PROPERTY(float outputCurrentPort0 READ getoutputCurrentPort0 NOTIFY outputCurrentPort0Changed)
    Q_PROPERTY(float time READ getPort0Time NOTIFY port0TimeChanged)
    Q_PROPERTY(float powerPort0 READ getpowerPort0  NOTIFY powerPort0Changed)

    //QProperty : Platform Id
    Q_PROPERTY(QString Id READ getPlatformId NOTIFY platformIdChanged)


public:
    explicit UserInterfaceBinding(QObject *parent = nullptr);

//Getter invoked when GUI tries to get the data
    float getoutputVoltagePort0();
    float getinputVoltagePort0();
    float getoutputCurrentPort0();
    float getpowerPort0();
    float getPort0Time();
    QString getPlatformId();

//Helper methods to handle QString to JSON conversion
    QJsonObject convertQstringtoJson(const QString string);
    QStringList getJsonObjectKeys(const QJsonObject json_obj);
    QVariantMap getJsonMapObject(const QJsonObject json_obj);
    QVariantMap validateJsonReply(const QVariantMap json_map);
    void handleUsbPowerNotification(const QVariantMap json_map);
    void handlePlatformIdNotification(const QVariantMap json_map);

//Notification Simulator
    friend void *simulateNotificationsThread(void *);
    //friend void *simulateCurrentNotificationsThread(void *);
    void handleNotification(QVariantMap current_map);
    //void handleCurrentNotification(QVariantMap current_map);

//Signalling done when something needs to be notified
signals:
    void outputVoltagePort0Changed(const float outputVoltagePort0);
    void inputVoltagePort0Changed(const float inputVoltagePort0);
    void outputCurrentPort0Changed(const float outputCurrentPort0);
    void port0TimeChanged(const float time);
    void powerPort0Changed(const float powerPort0);
    void platformIdChanged(const QString platformId);

private:
    //Members private to class
    platform_Ports Ports;
    pthread_t notificationThread;
    QString platformId;
    bool registrationSuccessful;

public:
    HostControllerClient HCCObj;
};


#endif // UserInterfaceBinding_H
