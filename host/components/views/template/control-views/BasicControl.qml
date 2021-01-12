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
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property var intervalState : 200
    property alias gpio: gpio
    property var xValue: 0
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var curve: timedGraphPoints.createCurve("movingCurve")
    property var curve2: timedGraphPoints.createCurve("movingCurve2")
    property var firstNotification: 1

    MouseArea {
        id: containMouseArea
        anchors.fill:root
        onClicked: {
            forceActiveFocus()
        }
    }

    property var obj: {
        "notification" : {
            "value": "my_cmd_simple_periodic",
            "payload": {
                "adc_read": platformInterface.notifications.my_cmd_simple_periodic.adc_read,
                "gauge_ramp": platformInterface.notifications.my_cmd_simple_periodic.gauge_ramp,
                "io_read": platformInterface.notifications.my_cmd_simple_periodic.io_read,
                "random_float": platformInterface.notifications.my_cmd_simple_periodic.random_float,
                "random_float_array": platformInterface.notifications.my_cmd_simple_periodic.random_float_array,
                "random_increment": set_random_array(2,platformInterface.notifications.my_cmd_simple_periodic.random_increment),
                "toggle_bool": platformInterface.notifications.my_cmd_simple_periodic.toggle_bool
            }
        }
    }

    function set_random_array(max,value){
        let dataArray = []
        for(let y = 0; y < max; y++) {
            var idxName = `index_${y}`
            var yValue = value[idxName]
            dataArray.push(yValue)
        }
        return dataArray
    }


    property var run_count: -1
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
            "io": gpio.checked,
            "dac": dac.value.toFixed(2)
        }
    }

    ColumnLayout {
        width: parent.width
        height: parent.height/1.1
        anchors.centerIn: parent
        anchors.top:parent.top
        anchors.topMargin: 200
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
                    id: powerControlHeading
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
                Image {
                    id: name
                    source: "images/commandicon.png"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: 100
                    }
                }
            }

            //            Rectangle {
            //                id: line1
            //                height: 1.5
            //                Layout.alignment: Qt.AlignCenter
            //                width: parent.width
            //                border.color: "lightgray"
            //                radius: 2
            //                anchors {
            //                    top: headingCommandHandler.bottom
            //                    topMargin: 7
            //                }
            //            }
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
                                id: gpioSwitchLabel
                                target: gpio
                                text: "IO Output"
                                font.bold: true
                                anchors.centerIn: parent
                                alignment: SGAlignedLabel.SideTopCenter

                                SGSwitch {
                                    id: gpio
                                    width: 50
                                    checked: false
                                    onToggled:  {
                                        platformInterface.commands.my_cmd_simple.update(dac.value,gpio.checked)
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
                                    width: 200
                                    from: 0                          // Default: 0.0
                                    to: 1
                                    onUserSet: {
                                        platformInterface.commands.my_cmd_simple.update(dac.value.toFixed(2),gpio.checked)
                                        delegateText1.text = JSON.stringify(my_cmd_simple_obj,null,4)

                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/2.5
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 15
                    color: "light gray"
                    Flickable {
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText1
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            text: JSON.stringify(my_cmd_simple_obj,null,4)
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
                    z:2
                }
                Image {
                    id: name2
                    source: "images/notificationicon.png"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: 100
                    }
                    z:2
                }

            }

            //            Rectangle {
            //                id: line2
            //                height: 1.5
            //                Layout.alignment: Qt.AlignCenter
            //                width: parent.width
            //                border.color: "lightgray"
            //                radius: 2
            //                anchors {
            //                    top: periodicNotification.bottom
            //                    topMargin: 7
            //                }
            //            }

            RowLayout {
                anchors.top: periodicNotification.bottom
                anchors.topMargin: 5
                width: parent.width
                height: parent.height - periodicNotification.height

                Item {
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
                                id: buttonStrip2
                                model: ["Graph","Gauge"]
                                anchors {
                                    centerIn: parent
                                    left: toggleSwitchContainer.right
                                }
                                onClicked: {
                                    if(index === 0) {
                                        timedGraphPoints.visible = true
                                        lable1.visible = true
                                        lable2.visible = true
                                    }
                                    else { timedGraphPoints.visible = false
                                        lable1.visible = false
                                        lable2.visible = false

                                    }
                                    if(index === 1) {
                                        sgCircularGauge.visible = true
                                        lable1.visible = false
                                        lable2.visible = false
                                    }
                                    else  {
                                        sgCircularGauge.visible = false
                                        lable1.visible = true
                                        lable2.visible = true
                                    }
                                }
                            }
                            Item{
                                id: inputSwitchConter
                                width:parent.width/3
                                height: parent.height
                                anchors {
                                    left: buttonStrip2.right
                                }
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
                                id: timedGraphPoints
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

                                property real lastTime


                                Component.onCompleted: {
                                    curve.color = "orange"
                                    curve2.color = "blue"
                                }

                                Connections {
                                    target: platformInterface.notifications.my_cmd_simple_periodic
                                    onNotificationFinished: {
                                        let dataArray = []
                                        let dataArray2 = []
                                        let random_float_array = platformInterface.notifications.my_cmd_simple_periodic.random_float_array
                                        let adc_read = platformInterface.notifications.my_cmd_simple_periodic.adc_read
                                        timedGraphPoints.xMin = platformInterface.notifications.my_cmd_simple_periodic.random_increment.index_0
                                        timedGraphPoints.xMax =  platformInterface.notifications.my_cmd_simple_periodic.random_increment.index_1
                                        xValue = timedGraphPoints.xMin
                                        for(let y = 0; y < random_float_array.length ; y++) {
                                            var yValue = platformInterface.notifications.my_cmd_simple_periodic.random_float_array[y]
                                            dataArray.push({"x":xValue, "y":yValue})
                                            dataArray2.push({"x":xValue, "y":adc_read})
                                            xValue++
                                        }
                                        console.log(JSON.stringify(dataArray))
                                        console.log(dataArray.length, dataArray2.length, firstNotification)

                                        if(dataArray.length > 0 && firstNotification !== 1) {
                                            curve.append(JSON.stringify(dataArray[dataArray.length -1]["x"]),JSON.stringify(dataArray[dataArray.length -1]["y"]))
                                            firstNotification++
                                        }
                                        if(dataArray2.length > 0 && firstNotification !== 1) {
                                            curve2.append(JSON.stringify(dataArray2[dataArray2.length -1]["x"]),JSON.stringify(dataArray2[dataArray2.length -1]["y"]))
                                            firstNotification++
                                        }
                                        // If the array contains more than one value at the first notification, append all the data points on curve
                                        else if(firstNotification === 1) {
                                            curve.appendList(dataArray)
                                            curve2.appendList(dataArray2)
                                            firstNotification++
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
                                // tickmarkStepSize: 0.5           // Default: (maxVal-minVal)/10
                                visible: buttonStrip2.index === 1 ? true : false
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
                                id: lable1
                                text:" ADC \n Input"
                                color: "blue"
                                font.bold: true
                                visible: buttonStrip2.index === 1 ? false : true
                                Layout.topMargin: 10
                            }
                            SGText {
                                id: lable2
                                text:" Random"
                                color: "orange"
                                font.bold: true
                                visible: buttonStrip2.index === 1 ? false : true
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredHeight: parent.height/1.05
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    color: "light gray"
                    Flickable {
                        id: flickable
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            property var cmd_simple_periodicText: obj
                            onCmd_simple_periodicTextChanged: {
                                var end =  selectionEnd
                                var start = selectionStart
                                console.log(end, start)
                                text = JSON.stringify(obj, null, 4)
                                select(start,end)
                            }
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }

                }
            } //end of row
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
                Image {
                    id: name3
                    source: "images/commandicon.png"
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset: 100
                    }
                }


            }

            //            Rectangle {
            //                id: line3
            //                height: 1.5
            //                Layout.alignment: Qt.AlignCenter
            //                width: parent.width
            //                border.color: "lightgray"
            //                radius: 2
            //                anchors {
            //                    top: configperiodicNotification.bottom
            //                    topMargin: 7
            //                }
            //            }

            RowLayout {
                anchors.top: configperiodicNotification.bottom
                anchors.topMargin: 5
                width: parent.width
                height: parent.height - configperiodicNotification.height

                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.6
                    ColumnLayout{
                        anchors.fill: parent
                        Item {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            RowLayout{
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
                                                    console.log(timedGraphPoints.count)
                                                    timedGraphPoints.curve(0).clear()
                                                    timedGraphPoints.curve(1).clear()
                                                    firstNotification = 1
                                                    //                                                    for (let i = 0; i < timedGraphPoints.count; i++) {
                                                    //                                                        if (timedGraphPoints.curve(i).name === "movingCurve") {
                                                    //                                                            timedGraphPoints.curve(0).clear()
                                                    //                                                            break
                                                    //                                                        }
                                                    //                                                    }

                                                }

                                                platformInterface.commands.my_cmd_simple_periodic_update.update(parseInt(interval.text),run_count,checked)
                                            }
                                            //                                            onCheckedChanged: {
                                            //                                                if(checked) {
                                            //                                                    timedGraphPoints.xMin = 0
                                            //                                                    timedGraphPoints.xMax = (intervalState/1000) * 5
                                            //                                                }
                                            //                                            }
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

                                        SGSubmitInfoBox {
                                            id: interval
                                            width: 100
                                            text: "2000"
                                            unit: "ms"
                                            IntValidator {
                                                bottom: 250
                                                top: 10000
                                            }
                                            placeholderText: "250-10000"
                                            onEditingFinished:{
                                                if(text) {
                                                    intervalState = parseInt(text)
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
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
                                        text: "Run Indefinately"
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
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(parseInt(interval.text),run_count,enableSwitch.checked)
                                                }
                                                else {
                                                    run_count = parseInt(runcount.text)
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(parseInt(interval.text),run_count,enableSwitch.checked)
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
                                        target: runcount
                                        text: "Run Count"
                                        font.bold: true
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.horizontalCenterOffset: -5
                                        alignment: SGAlignedLabel.SideTopCenter
                                        enabled: (runStateSwitch.checked) ? false : true
                                        opacity: (runStateSwitch.checked) ? 0.5 : 1.0

                                        SGSubmitInfoBox {
                                            id: runcount
                                            width: 90
                                            text: "10"
                                            IntValidator {  }
                                            unit: "  "

                                            onEditingFinished:{
                                                if(text) {
                                                    run_count = parseInt(runcount.text)
                                                    platformInterface.commands.my_cmd_simple_periodic_update.update(intervalState,run_count,enableSwitch.checked)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } // end of column
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "light gray"
                    Layout.alignment: Qt.AlignCenter
                    Layout.topMargin: 25

                    Flickable {
                        anchors.fill: parent
                        TextArea.flickable: TextArea {
                            id: delegateText2
                            anchors.fill: parent
                            readOnly: true
                            selectByMouse: true
                            text: JSON.stringify(my_cmd_simple_start_periodic_obj, null, 4)
                        }
                        ScrollBar.vertical: ScrollBar { }
                    }

                }
            }
        }
    }
}


