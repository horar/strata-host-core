#ifndef UserInterfaceBinding_H
#define UserInterfaceBinding_H

#include <QObject>
#include <QString>
#include <QKeyEvent>
#include <QDebug>
#include <QJsonObject>
#include <QJsonDocument>
#include <QQmlListProperty>
#include <QVariant>
#include <QStringList>
#include <QString>
#include <QJsonArray>
#include <string>
#include <thread>
#include <map>
#include <functional>
#include <stdlib.h>
#include "../../../include/HostControllerClient.hpp"  // TODO [ian] FIX THIS ... locally referenced files
#include <QMap>

// To simulate the data
#define BOARD_DATA_SIMULATION 0

//aPort = Variable to store current
//vPort = Variable to store voltage

using FaultMessages = QStringList;            // typedefs

struct platform_Ports {

    float v_tport[2];
    float v_oport[2];
    float a_oport[2];
    float temperature[2];
    float power[2];
    float v_iport[2];
};


//void *simulateVoltageNotificationsThread(void *);

typedef std::function<void(QJsonObject)> DataSourceHandler; // data source handler accepting QJsonObject

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
    Q_PROPERTY(float portNegotiatedContract NOTIFY portNegotiatedContractChanged)
    Q_PROPERTY(float portMaximumPower NOTIFY portMaximumPowerChanged)

    //QProperty for fault messages
    Q_PROPERTY(int  minimum_voltage NOTIFY minimumVoltageChanged)

    Q_PROPERTY(int over_temperature NOTIFY overTemperatureChanged)

    //QProperty : To know Platform Reset
    Q_PROPERTY(bool reset_status NOTIFY platformResetDetected)

    //QProperty : To know Platform Status
    Q_PROPERTY(bool platformState READ getPlatformState NOTIFY platformStateChanged)

    //QProperty : Platform Id
    Q_PROPERTY(e_MappedPlatformId Id READ getPlatformId NOTIFY platformIdChanged)

    //QProperty : To know USB-PDp- Port Status
    Q_PROPERTY(bool usbCPort1State  NOTIFY usbCPortStateChanged)

    //QProperty to show the swap cable status
    Q_PROPERTY(QString swapCable NOTIFY swapCableStatusChanged)

    //QProperty : To know USB-C port status
    //Q_PROPERTY(bool usbcPort1 READ getUsbCPort1  NOTIFY usbCPort1StateChanged)
    //Q_PROPERTY(bool usbcPort2 READ getUsbCPort2  NOTIFY usbCPort2StateChanged)

    //Qlist property to store all the active faults and fault history
    Q_PROPERTY(QStringList activeFaultsList READ activeFaults NOTIFY activeFaultsChanged)
    Q_PROPERTY(QStringList faultHistoryList READ faultHistory NOTIFY faultHistoryChanged)
