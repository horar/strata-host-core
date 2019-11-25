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
        "temperature" : 24.0
    }

    property var int_vin_vr_pg: {
        "value" : false
    }

    property var int_cp_on: {
        "value" : false
    }

    property var int_os_alert: {
        "value" : false
    }

    property var int_ro_mcu: {
        "value" : false
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

    property var vdac_vin : ({
                                 "cmd" : "vdac_vin",
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

    property var adc: {
        "vin_vr" : "0.00",
        "vin" : "0.00",
        "vcp" : "0.00",
        "vout" : "0.00",
        "iout" : "0.0",
        "iin" : "0.0"
    }


    property var ldo_cp_test: ({
                                   "cmd":"ldo_cp_test",
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
