#include "ImplementationInterfaceBinding.h"
#include "../../../include/zhelpers.hpp"

/*!
 * Constructor initialization
 * Initialize port voltages and current to NULL
 * Tie the respective signal and slots using connect
 */

ImplementationInterfaceBinding::ImplementationInterfaceBinding(QObject *parent) : QObject(parent) {

    hcc_object = new (hcc::HostControllerClient);
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
    platformState = false;

    // DocumentManager is a C++ model for QML objects and is a super class of QObject
    document_manager_ = static_cast<DocumentManager *>(parent);
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
    payloadObject.insert("loss_value", value);
    cmdMessageObject.insert("payload",payloadObject);
    QJsonDocument doc(cmdMessageObject);
    QString strJson(doc.toJson(QJsonDocument::Compact));
    if(hcc_object->sendCmd(strJson.toStdString()))
        qDebug() << "Radio button send";
    else
        qDebug() << "Radio button send failed";
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
float ImplementationInterfaceBinding::getinputVoltagePort0() {

    return Ports.v_tport[0];
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

/*!
 * Notification handlers
 * if there is any change in the newly received voltage from the
 * platform notify it to UI by emitting respective signals
 */

void ImplementationInterfaceBinding::handleNotification(QVariantMap current_map) {

    QVariantMap payloadMap;
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
        }  else {
            qDebug() << "Unsupported value field Received";
            qDebug() << "Received JSON = " <<current_map;
        }
    }
}

/*!
 * Notification handlers for cloud to UI
 * CLOUD JSON STRUCTURE
      {"cloud_sync":"document_set",
      "type" : "schematic",
      "documents":[
         {"data":*******","filename":"schematic15.png"}
       ]
      }
*/
void ImplementationInterfaceBinding::handleCloudNotification(QJsonObject json_obj) {
    // local variable declaration
    QList<QString> documents;
    QString viewer_type = json_obj.value("type").toString();  // Can be schematic, layout or assembly and so on

    // getting the json array
    QJsonArray document_array = json_obj["documents"].toArray();
    int document_array_size = document_array.size();

    // set the "list" size based on the received array size
    documents.reserve (document_array_size);

    // loop through the array and the data from cloud into the "list"
    foreach (const QJsonValue & image, document_array) {
        QJsonObject obj = image.toObject();
        QJsonDocument document_doc(obj);
        QString strJson(document_doc.toJson(QJsonDocument::Compact));
        documents.push_back (QString(strJson));
    }

    document_manager_->updateDocuments(viewer_type,documents);
}

/*!
 * \brief :
 *          @params: payloadMap map of usb_pd_power notification
 *                   parses and notifies the corresponding signal
 */
void ImplementationInterfaceBinding::handleUsbPowerNotification(const QVariantMap payloadMap) {

    // TODO [ian] needs error checking on json object parsing
    qDebug() << payloadMap;
    int port = payloadMap["port"].toInt();
#if !BOARD_DATA_SIMULATION
    float output_voltage = payloadMap["output"].toFloat();
    emit portOutputVoltageChanged(port, output_voltage);

    float target_voltage = payloadMap["target_volts"].toFloat();
    emit portTargetVoltageChanged(port, target_voltage);

    float current = payloadMap["current"].toFloat();
    emit portCurrentChanged(port, current);

    float power = payloadMap["power"].toFloat();
    emit portPowerChanged(port, power);

    float temperature = payloadMap["temperature"].toFloat();
    emit portTemperatureChanged(port, temperature);

    float input_voltage = payloadMap["input"].toFloat();
    emit portInputVoltageChanged(port, input_voltage);

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
    emit portInputVoltageChanged(portNumber,0);
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



/*!
 * End of notification handlers
 */


/*!
 * JSON Parser's
 */

//Convert the input QString in JSON format to JSON object
QJsonObject ImplementationInterfaceBinding::convertQstringtoJson(const QString string) {

    QByteArray json_String = string.toLocal8Bit();
    auto json_doc=QJsonDocument::fromJson(json_String);
    if(json_doc.isNull()){

        qDebug()<<"Failed to create JSON doc.";
        exit(2);
    }
    if(!json_doc.isObject()){
        qDebug()<<"JSON is not an object.";
        exit(3);
    }
    QJsonObject json_obj=json_doc.object();
    return json_obj;
}

//Get Keys of JSON object and store it in QStringList type object
QStringList ImplementationInterfaceBinding::getJsonObjectKeys(const QJsonObject json_obj) {

    QStringList list = json_obj.keys();
    return list;
}

//Convert JSON object to JSON map "to handle it like HASH Map"
QVariantMap ImplementationInterfaceBinding::getJsonMapObject(const QJsonObject json_obj) {

    QVariantMap json_map=json_obj.toVariantMap();
    return json_map;
}

//Validate Response from platform
QVariantMap ImplementationInterfaceBinding::validateJsonReply(const QVariantMap json_map) {

    QVariantMap current_map;
    if(json_map.contains("ack")) {

        current_map=json_map["ack"].toMap();
        //Methods to be included for handling acknowledgemnt
        qDebug() << "Acknowledgement Received for cmd = " << current_map ["cmd"].toString();
        qDebug() << "Validity = " << current_map ["response_verbose"].toString();
        qDebug() << "Port existence = " <<current_map["return_value"].toString();
        if(current_map["return_value"].toBool() == true) {

            registrationSuccessful = true;
        } else {
            registrationSuccessful = false;
        }
        return current_map;
    } else if(json_map.contains("notification")) {

        current_map = json_map["notification"].toMap();
        return current_map;
    } else {

//        qDebug() << "Unsupported command received from platform";
    }
    current_map.clear();
    return current_map;
}

/*!
 * End of JSON Parsers
 */


/*!
 *     Simulate JSON Messages and notify on changes
 */


void ImplementationInterfaceBinding::notificationsThreadHandle() {

    qDebug () << "Thread Created for notification ";
    notification_thread_running_ = true;

    while(notification_thread_running_) {
        /*
         *      CLOUD JSON STRUCTURE
            {"cloud_sync":"document_set",
              "type" : "schematic",
              "documents":[
                 {"data":*******","filename":"schematic15.png"}
                 ]
            }
         */
        //QTextStream stream( &file );

        // receive data from host controller client
        std::string response= hcc_object->receiveNotification();

        QString q_response = QString::fromStdString(response);

        // create the json document from the received string
        QJsonDocument doc= QJsonDocument::fromJson(q_response.toUtf8());
        QJsonObject json_obj=doc.object();

        // todo: [prasanth] needs better way to determine the handler

        // handler for cloud
        if(json_obj.contains("cloud_sync")) {
            qWarning() << "Notification Handler: Cloud";
            handleCloudNotification(json_obj);
        }
        // handler for platform
        else {
            QVariantMap json_map = getJsonMapObject(json_obj);
            json_map = getJsonMapObject(json_obj);
            QVariantMap current_map = validateJsonReply(json_map);
            if(current_map.contains("payload")) {
                handleNotification(current_map);
            }
        }
    }
}