public:

    // Enum for hardcode platforms;
    enum e_MappedPlatformId
    {
        NONE = 0,
        BUBU_INTERFACE,
        USB_PD,
    }PlatformNames;

    Q_ENUM(e_MappedPlatformId)

    explicit ImplementationInterfaceBinding(QObject *parent = nullptr);
    virtual ~ImplementationInterfaceBinding();

    Q_INVOKABLE void setOutputVoltageVBUS(int port, int voltage);

    Q_INVOKABLE void setRedriverLoss(float lossValue);
    Q_INVOKABLE void setRedriverConfiguration(QString value);
    Q_INVOKABLE void sendPlatformRefresh();
    Q_INVOKABLE bool getUSBCPortState(int port_number);





    // To set the maximum power request for a particular port in USB-PD platform
    Q_INVOKABLE void setMaximumPortPower(int port,int value);

    // To set the Minimum Input Voltage
    Q_INVOKABLE void setMinimumInputVoltage(int value);

    // To set the mode for fault protection for the board (shutdown/restart/none)
    Q_INVOKABLE void setFaultMode(QString faultModeAction);

    // To set input voltage foldback parameters (on/off, starting voltage, output wattage limit)
    Q_INVOKABLE void setVoltageFoldbackParameters(bool inEnabled,
                                                  float inVoltage,
                                                  int inWatts);

    //To set the temperature foldback parameters (on/off, starting temperature, output wattage limit)
    Q_INVOKABLE void setTemperatureFoldbackParameters(bool inEnabled,
                                                     float inTemperature,
                                                       int inWatts);

    //To set the input voltage that will trigger a fault when input falls below
    Q_INVOKABLE void setInputVoltageLimiting(float value);

    // To set the maximum temperature limit in platform
    Q_INVOKABLE void setMaximumTemperature(float value);

    //set the maximum current that can be drawn by a device connected to a port
    Q_INVOKABLE void setPortMaximumCurrent(int inPort,
                                           float inMaximumCurrent);

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
    e_MappedPlatformId getPlatformId();
    QStringList activeFaults() {return QStringList(active_faults_);}
    QStringList faultHistory() {return QStringList(fault_history_);}


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
    void handleInputUnderVoltageNotification(const QVariantMap payloadMap);
    void handleInputUnderVoltageValueNotification(const QVariantMap payloadMap);
    void handleOverTemperatureNotification(const QVariantMap payloadMap);
    void handleNegotiatedContractNotification(const QVariantMap payloadMap);
    void handleMaximumPortPowerNotification(const QVariantMap payloadMap);
    void handleFaultProtectionNotification(const QVariantMap json_map);
    void handleDataConfigurationNotification(const QVariantMap json_map);
    void handleFoldbackLimitingNotification(const QVariantMap json_map);
    void handleMaximumTemperatureNotification (const QVariantMap payloadMap);

//Constructing the string for fault messages
    QString constructFaultMessage(QString parameter,QString state,int value)
                                 {return QString(tr("%1 is %2 %3")).arg(parameter).arg(state).arg(value);}
    QString constructFaultMessage(QString parameter,QString state,int value,int port_number)
                                 {return QString(tr("%1 is %2 %3 for port %4")).arg(parameter).arg(state).arg(value).arg(port_number);}

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
    void portNegotiatedContractChanged(int port,float voltage,float maxCurrent);
    void portNegotiatedVoltageChanged(int port, float voltage);
    void portNegotiatedCurrentChanged(int port, float current);
    void portMaximumPowerChanged(int port, int watts);
    void faultProtectionChanged(QString protectionMode);
    void dataPathConfigurationChanged(QString dataConfiguration);
    void foldbackLimitingChanged(bool inputVoltageFoldbackEnabled,
                                 float inputVoltageFoldbackStartVoltage,
                                 int inputVoltageFoldbackOutputLimit,
                                 bool temperatureFoldbackEnabled,
                                 float temperatureFoldbackStartTemp,
                                 int temperatureFoldbackOutputLimit);
    void inputUnderVoltageChanged(float value);
    void maximumTemperatureChanged(float value)
;
    // fault messages notification
    void minimumVoltageChanged(bool state,int value);
    void overTemperatureChanged(bool state,int value);

    // fault message list notification
    void faultHistoryChanged();
    void activeFaultsChanged();

private:
    //Members private to class
    platform_Ports      Ports;
    e_MappedPlatformId  platformId;
    QString             rawPlatformId;
    bool                platformState,
                        usbCPort1State,
                        usbCPort2State;
    float               inputVoltage;
    bool                registrationSuccessful;
    bool                notification_thread_running_;
    float               port1Current,
                        port2Current;

    QMap<QString, e_MappedPlatformId> idMap;
    std::map<std::string, DataSourceHandler > data_source_handlers_;

    // For load board data simulation only
    float               targetVoltage;

    // Fault message lists
    FaultMessages active_faults_;
    FaultMessages fault_history_;

public:
    Spyglass::HostControllerClient *hcc_object;

    bool registerDataSourceHandler(std::string source, DataSourceHandler handler);

};


#endif // UserInterfaceBinding_H

