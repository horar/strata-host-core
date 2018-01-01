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
#include "HostControllerClient.hpp"
#include "DocumentManager.h"

using namespace HCC;

// To simulate the data
#define BOARD_DATA_SIMULATION 0
#define USB_NUM_PORTS         2     // todo move to config file

struct platform_port_data {
    float output_voltage;
    float input_voltage;
    float target_voltage;
    float temperature;
    float current;
    float power;
};

class ImplementationInterfaceBinding : public QObject
{
    Q_OBJECT

    // platform board connected status
    Q_PROPERTY(bool platformState READ getPlatformState NOTIFY platformStateChanged)

    // platform board unique id
    Q_PROPERTY(QString Id READ getPlatformId NOTIFY platformIdChanged)

public:

    ImplementationInterfaceBinding(DocumentManager * document_manager, HostControllerClient * host_controller_client);
    explicit ImplementationInterfaceBinding(QObject *parent = nullptr);
    virtual ~ImplementationInterfaceBinding();

    Q_INVOKABLE void setOutputVoltageVBUS(int port, int voltage);
    Q_INVOKABLE float getOutputVoltage(unsigned int port);
    Q_INVOKABLE float getInputVoltage(unsigned int port);
    Q_INVOKABLE float getOutputCurrent(unsigned int port);
    Q_INVOKABLE float getInputPower(unsigned int port);
    Q_INVOKABLE float getOutputPower(unsigned int port);
    Q_INVOKABLE float getTemperature(unsigned int port);
    Q_INVOKABLE bool getUSBCState(unsigned int port);

    Q_INVOKABLE bool getPlatformState();
    Q_INVOKABLE QString getPlatformId();

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

    std::thread notification_thread_;
    void notificationsThreadHandle();

    void handleNotification(QVariantMap current_map);
    void handleCloudNotification(QJsonObject json_obj);
    void clearBoardMetrics(int);

signals:
    void platformIdChanged(const QString platformId);
    void platformStateChanged(const bool platformState);
    void usbCPortStateChanged(int port, const bool value);

    // port metrics notification
    void portOutputVoltageChanged(int port, float value);
    void portInputVoltageChanged(int port, float value);
    void portTargetVoltageChanged(int port, float value);
    void portTemperatureChanged(int port, float value);
    void portPowerChanged(int port, float value);
    void portCurrentChanged(int port, float value);
    void portEfficencyChanged(int port, float input_power,float output_power);

private:
    platform_port_data port_data[USB_NUM_PORTS];
    QString platformId;
    bool platformState;
    bool USBCPortState[USB_NUM_PORTS];
    bool registrationSuccessful;
    bool notification_thread_running_;

    HCC::HostControllerClient *host_controller_client_;
    DocumentManager *document_manager_;

public:
    ImplementationInterfaceBinding(ImplementationInterfaceBinding const&) = delete;
    void operator=(ImplementationInterfaceBinding const&) = delete;
};


#endif // UserInterfaceBinding_H
