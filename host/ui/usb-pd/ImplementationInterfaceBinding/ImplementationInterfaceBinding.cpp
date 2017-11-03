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
    Ports.v_iport[0]='\0';
    Ports.v_iport[1]='\0';
    Ports.time[0]='\0';
    Ports.time[0]='\0';
    Ports.power[0]='\0';
    Ports.power[1]='\0';
    platformId= QString();
    platformState = false;
    // DocumentManager is a C++ model for QML objects and is a super class of QObject
    document_manager_ = static_cast<DocumentManager *>(parent);
    notification_thread_= std::thread(&ImplementationInterfaceBinding::notificationsThreadHandle,this);
}

ImplementationInterfaceBinding::~ImplementationInterfaceBinding() {

    hcc_object->notificationSocket->close();
    hcc_object->sendCmdSocket->close();
    zmq_term(hcc_object->context);
    delete(hcc_object);
    notification_thread_.detach();

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

    return Ports.v_iport[0];
}

/*! \brief gets the cached current of port 0
 */
float ImplementationInterfaceBinding::getoutputCurrentPort0() {

    return Ports.a_oport[0];
}

float ImplementationInterfaceBinding::getPort0Time() {

    return Ports.time[0];
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
        if(current_map["value"] == "usb_pd_power") {

            payloadMap = current_map["payload"].toMap();
            handleUsbPowerNotification(payloadMap);
        } else if(current_map["value"] == "platform_id") {
            payloadMap = current_map["payload"].toMap();
            handlePlatformIdNotification(payloadMap);
        } else if (current_map["value"] == "platform_connection_change_notification"){
            payloadMap=current_map["payload"].toMap();
            handlePlatformStateNotification(payloadMap);
        }else {
            qDebug() << "Unsupported value field Received";
            qDebug() << "Received JSON = " <<current_map;
        }
    }
}

/*!
 * Notification handlers for cloud to UI
 */
void ImplementationInterfaceBinding::handleCloudNotification(QJsonObject json_obj) {
    QList<QString> documents;
    QJsonArray assembly_array = json_obj["schematic"].toArray();
    int schematic_array_size = assembly_array.size();
    documents.reserve (schematic_array_size);
    foreach (const QJsonValue & assembly_image, assembly_array)
    {
        QJsonObject obj = assembly_image.toObject();
        QJsonDocument assembly_doc(obj);
        QString strJson(assembly_doc.toJson(QJsonDocument::Compact));
        documents.push_back (QString(strJson));
    }
    document_manager_->updateDocuments("schematic",documents);
}
/*!
 * \brief :
 *          @params: payloadMap map of usb_pd_power notification
 *                   parses and notifies the corresponding signal
 */
void ImplementationInterfaceBinding::handleUsbPowerNotification(const QVariantMap payloadMap) {

    int port = payloadMap["port"].toInt();

    if(port == 0) {

        if(Ports.v_oport[0] != payloadMap["output"].toFloat()) {
            Ports.v_oport[0] = payloadMap["output"].toFloat();
            emit outputVoltagePort0Changed(Ports.v_oport[0]);
        }

        if(Ports.v_iport[0] != payloadMap["input"].toFloat()) {
            Ports.v_iport[0] = payloadMap["input"].toFloat();
            emit inputVoltagePort0Changed(Ports.v_iport[0]);
        }

        if(Ports.a_oport[0] != payloadMap["current"].toFloat()) {
            Ports.a_oport[0] = payloadMap["current"].toFloat();
            emit outputCurrentPort0Changed(Ports.a_oport[0]);
        }

        if(Ports.power[0] != payloadMap["power"].toFloat()) {
            Ports.power[0] = payloadMap["power"].toFloat();
            emit powerPort0Changed(Ports.power[0]);
        }
        if(Ports.time[0] != payloadMap["time"].toFloat()) {
            Ports.time[0] = payloadMap["time"].toFloat();
            emit port0TimeChanged(Ports.time[0]);
        }

    }  else if(port == 1) {

        if(Ports.v_oport[1] != payloadMap["output"].toFloat()) {
            Ports.v_oport[1] = payloadMap["output"].toFloat();
            emit outputVoltagePort0Changed(Ports.v_oport[1]);
        }

        if(Ports.v_iport[1] != payloadMap["input"].toFloat()) {
            Ports.v_iport[1] = payloadMap["input"].toFloat();
            emit inputVoltagePort0Changed(Ports.v_iport[1]);
        }

        if(Ports.a_oport[1] != payloadMap["current"].toFloat()) {
            Ports.a_oport[1] = payloadMap["current"].toFloat();
            emit outputCurrentPort0Changed(Ports.a_oport[1]);
        }

        if(Ports.power[1] != payloadMap["power"].toFloat()) {
            Ports.power[1] = payloadMap["power"].toFloat();
            emit powerPort0Changed(Ports.power[1]);
        }
        if(Ports.time[1] != payloadMap["time"].toFloat()) {
            Ports.time[1] = payloadMap["time"].toFloat();
            emit port0TimeChanged(Ports.time[1]);
        }

    }
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
    qDebug() << "Status =" << payloadMap;
    if (status.compare("connected") == 0){

        bool platformStateTemp = true;
        if(platformStateTemp != platformState) {

            platformState = platformStateTemp;
            emit platformStateChanged(platformState);
            qDebug() << "platformStateChanged notification";
        }
    } else if (status.compare("disconnected") == 0) {

        bool platformStateTemp = false;
        if(platformStateTemp != platformState) {

            platformState = platformStateTemp;
            emit platformStateChanged(platformState);
            qDebug() << "platformStateChanged notification";
        }
    } else {

        qDebug() << "Unsupported PlatformState ";
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

        qDebug() << "Unsupported command received from platform";
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

    while(1) {

        //QTextStream stream( &file );
        std::string response= hcc_object->receiveNotification();
        QString q_response = QString::fromStdString(response);
        QJsonDocument doc= QJsonDocument::fromJson(q_response.toUtf8());
        QJsonObject json_obj=doc.object();
        if(json_obj.contains("command")) {
            qWarning() << "Notification Handler: Cloud";
            handleCloudNotification(json_obj);
        }
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
