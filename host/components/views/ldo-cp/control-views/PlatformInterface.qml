import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property var telemetry: {
        "vin_vr" : "0.000000",
        "vin" : "12.246975",
        "vcp" : "0.000000",
        "vout" : "0.000000",
        "iout" : "0.000000",
        "iin" : "0.000124",
        "ploss" : "0.000000",
        "temperature" : 24.19
    }

    property var int_vin_vr_pg: {
        "value" : true
    }

    property var int_cp_on: {
        "value" : true
    }

    property var int_os_alert: {
        "value" : true
    }

    property var int_ro_mcu: {
        "value" : true
    }

    property var enable_vin_vr : ({
            "cmd" : "en_vin_vr",
            "payload": {
                "value": 0 // default value
            },

            update: function (value) {
                this.set(value)
                this.send(this)
            },
            set: function (value) {
                this.payload.value = value
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var enable_ldo : ({
            "cmd" : "en_ldo",
            "payload": {
                "value": 0 // default value
            },

            update: function (value) {
                this.set(value)
                this.send(this)
            },
            set: function (value) {
                this.payload.value = value
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var enable_sw : ({
            "cmd" : "en_sw",
            "payload": {
                "value": 0 // default value
            },

            update: function (value) {
                this.set(value)
                this.send(this)
            },
            set: function (value) {
                this.payload.value = value
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var vdac_iout : ({
            "cmd" : "vdac_iout",
            "payload": {
                "value": 0.00 // default value
            },

            update: function (value) {
                this.set(value)
                this.send(this)
            },
            set: function (value) {
                this.payload.value = value
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var vdac_vin : ({
            "cmd" : "vdac_vin",
            "payload": {
                "value": 0.00 // default value
            },

            update: function (value) {
                this.set(value)
                this.send(this)
            },
            set: function (value) {
                this.payload.value = value
            },
            send: function () { CorePlatformInterface.send(this) },
            show: function () { CorePlatformInterface.show(this) }
        })

    property var adc: {
        "vin_vr" : "30.942004",
        "vin" : "38.839787",
        "vcp" : "15.987984",
        "vout" : "5.067494",
        "iout" : "0.467027",
        "iin" : "0.467771"
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
