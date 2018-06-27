.pragma library

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
        "phase_angle": "" ,   //Value varies from 0to 15. The numbers represent 0 degrees to 28.125 degrees
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

function setMotorOnOff(enabled)
{
    set_motor_on_off.payload.enable = enabled;
}

function setPhaseAngle(phase_angle)
{
    set_phase_angle.payload.phase_angle = phase_angle;
}

function setDriveMode(drive_mode)
{
    set_drive_mode.payload.drive_mode = drive_mode
}

function printDriveMode()
{
    console.log(JSON.stringify(set_drive_mode))
}

function setSystemModeSelection(system_mode)
{
    system_mode_selection.payload.system_mode = system_mode
}

function printsystemModeSelection()
{
    console.log(JSON.stringify(system_mode_selection))
}

function printPhaseAngle()
{
    console.log(JSON.stringify(set_phase_angle))
}

function setTarget(speed_target)
{
    speed_input.payload.speed_target = speed_target
}

function printSpeedInput()
{
    console.log(JSON.stringify(speed_input))
}

function printSetMotorState()
{
    console.log(JSON.stringify(set_motor_on_off))
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







