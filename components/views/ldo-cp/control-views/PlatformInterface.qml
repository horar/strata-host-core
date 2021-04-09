import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    property var telemetry: {
        "vin_vr" : "0.00",
        "vin" : "0.00",
        "vcp" : "0.00",
        "vout" : "0.00",
        "iout" : "0.0",
        "iin" : "0.0",
        "ploss" : "0.000",
        "temperature" : 23.0,
    }

    property var control_states: {
        "vin_vr_sel": "off",
        "vin_vr_set": "12.00",
        "iout_set": "0.0",
        "ldo_en": "off",
        "load_en": "off",

    }

    property var int_status: {
        "int_vin_vr_pg":false,
        "int_cp_on":false,
        "int_os_alert":false,
        "int_ro_mcu":false,
        "vin_good":false,
        "vin_vr_good":true,
        "ldo_clim":false
    }

    property var ldo_temp_alert: {
        "value" : false
    }

    property var config_running: {
        "value" : false
    }

    property var cp_test_invalid: {
        "value" : false
    }

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

    property var enable_load : ({
                                    "cmd" : "en_load",
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

    property var set_iout : ({
                                 "cmd" : "set_iout",
                                 "payload": {
                                     "value": 0.0 // default value
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

    property var set_vin_vr : ({
                                   "cmd" : "set_vin_vr",
                                   "payload": {
                                       "value": 12.0 // default value
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

    property var select_vin_vr : ({
                                      "cmd" : "select_vin_vr",
                                      "payload": {
                                          "value": "off" // default value
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


    property var ldo_cp_test: ({
                                   "cmd":"ldo_cp_test",
                                   "payload": { },
                                   update: function () {
                                       CorePlatformInterface.send(this)
                                   },
                                   send: function () { CorePlatformInterface.send(this) }
                               })


    property var get_all_states: ({
                                      "cmd":"get_all_states",
                                      update: function () {
                                          CorePlatformInterface.send(this)
                                      },
                                      send: function () { CorePlatformInterface.send(this) }
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
