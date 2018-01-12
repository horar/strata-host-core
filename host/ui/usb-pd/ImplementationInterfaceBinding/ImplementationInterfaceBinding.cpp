#include "ImplementationInterfaceBinding.h"
#include "../../../include/zhelpers.hpp"    // TODO [ian] next guy/gal that uses a relative file location is going to get the Walk of Shame

using namespace std;
using namespace Spyglass;

/*!
 * Constructor initialization
 * Initialize port voltages and current to NULL
 * Tie the respective signal and slots using connect
 */

ImplementationInterfaceBinding::ImplementationInterfaceBinding(QObject *parent) : QObject(parent) {

    hcc_object = new (HostControllerClient);
    Ports.a_oport[0]='\0';
    Ports.a_oport[1]='\0';
    Ports.v_oport[0]='\0';
    Ports.v_oport[1]='\0';
    Ports.v_tport[0]='\0';
    Ports.v_tport[1]='\0';
    Ports.temperature[0]='\0';
    Ports.temperature[0]='\0';
    Ports.power[0]='\0';
    Ports.power[1]='\0';
    platformId= QString();

#ifdef QT_NO_DEBUG
    platformState = false;
#else
    // Debug builds should not need a platform board
    platformState = true;
#endif

    notification_thread_= std::thread(&ImplementationInterfaceBinding::notificationsThreadHandle,this);

#if BOARD_DATA_SIMULATION
    // Simulation for load board data only
    targetVoltage = 5;
#endif

}

ImplementationInterfaceBinding::~ImplementationInterfaceBinding() {

    hcc_object->notificationSocket->close();
    hcc_object->sendCmdSocket->close();
    zmq_term(hcc_object->context);
    delete(hcc_object);
    notification_thread_.detach();
}

void ImplementationInterfaceBinding::setOutputVoltageVBUS(int port, int voltage)
{
    qDebug("ImplementationInterfaceBinding::setOutputVoltageVBUS(%d, %d)", port, voltage);

    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("cmd", "request_usb_pd_output_voltage");
    QJsonObject payloadObject;
    payloadObject.insert("port", port);
    payloadObject.insert("Volts", voltage);
    cmdMessageObject.insert("payload",payloadObject);
    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    if(port == 1) {
        if(hcc_object->sendCmd(strJson.toStdString()))
            qDebug() << "Radio button send";
        else
            qDebug() << "Radio button send failed";
    }
    if(port == 2) {
        if(hcc_object->sendCmd(strJson.toStdString()))
            qDebug() << "Radio button send";
        else
            qDebug() << "Radio button send failed";
    }


#if BOARD_DATA_SIMULATION
    // For load board data simulation only
    targetVoltage = voltage;
#endif
}

void ImplementationInterfaceBinding::setRedriverLoss(float lossValue)
{
    qDebug("ImplementationInterfaceBinding::setRedriverLoss(%f)", lossValue);
    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("cmd", "request_redriver_signal_loss");
    QJsonObject payloadObject;
    payloadObject.insert("loss_value", lossValue);
    cmdMessageObject.insert("payload",payloadObject);
    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    if(hcc_object->sendCmd(strJson.toStdString()))
        qDebug() << "Radio button send";
    else
        qDebug() << "Radio button send failed";
}

void ImplementationInterfaceBinding::setRedriverCount(int value)
{
    qDebug("ImplementationInterfaceBinding::setRedriverCount(%d)", value);
    QJsonObject cmdMessageObject;
    cmdMessageObject.insert("cmd", "request_redriver_count");
    QJsonObject payloadObject;
    payloadObject.insert("value", value);
    cmdMessageObject.insert("payload",payloadObject);
    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    if(hcc_object->sendCmd(strJson.toStdString()))
        qDebug() << "Radio button send" << doc;
    else
        qDebug() << "Radio button send failed";
}


bool ImplementationInterfaceBinding::getUSBCPortState(int port_number)
{
    switch(port_number) {
    case 1: return usbCPort1State; break;
    case 2: return usbCPort2State; break;
    }
    return false;
}

