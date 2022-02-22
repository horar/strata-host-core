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
  * File auto-generated by PlatformInterfaceGenerator on 2021-09-28 12:05:10.247 UTC-07:00
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

        // @notification: target_speed
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject target_speed: QtObject {
            property string caption: ""
            property string unit: ""
            property double value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: acceleration
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject acceleration: QtObject {
            property string caption: ""
            property string unit: ""
            property double value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 2
            }
        }

        // @notification: run
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-dynamic-sized
        property QtObject run: QtObject {
            property string caption: ""
            property string unit: ""
            property int value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: brake
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-dynamic-sized
        property QtObject brake: QtObject {
            property string caption: ""
            property string unit: ""
            property int value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: direction
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-dynamic-sized
        property QtObject direction: QtObject {
            property string caption: ""
            property string unit: ""
            property int value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: warning_1
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: bool
        // @property values: array-dynamic-sized
        property QtObject warning_1: QtObject {
            property string caption: "Warning 1"
            property string unit: ""
            property bool value: false
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: warning_2
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: bool
        // @property values: array-dynamic-sized
        property QtObject warning_2: QtObject {
            property string caption: "Warning 2"
            property string unit: ""
            property bool value: false
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: warning_3
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: bool
        // @property values: array-dynamic-sized
        property QtObject warning_3: QtObject {
            property string caption: "Warning 3"
            property string unit: ""
            property bool value: false
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: title
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: string
        // @property values: array-dynamic-sized
        property QtObject title: QtObject {
            property string caption: "Title"
            property string unit: ""
            property string value: ""
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: subtitle
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: string
        // @property values: array-dynamic-sized
        property QtObject subtitle: QtObject {
            property string caption: "Subtitle"
            property string unit: ""
            property string value: ""
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: actual_speed
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject actual_speed: QtObject {
            property string caption: "Caption"
            property string unit: "Unit"
            property double value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: board_temp
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject board_temp: QtObject {
            property string caption: "Caption"
            property string unit: "Unit"
            property double value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: input_voltage
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject input_voltage: QtObject {
            property string caption: "Caption"
            property string unit: "Unit"
            property double value: 0
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: status_log
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: string
        // @property values: array-dynamic-sized
        property QtObject status_log: QtObject {
            property string caption: "Status Log"
            property string unit: ""
            property string value: ""
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 1
            }
        }

        // @notification: toggle
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: bool
        // @property values: array-static-sized
        property QtObject toggle: QtObject {
            property string caption: "Toggle"
            property string unit: ""
            property bool value: true

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }

            // @property index_0: string
            // @property index_1: string
            property QtObject values: QtObject {
                objectName: "array"
                property string index_0: "True"
                property string index_1: "False"
            }
        }

        // @notification: slider
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-dynamic-sized
        property QtObject slider: QtObject {
            property string caption: "Slider"
            property string unit: "Unit"
            property int value: 2380
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 10000
                property int index_1: 0
                property int index_2: 10
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: infobox_integer
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-dynamic-sized
        property QtObject infobox_integer: QtObject {
            property string caption: "InfoBox Integer"
            property string unit: "Unit"
            property int value: 11
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: infobox_double
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: double
        // @property values: array-dynamic-sized
        property QtObject infobox_double: QtObject {
            property string caption: "InfoBox Double"
            property string unit: "Unit"
            property double value: 11.11
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: infobox_string
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: string
        // @property values: array-dynamic-sized
        property QtObject infobox_string: QtObject {
            property string caption: "InfoBox String"
            property string unit: "Unit"
            property string value: "Pass"
            property var values: []

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }
        }

        // @notification: combobox
        // @property caption: string
        // @property scales: array-static-sized
        // @property states: array-static-sized
        // @property unit: string
        // @property value: int
        // @property values: array-static-sized
        property QtObject combobox: QtObject {
            property string caption: "ComboBox"
            property string unit: ""
            property int value: 0

            signal notificationFinished()

            // @property index_0: int
            // @property index_1: int
            // @property index_2: int
            property QtObject scales: QtObject {
                objectName: "array"
                property int index_0: 0
                property int index_1: 0
                property int index_2: 0
            }

            // @property index_0: int
            property QtObject states: QtObject {
                objectName: "array"
                property int index_0: 0
            }

            // @property index_0: string
            // @property index_1: string
            // @property index_2: string
            property QtObject values: QtObject {
                objectName: "array"
                property string index_0: "Item 1"
                property string index_1: "Item 2"
                property string index_2: "Item 3"
            }
        }

        // @notification: advanced_view_tab
        // @property value: bool
        property QtObject advanced_view_tab: QtObject {
            property bool value: false

            signal notificationFinished()
        }
    }

    /******************************************************************
      * COMMANDS
    ******************************************************************/

    QtObject {
        id: commands

        // @command control_props
        property QtObject control_props: QtObject {
            signal commandSent()

            function update() {
                this.send()
            }

            function send() {
                platformInterface.send({
                    "cmd": "control_props"
                })
                commandSent()
            }
        }

        // @command run
        // @property value: bool
        property QtObject run: QtObject {
            property bool value: false

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "run",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command brake
        // @property value: bool
        property QtObject brake: QtObject {
            property bool value: false

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "brake",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command direction
        // @property value: bool
        property QtObject direction: QtObject {
            property bool value: true

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "direction",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command target_speed
        // @property value: double
        property QtObject target_speed: QtObject {
            property double value: 0

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "target_speed",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command acceleration
        // @property value: double
        property QtObject acceleration: QtObject {
            property double value: 0

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "acceleration",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command toggle
        // @property value: bool
        property QtObject toggle: QtObject {
            property bool value: true

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "toggle",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command slider
        // @property value: int
        property QtObject slider: QtObject {
            property int value: 2380

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "slider",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command infobox_integer
        // @property value: int
        property QtObject infobox_integer: QtObject {
            property int value: 11

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "infobox_integer",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command infobox_double
        // @property value: double
        property QtObject infobox_double: QtObject {
            property double value: 11.11

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "infobox_double",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command infobox_string
        // @property value: string
        property QtObject infobox_string: QtObject {
            property string value: "Pass"

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "infobox_string",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }

        // @command combobox
        // @property value: int
        property QtObject combobox: QtObject {
            property int value: 0

            signal commandSent()

            function update(value) {
                this.set(value)
                this.send()
            }

            function set(value) {
                this.value = value
            }

            function send() {
                platformInterface.send({
                    "cmd": "combobox",
                    "payload": {
                        "value": value
                    }
                })
                commandSent()
            }
        }
    }
}
