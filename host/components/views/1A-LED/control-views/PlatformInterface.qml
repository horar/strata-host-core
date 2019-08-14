import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    //TELEMETRY

    property var telemetry : {
        "lcsm": "0.000",
        "gcsm": "0.00",
        "vin": "0.000",
        "vout": "0.000",
        "vin_conn": "0.000",
        "temperature": 24.62
    }


    //INTERRUPTS

    property var int_os_alert: {
        "value" : true
    }

    //ENABLE/DISABLE LED DRIVER

    property var set_enable : ({
            "cmd" : "set_enable",
            "payload": {
                "enable": "on" // default value
            },

            update: function (enable) {
                this.set(enable)
                this.send(this)
            },
            set: function (enable) {
                this.payload.enable = enable
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    //DIM#_EN SETTINGS

    property var dim_en_ctrl_state: {
        "value" : 1.0
    }

    property var set_dim_en_duty : ({
            "cmd" : "dim_en_set_duty",
            "payload": {
                "duty": 1.0 // default value
            },

            update: function (duty) {
                this.set(duty)
                this.send(this)
            },
            set: function (duty) {
                this.payload.duty = duty
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var set_dim_en_frequency : ({
            "cmd" : "dim_en_set_freq",
            "payload": {
                "frequency": 10 // default value
            },

            update: function (frequency) {
                this.set(frequency)
                this.send(this)
            },
            set: function (frequency) {
                this.payload.frequency = frequency
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    //SET LED CONFIGURATION

    property var set_led : ({
            "cmd" : "set_led_config",
            "payload": {
                "led_config": "1 led" // default value
            },

            update: function (led_config) {
                this.set(led_config)
                this.send(this)
            },
            set: function (led_config) {
                this.payload.led_config = led_config
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    //ADC INPUTS

    property var status: {
        "lcsm" : "0.700",
        "gcsm" : "0.500",
        "vin" : "12.000",
        "vout" : "3.000",
        "vin_conn": "12.000"
    }

    property var get_status : ({
            "cmd" : "get_status",
            update: function () {
                this.set()
                this.send(this)
            },

            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    //TEMPERATURE SENSOR
    property var i2c_temp_noti_value: {
        "value" : 25
    }
    property var get_temp : ({
            "cmd" : "get_temp",
            update: function () {
                this.set()
                this.send(this)
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
