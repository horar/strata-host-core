import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help
import QtQuick.Controls 2.12

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true

    property var obj: {
        "value": "my_cmd_simple_periodic",
        "payload": {
            "adc_read": platformInterface.notifications.my_cmd_simple_periodic.adc_read.toFixed(3),
            "io_read": platformInterface.notifications.my_cmd_simple_periodic.io_read
        }
    }

    property var my_cmd_simple_start_periodic_obj: {
        "value": "my_cmd_simple_periodic_update",
        "payload": {
            "run_state": true,
            "interval": 2000,
            "run_count": -1
        }
    }

    property var my_cmd_simple_stop_periodic_obj: {
        "value": "my_cmd_simple_periodic_update",
        "payload": {
            "run_state": false,
            "interval": 2000,
            "run_count": -1
        }
    }


    property var my_cmd_simple_obj: {
        "value": "my_cmd_simple",
        "payload": {
            "io":gpio.checked,
            "dac": parseFloat(dac.text)
        }
    }


    function yourDataValueHere() {
        return Math.random()
    }
    property var obj1: {
        "value":"my_cmd_complex_periodic",
        "payload":{
            "bool_array":platformInterface.notifications.my_cmd_complex_periodic.bool_array,
            "bool_array_rval":platformInterface.notifications.my_cmd_complex_periodic.bool_array_rval,
            "bool_vector":platformInterface.notifications.my_cmd_complex_periodic.bool_vector,
            "float_array_3dec":platformInterface.notifications.my_cmd_complex_periodic.float_array_3dec,
            "float_array_rval_4dec":platformInterface.notifications.my_cmd_complex_periodic.float_array_rval_4dec,
            "float_vector_5dec":platformInterface.notifications.my_cmd_complex_periodic.float_vector_5dec,
            "int_array":platformInterface.notifications.my_cmd_complex_periodic.int_array,
            "int_array_rval":platformInterface.notifications.my_cmd_complex_periodic.int_array_rval,
            "int_vector":platformInterface.notifications.my_cmd_complex_periodic.int_vector,
            "single_bool":platformInterface.notifications.my_cmd_complex_periodic.single_bool,
            "single_bool_rval":platformInterface.notifications.my_cmd_complex_periodic.single_bool_rval,
            "single_float_1dec":platformInterface.notifications.my_cmd_complex_periodic.single_float_1dec,
            "single_float_rval_2dec":platformInterface.notifications.my_cmd_complex_periodic.single_float_rval_2dec,
            "single_int":platformInterface.notifications.my_cmd_complex_periodic.single_int,
            "single_int_rval":platformInterface.notifications.my_cmd_complex_periodic.single_int_rval,
            "single_string":platformInterface.notifications.my_cmd_complex_periodic.single_string,
            "string_array":platformInterface.notifications.my_cmd_complex_periodic.string_array,
            "string_array_rval":platformInterface.notifications.my_cmd_complex_periodic.string_array_rval,
            "string_literal":platformInterface.notifications.my_cmd_complex_periodic.string_literal,
            "string_vector":platformInterface.notifications.my_cmd_complex_periodic.string_vector
        }

    }

    GridLayout {
        width: parent.width
        height: parent.height/1.1
        anchors.centerIn: parent
        rows: 4
        columns: 2

        function openFile(fileUrl) {
            var request = new XMLHttpRequest();
            request.open("GET", fileUrl, false);
            request.send(null);
            return request.responseText;
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: gpioSwitchLabel
                        target: gpio
                        text: "GPIO On/Off State"
                        font.bold: true
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideTopCenter

                        SGSwitch {
                            id: gpio
                            width: 50

                            // 'checked' state is bound to and sets the
                            // _motor_running_control property in PlatformInterface
                            //checked: platformInterface.commands.my_cmd_simple.io
                            onCheckedChanged:{
                                platformInterface.commands.my_cmd_simple.update(gpio.checked,parseFloat(dac.text))
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: dacSwitchLabel
                        target: dac
                        text: "DAC State"
                        anchors.centerIn: parent
                        alignment: SGAlignedLabel.SideTopCenter

                        SGSubmitInfoBox {
                            id: dac
                            width: 50
                            text: "0.5"
                            //value: platformInterface.commands.my_cmd_simple.dac
                            onAccepted: {
                                platformInterface.commands.my_cmd_simple.update(gpio.checked,parseFloat(dac.text))
                            }
                        }
                    }
                }
            }
        }


        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "light gray"
            ScrollView {
                id: frame3
                clip: true
                anchors.fill: parent
                //other properties
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                SGText {
                    anchors.fill: parent
                    text: "Send: \n" + JSON.stringify(my_cmd_simple_obj,null,4) +
                          "\n Recevied: \n " + JSON.stringify(obj, null, 4)
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                spacing: 5
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.5
                    color: "red"
                    SGGraph{
                        id: timedGraphAxis
                        anchors.fill: parent
                        title: "Timed Graph - Points Move"
                        yMin: 0
                        yMax: 1
                        xMin: 0
                        xMax: 5
                        xTitle: "X Axis"
                        yTitle: "Y Axis"
                        panXEnabled: false
                        panYEnabled: false
                        zoomXEnabled: false
                        zoomYEnabled: false
                        autoUpdate: false
                        xGrid: true
                        yGrid: true
                        Component.onCompleted: {
                            let movingCurve = createCurve("movingCurve")
                            movingCurve.color = "turquoise"
                            movingCurve.autoUpdate = false
                        }

                        Timer {
                            id: graphTimerAxis
                            interval: 60
                            running: false
                            repeat: true

                            property real startTime
                            property real lastTime

                            onRunningChanged: {
                                if (running){
                                    timedGraphAxis.curve(0).clear()
                                    startTime = Date.now()
                                    lastTime = startTime
                                    timedGraphAxis.xMin = -5
                                    timedGraphAxis.xMax = 0
                                }
                            }

                            onTriggered: {
                                let currentTime = Date.now()
                                timedGraphAxis.curve(0).append((currentTime - startTime)/1000, yourDataValueHere())
                                timedGraphAxis.shiftXAxis((currentTime - lastTime)/1000)
                                removeOutOfViewPoints()
                                timedGraphAxis.update()
                                lastTime = currentTime
                            }

                            function removeOutOfViewPoints() {
                                // recursively clean up points that have moved out of view
                                if (timedGraphAxis.curve(0).at(0).x < timedGraphAxis.xMin) {
                                    timedGraphAxis.curve(0).remove(0)
                                    removeOutOfViewPoints()
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Column {
                        anchors {
                            verticalCenter: parent.verticalCenter
                        }
                        spacing: 5

                        SGButton {
                            text: "Start/stop \n timed graphing"
                            onClicked: {
                                if(graphTimerAxis.running === true) {
                                    platformInterface.commands.my_cmd_simple_periodic_update.update(false,2000,-1)
                                }
                                else {
                                    platformInterface.commands.my_cmd_simple_periodic_update.update(true,2000,-1)
                                }
                                graphTimerAxis.running = !graphTimerAxis.running

                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "light gray"
            ScrollView {
                id: frame2
                clip: true
                anchors.fill: parent
                //other properties
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                SGText {
                    anchors.fill: parent
                    text: {
                        if(graphTimerAxis.running === true)
                            "Send: \n" + JSON.stringify(my_cmd_simple_start_periodic_obj,null,4)
                        else
                            "Send: \n" + JSON.stringify(my_cmd_simple_stop_periodic_obj,null,4)
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            ColumnLayout {
                anchors.fill: parent
                RowLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: infoBoxLabel
                            target: infoBox
                            text: "infoBox"
                            font.bold: true
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideTopCenter

                            SGInfoBox {
                                id: infoBox
                                width: 55
                                text: platformInterface.notifications.my_cmd_complex_periodic.float_array_3dec.float_array_3dec_0
                            }
                        }

                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: infoBox2Label
                            target: infoBox2
                            text: "infoBox2"
                            font.bold: true
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideTopCenter

                            SGInfoBox {
                                id: infoBox2
                                width: 55
                                text: platformInterface.notifications.my_cmd_complex_periodic.float_array_rval_4dec.float_array_rval_4dec_1
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGAlignedLabel {
                            id: infoBox3Label
                            target: infoBox3
                            text: "infoBox3"
                            font.bold: true
                            anchors.centerIn: parent
                            alignment: SGAlignedLabel.SideTopCenter

                            SGInfoBox {
                                id: infoBox3
                                width: 55
                                text: platformInterface.notifications.my_cmd_complex_periodic.int_array_rval.int_array_rval_2
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    /*
                      This version of SGStatusLogBox shows how it can be customized for delegates made up of selectable text.
                       This is more efficient for things like output logs (1000+ lines) than a single text component as listView caches out-of-view delegates.
                    */
                    SGStatusLogBoxSelectableText {
                        id: logBoxText
                        title: "Selectable Text Status Logs"
                        filterEnabled: false
                        height: parent.height
                        width: parent.width/1.5
                        anchors.centerIn: parent

                        Component.onCompleted: {
                            for (let i = 0; i < 10; i++){
                                logBoxText.append("Message " + i)
                            }
                        }
                    }
                }
            }

        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "light gray"
            ScrollView {
                id: frame
                clip: true
                anchors.fill: parent
                //other properties
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                SGText {
                    id: content
                    anchors.fill: parent
                    text: {
                        "Received:" + "\n" + JSON.stringify(obj1, null, 4)
                    }
                }
            }
        }
    }
}


//import QtQuick 2.12
//import QtQuick.Layouts 1.12

//import tech.strata.sgwidgets 1.0
//import tech.strata.sgwidgets 0.9 as Widget09
//import "qrc:/js/help_layout_manager.js" as Help

//Widget09.SGResponsiveScrollView {
//    id: root

//    minimumHeight: 800
//    minimumWidth: 1000

//    Rectangle {
//        id: container
//        parent: root.contentItem
//        anchors {
//            fill: parent
//        }
//        color: "#DDA"

//        Rectangle {
//            color: "transparent"
//            opacity: .25
//            anchors {
//                centerIn: parent
//            }
//            width: minimumWidth
//            height: minimumHeight
//            border {
//                width: 1
//                color: "#000"
//            }

//            Text {
//                color:"#000"
//                text: "This rectangle represents the minimum height and width of this UI before it degrades to a scrollview"
//            }
//        }

//        Text {
//            id: name
//            text: "Basic Control View"
//            font {
//                pixelSize: 60
//            }
//            color:"white"
//            anchors {
//                centerIn: parent
//            }
//        }

//        Component.onCompleted: {
//            Help.registerTarget(motorSwitch, "This switch's state is set by platform notification and also can send platform commands. It is also sync'ed across Basic and Advanced control views.", 1, "controlHelp")
//        }

//        SGAlignedLabel {
//            id: motorSwitchLabel
//            target: motorSwitch
//            text: "Motor On/Off"
//            anchors {
//                top: name.bottom
//                horizontalCenter: name.horizontalCenter
//            }
//            alignment: SGAlignedLabel.SideTopCenter

//            SGSwitch {
//                id: motorSwitch
//                width: 50

//                // 'checked' state is bound to and sets the
//                // _motor_running_control property in PlatformInterface
//                checked: platformInterface._motor_running_control
//                onCheckedChanged: platformInterface._motor_running_control = checked
//            }
//        }

//        SGCircularGauge {
//            id: speedGauge
//            anchors {
//                top: motorSwitchLabel.bottom
//                horizontalCenter: name.horizontalCenter
//            }
//            height: 200
//            width: 200

//            value: platformInterface._motor_speed
//        }
//    }
//}