/*!
 * Getter and Setter methods, used for retriving/writing something to/from platform
 * Retreived/set value is indidcated by function name.
 * For instance getVoltagePort0 gets voltage of port 0 from
 * the platform
 */

/*! \brief gets the cached voltage of port 0
 */

float ImplementationInterfaceBinding::getoutputVoltagePort0() {

    qDebug() << "getting port 0 voltage";
    return Ports.v_oport[0];
}

/*! \brief gets the cached voltage of port 1
 */
float ImplementationInterfaceBinding::getInputVoltage() {

    return inputVoltage;
}

/*! \brief gets the cached current of port 0
 */
float ImplementationInterfaceBinding::getoutputCurrentPort0() {

    return Ports.a_oport[0];
}

float ImplementationInterfaceBinding::getPort0Temperature() {

    return Ports.temperature[0];
}

float ImplementationInterfaceBinding::getpowerPort0() {

    return Ports.power[0];
}

/*!
 * \brief update the platform Id
 */
QString ImplementationInterfaceBinding::getPlatformId() {

    return platformId;
}

/*!
 * \brief get platform connection state
 */
bool ImplementationInterfaceBinding::getPlatformState() {

    return platformState;
}

/*!
 * \brief get USB PD port 1 connection state
 */
bool ImplementationInterfaceBinding::getUSBCPort1State() {
    //usbCPortState[0] = usbCPort1State;
//    usbCPortState[1] = usbCPort2State;
    return usbCPort1State;
}

/*!
 * \brief get USB PD port 2 connection state
 */
bool ImplementationInterfaceBinding::getUSBCPort2State() {

    return usbCPort2State;
}

/*!
 * End of Getter and Setter Methods
 */


bool ImplementationInterfaceBinding::registerDataSourceHandler(std::string source, DataSourceHandler handler)
{
    qDebug("ImplementationInterfaceBinding::registerDataSourceHanlder:"
              "source=%s", source.c_str());

    auto search = data_source_handlers_.find(source);
    if( search != data_source_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::registerDataSourceHanlder:"
                  " ERROR: handler already exits for %s !!", source.c_str ());
        return false;
    }

    data_source_handlers_.emplace(std::make_pair(source, handler));

    // notify Host Controller Service of the data source connection
    // QJsonObject cmd;
    // cmd.insert("db::cmd", "request_usb_pd_output_voltage");

    // QJsonObject payload;
    // payload.insert("port", port);
    // payload.insert("Volts", voltage);
    // command.insert("payload",payload);
    // hcc_object->sendCmd(QString(QJsonDocument(cmd).toJson(QJsonDocument::Compact)).toStdString());
    return true;
}

/*!
 * Notification handlers
 * if there is any change in the newly received voltage from the
 * platform notify it to UI by emitting respective signals
 */

// TODO [ian] move handleNotification "dispatching" to use DataSourceHandlers
//
//  EXAMPLE implementation
//
//void ImplementationInterfaceBinding::handleNotification(QVariantMap current_map) // TODO [ian] why is this a QVariantMap and not a JSON object?
//{
//    QVariantMap payloadMap;
//    if(current_map.contains("value")) {
//
//        std::string notification = current_map["value"].toString().toStdString();
//        auto handler = data_source_handlers_.find(source);
//        if( handler == data_source_handlers_.end()) {
//            qCritical("ImplementationInterfaceBinding::handleNotification"
//                      " ERROR: no handler exits for %s !!", notification.c_str ());
//            return;
//        }
//
//        handler->second(current_map["payload"].toMap());  // dispatch handler for notification
//    }
//}

