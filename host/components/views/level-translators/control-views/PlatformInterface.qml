import QtQuick 2.12

import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //
    property var startup : {
        "oe_i2c":true,
        "oe_spi":true,
        "oe_ub":true,
        "tr_0":true,
        "tr_1":true,
        "tr_2":true,
        "tr_3":true
    }

    property var adc : {
        "vcca_i2c":0,
        "vcca_spi":0,
        "vcca_ub":0,
        "vccb_i2c":1.73,
        "vccb_spi":0,
        "vccb_ub":0
    }

    // -------------------------------------------------------------------
    // Outgoing Commands
    //
    property var startup_command : ({
                                        "cmd" : "startup",
                                        update: function () {
                                            this.send(this)
                                        },
                                        send: function () { CorePlatformInterface.send(this) },
                                        show: function () { CorePlatformInterface.show(this) }
                                    })

    property var tr_0_command : ({
                                     "cmd" : "tr_0",
                                     "payload": {
                                         "value":false
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

    property var tr_1_command : ({
                                     "cmd" : "tr_1",
                                     "payload": {
                                         "value":false
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

    property var tr_2_command : ({
                                     "cmd" : "tr_2",
                                     "payload": {
                                         "value":false
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

    property var tr_3_command : ({
                                     "cmd" : "tr_3",
                                     "payload": {
                                         "value":false
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

    property var oe_ub_command : ({
                                      "cmd" : "oe_ub",
                                      "payload": {
                                          "value":false
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

    property var oe_i2c_command : ({
                                       "cmd" : "oe_i2c",
                                       "payload": {
                                           "value":false
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

    property var oe_spi_command : ({
                                       "cmd" : "oe_spi",
                                       "payload": {
                                           "value":false
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
