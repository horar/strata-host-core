import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.sglayout 1.0

import "qrc:/js/help_layout_manager.js" as Help

UIBase { // start_uibase
    id: root
    columnCount: 40
    rowCount: 42

    property int intervalState: 2000
    property int run_count: -1 // Placeholder for valid value of run_count (-1 or the last value)
    property int run_countInfo: 10 // Placeholder for valid value of infobox of run_count
    property alias clearGraph: periodicNotificationGraph.clearGraph

    Component.onCompleted: {
        Help.registerTarget(controlViewRoot.tabBar, "These tabs contain different user interface functionality of the Strata evaluation board. Take the idea of walking the user into evaluating the board by ensuring the board is instantly functional when powered on and then dive into more complex tabs and features. These tabs are not required but contains in the template for illustration.", 0, "BasicControlHelp")
        Help.registerTarget(ioOutSwitch, "Toggle the state of a single IO output pin on the microcontroller. The IO Input control will reflect the state of the IO Output when the next Periodic Notification" + " \"" + "my_cmd_simple_periodic" + "\" "  + "is sent from the firmware to Strata.", 1, "BasicControlHelp")
        Help.registerTarget(dacOutSlider, "Sets the Digital to Analog Converter (DAC) pin of the microcontroller between 0 and full scale.", 2, "BasicControlHelp")
        Help.registerTarget(grayBoxHelpContainer, "These boxes indicate the command or notification communication between Strata and the board's firmware. The communication direction is indicated by the image in the top right corner of these boxes. The Serial Console Interface (SCI) should be used during firmware development to debug notifications and commands before connecting to the user interface.", 3, "BasicControlHelp")
        Help.registerTarget(periodNotiContainer, "This is a visualization of the data being sent as a notification to Strata using various user interface elements such as boolean indicators, live graphing, and gauges. The periodic notification is configured in the firmware to send the" + " \"" + "my_cmd_simple_periodic"+ "\" "  + "notification at a certain interval - indefinitely or with a certain run count configured in the Configure Periodic Notification section.", 4, "BasicControlHelp")
        Help.registerTarget(configPeriodNotiHelp, "Configures the periodic notification" + " \"" + "my_cmd_simple_periodic" + "\" "+ "with a certain interval - indefinitely or with a certain run count. The Run State will turn on/off the notification and will need to be toggled to enable the notification when the Run Count expires.", 5, "BasicControlHelp")
    }

    Item {
        id: grayBoxHelpContainer
        width: simpleCmdHandle.width + 10
        height: root.height
        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 0
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

    property var my_cmd_simple_start_periodic_obj: {
        "cmd": "my_cmd_simple_periodic_update",
        "payload": {
            "run_state": runStateSwitch.checked,
            "interval": intervalState,
            "run_count": parseInt(run_count)
        }
    }

    property var my_cmd_simple_obj: {
        "cmd": "my_cmd_simple",
        "payload": {
            "io": ioOutSwitch.checked,
            "dac": parseFloat(dacOutSlider.value.toFixed(2))
        }
    }

    LayoutRectangle { // start_dadc0
        id: textRect1
        layoutInfo.uuid: "dadc0"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 1

        color: "lightgrey"
    } // end_dadc0

    LayoutText { // start_86237
        id: simpleCommandHandler
        layoutInfo.uuid: "86237"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 1

        text: "Simple Command Handler"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        anchors {
            left: parent.left
            leftMargin: 10
        }
        verticalAlignment: Text.AlignVCenter
    } // end_86237

    LayoutSGIcon { // start_4aeea
        id: strataToBoard2
        layoutInfo.uuid: "4aeea"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 31
        layoutInfo.yRows: 1

        source: "images/StrataToBoard.png"
    } // end_4aeea

    LayoutText { // start_18179
        id: ioOutText
        layoutInfo.uuid: "18179"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 11
        layoutInfo.yRows: 4

        text: "IO Output"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_18179

    LayoutSGSwitch { // start_a761e
        id: ioOutSwitch
        layoutInfo.uuid: "a761e"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 12
        layoutInfo.yRows: 5

        checked: false
        checkedLabel: "on"
        uncheckedLabel: "off"
        labelsInside: true

        onToggled: {
            console.log("onToggled:", checked)
            platformInterface.commands.my_cmd_simple.update(dacOutSlider.value, ioOutSwitch.checked)
        }
    } // end_a761e

    LayoutText { // start_9fd37
        id: dacOutText
        layoutInfo.uuid: "9fd37"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 12
        layoutInfo.yRows: 8

        text: "DAC Output"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_9fd37

    LayoutSGSlider { // start_36237
        id: dacOutSlider
        layoutInfo.uuid: "36237"
        layoutInfo.columnsWide: 17
        layoutInfo.rowsTall: 3
        layoutInfo.xColumns: 5
        layoutInfo.yRows: 9

        from: 0
        to: 1.00
        live: false

        onUserSet: {
            console.log("onUserSet:", value)
            platformInterface.commands.my_cmd_simple.update(dacOutSlider.value, ioOutSwitch.checked)
        }
    } // end_36237

    LayoutRectangle { // start_870e3
        id: titleBackground1
        layoutInfo.uuid: "870e3"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 8
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 4

        color: "lightgrey"
    } // end_870e3

    LayoutRectangle { // start_4a3f7
        id: textRect2
        layoutInfo.uuid: "4a3f7"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 13

        color: "lightgrey"
    } // end_4a3f7

    LayoutText { // start_75d9f
        id: periodicNotification
        layoutInfo.uuid: "75d9f"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 13

        text: "Periodic Notification"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        anchors {
            left: parent.left
            leftMargin: 10
        }
        verticalAlignment: Text.AlignVCenter
    } // end_75d9f

    LayoutSGIcon { // start_1e3ac
        id: boardToStrata
        layoutInfo.uuid: "1e3ac"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 31
        layoutInfo.yRows: 13

        source: "images/BoardToStrata.png"
    } // end_1e3ac

    LayoutText { // start_ed906
        id: toggleText
        layoutInfo.uuid: "ed906"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 2
        layoutInfo.yRows: 16

        text: "Toggle"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_ed906

    LayoutSGStatusLight { // start_78e72
        id: toggleStatusLight
        layoutInfo.uuid: "78e72"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 3
        layoutInfo.yRows: 17

        status: {
            if (platformInterface.notifications.my_cmd_simple_periodic.toggle_bool === true) {
                return LayoutSGStatusLight.Green
            } else {
                return LayoutSGStatusLight.Off
            }
        }
    } // end_78e72

    LayoutSGButtonStrip { // start_94641
        id: graphGaugeButtonStrip
        layoutInfo.uuid: "94641"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 7
        layoutInfo.yRows: 17

        model: ["Graph","Gauge"]
        checkedIndices: 1

        onClicked: {
            console.info("Clicked", checkedIndices)
            if (index === 0) {
                periodicNotificationGraph.visible = true
                adcInText.visible = true
                randomText.visible = true
            } else {
                periodicNotificationGraph.visible = false
                adcInText.visible = false
                randomText.visible = false
            }
            if (index === 1) {
                circularGauge.visible = true
                adcInText.visible = false
                randomText.visible = false
            } else {
                circularGauge.visible = false
                adcInText.visible = true
                randomText.visible = true
            }
        }
    } // end_94641

    LayoutText { // start_c65d5
        id: ioInText
        layoutInfo.uuid: "c65d5"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 19
        layoutInfo.yRows: 16

        text: "IO Input"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_c65d5

    LayoutSGStatusLight { // start_a6397
        id: ioInStatusLight
        layoutInfo.uuid: "a6397"
        layoutInfo.columnsWide: 2
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 20
        layoutInfo.yRows: 17

        status: {
            if (platformInterface.notifications.my_cmd_simple_periodic.io_read === true) {
                return LayoutSGStatusLight.Green
            } else {
                return LayoutSGStatusLight.Off
            }
        }
    } // end_a6397

    LayoutSGGraph { // start_8727e
        id: periodicNotificationGraph
        layoutInfo.uuid: "8727e"
        layoutInfo.columnsWide: 22
        layoutInfo.rowsTall: 10
        layoutInfo.xColumns: 1
        layoutInfo.yRows: 20

        title: "Periodic Notification Graph"
        xMin: 0
        xMax: 5
        yMin: 0
        yMax: 1
        xTitle: "Interval Count"
        yTitle: "Values"
        xGrid: true
        yGrid: true
        gridColor: "black"

        property var random_float_array_curve: periodicNotificationGraph.createCurve("movingCurve1")
        property var adc_read_curve: periodicNotificationGraph.createCurve("movingCurve2")

        property int firstNotification: 1 //Count number of notification
        property bool clearGraph: false

        Connections {
            target: platformInterface.notifications.my_cmd_simple_periodic
            onNotificationFinished: {
                if (periodicNotificationGraph.clearGraph) {
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

                for (let y = 0; y < random_float_array.length ; y++) {
                    //Holds an array of values from notification
                    var yValue = platformInterface.notifications.my_cmd_simple_periodic.random_float_array[y]
                    dataArray.push({ "x": xValue, "y":yValue }) //Append to local array(dataArray) [{x,y},{x,y}....] for random_float_array
                    dataArray2.push({ "x": xValue, "y":adc_read }) //Append to local array that will hold the  [{x,y},{x,y}....] for adc_read
                    xValue++
                }

                // If the array contains more than one value at the first notification, append all the data points on the curves.
                if (periodicNotificationGraph.firstNotification === 1) {
                    periodicNotificationGraph.random_float_array_curve.appendList(dataArray)
                    periodicNotificationGraph.adc_read_curve.appendList(dataArray2)
                    periodicNotificationGraph.firstNotification++
                }

                // Append the latest which is the last value from dataArray and dataArray2.
                if (dataArray.length > 0 && periodicNotificationGraph.firstNotification !== 1) {
                    //Append the last value from dataArray[dataArray.length-1] = {x,y}
                    periodicNotificationGraph.random_float_array_curve.append(JSON.stringify(dataArray[dataArray.length -1]["x"]),JSON.stringify(dataArray[dataArray.length -1]["y"]))
                    periodicNotificationGraph.firstNotification++
                }
                if (dataArray2.length > 0 && periodicNotificationGraph.firstNotification !== 1) {
                    periodicNotificationGraph.adc_read_curve.append(JSON.stringify(dataArray2[dataArray2.length -1]["x"]),JSON.stringify(dataArray2[dataArray2.length -1]["y"]))
                    periodicNotificationGraph.firstNotification++
                }
            }
        }
    } // end_8727e

    LayoutSGCircularGauge { // start_b819b
        id: circularGauge
        layoutInfo.uuid: "b819b"
        layoutInfo.columnsWide: 15
        layoutInfo.rowsTall: 13
        layoutInfo.xColumns: 5
        layoutInfo.yRows: 18
        visible: graphGaugeButtonStrip.index === 1 ? true : false

        unitText: "Ramp\nValue"
        minimumValue: 0
        maximumValue: 5
        value: platformInterface.notifications.my_cmd_simple_periodic.gauge_ramp
        tickmarkStepSize: 1
    } // end_b819b

    LayoutText { // start_50ecf
        id: adcInText
        layoutInfo.uuid: "50ecf"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 23
        layoutInfo.yRows: 22

        text: "ADC Input"
        color: "blue"
        fontSizeMode: Text.Fit
        font.pixelSize: 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_50ecf

    LayoutText { // start_cfe58
        id: randomText
        layoutInfo.uuid: "cfe58"
        layoutInfo.columnsWide: 4
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 23
        layoutInfo.yRows: 25

        text: "Random"
        color: "orange"
        fontSizeMode: Text.Fit
        font.pixelSize: 30
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_cfe58

    LayoutRectangle { // start_06848
        id: titleBackground3
        layoutInfo.uuid: "06848"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 14
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 16

        color: "lightgrey"
    } // end_06848

    LayoutRectangle { // start_a944d
        id: textRect3
        layoutInfo.uuid: "a944d"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 31

        color: "lightgrey"
    } // end_a944d

    LayoutSGIcon { // start_360d3
        id: strataToBoard1
        layoutInfo.uuid: "360d3"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 31
        layoutInfo.yRows: 31

        source: "images/StrataToBoard.png"
    } // end_360d3

    LayoutText { // start_4bbc2
        id: runStateText
        layoutInfo.uuid: "4bbc2"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 5
        layoutInfo.yRows: 34

        text: "Run State"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_4bbc2

    LayoutSGSwitch { // start_90a37
        id: runStateSwitch
        layoutInfo.uuid: "90a37"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 6
        layoutInfo.yRows: 35

        checked: true
        checkedLabel: "on"
        uncheckedLabel: "off"
        labelsInside: true

        onToggled: {
            console.log("onToggled:", checked)
            if (!checked) {
                periodicNotificationGraph.clearGraph = true
            }
            platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState, run_count, checked)
        }
    } // end_90a37

    LayoutText { // start_7d3a9
        id: intervalText
        layoutInfo.uuid: "7d3a9"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 15
        layoutInfo.yRows: 34

        text: "Interval"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_7d3a9

    LayoutSGInfoBox { // start_0c95a
        id: intervalInfoBox
        layoutInfo.uuid: "0c95a"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 35

        text: "2000"
        readOnly: false // Set readOnly: false if you like to make SGInfoBox Editable

        onEditingFinished: {
            if (intervalInfoBox.text) {
                intervalState = parseInt(text)
                platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState, run_count, runStateSwitch.checked)
            }
        }

        onFocusChanged: {
            if (!focus) {
                intervalInfoBox.text = intervalState.toString()
            }
        }

        onAccepted: {
           console.log("Accepted:", text)
        }
    } // end_0c95a

    LayoutText { // start_d6441
        id: msText
        layoutInfo.uuid: "d6441"
        layoutInfo.columnsWide: 1
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 19
        layoutInfo.yRows: 35

        text: "ms"
        font.pixelSize: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_d6441

    LayoutText { // start_4b00f
        id: runIndefText
        layoutInfo.uuid: "4b00f"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 5
        layoutInfo.yRows: 38

        text: "Run Indefinitely"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_4b00f

    LayoutSGSwitch { // start_01355
        id: runIndefSwitch
        layoutInfo.uuid: "01355"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 6
        layoutInfo.yRows: 39

        checked: true
        checkedLabel: "on"
        uncheckedLabel: "off"
        labelsInside: true

        onToggled: {
            console.log("onToggled:", checked)
            if (checked) {
                run_count = -1
                platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState, run_count, runStateSwitch.checked)
            } else {
                run_count = run_countInfo
                platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState, run_count, runStateSwitch.checked)
            }
        }
    } // end_01355

    LayoutText { // start_97593
        id: runCountText
        layoutInfo.uuid: "97593"
        layoutInfo.columnsWide: 5
        layoutInfo.rowsTall: 1
        layoutInfo.xColumns: 15
        layoutInfo.yRows: 38
        enabled: (runIndefSwitch.checked) ? false : true
        opacity: (runIndefSwitch.checked) ? 0.5 : 1.0

        text: "Run Count"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    } // end_97593

    LayoutSGInfoBox { // start_bc288
        id: runCountInfoBox
        layoutInfo.uuid: "bc288"
        layoutInfo.columnsWide: 3
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 16
        layoutInfo.yRows: 39
        enabled: (runIndefSwitch.checked) ? false : true
        opacity: (runIndefSwitch.checked) ? 0.5 : 1.0

        text: "10"
        readOnly: false // Set readOnly: false if you like to make SGInfoBox Editable

        onEditingFinished: {
            if (runCountInfoBox.text) {
                run_count = parseInt(runCountInfoBox.text)
                run_countInfo = run_count
                platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState, run_count, runStateSwitch.checked)
            }
        }

        onAccepted: {
           console.log("Accepted:", text)
        }
    } // end_bc288

    LayoutRectangle { // start_e0518
        id: titleBackground2
        layoutInfo.uuid: "e0518"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 7
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 34

        color: "lightgrey"
    } // end_e0518

    LayoutContainer { // start_76037
        id: simpleCmdHandle
        layoutInfo.uuid: "76037"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 8
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 4
        contentItem: CommandSimple {
            id: cmdSimple_83e3e
        }
    } // end_76037

    LayoutContainer { // start_64a34
        id: periodNotiContainer
        layoutInfo.uuid: "64a34"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 14
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 16
        contentItem: PeriodicNotification {
            id: periodNoti_3b7a6
        }
    } // end_64a34

    LayoutItem { // start_aff41
        id: configPeriodNotiHelp
        layoutInfo.uuid: "aff41"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 11
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 31
    } // end_aff41

    LayoutText { // start_17037
        id: configPeriodicNotification
        layoutInfo.uuid: "17037"
        layoutInfo.columnsWide: 40
        layoutInfo.rowsTall: 2
        layoutInfo.xColumns: 0
        layoutInfo.yRows: 31

        text: "Configure Periodic Notification"
        fontSizeMode: Text.Fit
        font.pixelSize: 40
        anchors {
            left: parent.left
            leftMargin: 10
        }
        verticalAlignment: Text.AlignVCenter
    } // end_17037

    LayoutContainer { // start_a20d8
        id: configPeriodNoti
        layoutInfo.uuid: "a20d8"
        layoutInfo.columnsWide: 11
        layoutInfo.rowsTall: 7
        layoutInfo.xColumns: 28
        layoutInfo.yRows: 34
        contentItem: ConfigPeriodicNotification {
            id: configPeriodNoti_6551b
        }
    } // end_a20d8
} // end_uibase
