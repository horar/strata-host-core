/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12

import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0

UIBase { // start_uibase

    // ======================== General Settings ======================== //

    columnCount: 30
    rowCount: 25

    // ======================== UI Initialization ======================== //

    Component.onCompleted: {

        // ------------------------ Help Messages ------------------------ //
        Help.registerTarget(rect_6a35c, "The input section displays telemetry from the platform by monitoring inputs to motor controller.", 7, "BasicControlHelp") // input rectangle
        Help.registerTarget(layoutRectangle_bead4, "The output section displays telemetry from the platform by monitoring outputs of the motor controller.", 8, "BasicControlHelp") // output rectangle
        Help.registerTarget(b_status_log_help_message, "The status log will show timestamped messages reported by the motor controller. Click the Clear button to clear the status log.", 9, "BasicControlHelp")

        // -------------- Other Startup Tasks -------------- //
        // Such as synchronizing the UI and firmware

    }

    // ======================== UI Objects ======================== //

    // ------------------------ General UI Setup and Titles ------------------------ //

    LayoutText { // start_8695e
        id: b_title
        layoutInfo.uuid: "8695e"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 0

        text: platformInterface.notifications.title.caption
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_8695e

    LayoutText { // start_bb4f0
        id: b_subtitle
        layoutInfo.uuid: "bb4f0"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 1

        text: platformInterface.notifications.subtitle.caption
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#7f7f7f"
    } // end_bb4f0

    LayoutRectangle { // start_6a35c
        id: rect_6a35c
        layoutInfo.uuid: "6a35c"
        layoutInfo.columnsWide: 7
        layoutInfo.rowsTall: 15
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 3

        color: "#ffffff"
        border.width: 3
    } // end_6a35c

    LayoutDivider { // start_c0d6c
        id: divider_c0d6c
        layoutInfo.uuid: "c0d6c"
        layoutInfo.columnsWide: 7
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 3
    } // end_c0d6c

    LayoutRectangle { // start_bead4
        id: layoutRectangle_bead4
        layoutInfo.uuid: "bead4"
        layoutInfo.columnsWide: 20
        layoutInfo.rowsTall: 15
        layoutInfo.xColumns: 9
        layoutInfo.yRows: 3

        color: "#ffffff"
        border.width: 3
    } // end_bead4

    LayoutText { // start_6d841
        id: layoutText_6d841
        layoutInfo.uuid: "6d841"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 2
        layoutInfo.yRows: 3

        text: "Input"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_6d841

    LayoutText { // start_aad3b
        id: layoutText_aad3b
        layoutInfo.uuid: "aad3b"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 3

        text: "Output"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_aad3b

    LayoutDivider { // start_ef0b6
        id: layoutDivider_ef0b6
        layoutInfo.uuid: "ef0b6"
        layoutInfo.columnsWide: 20
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 9
        layoutInfo.yRows: 3
    } // end_ef0b6

   // ------------------------ Gauges and Log ------------------------ //

    LayoutSGCircularGauge { // start_7b02e
        id: b_actual_speed
        layoutInfo.uuid: "7b02e"
        layoutInfo.columnsWide: 10
        layoutInfo.rowsTall: 14
        layoutInfo.xColumns: 10
        layoutInfo.yRows: 3

        // units
        unitText: platformInterface.notifications.actual_speed.unit
        // states
        // TBD or NA, used to disable/enable/gray certain UI elements
        // scales
        maximumValue: platformInterface.notifications.actual_speed.scales.index_0
        minimumValue: platformInterface.notifications.actual_speed.scales.index_1
        tickmarkStepSize: platformInterface.notifications.actual_speed.scales.index_2
        // value
        value: platformInterface.notifications.actual_speed.value
        // values
        // TBD or NA, used for array UI elements

        // change color of gauges to match EMEA's custom colors
        function lerpColor (color1, color2, x){
            if (Qt.colorEqual(color1, color2)){
                return color1;
            } else {
                return Qt.hsva(
                    color1.hsvHue * (1 +  x) + color2.hsvHue * x,
                    color1.hsvSaturation * (1 + x) + color2.hsvSaturation * x,
                    color1.hsvValue * (1 + x) + color2.hsvValue * x, 1
                    );
            }
        }
    } // end_7b02e

    LayoutText { // start_18cff
        id: b_actual_speed_caption
        layoutInfo.uuid: "18cff"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 13
        layoutInfo.yRows: 16

        text: platformInterface.notifications.actual_speed.caption

        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_18cff

    LayoutSGCircularGauge { // start_116ab
        id: b_board_temp
        layoutInfo.uuid: "116ab"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 9
        layoutInfo.xColumns: 23
        layoutInfo.yRows: 7

        // units
        unitText: platformInterface.notifications.board_temp.unit
        // states
        // TBD or NA, used to disable/enable/gray certain UI elements
        // scales
        maximumValue: platformInterface.notifications.board_temp.scales.index_0
        minimumValue: platformInterface.notifications.board_temp.scales.index_1
        tickmarkStepSize: platformInterface.notifications.board_temp.scales.index_2
        // value
        value: platformInterface.notifications.board_temp.value
        // values
        // TBD or NA, used for array UI elements

        // change color of gauges to match EMEA's custom colors
        function lerpColor (color1, color2, x){
            if (Qt.colorEqual(color1, color2)){
                return color1;
            } else {
                return Qt.hsva(
                    color1.hsvHue * (1 +  x) + color2.hsvHue * x,
                    color1.hsvSaturation * (1 + x) + color2.hsvSaturation * x,
                    color1.hsvValue * (1 + x) + color2.hsvValue * x, 1
                    );
            }
        }
    } // end_116ab

    LayoutText { // start_d490f
        id: b_board_temp_caption
        layoutInfo.uuid: "d490f"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 23
        layoutInfo.yRows: 15

        text: platformInterface.notifications.board_temp.caption

        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_d490f

    LayoutSGCircularGauge { // start_b06c4
        id: b_input_voltage
        layoutInfo.uuid: "b06c4"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 9
        layoutInfo.xColumns: 2
        layoutInfo.yRows: 7

        // units
        unitText: platformInterface.notifications.input_voltage.unit
        // states
        // TBD or NA, used to disable/enable/gray certain UI elements
        // scales
        maximumValue: platformInterface.notifications.input_voltage.scales.index_0
        minimumValue: platformInterface.notifications.input_voltage.scales.index_1
        tickmarkStepSize: platformInterface.notifications.input_voltage.scales.index_2
        // value
        value: platformInterface.notifications.input_voltage.value
        valueDecimalPlaces: 1
        // values
        // TBD or NA, used for array UI elements

        // change color of gauges to match EMEA's custom colors
        function lerpColor (color1, color2, x){
            if (Qt.colorEqual(color1, color2)){
                return color1;
            } else {
                return Qt.hsva(
                    color1.hsvHue * (1 +  x) + color2.hsvHue * x,
                    color1.hsvSaturation * (1 + x) + color2.hsvSaturation * x,
                    color1.hsvValue * (1 + x) + color2.hsvValue * x, 1
                    );
            }
        }
    } // end_b06c4

    LayoutText { // start_f52c7
        id: b_input_voltage_caption
        layoutInfo.uuid: "f52c7"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 2
        layoutInfo.yRows: 15

        text: platformInterface.notifications.input_voltage.caption

        fontSizeMode: Text.Fit
        font.pixelSize: 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: "#000000"
    } // end_f52c7

    LayoutContainer { // start_abcde
        id: b_status_log
        layoutInfo.uuid: "abcde"
        layoutInfo.columnsWide: 25
        layoutInfo.rowsTall: 5
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 19

        contentItem: SGStatusLogBox {
            id: b_status_log_box
            title: platformInterface.notifications.status_log.caption
            filterEnabled: false

            Connections {
                target: platformInterface.notifications.status_log
                // Create status log message in the format of "hh:mm:ss:ms: Error message from status log notification"
                onNotificationFinished: {
                    var status_log_message = ""
                    var d = new Date()
                    var time_hhmmss = d.toTimeString().split(' ')[0] // hh:mm:ss format
                    var time_ms = String(d.getMilliseconds()).padStart(3, '0') // three digits of ms with zeros padded in front
                    status_log_message = time_hhmmss + ":" + time_ms + ": " + platformInterface.notifications.status_log.value
                    b_status_log_box.append(status_log_message)
                }
            }
        }
    } // end_abcde

    LayoutButton { // start_c06e2
        id: b_status_log_box_clear
        layoutInfo.uuid: "c06e2"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 5
        layoutInfo.xColumns: 27
        layoutInfo.yRows: 19

        text: "Clear"

        onClicked: {
            b_status_log_box.clear()
        }
    } // end_c06e2

    // ======================== Help Message Helper Rectangles ======================== //

    LayoutRectangle { // start_60e25
        id: b_status_log_help_message
        layoutInfo.uuid: "60e25"
        layoutInfo.columnsWide: 28
        layoutInfo.rowsTall: 5
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 19
        opacity: 0
    } // end_60e25

} // end_uibase