void ImplementationInterfaceBinding::handleNotification(QVariantMap current_map) {

    QVariantMap payloadMap;

    // TODO FIX [ian] why is the "notification" keyword called "value"??!!
    if(current_map.contains("value")) {
        if(current_map["value"] == "request_usb_power_notification") {
            payloadMap = current_map["payload"].toMap();
            handleUsbPowerNotification(payloadMap);
        } else if(current_map["value"] == "platform_id") {
            payloadMap = current_map["payload"].toMap();
            handlePlatformIdNotification(payloadMap);
        } else if (current_map["value"] == "platform_connection_change_notification"){
            payloadMap=current_map["payload"].toMap();
            handlePlatformStateNotification(payloadMap);
        } else if (current_map["value"] == "usb_pd_port_connect"){
            payloadMap=current_map["payload"].toMap();
            handleUSBCportConnectNotification(payloadMap);
        } else if (current_map["value"] == "usb_pd_port_disconnect"){
            payloadMap=current_map["payload"].toMap();
            handleUSBCportDisconnectNotification(payloadMap);
        } else if (current_map["value"] == "usb_pd_cable_swap_notification"){
            payloadMap=current_map["payload"].toMap();
            handleUSBPDcableswapNotification(payloadMap);
        } else if (current_map["value"] == "request_input_voltage_notification"){
            payloadMap=current_map["payload"].toMap();
            handleInputVoltageNotification(payloadMap);
        } else if (current_map["value"] == "request_reset_notification"){
            payloadMap=current_map["payload"].toMap();
            handleResetNotification(payloadMap);
        } else {
            qDebug() << "Unsupported value field Received";
            qDebug() << "Received JSON = " <<current_map;
        }
    }
}

/*
  Notification handlers for cloud to UI
  CLOUD JSON STRUCTURE
{
  "cloud_sync": "document_set",
  "type": "schematic",
  "documents": [
    {
      "data": "*******",
      "filename": "schematic15.png"
    }
  ]
}

{
  "cloud::notification": {
    "type": "document",
    "name": "schematic",
    "documents": [
      {"data": "*******","filename": "schematic1.png"},
      {"data": "*******","filename": "schematic1.png"}
    ]
  }
}

{
  "cloud::notification": {
    "type": "marketing",
    "name": "adas_sensor_fusion",
    "data": "raw html"
  }
}

*/
void ImplementationInterfaceBinding::handleCloudNotification(QJsonObject json_obj)
{
    if( json_obj.contains("cloud::notification") == false ) {
        qCritical("ImplementationInterfaceBinding::handleCloudNotification"
                  " ERROR: cloud_sync argument does not exist!!");
        return;
    }

    // data source type: document_set, chat, marketing et al
    QJsonObject payload = json_obj["cloud::notification"].toObject();
    string type = payload.value("type").toString().toStdString();

    auto handler = data_source_handlers_.find(type);
    if( handler == data_source_handlers_.end()) {
        qCritical("ImplementationInterfaceBinding::handleNotification"
                  " ERROR: no handler exits for %s !!", type.c_str ());
        return;
    }

    handler->second(payload);  // dispatch handler for notification

}

/*!
 * \brief :
 *          @params: payloadMap map of usb_pd_power notification
 *                   parses and notifies the corresponding signal
 */
void ImplementationInterfaceBinding::handleUsbPowerNotification(const QVariantMap payloadMap) {

    // TODO [ian] needs error checking on json object parsing
//    qDebug() << payloadMap;
    int port = payloadMap["port"].toInt();
#if !BOARD_DATA_SIMULATION
    float output_voltage = payloadMap["output"].toFloat();
    emit portOutputVoltageChanged(port, output_voltage);

    float target_voltage = payloadMap["target_volts"].toFloat();
    emit portTargetVoltageChanged(port, target_voltage);

    float current = payloadMap["current"].toFloat();

    if(port == 1) {
        port1Current = current;
    }
    if(port == 2) {
        port2Current = current;
    }

    if(usbCPort2State && usbCPort2State)
        emit portCurrentChanged(port, port2Current+port1Current);
    else if(usbCPort1State && !usbCPort2State)
        emit portCurrentChanged(port, port1Current);
    else if(!usbCPort1State && usbCPort2State)
        emit portCurrentChanged(port, port2Current);

    float power = payloadMap["power"].toFloat();
    emit portPowerChanged(port, power);

    float temperature = payloadMap["temperature"].toFloat();
    emit portTemperatureChanged(port, temperature);

    float input_voltage = payloadMap["input"].toFloat();
    emit portEfficencyChanged(port, input_voltage*current, power);
#else
// For load board data simulation only
    float output_voltage = targetVoltage +  static_cast <float> ((rand()%10)/10);
    emit portOutputVoltageChanged(port, output_voltage);

    float target_voltage = targetVoltage; //payloadMap["target_volts"].toFloat();
    emit portTargetVoltageChanged(port, target_voltage);

    float current = 2.5;//payloadMap["current"].toFloat();
    emit portCurrentChanged(port, current);

    float power = current*output_voltage;//payloadMap["power"].toFloat();
    emit portPowerChanged(port, power);

    float temperature = 27;//payloadMap["temperature"].toFloat();
    emit portTemperatureChanged(port, temperature);

    float input_voltage = payloadMap["input"].toFloat();
    emit portInputVoltageChanged(port, input_voltage);

#endif

}

