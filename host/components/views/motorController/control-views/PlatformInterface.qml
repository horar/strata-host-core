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
        "current":700,         // in mA
        "voltage": 12.1        // in volts
    }

    property var step_notification : {
        "current":700,          // in mA
        "voltage": 12.1        // in volts
    }

    property var pwm_frequency_notification : {
        "frequency":1000,       // in mA
    }

    property var dc_pwm_mode_1_notification : {
            "mode" : "on_off"     //or "on_brake"
    }

    property var dc_pwm_mode_2_notification : {
            "mode" : "on_off"     //or "on_brake"
    }

    property var dc_direction_1_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var dc_direction_2_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var dc_duty_1_notification : {
        "duty":.75       // % of duty cycle
    }

    property var dc_duty_2_notification : {
        "duty":.75       // % of duty cycle
    }

    property var motor_run_1_notification : {
        "mode" : 1     // 1 = "run", 2="brake", 3="open"
    }

    property var motor_run_2_notification : {
        "mode" : 1     // 1 = "run", 2="brake", 3="open"
    }

    property var dc_ocp_notification : {
        "ocp_set" : "off"     // or "on"
    }

    property var step_excitation_notification : {
        "excitation":"half_step"       // or full_step
    }

    property var step_direction_notification : {
        "direction":"clockwise"       // or counterclockwise
    }

    property var step_speed_notification : {
        "speed":250,       // value dependant on step_speed_unit
        "unit":"sps"       // steps per second (sps) or rpm
    }

    property var step_angle_notification:{
        "angle":"7.5"
    }

    property var step_duration_notification : {
        "duration":1080,       // steps per second or rpm
        "unit":"seconds"      // or seconds or steps or degrees
    }

    property var step_run_notification:{
        "mode": 1 // set to 1 for "run", 2 for "hold" or 3 for "free"
    }

    property var step_ocp_notification : {
        "ocp_set" : "off"     // or "on"
    }

    property var ocp_enable_notification : {
        "enable" : "off"     // or "on"         //enables OCP for both DC and stepper motors
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
                 "cmd":"pwm_frequency",
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

    property var set_pwm_mode_1:({
                 "cmd":"dc_pwm_mode_1",
                 "payload":{
                    "mode":"on_brake"
                    },
                 update: function(mode){
                   this.set(mode)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inMode){
                     this.payload.mode = inMode;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var set_pwm_mode_2:({
                 "cmd":"dc_pwm_mode_2",
                 "payload":{
                    "mode":"on_brake"
                    },
                 update: function(mode){
                   this.set(mode)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inMode){
                     this.payload.mode = inMode;
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
                 "cmd":"setdcduty_1",
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
                 "cmd":"setdcduty_2",
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

    property var dc_ocp_reset:({
                 "cmd":"dc_ocp_reset",
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


    property var motor_run_1:({
                 "cmd":"motor_run_1",
                 "payload":{
                    "mode": 3 //set to 1 for "run", 2 for "brake" or 3 for "open"
                    },
                 update: function(inMode){
                   this.set(inMode);
                   CorePlatformInterface.send(this)
                 },
                 set: function(inMode){
                     this.payload.mode = inMode;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var motor_run_2:({
                 "cmd":"motor_run_2",
                 "payload":{
                    "mode": 3 //set to 1 for "run", 2 for "brake" or 3 for "open"
                    },
                 update: function(inMode){
                   this.set(inMode);
                   CorePlatformInterface.send(this)
                 },
                 set: function(inMode){
                   this.payload.mode = inMode;
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
                    "excitation":"half_step"    //or full_step
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
                    "speed":250,    //0 to 1000
                    "unit":"sps"    //steps per second (sps) or rpm
                    },
                 update: function(speed,unit){
                      this.set(speed,unit)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inSpeed,inUnit){
                     this.payload.speed = inSpeed;
                     this.payload.unit = inUnit;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })



    property var step_duration:({
                 "cmd":"step_duration",
                 "payload":{
                    "duration":1080,    //set 0 to infinite for run value
                    "unit":"degrees"    //seconds, steps or degrees
                    },
                 update: function(duration,unit){
                      this.set(duration,unit)
                   CorePlatformInterface.send(this)
                 },
                 set: function(inDuration,inUnit){
                     this.payload.duration = inDuration;
                     this.payload.unit = inUnit;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_run:({
                 "cmd":"step_run",
                 "payload":{
                    "mode" : 1  //set to 1 for "run", 2 for "hold" or 3 for "free"
                    },
                 update: function(mode){
                   this.set(mode);
                   CorePlatformInterface.send(this)
                 },
                 set: function(inMode){
                   this.payload.mode = inMode;
                  },
                 send: function(){
                   CorePlatformInterface.send(this)
                  }
     })

    property var step_ocp_reset:({
                 "cmd":"step_ocp_reset",
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

    property var ocp_enable:({
                 "cmd":"ocp_enable",
                 "payload":{
                    "enable":"on"
                    },
                 update: function(enabled){
                   this.set(enabled);
                   CorePlatformInterface.send(this);
                 },
                 set: function(inEnabled){
                     this.payload.enable = inEnabled;
                  },
                 send: function(){
                   CorePlatformInterface.send(this);
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
