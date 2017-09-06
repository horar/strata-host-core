#include <UserInterfaceBinding.h>


/*!
 * Constructor initialization
 * Initialize port voltages and current to NULL
 * Tie the respective signal and slots using connect
 */

UserInterfaceBinding::UserInterfaceBinding(QObject *parent) : QObject(parent) {

    Ports.a_oport[0]=-1;
    Ports.a_oport[1]=-1;
    Ports.v_oport[0]=-1;
    Ports.v_oport[1]=-1;
    Ports.v_iport[0]=-1;
    Ports.v_iport[1]=-1;
    Ports.time[0]=-1;
    Ports.time[0]=-1;
    Ports.power[0]=-1;
    Ports.power[1]=-1;
    platformId= QString();
    pthread_create(&notificationThread,NULL,notificationsThreadHandle,this);
}

/*!
 * Getter and Setter methods, used for retriving/writing something to/from platform
 * Retreived/set value is indidcated by function name.
 * For instance getVoltagePort0 gets voltage of port 0 from
 * the platform
 */

/*! \brief gets the cached voltage of port 0
 */

float UserInterfaceBinding::getoutputVoltagePort0() {

    qDebug() << "getting port 0 voltage";
    return Ports.v_oport[0];
}

/*! \brief gets the cached voltage of port 1
 */
float UserInterfaceBinding::getinputVoltagePort0() {

    return Ports.v_iport[0];
}

/*! \brief gets the cached current of port 0
 */
float UserInterfaceBinding::getoutputCurrentPort0() {

    return Ports.a_oport[0];
}

float UserInterfaceBinding::getPort0Time() {

    return Ports.time[0];
}

float UserInterfaceBinding::getpowerPort0() {

    return Ports.power[0];
}

/*!
 * \brief update the platform Id
 */
QString UserInterfaceBinding::getPlatformId() {

    return platformId;
}

/*!
 * End of Getter and Setter Methods
 */



/*!
 * Notification handlers
 * if there is any change in the newly received voltage from the
 * platform notify it to UI by emitting respective signals
 */

void UserInterfaceBinding::handleNotification(QVariantMap current_map) {

    QVariantMap payloadMap;
    if(current_map.contains("value")) {
        if(current_map["value"] == "usb_pd_power") {

            payloadMap = current_map["payload"].toMap();
            handleUsbPowerNotification(payloadMap);
        } else if(current_map["value"] == "platform_id") {
            payloadMap = current_map["payload"].toMap();
            handlePlatformIdNotification(payloadMap);
        }else {
            qDebug() << "Unsupported value field Received";
            qDebug() << "Received JSON = " <<current_map;
        }
    }
}

/*!
 * \brief :
 *          @params: payloadMap map of usb_pd_power notification
 *                   parses and notifies the corresponding signal
 */
