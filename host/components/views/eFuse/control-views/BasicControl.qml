import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property bool holder: false
    property int bitData: 0
    property string binaryConversion: ""
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    property var temp1_noti: platformInterface.status.temp1
    onTemp1_notiChanged: {
        sgCircularGauge.value = temp1_noti
    }
    property var temp2_noti: platformInterface.status.temp2
    onTemp2_notiChanged: {
        sgCircularGauge2.value = temp2_noti
    }
    property var vin_noti: platformInterface.status.vin
    onVin_notiChanged: {
        inputVoltage.info = vin_noti.toFixed(2)
    }
    property var vout_noti: platformInterface.status.vout
    onVout_notiChanged: {
        ouputVoltage.info = vout_noti.toFixed(2)
    }
    property var iin_noti: platformInterface.status.iin
    onIin_notiChanged: {
        inputCurrent.info = iin_noti.toFixed(2)
    }
    property var iout_noti: platformInterface.status.iout
    onIout_notiChanged: {
        ouputCurrent.info = iout_noti.toFixed(2)
    }



    Rectangle{
        width: parent.width
        height: parent.height
        color: "#a9a9a9"
        id: graphContainer

        Text {
            id: partNumber
            text: "eFuse" + " " + platformInterface.board_id.board_id
            font.bold: true
            color: "white"
            anchors{
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            font.pixelSize: 35
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: topSetting
            width: parent.width/2
            height: parent.height/2.5

            anchors {
                horizontalCenter: parent.horizontalCenter
                top: partNumber.bottom
                topMargin: 20
            }
            color: "#696969"

            RowLayout {
                anchors.fill: parent

                SGCircularGauge {
                    id: sgCircularGauge
                    value: platformInterface.periodic_status.temperature1.toFixed(2)
                    minimumValue: -55
                    maximumValue: 125
                    tickmarkStepSize: 10
                    width: parent.width/1.5
                    height: parent.height
                    gaugeRearColor: "white"                  // Default: "#ddd"(background color that gets filled in by gauge)
                    centerColor: "white"
                    outerColor: "white"
                    gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    unitLabel: "RPM"
                    gaugeTitle: "Temp Sensor 1"
                    Layout.alignment: Qt.AlignCenter

                }


                SGCircularGauge {
                    id: sgCircularGauge2
                    width: parent.width/2
                    height: parent.height
                    minimumValue: -55
                    maximumValue: 125
                    value: platformInterface.periodic_status.temperature2.toFixed(2)
                    tickmarkStepSize: 10
                    gaugeRearColor: "white"                  // Default: "#ddd"(background color that gets filled in by gauge)
                    centerColor: "white"
                    outerColor: "white"
                    gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                    gaugeFrontColor2: Qt.rgba(1,0,0,1)
                    unitLabel: "RPM"                        // Default: "RPM"
                    gaugeTitle: "Temp Sensor 2"
                    Layout.alignment: Qt.AlignCenter

                }

            }
        }

        Rectangle {
            id: bottomSetting
            width: parent.width
            height: parent.height/2.5

            anchors {
                left: parent.left
                top: topSetting.bottom
                topMargin: 20
            }
            color: "#696969"

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredWidth: parent.width/3
                    Layout.preferredHeight: parent.height - 100
                    Layout.alignment: Qt.AlignCenter
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent

                        SGLabelledInfoBox {
                            id: inputVoltage
                            width: parent.width
                            height: parent.height/2
                            infoBoxWidth: parent.width/2
                            label: "Input Voltage "
                            info: platformInterface.periodic_status.vin.toFixed(2)
                            unit: "V"
                            infoBoxColor: "black"
                            labelColor: "white"
                            unitSize: ratioCalc * 20
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                        }

                        SGLabelledInfoBox {
                            id: inputCurrent
                            width: parent.width
                            height: parent.height/2
                            infoBoxWidth: parent.width/2
                            label: "Input Current "
                            info: platformInterface.periodic_status.iin.toFixed(2)
                            unit: "A"
                            infoBoxColor: "black"
                            labelColor: "white"
                            fontSize: ratioCalc * 20
                            unitSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                        }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: parent.width/3
                    Layout.preferredHeight: parent.height - 100
                    Layout.alignment: Qt.AlignCenter
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent

                        SGLabelledInfoBox {
                            id: ouputVoltage
                            width: parent.width
                            height: parent.height/2
                            infoBoxWidth: parent.width/2
                            label: "Output Voltage "
                            info: platformInterface.periodic_status.vout.toFixed(2)
                            unit: "V"
                            infoBoxColor: "black"
                            labelColor: "white"
                            unitSize: ratioCalc * 20
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                        }

                        SGLabelledInfoBox {
                            id: ouputCurrent
                            width: parent.width
                            height: parent.height/2
                            infoBoxWidth: parent.width/2
                            label: "Output Current "
                            info: platformInterface.periodic_status.iin.toFixed(2)
                            unit: "A"
                            infoBoxColor: "black"
                            labelColor: "white"
                            fontSize: ratioCalc * 20
                            unitSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                        }
                    }

                }

                Rectangle {
                    Layout.preferredWidth: parent.width/3
                    Layout.preferredHeight: parent.height - 100
                    Layout.alignment: Qt.AlignCenter
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        SGSwitch {
                            id: eFuse1
                            label: "Enable 1"
                            width: parent.width
                            height: parent.height/2.8
                            fontSizeLabel: ratioCalc * 20
                            labelLeft: true              // Default: true (controls whether label appears at left side or on top of switch)
                            checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                            uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                            labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                            switchWidth: 88                // Default: 52 (change for long custom checkedLabels when labelsInside)
                            switchHeight: 26                // Default: 26
                            textColor: "white"              // Default: "black"
                            handleColor: "#33b13b"            // Default: "white"
                            grooveColor: "black"             // Default: "#ccc"
                            grooveFillColor: "black"         // Default: "#0cf"
                            Layout.alignment: Qt.AlignCenter
                            onToggled: {
                                if(checked)
                                    platformInterface.set_enable_1.update("on")
                                else  platformInterface.set_enable_1.update("off")

                            }
                        }


                        SGSwitch {
                            id: eFuse2
                            label: "Enable 2"
                            width: parent.width
                            height: parent.height/3
                            fontSizeLabel: ratioCalc * 20
                            labelLeft: true              // Default: true (controls whether label appears at left side or on top of switch)
                            checkedLabel: "On"       // Default: "" (if not entered, label will not appear)
                            uncheckedLabel: "Off"    // Default: "" (if not entered, label will not appear)
                            labelsInside: true              // Default: true (controls whether checked labels appear inside the control or outside of it
                            switchWidth: 88                 // Default: 52 (change for long custom checkedLabels when labelsInside)
                            switchHeight: 26                // Default: 26
                            textColor: "white"              // Default: "black"
                            handleColor: "#33b13b"            // Default: "white"
                            grooveColor: "black"             // Default: "#ccc"
                            grooveFillColor: "black"         // Default: "#0cf"
                            Layout.alignment: Qt.AlignCenter
                            Layout.topMargin: 10

                            onToggled: {
                                if(checked)
                                    platformInterface.set_enable_2.update("on")
                                else  platformInterface.set_enable_2.update("off")

                            }

                        }

                        SGStatusLight {
                            width: parent.width
                            height: parent.height/3
                            label: "<b>Input Voltage  Good:</b>" // Default: "" (if not entered, label will not appear)
                            labelLeft: true       // Default: true
                            lightSize: ratioCalc * 40          // Default: 50
                            textColor: "white"      // Default: "black"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter

                        }

                    }

                }

            }
        }
    }
}
