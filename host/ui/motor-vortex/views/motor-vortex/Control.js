.pragma library
//.import Qt.tech.spyglass.CoreInterface 1.0 as CoreInterface
var LocalCoreInterface = null

function setCoreInterface(coreInt)
{
    LocalCoreInterface = coreInt;
    console.log("heyyy dude I'm in abc function");
}

/*
  Platform Identification Request
*/
var platform_identification_request = {
    "cmd" : "request_platform_id"
}

/*
  System Mode Selection
*/
var system_mode_selection = {
    "cmd" : "set_system_mode",
    "payload":  {
        "system_mode":" " // "automation" or "manual"
    }
}

/*
  Set Speed Target in Manual Mode
*/
var speed_input = {
    "cmd":"speed_input",
    "payload":{
        "speed_target":""    //in RPM
    }
}

/*
  Set Drive Mode
*/

var set_drive_mode = {
    "cmd" : "set_drive_mode",
    "payload": {
        "drive_mode" : " ",
    }
}

/*
  Set phase angle
*/

var set_phase_angle = {
    "cmd":"set_phase_angle",
    "payload":{
        "phase_angle": "" ,   //Value varies from 0 to 15. The numbers represent 0 degrees to 28.125 degrees
    }
}
/*
  set motor on/off
*/
var set_motor_on_off = {
    "cmd" : "set_motor_on_off",
    "payload" :  {
        "enable": ""
    }
}

/*
  set reset mcu
*/

var set_reset_mcu = {
    "cmd":"reset_mcu"
}

/*
  set_ramp_rate
*/
var set_ramp_rate = {
    "cmd": "set_ramp_rate",
    "payload" : {
        "ramp_rate": ""
    }
}

function setRampRate(ramp_rate)
{
    set_ramp_rate.payload.ramp_rate = ramp_rate;
    LocalCoreInterface.sendCommand(getRampRate());
}

function setMotorOnOff(enabled)
{
    set_motor_on_off.payload.enable = enabled;
    LocalCoreInterface.sendCommand(getMotorstate());
}

function setPhaseAngle(phase_angle)
{
    set_phase_angle.payload.phase_angle = phase_angle;
    LocalCoreInterface.sendCommand(getSetPhaseAngle());
}

function setDriveMode(drive_mode)
{
    set_drive_mode.payload.drive_mode = drive_mode
    LocalCoreInterface.sendCommand(getDriveMode());
}

function setSystemModeSelection(system_mode)
{
    system_mode_selection.payload.system_mode = system_mode;
    LocalCoreInterface.sendCommand(getSystemModeSelection());
}

function setTarget(speed_target)
{
    speed_input.payload.speed_target = speed_target
    LocalCoreInterface.sendCommand(getSpeedInput());
}

function setReset()
{
    LocalCoreInterface.sendCommand(getResetcmd());
}

function printsystemModeSelection()
{
    console.log(JSON.stringify(system_mode_selection))
    console.log("core", LocalCoreInterface)
}

function printDriveMode()
{
    console.log(JSON.stringify(set_drive_mode))
}

function printPhaseAngle()
{
    console.log(JSON.stringify(set_phase_angle))
}

function printSpeedInput()
{
    console.log(JSON.stringify(speed_input))
}

function printSetMotorState()
{
    console.log(JSON.stringify(set_motor_on_off))
}

function printSetRampRate()
{
    console.log(JSON.stringify(set_ramp_rate))
}

function getSystemModeSelection()
{
    return JSON.stringify(system_mode_selection)
}

function getSpeedInput()
{
    return JSON.stringify(speed_input)
}

function getDriveMode()
{
    return JSON.stringify(set_drive_mode)
}

function getSetPhaseAngle()
{
    return JSON.stringify(set_phase_angle)
}

function getMotorstate()
{
    return JSON.stringify(set_motor_on_off)
}
function getResetcmd()
{
    return JSON.stringify(set_reset_mcu)
}

function getRampRate()
{
    return JSON.stringify(set_ramp_rate)
}







