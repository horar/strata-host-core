import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "qrc:/../SGAccordion/"
import "qrc:/../SGSwitch/"
import "qrc:/../SGSlider/"
import "qrc:/../SGSegmentedButtonStrip/"
import "qrc:/../SGCircularGauge/"
import "qrc:/../SGComboBox/"
import "qrc:/../SGGraph/"
import "qrc:/../SGLabelledInfoBox/"
import "qrc:/../SGOutputLogBox/"
import "qrc:/../SGPopout/"
import "qrc:/../SGRadioButton/"
import "qrc:/../SGStatusLight/"
import "qrc:/../SGStatusListBox/"
import "qrc:/../SGSubmitInfoBox/"
import "qrc:/../SGToolTipPopup/"
import "qrc:/../SGCapacityBar/"

Window {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("SpyGlass Widget Gallery")


    SGAccordion {
        id: accordion

        width: mainWindow.width
        height: mainWindow.height

        // accordionItems contains a ColumnLayout as a container for SGAccordionItems
        accordionItems:   Column { // must have ColumnLayout as container since loader works only with single widgets
            spacing: 0

            SGAccordionItem {
                title: "SG Switch"
                open: false

                // contents contains SGAccordionItem content
                contents: Item {  // must have some Item as container for multiple widgets since loader only works with single widgets
                    height: childrenRect.height + 40

                    SGSwitch {
                        id: sgSwitch

                        // Optional Configuration:
                        label: "<b>Switch:</b>"         // Default: "" (if not entered, label will not appear)
                        labelLeft: false                // Default: true
                        checkedLabel: "Switch On"       // Default: "" (if not entered, label will not appear)
                        uncheckedLabel: "Switch Off"    // Default: "" (if not entered, label will not appear)
                        switchWidth: 84                 // Default: 52 (change for long custom checkedLabels when labelsInside)

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        onCheckedChanged: console.log("Switch toggled")
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Tool Tip Popup"

                contents: Item{
                    height: childrenRect.height + 40

                    Rectangle {
                        id: hoverContainer
                        color: "tomato"
                        height: 50
                        width: hoverText.contentWidth + 40

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 40
                        }

                        Text {
                            id: hoverText
                            text: qsTr("Hover Here")
                            color: "white"
                            anchors {  centerIn: parent }
                        }

                        MouseArea {
                            id: hoverArea
                            anchors { fill: parent }
                            hoverEnabled: true
                        }

                        SGToolTipPopup {
                            id: sgToolTipPopup

                            showOn: hoverArea.containsMouse
                            anchors {
                                bottom: hoverText.top
                                horizontalCenter: hoverText.horizontalCenter
                            }
                            z:50

                            // Optional Configuration:
                            radius: 8       // Default: 5 (0 for square)
                            color: "#0ce"   // Default: "#00ccee"

                            // Content can contain any single object (which can have nested objects within it)
                            content: Text {
                                text: qsTr("This is a SGToolTipPopup")
                                color: "white"
                            }
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Slider"

                contents: Item{
                    height: childrenRect.height + 40

                    SGSlider {
                        id: sgSliderCustom
                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        label: "RPM:"              // Default: "" (if not entered, label will not appear)
                        labelLeft: false             // Default: true
                        width: 300
                        grooveColor: "#ddd"   // Default: "#dddddd"
                        grooveFillColor: "lightgreen"      // Default: "#888888"
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Radio Button"

                contents: Item{
                    height: childrenRect.height + 40

                    SGRadioButtonContainer {
                        id: buttons

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        // Optional configuration:
                        label: "<b>Radio Buttons:</b>" // Default: "" (will not appear if not entered)
                        labelLeft: false

                        radioGroup: GridLayout {
                            columnSpacing: 10
                            rowSpacing: 10
                            columns: 1          // Comment this line for horizontal row layout

                            property alias ps : ps
                            property alias trap: trap
                            property alias square: square

                            SGRadioButton {
                                id: ps
                                text: "Pseudo-Sinusoidal"
                                checked: true
                                onCheckedChanged: { if (checked) console.log ( "PS Checked!") }
                            }

                            SGRadioButton {
                                id: trap
                                text: "Trapezoidal"
                                onCheckedChanged: { if (checked) console.log ( "Trap Checked!") }
                                enabled: false
                            }

                            SGRadioButton {
                                id: square
                                text: "Square"
                                onCheckedChanged: { if (checked) console.log ( "Square Checked!") }
                            }
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Segmented Button Strip"

                contents: Item{
                    height: childrenRect.height + 40

                    SGSegmentedButtonStrip {
                        id: segmentedButtonsExample

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        label: "Input:"                 // Default: "" (will not appear if not entered)
                        labelLeft: false                // Default: true (true: label on left, false: label on top)

                        segmentedButtons: GridLayout {
                            columnSpacing: 2

                            SGSegmentedButton{
                                text: qsTr("DVD")
                                checked: true  // Sets default checked button when exclusive
                            }

                            SGSegmentedButton{
                                text: qsTr("Blu-Ray")
                            }

                            SGSegmentedButton{
                                text: qsTr("VHS")
                            }

                            SGSegmentedButton{
                                text: qsTr("Radio")
                            }

                            SGSegmentedButton{
                                text: qsTr("Betamax")
                                enabled: false
                            }
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Status Light"

                contents: Item{
                    height: childrenRect.height + 40

                    SGStatusLight {
                        id: sgStatusLight
                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        label: "<b>Status:</b>" // Default: "" (if not entered, label will not appear)
                        labelLeft: false        // Default: true

                        // Useful Signals:
                        onStatusChanged: console.log("Changed to " + status)
                    }


                    Button {
                        id: switchStatus
                        anchors {
                            left: sgStatusLight.right
                            leftMargin: 40
                            verticalCenter: sgStatusLight.verticalCenter
                        }
                        property real status: 0
                        text: "Switch Status"
                        onClicked: {
                            if (status > 3) { status = 0 } else { status++ }
                            switch (status) {
                                case 1:
                                    sgStatusLight.status = "green"
                                    break;
                                case 2:
                                    sgStatusLight.status = "yellow"
                                    break;
                                case 3:
                                    sgStatusLight.status = "orange"
                                    break;
                                case 4:
                                    sgStatusLight.status = "red"
                                    break;
                                default:
                                    sgStatusLight.status = "off"
                                    break;
                            }
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Submit Info Box"

                contents: Item{
                    height: childrenRect.height + 40

                    SGSubmitInfoBox {
                        id: applyInfoBox

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        input: "6"    // String to this to be displayed in box
                        infoBoxWidth: 80            // Must be set by user based on their needs

                        label: "Voltage (volts):"       // Default: "" (if not entered, label will not appear)
                        labelLeft: false                 // Default: true (if false, label will be on top)
                        realNumberValidation: true      // Default: false (set true to restrict enterable values to real numbers)
                        buttonText: "Apply"

                        onApplied: console.log("Applied string value is " + value)
                    }

                }
            }

            SGAccordionItem {
                open: false
                title: "SG Status List Box"

                contents: Item{
                    height: childrenRect.height + 40
                    SGStatusListBox{
                        id: logBox
                        model: demoModel
                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }
                        title: "Status List"            // Default: "" (title bar will not be visible when empty string)
                        statusTextColor: "#777777"      // Default: "#000000" (black)
                    }

                    ListModel {
                        id: demoModel
                        ListElement {
                            status: "Port 1 Temperature: 71°C"
                        }
                    }

                    Button{
                        id: debugButton
                        text: "Add to model"
                        anchors {
                            top: logBox.bottom
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }
                        onClicked: {
                            demoModel.append({ "status" : Date.now() + " fault" });
                        }
                    }

                    Button{
                        text: "Remove from model"
                        x: 200
                        anchors {
                            bottom: debugButton.bottom
                            left: debugButton.right
                            leftMargin: 10
                        }
                        onClicked: {
                            if (demoModel.count > 0) {
                                demoModel.remove(demoModel.count-1);
                            }
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Popout"

                contents: Item{
                    height: childrenRect.height + 40

                    SGPopout {
                        id: popout1
                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }
                        title: "Popout 1"
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Labelled Info Box"

                contents: Item{
                    height: childrenRect.height + 40

                    SGLabelledInfoBox {
                        id: defaultLabelledInfoBox
                        infoBoxWidth: 70
                        label: "Speed:"
                        info: "40 rpm"
                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Graph"

                contents: Item{
                    height: childrenRect.height + 40

                    SGGraph {
                        // ChartView needs to be run in a QApplication, not the default QGuiApplication
                        // https://stackoverflow.com/questions/34099236/qtquick-chartview-qml-object-seg-faults-causes-qml-engine-segfault-during-load
                        id: graph

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        height: 300
                        width: 300

                        inputData: graphData.stream          // Set the graph's data source here

                        title: "<b>Graph</b>"                  // Default: empty
                        xAxisTitle: "Seconds"           // Default: empty
                        yAxisTitle: "Why Axes"          // Default: empty
                        minYValue: 0                    // Default: 0
                        maxYValue: 20                   // Default: 10
                        minXValue: 0                    // Default: 0
                        maxXValue: 5                    // Default: 10
                        showXGrids: false               // Default: false
                        showYGrids: true                // Default: false
                        showOptions: false               // Default: false
                    }

                    SGSwitch {
                        id: graphSwitch
                        label: "Demo Data"
                        checked: false
                        anchors {
                            left: graph.right
                            leftMargin: 40
                            verticalCenter: graph.verticalCenter
                        }
                    }

                    // Sends demo data stream with adjustible timing interval output
                    Timer {
                        id: graphData
                        property real stream
                        property real count: 0
                        interval: 100
                        running: graphSwitch.checked
                        repeat: true
                        onTriggered: {
                            count += interval;
                            stream = Math.sin(count/500)*10+10;
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Combo Box"

                contents: Item{
                    height: childrenRect.height + 40

                    SGComboBox {
                        id: sgComboBox
                        model: ["Amps", "Volts", "Watts"]

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }
                        label: "<b>ComboBox:</b>"   // Default: "" (if not entered, label will not appear)
                        labelLeft: false            // Default: true
                        comboBoxWidth: 150          // Default: 120 (set depending on model info length)
                        textColor: "black"          // Default: "black"
                        indicatorColor: "#aaa"      // Default: "#aaa"
                        borderColor: "#aaa"         // Default: "#aaa"
                        boxColor: "white"           // Default: "white"
                        dividers: true              // Default: false

                        onActivated: console.log("item " + index + " activated")
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Circular Gauge"

                contents: Item{
                    height: childrenRect.height + 40

                    SGCircularGauge {
                        id: sgCircularGauge
                        //value: data.stream

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        // Optional Configuration:
                        value: gaugecontrol.value
                        minimumValue: 0
                        maximumValue: 100
                        tickmarkStepSize: 10
                        gaugeRearColor: "#ddd"
                        centerColor: "black"
                        outerColor: "#999"
                        gaugeFrontColor1: Qt.rgba(0,.75,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        unitLabel: "RPM"                        // Default: "RPM"
                    }

                    SGSlider {
                        id: gaugecontrol
                        label: "Demo Control:"
                        labelLeft: false
                        live: true
                        anchors {
                            left: sgCircularGauge.right
                            leftMargin: 40
                            verticalCenter: sgCircularGauge.verticalCenter
                        }
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "SG Capacity Bar"

                contents: Item{
                    height: childrenRect.height + 40

                    SGCapacityBar {
                        id: capacityBar

                        anchors {
                            top: parent.top
                            topMargin: 20
                            left:parent.left
                            leftMargin: 20
                        }

                        label: "<b>Load Capacity:</b>"  // Default: "" (if not entered, label will not appear)
                        labelLeft: false
                        showThreshold: true             // Default: false
                        thresholdValue: 80              // Default: maximumValue

                        gaugeElements: Row {
                            id: container
                            property real totalValue: childrenRect.width // Necessary for over threshold detection signal

                            SGCapacityBarElement{
                                color: "#7bdeff"
                                value: graphData2.stream1
                            }

                            SGCapacityBarElement{
                                color: "#c6e78f"
                                value: graphData2.stream2
                            }
                        }

                        // Usable Signals:
                        onOverThreshold: console.log("Over Threshold!")
                    }

                    SGSwitch {
                        id: capBarSwitch
                        label: "Demo Data"
                        checked: false
                        anchors {
                            left: capacityBar.right
                            leftMargin: 40
                            verticalCenter: capacityBar.verticalCenter
                        }
                    }

                    // Sends demo data stream with adjustible timing interval output
                    Timer {
                        id: graphData2
                        property real stream1
                        property real stream2
                        property real count: 0
                        interval: 100
                        running: capBarSwitch.checked
                        repeat: true
                        onTriggered: {
                            count += interval;
                            stream1 = Math.sin(count/500)*10+50;
                            stream2 = Math.sin((count-800)/500)*10+25;
                        }
                    }
                }
            }
        }
    }
}
