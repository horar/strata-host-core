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

// To simulate the data
#define BOARD_DATA_SIMULATION 0

//aPort = Variable to store current
//vPort = Variable to store voltage

struct platform_Ports {

    float v_tport[2];
    float v_oport[2];
    float a_oport[2];
    float temperature[2];
    float power[2];
    float v_iport[2];
};


//void *simulateVoltageNotificationsThread(void *);

class ImplementationInterfaceBinding : public QObject
{
    Q_OBJECT

    // QProperty for all ports 
    Q_PROPERTY(float outputVoltage NOTIFY portOutputVoltageChanged)
    Q_PROPERTY(float inputVoltage READ getInputVoltage NOTIFY portInputVoltageChanged)
    Q_PROPERTY(float targetVoltage NOTIFY portTargetVoltageChanged)
    Q_PROPERTY(float portTemperature NOTIFY portTemperatureChanged)
    Q_PROPERTY(float portCurrent NOTIFY portCurrentChanged)
    Q_PROPERTY(float portPower NOTIFY portPowerChanged)
    Q_PROPERTY(float inputPower NOTIFY portEfficiencyChanged)
    Q_PROPERTY(float outputPower NOTIFY portEfficiencyChanged)

    //QProperty : To know Platform Reset
    Q_PROPERTY(bool reset_status NOTIFY platformResetDetected)

    //QProperty : To know Platform Status
    Q_PROPERTY(bool platformState READ getPlatformState NOTIFY platformStateChanged)

    //QProperty : Platform Id
    Q_PROPERTY(QString Id READ getPlatformId NOTIFY platformIdChanged)

    //QProperty : To know USB-PDp- Port Status
    Q_PROPERTY(bool usbCPort1State  NOTIFY usbCPortStateChanged)

    //QProperty to show the swap cable status
    Q_PROPERTY(QString swapCable NOTIFY swapCableStatusChanged)

    //QProperty : To know USB-C port status
    //Q_PROPERTY(bool usbcPort1 READ getUsbCPort1  NOTIFY usbCPort1StateChanged)
    //Q_PROPERTY(bool usbcPort2 READ getUsbCPort2  NOTIFY usbCPort2StateChanged)
public:

    explicit ImplementationInterfaceBinding(QObject *parent = nullptr);
    virtual ~ImplementationInterfaceBinding();

    Q_INVOKABLE void setOutputVoltageVBUS(int port, int voltage);

    std::thread notification_thread_;
    void notificationsThreadHandle();
//Getter invoked when GUI tries to get the data
    float getoutputVoltagePort0();
    float getInputVoltage();
    float getoutputCurrentPort0();
    float getpowerPort0();
    float getPort0Temperature();
    bool getPlatformState();
    bool getUSBCPort1State();
    bool getUSBCPort2State();
    QString getPlatformId();

    Q_INVOKABLE void setRedriverLoss(float lossValue);
    Q_INVOKABLE void setRedriverCount(int value);
    QJsonObject convertQstringtoJson(const QString string);
    QStringList getJsonObjectKeys(const QJsonObject json_obj);
    QVariantMap getJsonMapObject(const QJsonObject json_obj);
    QVariantMap validateJsonReply(const QVariantMap json_map);
    void handleUsbPowerNotification(const QVariantMap json_map);
    void handlePlatformIdNotification(const QVariantMap json_map);
    void handlePlatformStateNotification(const QVariantMap json_map);
    void handleUSBCportConnectNotification(const QVariantMap json_map);
    void handleUSBCportDisconnectNotification(const QVariantMap json_map);
    void handleUSBPDcableswapNotification(const QVariantMap json_map);
    void handleInputVoltageNotification(const QVariantMap json_map);
    void handleResetNotification(const QVariantMap payloadMap);

//Notification Simulator
    friend void *simulateNotificationsThread(void *);
    //friend void *simulateCurrentNotificationsThread(void *);
    void handleNotification(QVariantMap current_map);
    void handleCloudNotification(QJsonObject json_obj);
    void clearBoardMetrics(int);
    //void handleCurrentNotification(QVariantMap current_map);

//Signalling done when something needs to be notified
signals:
    void outputVoltagePort0Changed(const float outputVoltagePort0);
    void inputVoltagePort0Changed(const float inputVoltage);
    void outputCurrentPort0Changed(const float outputCurrentPort0);
    void port0TemperatureChanged(const float time);
    void powerPort0Changed(const float powerPort0);
    void platformIdChanged(const QString platformId);
    void swapCableStatusChanged(const QString cableStatus);
    void platformStateChanged(const bool platformState);
    void usbCPortStateChanged(int port, const bool value);
    void platformResetDetected(bool reset_status);
    // port metrics notification
    void portOutputVoltageChanged(int port, float value);
    void portInputVoltageChanged(int port, float value);
    void portTargetVoltageChanged(int port, float value);
    void portTemperatureChanged(int port, float value);
    void portPowerChanged(int port, float value);
    void portCurrentChanged(int port, float value);
    void portEfficencyChanged(int port, float input_power,float output_power);
private:
    //Members private to class
    platform_Ports Ports;
    QString platformId;
    bool platformState, usbCPort1State, usbCPort2State;
    float inputVoltage;
    bool registrationSuccessful;
    DocumentManager *document_manager_;
    bool notification_thread_running_;

    // For load board data simulation only
    float targetVoltage;
public:
    hcc::HostControllerClient *hcc_object;
    float port1Current,port2Current;
};


#endif // UserInterfaceBinding_H
