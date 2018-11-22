#include "PlatformController.h"
#include <iostream>

#include <QDebug>

using namespace std;

PlatformController::PlatformController(QObject *parent): QObject(parent),
    serial_(ConnectorFactory::getConnector("platform")),
    platformConnected_(false),
    verboseName_(QStringLiteral("No Platform Connected")),
    aboutToQuit_(false)
{

    qDebug() << Q_FUNC_INFO << "PLATFORM CONTROLLER: STARTING CONNECTOR";
    connector_= std::thread(&PlatformController::connectWorker, this);
}

PlatformController::~PlatformController()
{
    {
        std::lock_guard lock(quitMutex_);
        aboutToQuit_ = true;
    }
    if (serial_->isSpyglassPlatform()) {
        serial_->close();
    }

    connector_.join();
    if (reader_.joinable()) {
        reader_.join();
    }
    qDebug() << "PlatformController Destructing";
}

string PlatformController::toString(const QString& s)
{
    return s.toStdString();
}

QString PlatformController::toQString(const string& s)
{
    return QString::fromStdString(s);
}

void PlatformController::initializePlatform()
{
    setVerboseName(toQString(serial_->getDealerID()));
    setPlatformID(toQString(serial_->getPlatformUUID()));

    reader_= std::thread(&PlatformController::readWorker, this);
}

void PlatformController::sendCommand(QString cmd, QString platformID)
{
    // TODO: add ability to send command to specific platformID
    serial_->send(cmd.toStdString());
}

QString PlatformController::verboseName() const
{
    return verboseName_;
}

QString PlatformController::platformID() const
{
    return platformID_;
}

QString PlatformController::notification() const
{
    return notification_;
}

bool PlatformController::platformConnected() const
{
    return platformConnected_;
}

void PlatformController::setVerboseName(QString verboseName)
{
    if (verboseName_ == verboseName)
        return;

    verboseName_ = verboseName;
    emit verboseNameChanged(verboseName_);
}

void PlatformController::setPlatformID(QString platformID)
{
    if (platformID_ == platformID)
        return;

    platformID_ = platformID;
    emit platformIDChanged(platformID_);
}

void PlatformController::setNotification(QString notification)
{
    if (notification_ == notification)
        return;

    notification_ = notification;
    emit notificationChanged(notification_, platformID_);
}

void PlatformController::setPlatformConnected(bool platformConnected)
{
    if (platformConnected_ == platformConnected) {
        return;
    }

    platformConnected_ = platformConnected;

    payload_["platformID"] = platformID_;
    payload_["connected"] = platformConnected_;
    payload_["verboseName"] = verboseName_;
    QJsonDocument doc(payload_);
    emit platformConnectedChanged(doc.toJson(QJsonDocument::Compact));
}

void PlatformController::readWorker()
{
    while(!aboutToQuit_)
    {
        string answer;
        qDebug() << Q_FUNC_INFO << "READING.. on platform:" << platformID_;
        if (!serial_->read(answer))
        {
            qWarning() << Q_FUNC_INFO << "READING ERROR..";
            setPlatformConnected(false);

            serial_->close();
            while(!platformConnected_)
            {
                qDebug() << Q_FUNC_INFO << "READER: WAITING FOR PLATFORM TO RECONNECT";
                setPlatformConnected(serial_->isSpyglassPlatform());
                {
                    std::shared_lock lock(quitMutex_);
                    if (aboutToQuit_) return;
                }
                this_thread::sleep_for(chrono::seconds(1));
            }
            if(this->platformConnected_)
            {
                setPlatformConnected(true);
            }
        }
        else
        {
            setNotification(toQString(answer));
        }
    }
}

void PlatformController::connectWorker()
{
    while(true)
    {
        const bool connected = serial_->isSpyglassPlatform();
        qDebug() << Q_FUNC_INFO << "searching for boards, connected:" << connected;
        if(!connected)
        {
            {
                std::shared_lock lock(quitMutex_);
                if (aboutToQuit_) return;
            }
//            sleep(1);
            chrono::milliseconds timespan(250);
            this_thread::sleep_for(timespan);
            continue;
        }


        initializePlatform();

        setPlatformConnected(true);
        return;
    }
}