void ImplementationInterfaceBinding::handlePlatformIdNotification(const QVariantMap payloadMap) {

    if (payloadMap.contains("platform_id")){

        QString platformIdTemp = payloadMap["platform_id"].toString();
        qDebug() << "Received platformId = " << platformId;
        if(platformIdTemp != platformId) {

            platformState=true;
            emit platformStateChanged(platformState);
            platformId = platformIdTemp;
            emit platformIdChanged(platformId);
            qDebug() << "PlatformIdChanged notification";
        }
    }
}

void ImplementationInterfaceBinding::handlePlatformStateNotification(const QVariantMap payloadMap) {

    QString status = payloadMap["status"].toString();
//    qDebug() << "Status =" << payloadMap;
    if (status.compare("connected") == 0){

        bool platformStateTemp = true;
// TODO[Prasanth]: Needs code cleaning
        if(platformStateTemp != platformState) {

            platformState = platformStateTemp;
            emit platformStateChanged(platformState);
            qDebug() << "platformStateChanged notification";
        }
    } else if (status.compare("disconnected") == 0) {

        bool platformStateTemp = false;
// TODO[Prasanth]: Needs code cleaning
        if(platformStateTemp != platformState) {

            platformState = platformStateTemp;
            emit platformStateChanged(platformState);
            qDebug() << "platformStateChanged notification";
        }
    } else {

//        qDebug() << "Unsupported PlatformState ";
    }
}

void ImplementationInterfaceBinding::handleUSBCportConnectNotification(const QVariantMap payloadMap) {
    QString usbCPortId = payloadMap["port_id"].toString();
    QString connection_state = payloadMap["connection_state"].toString();

    if (connection_state.compare("connected") == 0) {
        if (usbCPortId.compare("USB_C_port_1") == 0) {

            usbCPort1State =  true;
            emit usbCPortStateChanged(1,usbCPort1State);
        }
        else if(usbCPortId.compare("USB_C_port_2") == 0) {
            usbCPort2State =  true;
            emit usbCPortStateChanged(2,usbCPort2State);
        }
        else {
            qDebug() << "Unsupported Connection USBC connection state";
        }
    }
}

/*!
 * \brief :
 *          @params: USB C port number
 *                   emits 0 to all the board parameters when the port is disconnected
 */
void ImplementationInterfaceBinding::clearBoardMetrics(int portNumber){

    emit portOutputVoltageChanged(portNumber,0);
    emit portTargetVoltageChanged(portNumber,0);
    emit portPowerChanged(portNumber,0);
    emit portCurrentChanged(portNumber,0);
    emit portTemperatureChanged(portNumber,0);
//    emit portInputVoltageChanged(portNumber,0); // TODO FIXME [ian] why is this commented out?
}


void ImplementationInterfaceBinding::handleUSBCportDisconnectNotification(const QVariantMap payloadMap) {
    QString usbCPortId = payloadMap["port_id"].toString();
    QString connection_state = payloadMap["connection_state"].toString();

    if (connection_state.compare("disconnected") == 0) {
        if (usbCPortId.compare("USB_C_port_1") == 0) {
            usbCPort1State =  false;
            emit usbCPortStateChanged(1,usbCPort1State);
            // TODO:[Prasanth] Needs to dynamically pass the port number
            clearBoardMetrics(1);
        }
        else if(usbCPortId.compare("USB_C_port_2") == 0) {
            usbCPort2State =  false;
            emit usbCPortStateChanged(2,usbCPort2State);
            clearBoardMetrics(2);
        }
        else {
            qDebug() << "Unsupported Connection USBC connection state";
        }
    }
}

