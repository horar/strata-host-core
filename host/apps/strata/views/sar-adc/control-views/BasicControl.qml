import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help
import Fonts 1.0

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    Rectangle{
        width: parent.width
        height: parent.height/1.8
        color: "#a9a9a9"
        // color: "transparent"
        id: graphContainer

        Text {
            id: partNumber
            text: "STR-NCD98010-GEVK"
            font.bold: true
            color: "white"
            anchors{
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }

            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter

        }

        SGGraphStatic {
            id: graph
            anchors {
                top: partNumber.bottom
                topMargin: 10

            }
            width: parent.width/2
            height: parent.height - 100
            title: "Time Domain"                  // Default: empty
            xAxisTitle: "Seconds"            // Default: empty
            yAxisTitle: "Voltage"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "green"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 20                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 20                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false

            Component.onCompleted: {
                for (var i = 0; i < 100; i=(i+.1)){
                    series1.append(i, Math.sin(i)+10)
                }
            }
        }

        SGGraphStatic {
            id: graph2
            anchors {
                left: graph.right
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: partNumber.bottom
                topMargin: 10
            }
            width: parent.width/2
            height: parent.height - 100
            textSize: 15
            title: "Frequency Domain"                  // Default: empty
            xAxisTitle: "Seconds"            // Default: empty
            yAxisTitle: "Voltage"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "white"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 20                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 20                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false

            Component.onCompleted: {
                for (var i = 0; i < 100; i=(i+.1)){
                    series1.append(i, Math.sin(i)+10)
                }
            }

            Button {
                id: plotSetting1
                anchors{
                    top: graph2.bottom
                    right: parent.right
                }
                width: ratioCalc * 120
                height : ratioCalc * 50
                background: Rectangle {
                    color: "#00ced1"
                    border.width: 1
                    border.color: "gray"
                    radius: 10

                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "Histrogram"
                    font.bold: true
                    anchors.centerIn: parent
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }
            Button {
                anchors{
                    top: graph2.bottom
                    right: plotSetting1.left
                    rightMargin: 5
                }
                width: ratioCalc * 100
                height : ratioCalc * 50
                background: Rectangle {
                    color: "#00ced1"
                    border.width: 1
                    border.color: "gray"
                    radius: 10
                    Layout.alignment: Qt.AlignCenter
                }
                Text {
                    text: "FTT"
                    font.bold: true
                    anchors.centerIn: parent
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    color: "white"
                }
            }

        }
    }
    Rectangle{
        width: parent.width
        height: parent.height/2
        color: "#696969"
        anchors.top: graphContainer.bottom

        Row{
            anchors.fill: parent

            Column{
                width: 450 * ratioCalc
                height: 400 * ratioCalc
                spacing: 10

                Rectangle {
                    // color: "#c0c0c0"
                    color: "transparent"
                    width: ratioCalc * 400
                    height: ratioCalc * 100

                    ColumnLayout {
                        spacing: 5
                        width: ratioCalc * 400
                        height: ratioCalc * 100
                        Text {
                            id: containerTitle
                            text: "ADC Stimuli"
                            font.bold: true
                            font.pixelSize: 23
                            color: "white"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        SGRadioButtonContainer {
                            id: dvsButtonContainer
                            // Optional configuration:
                            //fontSize: (parent.width+parent.height)/32
                            label: "DVDD:" // Default: "" (will not appear if not entered)
                            labelLeft: true         // Default: true
                            textColor: "white"      // Default: "#000000"  (black)
                            radioColor: "black"     // Default: "#000000"  (black)
                            exclusive: true         // Default: true
                            Layout.alignment: Qt.AlignHCenter

                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10

                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: dvdd1
                                    text: "3.3V"
                                }

                                SGRadioButton {
                                    id: dvdd2
                                    text: "1.8V"

                                }
                            }
                        }
                        SGRadioButtonContainer {
                            id: avddButtonContainer
                            // Optional configuration:
                            //fontSize: (parent.width+parent.height)/32
                            label: "AVDD:" // Default: "" (will not appear if not entered)
                            labelLeft: true         // Default: true
                            textColor: "white"      // Default: "#000000"  (black)
                            radioColor: "black"     // Default: "#000000"  (black)
                            exclusive: true         // Default: true
                            Layout.alignment: Qt.AlignHCenter

                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10

                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: avdd1
                                    text: "3.3V"
                                }

                                SGRadioButton {
                                    id: avdd2
                                    text: "1.8V"

                                }
                            }
                        }
                    }

                }


                Rectangle{
                    width: ratioCalc * 400
                    height: ratioCalc * 50
                    color: "transparent"

                    SGLabelledInfoBox {
                        label: "Input Frequency"
                        info: "1000.5"
                        unit: "kHz"
                        infoBoxWidth: ratioCalc * 150
                        infoBoxHeight : ratioCalc * 40
                        fontSize: 15
                        unitSize: 10
                        infoBoxColor: "black"
                        labelColor: "white"

                        anchors{
                            centerIn: parent
                        }
                    }
                }
                SGStatusListBox {
                    id: interruptError
                    height: parent.height/2.2
                    width: parent.width/1.1
                    title: "Status:"
                    titleBoxColor: "black"
                    titleTextColor: "white"
                    statusBoxColor: " black"
                    statusTextColor: "green"
                    model: faultModel
                }

                ListModel {
                    id: faultModel
                    ListElement {
                            status: "Message 1"
                        }
                    ListElement {
                            status: "Message 2"
                        }
                    ListElement {
                            status: "Message 3"
                        }

                }

            }

            Rectangle {
                width: 350 * ratioCalc
                height: 400 * ratioCalc
                color: "transparent"
                Column{
                    width: 350 * ratioCalc
                    height: 400 * ratioCalc
                    spacing:  10

                    Rectangle {
                        width: 350 * ratioCalc
                        height: 50 * ratioCalc

                        color: "transparent"
                        Button {
                            width: 150 * ratioCalc
                            height: 50 * ratioCalc
                            anchors {
                                centerIn: parent
                            }
                            background: Rectangle {
                                color: "#00ced1"
                                border.width: 1
                                border.color: "gray"
                                radius: 10
                            }
                            Text {
                                text: "Acquire Data"
                                font.bold: true
                                color: "white"
                                anchors.centerIn: parent
                                font.pixelSize: 20
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }


                    Rectangle {
                        id: gaugeContainer
                        width: 350 * ratioCalc
                        height: 200 * ratioCalc
                        Layout.alignment: Qt.AlignHCenter
                        color: "transparent"
                        SGCircularGauge{
                            id:lightGauge
                            anchors.fill: parent
                            gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            minimumValue: 0
                            maximumValue: 100
                            tickmarkStepSize: 10
                            outerColor: "white"
                            unitLabel: "µW"
                            gaugeTitle : "Average" + "\n"+ "Power"
                            value: 50
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                    Rectangle {
                        width:  ratioCalc * 290
                        height:  ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignHCenter

                        SGLabelledInfoBox {
                            id: powerConsumption
                            label: "Power Consumption"
                            info: "92"
                            unit: "uW"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 50
                            fontSize: 15
                            unitSize: 10
                            anchors.fill: parent
                            infoBoxColor: "black"
                            labelColor: "white"

                        }
                    }

                }
            }
            Rectangle {
                width: 350 * ratioCalc
                height: 400 * ratioCalc
//                border.color: "gray"
//                border.width: 2
//                radius: 10
                color: "transparent"

                Text {
                    id: title
                    width: ratioCalc * 50
                    height: ratioCalc * 50
                    text: " ADC Performance \n Metrics"
                    color: "white"
                    anchors{
                        top: parent.top
                        topMargin: 10
                        horizontalCenter: parent.horizontalCenter
                    }
                    font.pixelSize: 20
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    //  fontSizeMode: Text.Fit


                }
                Column {
                    width: ratioCalc * 300
                    height: ratioCalc * 300
                    spacing: 10

                    anchors {
                        top: title.bottom
                        topMargin: 20
                    }

                    Rectangle{
                        width: ratioCalc * 300
                        height: ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignCenter
                        SGLabelledInfoBox {
                            label: "SNR"
                            info: "68.9"
                            unit: "dB"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 40
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{
                        width: ratioCalc * 300
                        height: ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignCenter
                        SGLabelledInfoBox {
                            label: "SNDR"
                            info: "67.8"
                            unit: "dB"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 40
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{
                        width: ratioCalc * 300
                        height: ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignCenter
                        SGLabelledInfoBox {
                            label: "THD"
                            info: "70"
                            unit: "dB"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 40
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{
                        width: ratioCalc * 300
                        height: ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignCenter
                        SGLabelledInfoBox {
                            label: "ENOB"
                            info: "11.5"
                            unit: "bits"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 40
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{
                        width: ratioCalc * 300
                        height: ratioCalc * 50
                        color: "transparent"
                        Layout.alignment: Qt.AlignCenter
                        SGLabelledInfoBox {
                            label: "Offset"
                            info: "2.5"
                            unit: "bits"
                            infoBoxWidth: ratioCalc * 100
                            infoBoxHeight : ratioCalc * 40
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                }
            }
        }
    }
}




