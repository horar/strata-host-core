/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.common 1.0
import QtQml 2.12


/******************************************************************
  * File auto-generated by PlatformInterfaceGenerator on 2021-09-28 11:51:27.202 UTC-07:00
******************************************************************/

PlatformInterfaceBase {
    id: platformInterface
    apiVersion: 2

    property alias notifications: notifications
    property alias commands: commands

    /******************************************************************
      * NOTIFICATIONS
    ******************************************************************/

    QtObject {
        id: notifications

        // @notification: my_cmd_simple_periodic
        // @property adc_read: double
        // @property gauge_ramp: double
        // @property io_read: bool
        // @property random_float: double
        // @property random_float_array: array-dynamic-sized
        // @property random_increment: array-static-sized
        // @property toggle_bool: bool
        property QtObject my_cmd_simple_periodic: QtObject {
            property double adc_read: 0
            property double gauge_ramp: 0
            property bool io_read: false
            property double random_float: 0
            property var random_float_array: []
            property bool toggle_bool: false

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            property QtObject random_increment: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
            }
        }
    }

    /******************************************************************
      * COMMANDS
    ******************************************************************/

    QtObject {
        id: commands

        // @command my_cmd_simple
        // @property dac: double
        // @property io: bool
        property QtObject my_cmd_simple: QtObject {
            property double dac: 0
            property bool io: false

            signal commandSent()

            function update(dac, io) {
                this.set(dac, io)
                this.send()
            }

            function set(dac, io) {
                this.dac = dac
                this.io = io
            }

            function send() {
                platformInterface.send({
                    "cmd": "my_cmd_simple",
                    "payload": {
                        "dac": dac,
                        "io": io
                    }
                })
                commandSent()
            }
        }

        // @command my_cmd_simple_periodic_update
        // @property interval: int
        // @property run_count: int
        // @property run_state: bool
        property QtObject my_cmd_simple_periodic_update: QtObject {
            property int interval: 0
            property int run_count: 0
            property bool run_state: false

            signal commandSent()

            function update(interval, run_count, run_state) {
                this.set(interval, run_count, run_state)
                this.send()
            }

            function set(interval, run_count, run_state) {
                this.interval = interval
                this.run_count = run_count
                this.run_state = run_state
            }

            function send() {
                platformInterface.send({
                    "cmd": "my_cmd_simple_periodic_update",
                    "payload": {
                        "interval": interval,
                        "run_count": run_count,
                        "run_state": run_state
                    }
                })
                commandSent()
            }
        }

        // @command my_cmd_i2c
        property QtObject my_cmd_i2c: QtObject {
            signal commandSent()

            function update() {
                this.send()
            }

            function send() {
                platformInterface.send({
                    "cmd": "my_cmd_i2c"
                })
                commandSent()
            }
        }
    }
}
