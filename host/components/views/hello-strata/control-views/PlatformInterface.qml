import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property var test: ({
                            "cmd":"request_platform_id",
                            update: function () {
                                CorePlatformInterface.send(this)
                            },
                            send: function () { CorePlatformInterface.send(this) }
                        })

    // -------------------------------------------------------------------
    // DAC and PWM to LED APIs

    property var setPwmLedFreq: ({
                                    "cmd": "setPwmLedFreq",
                                     "payload": {
                                         "frequency":0
                                     },
                                     update: function (frequency) {
                                         this.set(frequency)
                                         this.send()
                                     },
                                     set: function (frequency) {
                                         this.payload.frequency = frequency
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var setPwmLedDuty: ({
                                     "cmd":"setPwmLedDuty",
                                     "payload": {
                                         "duty":0
                                     },
                                     update: function (duty) {
                                         this.set(duty)
                                         this.send()
                                     },
                                     set: function (duty) {
                                         this.payload.duty = duty
                                     },
                                     send: function () { CorePlatformInterface.send(this) }
                                 })

    property var setDacLed: ({
                                 "cmd":"setDacLed",
                                 "payload": {
                                     "intensity":0
                                 },
                                 update: function (intensity) {
                                     this.set(intensity)
                                     this.send()
                                 },
                                 set: function (intensity) {
                                     this.payload.intensity = intensity
                                 },
                                 send: function () { CorePlatformInterface.send(this) }
                             })

    // -------------------------------------------------------------------
    // PWM Motor Control APIs

    property var enableMotor: ({
                                   "cmd":"enableMotor",
                                   "payload": {
                                       "enable":false
                                   },
                                   update: function (enable) {
                                       this.set(enable)
                                       this.send()
                                   },
                                   set: function (enable) {
                                       this.payload.enable = enable
                                   },
                                   send: function () { CorePlatformInterface.send(this) }
                               })

    property var brakeMotor: ({
                                  "cmd":"brakeMotor",
                                  "payload": {
                                      "brake":false
                                  },
                                  update: function (brake) {
                                      this.set(brake)
                                      this.send()
                                  },
                                  set: function (brake) {
                                      this.payload.brake = brake
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    property var driveMotor: ({
                                  "cmd":"driveMotor",
                                  "payload": {
                                      "pwm":.5,
                                      "forward":true
                                  },
                                  update: function (pwm, forward) {
                                      this.set(pwm, forward)
                                      this.send()
                                  },
                                  set: function (pwm, forward) {
                                      this.payload.pwm = pwm
                                      this.payload.forward = forward
                                  },
                                  send: function () { CorePlatformInterface.send(this) }
                              })

    // -------------------------------------------------------------------
    // Helper functions

    function send (command) {
        console.log("send:", JSON.stringify(command));
        coreInterface.sendCommand(JSON.stringify(command))
    }

    function show (command) {
        console.log("show:", JSON.stringify(command));
    }

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
