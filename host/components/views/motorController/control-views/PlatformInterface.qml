import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    property var platform_info_notification:{
          "firmware_ver":"0.0.0",           // firmware version string
          "frequency":915.2                 // frequency in MHz
           }


    property var toggle_receive_notification:{
               "enabled":true,                 // or 'false'
    }

    property var dc_notification : {
        "Current":700,         // in mA
        "Voltage": 12.1        // in volts
    }

    property var step_notification : {
        "Current":700,          // in mA
        "Voltage": 12.1        // in volts
    }

    property var pwm_frequency_notification : {
        "frequency":1000,       // in mA
    }

    property var dc_direction_1_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var dc_direction_2_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var step_direction_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var step_excitation_notification : {
        "excitation":"half-step"       // or full-step
    }

    property var dc_duty_1_notification : {
        "duty":75       // % of duty cycle
    }

    property var dc_duty_2_notification : {
        "duty":75       // % of duty cycle
    }

    property var dc_start_1_notification : {
    }

    property var dc_start_2_notification : {
    }

    property var dc_brake_1_notification : {
    }

    property var dc_brake_2_notification : {
    }

    property var dc_open_1_notification : {
    }

    property var dc_open_2_notification : {
    }

    property var step_speed_notification : {
        "speed":250       // value dependant on step_speed_unit
    }

    property var step_speed_unit_notification : {
        "unit":"sps"       // steps per second or rpm
    }

    property var step_angle_notification:{
        "angle":"7.5"
    }

    property var step_duration_notification : {
        "duration":1080       // steps per second or rpm
    }

    property var step_duration_unit_notification : {
        "unit":"degrees"      // or seconds or steps
    }

    property var step_start_notification : {
    }

    property var step_hold_notification : {
    }

    property var step_open_notification : {
    }

    // --------------------------------------------------------------------------------------------
    //          Commands
    //--------------------------------------------------------------------------------------------

    property var requestPlatformId:({
                 "cmd":"request_platform_id",
                 "payload":{
                  },
                 send: function(){
                      CorePlatformInterface.send(this)
                 }
     })

   property var refresh:({
                "cmd":"request_platform_refresh",
                "payload":{
                 },
                send: function(){
                     CorePlatformInterface.send(this)
                }
    })


    property var set_pwm_frequency:({
                 "cmd":"PWM_frequency",
                 "payload":{
                    "frequency":1000
                    },
                 update: function(frequency){
                   this.set(frequency)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inFrequency){
                     this.payload.frequency = inFrequency;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_dc_direction_1:({
                 "cmd":"dc_direction_1",
                 "payload":{
                    "direction":"clockwise"     //or counterclockwise
                    },
                 update: function(direction){
                   this.set(direction)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDirection){
                     this.payload.direction = inDirection;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_dc_direction_2:({
                 "cmd":"dc_direction_2",
                 "payload":{
                    "direction":"clockwise"     //or counterclockwise
                    },
                 update: function(direction){
                   this.set(direction)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDirection){
                     this.payload.direction = inDirection;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_dc_duty_1:({
                 "cmd":"dc_duty_1",
                 "payload":{
                    "duty":75     //% of duty cycle
                    },
                 update: function(duty){
                   this.set(duty)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDuty){
                     this.payload.duty = inDuty;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_dc_duty_2:({
                 "cmd":"dc_duty_2",
                 "payload":{
                    "duty":75     //% of duty cycle
                    },
                 update: function(duty){
                   this.set(duty)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDuty){
                     this.payload.duty = inDuty;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_start_1:({
                 "cmd":"dc_start_1",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_start_2:({
                 "cmd":"dc_start_2",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_brake_1:({
                 "cmd":"dc_brake_1",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_brake_2:({
                 "cmd":"dc_brake_2",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_open_1:({
                 "cmd":"dc_open_1",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var dc_open_2:({
                 "cmd":"dc_open_2",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    //--------------------------------------------------------------------
    //      Step commands
    //--------------------------------------------------------------------
    property var step_excitation:({
                 "cmd":"step_excitation",
                 "payload":{
                    "excitation":"half-step"    //or full-step
                    },
                 update: function(excitationStep){
                      this.set(excitationStep)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inExcitation){
                     this.payload.excitation = inExcitation;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_direction:({
                 "cmd":"step_direction",
                 "payload":{
                    "direction":"clockwise"    //or counterclockwise
                    },
                 update: function(direction){
                      this.set(direction)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDirection){
                     this.payload.direction = inDirection;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_angle:({
                 "cmd":"step_angle",
                 "payload":{
                    "angle":"7.5"
                    },
                 update: function(angle){
                      this.set(angle)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inAngle){
                     this.payload.angle = inAngle;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_speed:({
                 "cmd":"step_speed",
                 "payload":{
                    "speed":250    //0 to 1000
                    },
                 update: function(speed){
                      this.set(speed)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inSpeed){
                     this.payload.speed = inSpeed;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_speed_unit:({
                 "cmd":"step_speed_unit",
                 "payload":{
                    "unit":"sps"    //steps per second or rpm
                    },
                 update: function(unit){
                      this.set(unit)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inUnit){
                     this.payload.unit = inUnit;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_duration:({
                 "cmd":"step_duration",
                 "payload":{
                    "duration":1080    //depends on step_duration_unit
                    },
                 update: function(duration){
                      this.set(duration)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDuration){
                     this.payload.duration = inDuration;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_start:({
                 "cmd":"step_start",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_hold:({
                 "cmd":"step_hold",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_open:({
                 "cmd":"step_open",
                 "payload":{
                    },
                 update: function(){
                   CorePlatformInterface.send(this)
                 },
                 set: function(){
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    // -------------------------------------------------------------------
    // Listens to message notifications coming from CoreInterface.cpp
    // Forward messages to core_platform_interface.js to process

    Connections {
        target: coreInterface
        onNotification: {
            CorePlatformInterface.data_source_handler(payload)
        }
    }
}
