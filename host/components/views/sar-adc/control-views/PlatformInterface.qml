import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

Item {
    id: platformInterface

    // -------------------------------------------------------------------
    // UI Control States
    //

    property var get_clk_freqs : {
       "clk":[10,50,100,500,1000,32000]
    }

    property var get_power : {
       "AVDD":20,
       "DVDD":30,
       "Total":50
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

    // @command: set_adc_supply
    // @description: sends ADC Supply command to platform
    //
    property var set_adc_supply : ({
                                       "cmd" : "set_adc_supply",
                                       "payload": {
                                           "DVDD":3.3,
                                           "AVDD":1.8
                                       },

                                       update: function (DVDD,AVDD) {
                                           this.set(DVDD,AVDD)
                                           this.send(this)
                                       },
                                       set: function (DVDD,AVDD) {
                                           this.payload.DVDD = DVDD
                                           this.payload.AVDD = AVDD
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })

    // @command: get_clk_freqs
    // @description: sends get_clk_freqs command to platform
    //

    property var get_clk_freqs_values: ({ "cmd" : "get_clk_freqs",
                                     update: function () {
                                         CorePlatformInterface.send(this)
                                     },
                                     send: function () { CorePlatformInterface.send(this) },
                                     show: function () { CorePlatformInterface.show(this) }

                                 })

    // @command: set_adc_supply
    // @description: sends ADC Supply command to platform
    //
    property var set_clk : ({
                                       "cmd" : "set_clk",
                                       "payload": {
                                           "clk":50
                                       },
                                       update: function (clk) {
                                           this.set(clk)
                                           this.send(this)
                                       },
                                       set: function (clk) {
                                           this.payload.clk = clk
                                       },
                                       send: function () { CorePlatformInterface.send(this) },
                                       show: function () { CorePlatformInterface.show(this) }
                                   })


    // @command: get_clk_freqs
    // @description: sends get_clk_freqs command to platform
    //

    property var get_power_value: ({ "cmd" : "get_power",
                                     update: function () {
                                         CorePlatformInterface.send(this)
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
