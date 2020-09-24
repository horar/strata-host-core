import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // Incoming Notification Messages
    //

    //DC link voltage
    property var link_voltage: {
        "link_v": 12.1
    }

    //Phase current
    property var phase_current: {
        "p_current": 13
    }

    //Shaft speed
    property var speed: {
        "rpm": 1600
    }

    //Target speed
    property var target_speed: {
        "rpm": 0
    }

    //Poles
    property var poles: {
        "poles": 6
    }

    onPolesChanged: {
        //mark has requested that we echo back the poles notification to the platform when it's changed
        platformInterface.set_poles.update(poles)
    }

    //shaft direction
    property var direction: {
        "direction": "anti-clockwise" //or clockwise
    }

    //motor state
    property var state: {
        "M_state": "Halted",
        "Statecolor": "lime"
    }






    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    // Define and document platform commands here.
    //
    // Built-in functions:
    //   update(): sets properties and sends command in one call
    //   set():    can set single or multiple properties before sending to platform
    //   send():   sends current command
    //   show():   console logs current command and properties
    //

    property var request_platform_refresh : ({
            "cmd" : "request_platform_refresh",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })


    property var request_link_voltage : ({
            "cmd" : "request_link_voltage",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var request_phase_current : ({
            "cmd" : "request_phase_current",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var request_speed : ({
            "cmd" : "request_speed",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })


    property var set_target_speed : ({
            "cmd" : "set_target_speed",
            "payload": {
                "rpm": 1792 // default value
            },

            update: function (speed) {
                this.set(speed)
                this.send(this)
            },
            set: function (speed) {
                this.payload.rpm = speed
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var set_poles : ({
            "cmd" : "set_poles",
            "payload": {
                "value": 4
            },

            update: function (numberOfPoles) {
                this.set(numberOfPoles)
                this.send(this)
            },
            set: function (inNumberOfPoles) {
                this.payload.value = inNumberOfPoles
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var set_direction : ({
            "cmd" : "set_direction",
            "payload": {
                "direction": "anti-clockwise"   //or clockwise
            },

            update: function (direction) {
                this.set(direction)
                this.send(this)
            },
            set: function (inDirection) {
                this.payload.direction = inDirection
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var get_direction : ({
            "cmd" : "get_direction",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var get_state : ({
            "cmd" : "get_state",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })


    property var start_motor : ({
            "cmd" : "start_motor",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var stop_motor : ({
            "cmd" : "stop_motor",
            "payload": {},

            update: function () {
                this.send(this)
            },
            set: function () {
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
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
