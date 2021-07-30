import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

/********************************************************************************************************
    This is a Template UI that works directly with the Template FW found
    Under Embedded Strata Core (Refer: README):
                https://code.onsemi.com/projects/SECSWST/repos/embedded-strata-core/browse/template
*********************************************************************************************************/
Item {
    id: root
    property real ratioCalc: root.width / 1200
    property var intervalState : 2000
    property alias clearGraph: periodicNotificationGraph.clearGraph

    Component.onCompleted: {
        Help.registerTarget(navTabs, "These tabs contain different user interface functionality of the Strata evaluation board. Take the idea of walking the user into evaluating the board by ensuring the board is instantly functional when powered on and then dive into more complex tabs and features. These tabs are not required but contains in the template for illustration.", 0, "BasicControlHelp")
        Help.registerTarget(ioSwitchLabel, "Toggle the state of a single IO output pin on the microcontroller. The IO Input control will reflect the state of the IO Output when the next Periodic Notification" + " \"" + "my_cmd_simple_periodic" + "\" "  + "is sent from the firmware to Strata.", 1, "BasicControlHelp")
        Help.registerTarget(dacSwitchLabel, "Sets the Digital to Analog Converter (DAC) pin of the microcontroller between 0 and full scale.", 2, "BasicControlHelp")
        Help.registerTarget(grayBoxHelpContainer, "These boxes indicate the command or notification communication between Strata and the board's firmware. The communication direction is indicated by the image in the top right corner of these boxes. The Serial Console Interface (SCI) should be used during firmware development to debug notifications and commands before connecting to the user interface.", 3, "BasicControlHelp")
        Help.registerTarget(perodicNotificationContainer, "This is a visualization of the data being sent as a notification to Strata using various user interface elements such as boolean indicators, live graphing, and gauges. The periodic notification is configured in the firmware to send the" + " \"" + "my_cmd_simple_periodic"+ "\" "  + "notification at a certain interval - indefinitely or with a certain run count configured in the Configure Periodic Notification section.", 4, "BasicControlHelp")
        Help.registerTarget(configperiodicNotificationContainer, "Configures the periodic notification" + " \"" + "my_cmd_simple_periodic" + "\" "+ "with a certain interval - indefinitely or with a certain run count. The Run State will turn on/off the notification and will need to be toggled to enable the notification when the Run Count expires.", 5, "BasicControlHelp")
    }

    Item {
        id: grayBoxHelpContainer
        width: grayBox1.width + 10
        height: grayBox1.height * 3.8
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 100
    }

    MouseArea {
        id: containMouseArea
        anchors.fill: root

        onClicked: {
            forceActiveFocus()
        }
    }

    property var my_cmd_simple_periodic_text: {
        "notification" : {
            "value": "my_cmd_simple_periodic",
            "payload": {
                "adc_read": platformInterface.notifications.my_cmd_simple_periodic.adc_read,
                "gauge_ramp": platformInterface.notifications.my_cmd_simple_periodic.gauge_ramp,
                "io_read": platformInterface.notifications.my_cmd_simple_periodic.io_read,
                "random_float": platformInterface.notifications.my_cmd_simple_periodic.random_float,
                "random_float_array": platformInterface.notifications.my_cmd_simple_periodic.random_float_array,
                "random_increment": formating_random_increment(2,platformInterface.notifications.my_cmd_simple_periodic.random_increment),
                "toggle_bool": platformInterface.notifications.my_cmd_simple_periodic.toggle_bool
            }
        }
    }

    function formating_random_increment(max,value){
        let dataArray = []
        for(let y = 0; y < max; y++) {
            var idxName = `index_${y}`
            var yValue = value[idxName]
            dataArray.push(yValue)
        }
        return dataArray
    }

    property var run_count: -1 //Placeholder for valid value of run_count (-1 or the last value)
    property var run_countInfo: 10 //Placeholder for valid value of infobox of run_count

    property var my_cmd_simple_start_periodic_obj: {
        "cmd": "my_cmd_simple_periodic_update",
        "payload": {
            "run_state": enableSwitch.checked,
            "interval": intervalState,
            "run_count": parseInt(run_count)
        }
    }

    property var my_cmd_simple_obj: {
        "cmd": "my_cmd_simple",
        "payload": {
            "io": io.checked,
            "dac": parseFloat(dac.value.toFixed(2))
        }
    }

    ColumnLayout {
        width: parent.width
        height: parent.height/1.1
        anchors.centerIn: parent
        anchors.top:parent.top
        anchors.topMargin: 250
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.right: parent.right
        anchors.rightMargin: 20
        spacing: 20

        Item {
            Layout.preferredHeight: parent.height/4
            Layout.fillWidth: true

            Rectangle{
                id: headingCommandHandler
                width: parent.width
                height: parent.height/5
                border.color: "lightgray"
                color: "lightgray"

                Text {
                    id: simpleControlHeading
                    text: "Simple Command Handler"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 10
                    }
                }
            }

            RowLayout {
                anchors.top: headingCommandHandler.bottom
                anchors.topMargin: 5
                width: parent.width
                height: parent.height - headingCommandHandler.height

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.6

                    ColumnLayout {
                        anchors.fill: parent

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: ioSwitchLabel
                                target: io
                                text: "IO Output"
                                font.bold: true
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideTopCenter

                                SGSwitch {
                                    id: io
                                    width: 50
                                    checked: false
                                    onToggled:  {
                                        platformInterface.commands.my_cmd_simple.update(dac.value,io.checked)
                                        delegateText1.text =  JSON.stringify(my_cmd_simple_obj,null,4)
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: dacSwitchLabel
                                target: dac
                                text: "DAC Ouput"
                                font.bold: true
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideTopCenter

                                SGSlider {
                                    id: dac
                                    width: 250
                                    from: 0.00
                                    to: 1.00
                                    stepSize: 0.01
                                    inputBox.validator: DoubleValidator { top: 1.00; bottom:0.00 }
                                    inputBox.text: dac.value.toFixed(2)
                                    contextMenuEnabled: true
                                    onUserSet: {
                                        inputBox.text = parseFloat(value.toFixed(2))
                                        platformInterface.commands.my_cmd_simple.update( parseFloat(value.toFixed(2)),io.checked)
                                        delegateText1.text = JSON.stringify(my_cmd_simple_obj,null,4)
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 15
                    Layout.rightMargin: 15
                    color: "light gray"

                    Image {
                        source: "images/StrataToBoard.png"
                        anchors {
                            right: parent.right
                            top: parent.top
                        }
                        width: 100
                        height: 50
                        fillMode: Image.PreserveAspectFit
                    }

                    Flickable {
                        id: grayBox1
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText1
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            text: JSON.stringify(my_cmd_simple_obj,null,4)
                            persistentSelection: true   // must deselect manually

                            onActiveFocusChanged: {
                                if ((activeFocus === false) && (delegateTextContextMenuPopup1.visible === false)) {
                                    delegateText1.deselect()
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                acceptedButtons: Qt.RightButton
                                onClicked: {
                                    delegateText1.forceActiveFocus()
                                }
                                onReleased: {
                                    if (containsMouse) {
                                        delegateTextContextMenuPopup1.popup(null)
                                    }
                                }
                            }

                            SGContextMenuEditActions {
                                id: delegateTextContextMenuPopup1
                                textEditor: delegateText1
                            }
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
            } //end of row
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Rectangle {
                id: periodicNotification
                width: parent.width
                height: parent.height/9
                color: "lightgray"

                Text {
                    id: periodicNotificationHeading
                    text: "Periodic Notification"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 10
                    }
                }
            }

            RowLayout {
                anchors.top: periodicNotification.bottom
                anchors.topMargin: 5
                width: parent.width
                height: parent.height - periodicNotification.height

                Item {
                    id: perodicNotificationContainer
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.6

                    ColumnLayout{
                        width: parent.width - graphLabel.width
                        height:  parent.height

                        Item  {
                            Layout.preferredHeight: parent.height/5
                            Layout.fillWidth: true

                            Item{
                                id: toggleSwitchContainer
                                width:parent.width/3
                                height: parent.height

                                SGAlignedLabel {
                                    id: toggleLEDLabel
                                    target: toggleLED
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors {
                                        centerIn: parent
                                    }
                                    text: "Toggle"
                                    font.bold: true

                                    SGStatusLight {
                                        id: toggleLED
                                        width : 30
                                        status: {
                                            if(platformInterface.notifications.my_cmd_simple_periodic.toggle_bool === true)
                                                return SGStatusLight.Green
                                            else return SGStatusLight.Off
                                        }
                                    }
                                }
                            }

                            SGButtonStrip {
                                id: graphGaugeButtonStrip
                                model: ["Graph","Gauge"]
                                anchors {
                                    centerIn: parent
                                    left: toggleSwitchContainer.right
                                }
                                checkedIndices: 1
                                onClicked: {
                                    if(index === 0) {
                                        periodicNotificationGraph.visible = true
                                        adcLegend.visible = true
                                        randomLegend.visible = true
                                    }
                                    else { periodicNotificationGraph.visible = false
                                        adcLegend.visible = false
                                        randomLegend.visible = false

                                    }
                                    if(index === 1) {
                                        sgCircularGauge.visible = true
                                        adcLegend.visible = false
                                        randomLegend.visible = false
                                    }
                                    else  {
                                        sgCircularGauge.visible = false
                                        adcLegend.visible = true
                                        randomLegend.visible = true
                                    }
                                }
                            }

                            Item{
                                id: inputSwitchConter
                                width:parent.width/3
                                height: parent.height
                                anchors.left: graphGaugeButtonStrip.right

                                SGAlignedLabel {
                                    id: inputLEDLabel
                                    target: inputLED
                                    alignment: SGAlignedLabel.SideTopCenter
                                    anchors.centerIn: parent
                                    text: "IO Input"
                                    font.bold: true

                                    SGStatusLight {
                                        id: inputLED
                                        width : 30
                                        status: {
                                            if(platformInterface.notifications.my_cmd_simple_periodic.io_read === true)
                                                return SGStatusLight.Green
                                            else return SGStatusLight.Off
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGGraph{
                                id: periodicNotificationGraph
                                anchors.fill: parent
                                title: "Periodic Notification Graph "
                                yMin: 0
                                yMax: 1
                                xMin: 0
                                xMax: 5
                                xTitle: "Interval Count"
                                yTitle: "Values"
                                panXEnabled: false
                                panYEnabled: false
                                zoomXEnabled: false
                                zoomYEnabled: false
                                xGrid: true
                                yGrid: true

                                /*
                                  Create curves for the graph
                                */
                                property var random_float_array_curve: periodicNotificationGraph.createCurve("movingCurve1")
                                property var adc_read_curve: periodicNotificationGraph.createCurve("movingCurve2")

                                property var firstNotification: 1 //Count number of notification
                                property bool clearGraph: false

                                Connections {
                                    target: platformInterface.notifications.my_cmd_simple_periodic
                                    onNotificationFinished: {
                                        if(periodicNotificationGraph.clearGraph) {
                                            periodicNotificationGraph.curve(0).clear()
                                            periodicNotificationGraph.curve(1).clear()
                                            periodicNotificationGraph.firstNotification = 1
                                            periodicNotificationGraph.clearGraph = false
                                        }

                                        periodicNotificationGraph.random_float_array_curve.color = "orange"
                                        periodicNotificationGraph.adc_read_curve.color = "blue"

                                        let dataArray = []
                                        let dataArray2 = []
                                        let xValue = 0
                                        let random_float_array = platformInterface.notifications.my_cmd_simple_periodic.random_float_array
                                        let adc_read = platformInterface.notifications.my_cmd_simple_periodic.adc_read

                                        periodicNotificationGraph.xMin = platformInterface.notifications.my_cmd_simple_periodic.random_increment.index_0
                                        periodicNotificationGraph.xMax =  platformInterface.notifications.my_cmd_simple_periodic.random_increment.index_1
                                        xValue = periodicNotificationGraph.xMin

                                        for(let y = 0; y < random_float_array.length ; y++) {
                                            //Holds an array of values from notification
                                            var yValue = platformInterface.notifications.my_cmd_simple_periodic.random_float_array[y]
                                            dataArray.push({ "x": xValue, "y":yValue }) //Append to local array(dataArray) [{x,y},{x,y}....] for random_float_array
                                            dataArray2.push({ "x": xValue, "y":adc_read }) //Append to local array that will hold the  [{x,y},{x,y}....] for adc_read
                                            xValue++
                                        }

                                        // If the array contains more than one value at the first notification, append all the data points on the curves.
                                        if(periodicNotificationGraph.firstNotification === 1) {
                                            periodicNotificationGraph.random_float_array_curve.appendList(dataArray)
                                            periodicNotificationGraph.adc_read_curve.appendList(dataArray2)
                                            periodicNotificationGraph.firstNotification++
                                        }

                                        // Append the latest which is the last value from dataArray and dataArray2.
                                        if(dataArray.length > 0 && periodicNotificationGraph.firstNotification !== 1) {
                                            //Append the last value from dataArray[dataArray.length-1] = {x,y}
                                            periodicNotificationGraph.random_float_array_curve.append(JSON.stringify(dataArray[dataArray.length -1]["x"]),JSON.stringify(dataArray[dataArray.length -1]["y"]))
                                            periodicNotificationGraph.firstNotification++
                                        }
                                        if(dataArray2.length > 0 && periodicNotificationGraph.firstNotification !== 1) {
                                            periodicNotificationGraph.adc_read_curve.append(JSON.stringify(dataArray2[dataArray2.length -1]["x"]),JSON.stringify(dataArray2[dataArray2.length -1]["y"]))
                                            periodicNotificationGraph.firstNotification++
                                        }
                                    }
                                }
                            }

                            SGCircularGauge {
                                id: sgCircularGauge
                                width: parent.width/2
                                height: parent.height
                                anchors.centerIn: parent
                                value: platformInterface.notifications.my_cmd_simple_periodic.gauge_ramp
                                unitText: "Ramp\nvalue"               // Default: ""
                                minimumValue: 0                 // Default: 0
                                maximumValue: 5               // Default: 100
                                valueDecimalPlaces: 0
                                tickmarkStepSize: 1           // Default: (maxVal-minVal)/10
                                visible: graphGaugeButtonStrip.index === 1 ? true : false
                            }
                        }
                    }

                    Item{
                        id: graphLabel
                        width: 110
                        height: 110
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter

                        ColumnLayout {
                            anchors.fill: parent

                            SGText {
                                id: adcLegend
                                text:" ADC \n Input"
                                color: "blue"
                                font.bold: true
                                visible: graphGaugeButtonStrip.index === 1 ? false : true
                                Layout.topMargin: 10
                            }

                            SGText {
                                id:  randomLegend
                                text:" Random"
                                color: "orange"
                                font.bold: true
                                visible: graphGaugeButtonStrip.index === 1 ? false : true
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: parent.height/1.05
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    color: "light gray"
                    Layout.rightMargin: 15

                    Image {
                        source: "images/BoardToStrata.png"
                        anchors {
                            right: parent.right
                            top: parent.top
                        }
                        width: 100
                        height: 50
                        fillMode: Image.PreserveAspectFit
                    }

                    Flickable {
                        id: graybox2
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            persistentSelection: true   // must deselect manually
                            property var cmd_simple_periodicText: my_cmd_simple_periodic_text

                            onActiveFocusChanged: {
                                if ((activeFocus === false) && (delegateTextContextMenuPopup.visible === false)) {
                                    delegateText.deselect()
                                }
                            }

                            onCmd_simple_periodicTextChanged: {
                                //set a highlighted area from the start,end cursor position
                                var end =  selectionEnd
                                var start = selectionStart
                                text = JSON.stringify(my_cmd_simple_periodic_text, null, 4)
                                select(start,end)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                acceptedButtons: Qt.RightButton
                                onClicked: {
                                    delegateText.forceActiveFocus()
                                }
                                onReleased: {
                                    if (containsMouse) {
                                        delegateTextContextMenuPopup.popup(null)
                                    }
                                }
                            }

                            SGContextMenuEditActions {
                                id: delegateTextContextMenuPopup
                                textEditor: delegateText
                            }
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
            }
        }

        Item {
            Layout.preferredHeight: parent.height/4
            Layout.fillWidth: true

            Rectangle {
                id: configperiodicNotification
                width: parent.width
                height: parent.height/5
                color: "lightgray"

                Text {
                    id: configperiodicNotificationHeading
                    text: "Configure Periodic Notification"
                    font.bold: true
                    font.pixelSize: ratioCalc * 20
                    color: "#696969"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 10
                    }
                }
            }

            RowLayout {
                anchors.top: configperiodicNotification.bottom
                anchors.topMargin: 5
                width: parent.width
                height: parent.height - configperiodicNotification.height

                Item {
                    id: configperiodicNotificationContainer
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.6

                    ColumnLayout{
                        anchors.fill: parent

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            RowLayout {
                                anchors.fill: parent

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    SGAlignedLabel {
                                        id: enableLabel
                                        target: enableSwitch
                                        text: "Run State"
                                        font.bold: true
                                        anchors.centerIn: parent
                                        alignment: SGAlignedLabel.SideTopCenter

                                        SGSwitch {
                                            id: enableSwitch
                                            width: 50
                                            checked: true

                                            onToggled: {
                                                if(!checked) {
                                                    periodicNotificationGraph.clearGraph = true
                                                }
                                                platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,checked)
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    SGAlignedLabel {
                                        id: intervalLabel
                                        target: interval
                                        text: "Interval"
                                        font.bold: true
                                        anchors.centerIn: parent
                                        alignment: SGAlignedLabel.SideTopCenter

                                        SGInfoBox {
                                            id: interval
                                            width: 100
                                            text: "2000"
                                            unit: "ms"
                                            readOnly: false
                                            validator: IntValidator {
                                                bottom: 250
                                                top: 10000
                                            }
                                            placeholderText: "250-10000"
                                            contextMenuEnabled: true

                                            onEditingFinished:{
                                                if(interval.text) {
                                                    intervalState = parseInt(text)
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
                                                }
                                            }

                                            onFocusChanged: {
                                                if(!focus){
                                                    interval.text = intervalState.toString()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            RowLayout{
                                anchors.fill: parent

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    SGAlignedLabel {
                                        id: runStateLabel
                                        target: runStateSwitch
                                        text: "Run Indefinitely"
                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                        }
                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopCenter

                                        SGSwitch {
                                            id: runStateSwitch
                                            width: 50
                                            checked: true

                                            onToggled: {
                                                if(checked) {
                                                    run_count = -1
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
                                                }
                                                else {
                                                    run_count = run_countInfo
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true

                                    SGAlignedLabel {
                                        id: runcountLabel
                                        target: runCountInfoBox
                                        text: "Run Count"
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.horizontalCenterOffset: -5
                                        alignment: SGAlignedLabel.SideTopCenter
                                        enabled: (runStateSwitch.checked) ? false : true
                                        opacity: (runStateSwitch.checked) ? 0.5 : 1.0

                                        SGInfoBox {
                                            id: runCountInfoBox
                                            width: 90
                                            text: "10"
                                            validator: IntValidator {
                                                top: 32767
                                                bottom: 1
                                            }
                                            unit: "  "
                                            readOnly: false
                                            enabled: (runStateSwitch.checked) ? false : true
                                            opacity: (runStateSwitch.checked) ? 0.5 : 1.0
                                            contextMenuEnabled: true

                                            onEditingFinished:{
                                                if(runCountInfoBox.text) {
                                                    run_count = parseInt(runCountInfoBox.text)
                                                    run_countInfo = run_count // holds the valid value of run count in case user enter a invalid or null value
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
                                                }
                                            }

                                            onFocusChanged: {
                                                runCountInfoBox.text = run_count.toString()
                                            }
                                        }
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
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 25
                    Layout.rightMargin: 15

                    Image {
                        source: "images/StrataToBoard.png"
                        anchors {
                            right: parent.right
                            top: parent.top
                        }
                        width: 100
                        height: 50
                        fillMode: Image.PreserveAspectFit
                    }

                    Flickable {
                        id: graybox3
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText2
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            text: JSON.stringify(my_cmd_simple_start_periodic_obj, null, 4)
                            persistentSelection: true   // must deselect manually

                            onActiveFocusChanged: {
                                if ((activeFocus === false) && (delegateTextContextMenuPopup2.visible === false)) {
                                    delegateText2.deselect()
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.IBeamCursor
                                acceptedButtons: Qt.RightButton
                                onClicked: {
                                    delegateText2.forceActiveFocus()
                                }
                                onReleased: {
                                    if (containsMouse) {
                                        delegateTextContextMenuPopup2.popup(null)
                                    }
                                }
                            }

                            SGContextMenuEditActions {
                                id: delegateTextContextMenuPopup2
                                textEditor: delegateText2
                            }
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
            }
        }
    }
}