void UserInterfaceBinding::handleUsbPowerNotification(const QVariantMap payloadMap) {

    int port = payloadMap["port"].toInt();

    if(port == 0) {
        qDebug() << "in handlling power notification" ;
        if(Ports.v_oport[0] != payloadMap["output"].toFloat()) {
            Ports.v_oport[0] = payloadMap["output"].toFloat();
            //ceil(Ports.v_oport[0]);
            qDebug() << "ouput Voltage emitted " << payloadMap["output"].toFloat();

            emit outputVoltagePort0Changed(Ports.v_oport[0]);
        }

        if(Ports.v_iport[0] != payloadMap["input"].toFloat()) {
            Ports.v_iport[0] = payloadMap["input"].toFloat();
            qDebug() << "input Voltage emitted "<<payloadMap["input"].toFloat();
            //ceil(Ports.v_iport[0]);
            emit inputVoltagePort0Changed(Ports.v_iport[0]);
        }

        if(Ports.a_oport[0] != payloadMap["current"].toFloat()) {
            Ports.a_oport[0] = payloadMap["current"].toFloat();
            qDebug() << "output current emitted " << payloadMap["current"].toFloat();
            //ceil(Ports.a_oport[0]);
            emit outputCurrentPort0Changed(Ports.a_oport[0]);
        }

        if(Ports.power[0] != payloadMap["power"].toFloat()) {
            Ports.power[0] = payloadMap["power"].toFloat();
            qDebug() << "output power emitted " <<payloadMap["power"].toFloat();
            //ceil(Ports.power[0]);
            emit powerPort0Changed(Ports.power[0]);
        }
        if(Ports.time[0] != payloadMap["time"].toFloat()) {
            Ports.time[0] = payloadMap["time"].toFloat();
            qDebug() << "time emitted " << payloadMap["time"].toFloat();
            //ceil(Ports.time[0]);
            emit port0TimeChanged(Ports.time[0]);
        }

    }  else if(port == 1) {

        if(Ports.v_oport[1] != payloadMap["output"].toFloat()) {
            Ports.v_oport[1] = payloadMap["output"].toFloat();
            //ceil(Ports.v_oport[1]);
            emit outputVoltagePort0Changed(Ports.v_oport[1]);
        }

        if(Ports.v_iport[1] != payloadMap["input"].toFloat()) {
            Ports.v_iport[1] = payloadMap["input"].toFloat();
            //ceil(Ports.v_iport[1]);
            emit inputVoltagePort0Changed(Ports.v_iport[1]);
        }

        if(Ports.a_oport[1] != payloadMap["current"].toFloat()) {
            Ports.a_oport[1] = payloadMap["current"].toFloat();
            //ceil(Ports.a_oport[1]);
            emit outputCurrentPort0Changed(Ports.a_oport[1]);
        }

        if(Ports.power[1] != payloadMap["power"].toFloat()) {
            Ports.power[1] = payloadMap["power"].toFloat();
            //ceil(Ports.power[1]);
            emit powerPort0Changed(Ports.power[1]);
        }
        if(Ports.time[1] != payloadMap["time"].toFloat()) {
            Ports.time[1] = payloadMap["time"].toFloat();
            //ceil(Ports.time[1]);
            emit port0TimeChanged(Ports.time[1]);
        }

    }
}

void UserInterfaceBinding::handlePlatformIdNotification(const QVariantMap payloadMap) {

    if (payloadMap.contains("platform_id")){

            QString platformIdTemp = payloadMap["platform_id"].toString();
            qDebug() << "Received platformId = " << platformId;
            if(platformIdTemp != platformId) {
                platformId = platformIdTemp;
                emit platformIdChanged(platformId);
                qDebug() << "PlatformIdChanged notification";
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
QJsonObject UserInterfaceBinding::convertQstringtoJson(const QString string) {

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
QStringList UserInterfaceBinding::getJsonObjectKeys(const QJsonObject json_obj) {

    QStringList list = json_obj.keys();
    return list;
}

//Convert JSON object to JSON map "to handle it like HASH Map"
QVariantMap UserInterfaceBinding::getJsonMapObject(const QJsonObject json_obj) {

    QVariantMap json_map=json_obj.toVariantMap();
    return json_map;
}

//Validate Response from platform
QVariantMap UserInterfaceBinding::validateJsonReply(const QVariantMap json_map) {

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

void *notificationsThreadHandle(void* ObjectHost) {
    //read series of files each loop
    UserInterfaceBinding *Obj = (UserInterfaceBinding *)ObjectHost;
    HostControllerClient Object= Obj->HCCObj;
    qDebug () << "Thread Created for notification ";
    while(1) {
        QJsonObject json_obj = Object.receiveNotification();
        qDebug()<<"Response received  = " << json_obj;

        QVariantMap json_map = Obj->getJsonMapObject(json_obj);
        json_map = Obj->getJsonMapObject(json_obj);
        QVariantMap current_map = Obj->validateJsonReply(json_map);
        if(current_map.contains("payload")) {

            Obj->handleNotification(current_map);
        }
    }
}