void ImplementationInterfaceBinding::handleUSBPDcableswapNotification(const QVariantMap json_map) {
    QString swapCable = json_map["swap_cable"].toString();
    emit swapCableStatusChanged(swapCable);
    qDebug() << "cable notification "<<swapCable;
}

void ImplementationInterfaceBinding::handleInputVoltageNotification(const QVariantMap json_map) {
    float input_voltage = json_map["input"].toFloat();
    inputVoltage = input_voltage;
    emit portInputVoltageChanged(1, inputVoltage);
}

void ImplementationInterfaceBinding::handleResetNotification(const QVariantMap payloadMap) {
    bool status = payloadMap["reset_status"].toBool();
    if(status) {
        emit platformResetDetected(status);
    }
}
/*!
 * End of notification handlers
 */


/*!
 * JSON Parser's
 */

//Convert JSON object to JSON map "to handle it like HASH Map"
QVariantMap ImplementationInterfaceBinding::getJsonMapObject(const QJsonObject json_obj)
{

    QVariantMap json_map=json_obj.toVariantMap();
    return json_map;
}

//Validate Response from platform
QVariantMap ImplementationInterfaceBinding::validateJsonReply(const QVariantMap json_map)
{
    QVariantMap current_map;
    if(json_map.contains("ack")) {
        current_map=json_map["ack"].toMap();

        qDebug() << "Acknowledgement Received for cmd = " << current_map ["cmd"].toString();
        qDebug() << "Validity = " << current_map ["response_verbose"].toString();
        qDebug() << "Port existence = " << current_map["return_value"].toString();
        if(current_map["return_value"].toBool() == true) {
            registrationSuccessful = true;
        }
        else {
            registrationSuccessful = false;
        }
        return current_map;
    }
    else if(json_map.contains("notification")) {
        current_map = json_map["notification"].toMap();
        return current_map;
    }
    else {
        qCritical("ERROR: invalid 'ack' reply !!!!");
        if( json_map.isEmpty() ) {
            qCritical("ERROR: Platform Reply is empty");
        }
    }
    current_map.clear();
    return current_map;
}

/*!
 * End of JSON Parsers
 */

void ImplementationInterfaceBinding::notificationsThreadHandle()
{

    qDebug () << "Thread Created for notification ";
    notification_thread_running_ = true;

    while(notification_thread_running_) {

#if USE_DEBUG_JSON
        // FIXME debugging/testing only. REMOVE BEFORE COMMIT
        QString raw = R"(
                      {
                         "cloud_sync":"document_set",
                         "type" : "schematic",
                         "documents":[
                            {"data":"*******","filename":"schematic1.png"},
                      {"data":"******1","filename":"schematic1.png"},
                      {"data":"******2","filename":"schematic2.png"},
                      {"data":"******3","filename":"schematic3.png"},
                      {"data":"******4","filename":"schematic4.png"},
                      {"data":"******5","filename":"schematic5.png"},
                      {"data":"******6","filename":"schematic6.png"}

                         ]
                      })";

        QJsonDocument doc = QJsonDocument::fromJson(raw.toUtf8());
        handleCloudNotification(doc.object());
        // end FIXME

        sleep(5);
#endif

        // receive data from host controller client
        std::string response= hcc_object->receiveNotification();

        QString q_response = QString::fromStdString(response);
        QJsonDocument doc= QJsonDocument::fromJson(q_response.toUtf8());
        QJsonObject json_obj=doc.object();

        // todo: [prasanth] needs better way to determine the handler
        // handler for cloud
        if(json_obj.contains("cloud::notification")) {
            qWarning() << "Notification Handler: Cloud";
            handleCloudNotification(json_obj);
        }
        else {
            // handler for platform
            QVariantMap json_map = getJsonMapObject(json_obj);
            json_map = getJsonMapObject(json_obj);
            QVariantMap current_map = validateJsonReply(json_map);
            if(current_map.contains("payload")) {
                handleNotification(current_map);
            }
        }
    }
}

