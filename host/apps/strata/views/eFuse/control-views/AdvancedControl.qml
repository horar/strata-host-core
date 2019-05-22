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

    Rectangle{
        width: parent.width
        height: parent.height
        color: "#a9a9a9"
        id: graphContainer

        Text {
            id: partNumber
            text: "eFuse"
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
            width: parent.width/2.4
            height: parent.height/2

            anchors {
                left: parent.left
                leftMargin: 40
                top: partNumber.bottom
                topMargin: 20
            }
            color: "#696969"

            ColumnLayout {
                anchors.fill: parent

                SGCircularGauge {
                    id: sgCircularGauge
                    value: 50
                    minimumValue: 0
                    maximumValue: 100
                    tickmarkStepSize: 10
                    width: parent.width
                    height: parent.height/3
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
                    value: 50
                    width: parent.width
                    height: parent.height/3
                    minimumValue: 0
                    maximumValue: 100
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
            id: leftSetting
            width: parent.width/2
            height: parent.height/2

            anchors {
                left: topSetting.right
                leftMargin: 10
                top: partNumber.bottom
                topMargin: 20
            }
            color: "#696969"
            ColumnLayout {
                anchors.fill: parent
                Text {
                    text: "Telemetry"
                    font.bold: true
                    color: "white"
                    font.pixelSize: ratioCalc * 30
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignCenter

                }

                SGLabelledInfoBox {
                    id: inputVoltage
                    Layout.preferredWidth: parent.width/2
                    Layout.preferredHeight: parent.height/6
                    infoBoxWidth: parent.width/3
                    label: "Input Voltage "
                    info: "100"
                    unit: "V"
                    infoBoxColor: "black"
                    labelColor: "white"
                    unitSize: ratioCalc * 20
                    fontSize: ratioCalc * 20
                    Layout.alignment: Qt.AlignCenter
                }

                SGLabelledInfoBox {
                    id: inputCurrent
                    Layout.preferredWidth: parent.width/2
                    Layout.preferredHeight: parent.height/6
                    infoBoxWidth: parent.width/3
                    label: "Input Current "
                    info: "100"
                    unit: "A"
                    infoBoxColor: "black"
                    labelColor: "white"
                    fontSize: ratioCalc * 20
                    unitSize: ratioCalc * 20
                    Layout.alignment: Qt.AlignCenter
                }
                SGLabelledInfoBox {
                    id: ouputVoltage
                    Layout.preferredWidth: parent.width/2
                    Layout.preferredHeight: parent.height/6
                    infoBoxWidth: parent.width/3
                    label: "Output Voltage "
                    info: "100"
                    unit: "V"
                    infoBoxColor: "black"
                    labelColor: "white"
                    unitSize: ratioCalc * 20
                    fontSize: ratioCalc * 20
                    Layout.alignment: Qt.AlignCenter
                }

                SGLabelledInfoBox {
                    id: ouputCurrent
                    Layout.preferredWidth: parent.width/2
                    Layout.preferredHeight: parent.height/6
                    infoBoxWidth: parent.width/3
                    label: "Output Current "
                    info: "100"
                    unit: "A"
                    infoBoxColor: "black"
                    labelColor: "white"
                    fontSize: ratioCalc * 20
                    unitSize: ratioCalc * 20
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight {
                    width: parent.width
                    height: parent.height/8
                    label: "<b>Input Voltage Good:</b>" // Default: "" (if not entered, label will not appear)
                    labelLeft: true       // Default: true
                    lightSize: ratioCalc * 30         // Default: 50
                    textColor: "white"      // Default: "black"
                    fontSize: ratioCalc * 20
                    Layout.alignment: Qt.AlignCenter
                }
                RowLayout {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: parent.height/8
                    Layout.alignment: Qt.AlignCenter
                    SGStatusLight {
                        width: parent.width/2
                        height: parent.height
                        label: "<b>Thermal Failure 1:</b>" // Default: "" (if not entered, label will not appear)
                        labelLeft: true       // Default: true
                        lightSize: ratioCalc * 30           // Default: 50
                        textColor: "white"      // Default: "black"
                        fontSize: ratioCalc * 20
                        Layout.alignment: Qt.AlignCenter
                    }
                    SGStatusLight {
                        width: parent.width/2
                        height: parent.height
                        label: "<b>Thermal Failure 2:</b>" // Default: "" (if not entered, label will not appear)
                        labelLeft: true       // Default: true
                        lightSize: ratioCalc * 30           // Default: 50
                        textColor: "white"      // Default: "black"
                        fontSize: ratioCalc * 20
                        Layout.alignment: Qt.AlignCenter
                    }
                }

            }
        }

        Rectangle {
            id: bottomSetting
            width: parent.width
            height: parent.height/3

            anchors {
                top: topSetting.bottom
                topMargin: 10
            }
            color: "#696969"

            Text {
                id: titleControl
                text: "Control"
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
                id: bottomLeftSetting
                width: parent.width/2.5
                height: parent.height/1.5
                color: "#696969"
                anchors {
                    left: parent.left
                    top: titleControl.bottom
                    topMargin: 5
                }

                ColumnLayout {
                    anchors.fill: parent
                    SGSwitch {
                        id: eFuse1
                        label: "Enable 1"
                        width: parent.width
                        height: parent.height/3
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
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SGComboBox {
                        id: rlim1
                        comboBoxWidth: parent.width/4
                        comboBoxHeight: parent.height/6
                        label: "<b>RLIM 1</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "white"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["100", "55", "38", "29"]
                        Layout.alignment: Qt.AlignCenter
                        fontSize: ratioCalc * 20
                    }

                    SGComboBox {
                        id: sr1
                        comboBoxWidth: parent.width/4
                        comboBoxHeight: parent.height/6
                        label: "<b>\t SR 1</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "white"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["1ms", "5ms"]
                        Layout.alignment: Qt.AlignCenter

                        fontSize: ratioCalc * 20
                    }


                }
            }
            Rectangle {
                id: middleSetting
                width: parent.width/5
                height: parent.height/1.5
                color: "#696969"
                anchors {
                    left: bottomLeftSetting.right
                    leftMargin: 20
                    top: titleControl.bottom
                    topMargin: 5
                }
                Button {
                    id: plotSetting2
                    width: ratioCalc * 130
                    height : ratioCalc * 50
                    text: qsTr("Short Circuit EN")
                    checkable: true
                    background: Rectangle {
                        id: backgroundContainer2
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: plotSetting2.down ? "#17a81a" : "black"//"#21be2b"
                        border.width: 1
                        color: "#33b13b"
                        radius: 10
                    }
                    anchors.centerIn: parent

                    contentItem: Text {
                        text: plotSetting2.text
                        font: plotSetting2.font
                        opacity: enabled ? 1.0 : 0.3
                        color: plotSetting2.down ? "#17a81a" : "white"//"#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }

            }

            Rectangle {
                id: bottomRightSetting
                width: parent.width/2.5
                height: parent.height/1.5
                color: "#696969"
                anchors {
                    left: middleSetting.right
                    leftMargin: 20
                    top: titleControl.bottom
                    topMargin: 5
                }

                ColumnLayout {
                    anchors.fill: parent
                    SGSwitch {
                        id: eFuse2
                        label: "Enable 2"
                        width: parent.width
                        height: parent.height/2
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
                        Layout.alignment: Qt.AlignHCenter
                    }

                    SGComboBox {
                        id: rlim2
                        comboBoxWidth: parent.width/4
                        comboBoxHeight: parent.height/6
                        label: "<b>RLIM 2</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "white"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["100", "55", "38", "29"]
                        Layout.alignment: Qt.AlignHCenter
                        fontSize: ratioCalc * 20
                    }

                    SGComboBox {
                        id: sr2
                        comboBoxWidth: parent.width/4
                        comboBoxHeight: parent.height/6
                        label: "<b>\t SR 2</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true            // Default: true
                        textColor: "white"         // Default: "black"
                        indicatorColor: "#33b13b"      // Default: "#aaa"
                        borderColor: "black"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        model: ["1ms", "5ms"]
                        Layout.alignment: Qt.AlignHCenter
                        fontSize: ratioCalc * 20
                    }
                }
            }
        }
    }
}
