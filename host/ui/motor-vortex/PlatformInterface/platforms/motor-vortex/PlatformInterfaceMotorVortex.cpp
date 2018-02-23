#include <PlatformInterface/platforms/motor-vortex/PlatformInterfaceMotorVortex.h>

using namespace PlatformInterfaceMotorVortex;
using namespace std;
using namespace Spyglass;

PlatformInterface::PlatformInterface(QObject *parent) : CoreInterface(parent)
{
    qDebug() << "PlatformInterfaceMotorVortex::PlatformInterface::PlatformInterface CTOR called";

    // ---
    // Platform Implementation Notification handlers
    //
    qDebug() << "PlatformInterfaceMotorVortex::PlatformInterface::PlatformInterface register for pi_stats";
    registerNotificationHandler("pi_stats",
                                bind(&PlatformInterface::motorStatsNotificationHandler,
                                     this, placeholders::_1));

}

PlatformInterface::~PlatformInterface()
{
    qDebug() << "PlatformInterfaceMotorVortex::PlatformInterface::~PlatformInterface DTOR called";
}

// -----
// Platform Implementation Commands
//
// Add Platform Specific Command Handlers
// Q_INVOKABLE() functions

// @f setMotorSpeed
// @b set motor speed
//
bool PlatformInterface::setMotorSpeed( unsigned int speed )
{
    qDebug("PlatformInterfaceMotorVortex::setMotorSpeed(%d)", speed);

    // { "cmd":"speed_input",
    //   "payload": {
    //   "speed_target":3000
    //  }}

    QJsonObject cmd, payload;

    cmd.insert("cmd", QJsonValue("speed_input"));
    payload.insert("speed_target", QJsonValue((double)speed));
    cmd.insert("payload", payload);
    QJsonDocument doc(cmd);
    QString cmd_json(doc.toJson(QJsonDocument::Compact));

    bool rv = hcc->sendCmd(cmd_json.toStdString());
    if( rv == false) {
        qCritical() << "ERROR:PlatformInterfaceMotorVortex::setMotorSpeed:"
                       " command send failure";
    }

    return rv;
}

// @f setMotorMode
// @b set motor mode to manual control or automatic demo
//
bool PlatformInterface::setMotorMode( QString mode )
{
    qDebug("PlatformInterfaceMotorVortex::setMotorMode(%s)",
           mode.toStdString().c_str());

    // Manual:
    //
    // {"cmd":"set_system_mode",
    //  "payload":{"system_mode":1}}
    //
    // Automation:
    //
    // {"cmd":"set_system_mode",
    //  "payload":{"system_mode":0}}
    //
    QJsonObject cmd, payload;

    cmd.insert("cmd", QJsonValue("set_system_mode"));
    payload.insert("system_mode", mode == "manual" ? QJsonValue("manual") :QJsonValue("automation"));
    cmd.insert("payload", payload);
    QJsonDocument doc(cmd);
    QString cmd_json(doc.toJson(QJsonDocument::Compact));

    qDebug() << "cmd: " << cmd_json;

    bool rv = hcc->sendCmd(cmd_json.toStdString());
    if( rv == false) {
        qCritical() << "ERROR:PlatformInterfaceMotorVortex::setMotorMode:"
                       " command send failure";
    }

    return rv;
}

// END Platform Implementation Commands
// ----------


// -----
// Platform Implementation Notification Handlers
//
// Add Platform Specific Notification Handlers here

// @f motorStats
// @b Motor statistics
//
void PlatformInterface::motorStatsNotificationHandler(QJsonObject payload)
{
    //{
    //   "notification": {
    //         "value":"pi_stats",
    //         "payload": {
    //               "speed_target":4000,
    //               "current_speed":3880,
    //               "error":120,
    //               "sum":0.00,
    //               "duty_now":0.58,
    //               "mode":"automation"}}}
    //
    // current_speed is the actual measured speed of the motor.

    unsigned int current_speed = payload["current_speed"].toInt();
    unsigned int target_speed = payload["speed_target"].toInt();
    QString motor_mode = payload["mode"].toString();

    qDebug() << "current_speed = " << current_speed;
    qDebug() << "target_speed = " << target_speed;
    qDebug() << "mode = " << motor_mode;

    if( current_speed != current_speed_ ) {
        qDebug() << "EMIT: current_speed = " << current_speed;
        current_speed_ = current_speed;
        emit motorSpeedChanged(current_speed_);
    }

    // TODO [ian] target speed is not used at this time.
    //    if( target_speed != target_speed_ ) {
    //        target_speed_ = target_speed;
    //        emit targetSpeedChanged(target_speed_);
    //    }

    if( motor_mode != motor_mode_ ) {
        motor_mode_ = motor_mode;
        emit motorModeChanged(motor_mode_);
    }
}

// END Platform Implementation Notification Handlers
// ----------
