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
#include <QString>
#include <QJsonArray>
#include <thread>
#include <stdlib.h>
#include "../../../include/HostControllerClient.hpp"
#include "DocumentManager.h"

//aPort = Variable to store current
//vPort = Variable to store voltage

struct platform_Ports {

    float v_iport[2];
    float v_oport[2];
    float a_oport[2];
    float time[2];
    float power[2];
};


//void *simulateVoltageNotificationsThread(void *);

class ImplementationInterfaceBinding : public QObject
{
    Q_OBJECT
    //QProperty : Port 0 Voltage, Current, Time and Power properties
    Q_PROPERTY(float outputVoltagePort0 READ getoutputVoltagePort0 NOTIFY outputVoltagePort0Changed)
    Q_PROPERTY(float inputVoltagePort0 READ getinputVoltagePort0 NOTIFY inputVoltagePort0Changed)
    Q_PROPERTY(float outputCurrentPort0 READ getoutputCurrentPort0 NOTIFY outputCurrentPort0Changed)
    Q_PROPERTY(float time READ getPort0Time NOTIFY port0TimeChanged)
    Q_PROPERTY(float powerPort0 READ getpowerPort0  NOTIFY powerPort0Changed)

    //QProperty : To know Platform Status
    Q_PROPERTY(bool platformState READ getPlatformState NOTIFY platformStateChanged)

    //QProperty : Platform Id
    Q_PROPERTY(QString Id READ getPlatformId NOTIFY platformIdChanged)

    //QProperty : To know USB-C port status
    //Q_PROPERTY(bool usbcPort1 READ getUsbCPort1  NOTIFY usbCPort1StateChanged)
    //Q_PROPERTY(bool usbcPort2 READ getUsbCPort2  NOTIFY usbCPort2StateChanged)
public:

    explicit ImplementationInterfaceBinding(QObject *parent = nullptr);
    virtual ~ImplementationInterfaceBinding();

    std::thread notification_thread_;
    void notificationsThreadHandle();
//Getter invoked when GUI tries to get the data
    float getoutputVoltagePort0();
    float getinputVoltagePort0();
    float getoutputCurrentPort0();
    float getpowerPort0();
    float getPort0Time();
    bool getPlatformState();
    QString getPlatformId();
    //bool get

//Helper methods to handle QString to JSON conversion
    QJsonObject convertQstringtoJson(const QString string);
    QStringList getJsonObjectKeys(const QJsonObject json_obj);
    QVariantMap getJsonMapObject(const QJsonObject json_obj);
    QVariantMap validateJsonReply(const QVariantMap json_map);
    void handleUsbPowerNotification(const QVariantMap json_map);
    void handlePlatformIdNotification(const QVariantMap json_map);
    void handlePlatformStateNotification(const QVariantMap json_map);

//Notification Simulator
    friend void *simulateNotificationsThread(void *);
    //friend void *simulateCurrentNotificationsThread(void *);
    void handleNotification(QVariantMap current_map);
    void handleCloudNotification(QJsonObject json_obj);
    //void handleCurrentNotification(QVariantMap current_map);

//Signalling done when something needs to be notified
signals:
    void outputVoltagePort0Changed(const float outputVoltagePort0);
    void inputVoltagePort0Changed(const float inputVoltagePort0);
    void outputCurrentPort0Changed(const float outputCurrentPort0);
    void port0TimeChanged(const float time);
    void powerPort0Changed(const float powerPort0);
    void platformIdChanged(const QString platformId);
    void platformStateChanged(const bool platformState);

private:
    //Members private to class
    platform_Ports Ports;
    QString platformId;
    bool platformState, usbC_Port_1_State, usbC_Port_2_State;
    bool registrationSuccessful;
    DocumentManager *document_manager_;

public:
    hcc::HostControllerClient *hcc_object;
};


#endif // UserInterfaceBinding_H
