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
        height: parent.height/1.7
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
            height: parent.height - 130
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
            height: parent.height - 130
            textSize: 15
            title: "Frequency Domain"                  // Default: empty
            xAxisTitle: "Frequency (KHz)"            // Default: empty
            yAxisTitle: "Power (dB)"          // Default: empty
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
            GridLayout{
                width: ratioCalc * 250
                height: ratioCalc * 75
                anchors{
                    top: graph2.bottom
                    horizontalCenter: graph2.horizontalCenter
                }
                Button {
                    id: plotSetting1
                    width: ratioCalc * 130
                    height : ratioCalc * 50
                    text: qsTr(" Histogram")
                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: plotSetting1.down ? "#17a81a" : "black"//"#21be2b"
                        border.width: 1
                        color: "#33b13b"
                        radius: 10
                    }
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Text {
                        text: plotSetting1.text
                        font: plotSetting1.font
                        opacity: enabled ? 1.0 : 0.3
                        color: plotSetting1.down ? "#17a81a" : "white"//"#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        graph2.yAxisTitle = "Hit Count"
                        graph2.xAxisTitle = "Codes"
                    }
                }
                Button {
                    id: plotSetting2
                    width: ratioCalc * 130
                    height : ratioCalc * 50
                    text: qsTr("FFT")
                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: plotSetting2.down ? "#17a81a" : "black"//"#21be2b"
                        border.width: 1
                        color: "#33b13b"
                        radius: 10
                    }
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Text {
                        text: plotSetting2.text
                        font: plotSetting2.font
                        opacity: enabled ? 1.0 : 0.3
                        color: plotSetting2.down ? "#17a81a" : "white"//"#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onClicked: {
                        graph2.yAxisTitle = "Power (dB)"
                        graph2.xAxisTitle = "Frequency (KHz)"
                    }
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
            Rectangle {
                width:parent.width/2.7
                height : parent.height
                anchors{
                    top: parent.top
                    topMargin: 10

                }
                color: "transparent"


                Rectangle{
                    id: adcSetting
                    width: parent.width
                    height: parent.height/4
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent

                        Text {
                            width: ratioCalc * 50
                            height : ratioCalc * 50
                            id: containerTitle
                            text: "ADC Stimuli"
                            font.bold: true
                            font.pixelSize: 20
                            color: "white"
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
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
                            Layout.alignment: Qt.AlignCenter

                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10

                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: dvdd1
                                    text: "3.3V"
                                    checked: true
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
                            Layout.alignment: Qt.AlignCenter

                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10

                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: avdd1
                                    text: "3.3V"
                                    checked: true
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
                    id: frequencySetting
                    width:  parent.width
                    height : parent.height/6
                    color: "transparent"
                    anchors{
                        top: adcSetting.bottom
                    }

                    SGSubmitInfoBox{
                        label: "Input Frequency"
                        input: "1000.5"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight: parent.height/2
                        infoBoxColor: "black"
                        textColor: "White"
                        fontSize: 20 * ratioCalc
                        buttonVisible: false
                        anchors.centerIn: parent
                        unit: "kHz"
                    }
                }
                Rectangle{
                    id: dataModel
                    width:  parent.width/0.9
                    height : parent.height/3
                    color: "transparent"

                    anchors{
                        top:frequencySetting.bottom
                    }

                    SGStatusListBox {
                        id: interruptError
                        implicitWidth: parent.width/1.5
                        implicitHeight : parent.height
                        title: "Status:"
                        titleBoxColor: "black"
                        titleTextColor: "white"
                        statusBoxColor: " black"
                        statusTextColor: "green"
                        model: faultModel
                        anchors.centerIn: parent
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

            }


            Rectangle {
                width:parent.width/4
                height : parent.height
                color: "transparent"

                Rectangle{
                    id: acquireButtonContainer
                    color: "transparent"
                    width: parent.width
                    height: parent.height/5
                    Button {
                        id: acquireDataButton
                        width: parent.width/3
                        height: parent.height/1.7

                        text: qsTr("Acquire \n Data")
                        anchors.centerIn: parent
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            border.color: acquireDataButton.down ? "#17a81a" : "black"//"#21be2b"
                            border.width: 1
                            color: "#33b13b"
                            radius: 10
                        }

                        contentItem: Text {
                            text: acquireDataButton.text
                            font: acquireDataButton.font
                            opacity: enabled ? 1.0 : 0.3
                            color: acquireDataButton.down ? "#17a81a" : "white"//"#21be2b"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight

                        }
                    }
                }
                Rectangle {
                    id: gaugeContainer
                    anchors{
                        top: acquireButtonContainer.bottom
                    }

                    width: parent.width
                    height: parent.height/2.4
                    color: "transparent"
                    SGCircularGauge{
                        id:lightGauge
                        anchors {
                            fill: parent
                            horizontalCenter: parent.horizontalCenter
                        }
                        gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        minimumValue: 0
                        maximumValue: 100
                        tickmarkStepSize: 10
                        outerColor: "white"
                        unitLabel: "µW"
                        gaugeTitle : "Average" + "\n"+ "Power"
                        value: 50
                    }
                }
                Rectangle {
                    width:  parent.width
                    height : parent.height/6
                    color: "transparent"
                    anchors.top: gaugeContainer.bottom
                    SGLabelledInfoBox {
                        id: powerConsumption
                        label: "Power Consumption"
                        info: "92"
                        unit: "µW"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight: parent.height/2
                        fontSize: 15
                        unitSize: 10
                        infoBoxColor: "black"
                        labelColor: "white"
                        infoTextColor: "#48d1cc"
                        anchors.centerIn: parent
                    }
                }
            }


            Rectangle {
                width:parent.width/3
                height : parent.height
                color: "transparent"
                Rectangle {
                    id: titleContainer
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    Text {
                        id: title
                        text: " ADC Performance \n Metrics"
                        color: "white"
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column{
                    width: parent.width
                    height: parent.height - titleContainer.height
                    anchors{
                        top: titleContainer.bottom
                    }

                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "SNR"
                            info: "68.9"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                            infoTextColor: "#ffa500"
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "SNDR"
                            info: "67.8"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                            infoTextColor: "#f0e68c"
                        }
                    }
                    Rectangle{

                        color: "transparent"
                        width: parent.width
                        height: parent.height/7
                        SGLabelledInfoBox {
                            label: "THD"
                            info: "70"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                            infoTextColor: "#ffff00"
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"
                        SGLabelledInfoBox {
                            label: "ENOB"
                            info: "11.5"
                            unit: "bits"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                            infoTextColor: "#cd5c5c"
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "Offset"
                            info: "2.5"
                            unit: "bits"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
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
