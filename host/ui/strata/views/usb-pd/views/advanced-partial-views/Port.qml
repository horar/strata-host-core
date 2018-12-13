import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../../sgwidgets"

Item {
    id: root

    property bool debugLayout: true
    property int portNumber: 1
    property alias portConnected: portInfo.portConnected
    property alias portColor: portInfo.portColor
    property bool showGraphs: false

    width: parent.width
    height: graphSelector.nothingChecked ? portSettings.height : portSettings.height + portGraphs.height

    PortInfo {
        id: portInfo
        anchors {
            left: parent.left
            top: root.top
            topMargin: 110
        }
        advertisedVoltage:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return platformInterface.request_usb_power_notification.negotiated_voltage
            }
            else{
                return portInfo.advertisedVoltage;
            }
        }
        maxPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
               return Math.round(platformInterface.request_usb_power_notification.maximum_power *100)/100
            }
            else{
                return portInfo.maxPower;
            }
        }
        inputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current *100)/100
            }
            else{
                return portInfo.inputPower;
            }
        }
        outputPower:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current *100)/100
            }
            else{
                return portInfo.outputPower;
            }
        }
        outputVoltage:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.output_voltage *100)/100
            }
            else{
                return portInfo.outputVoltage;
            }
        }
        portTemperature:{
            if (platformInterface.request_usb_power_notification.port === portNumber){
                return Math.round(platformInterface.request_usb_power_notification.temperature *10)/10
            }
            else{
                return portInfo.portTemperature;
            }
        }
//        efficency: {
//            var theInputPower = platformInterface.request_usb_power_notification.input_voltage * platformInterface.request_usb_power_notification.input_current;
//            var theOutputPower = platformInterface.request_usb_power_notification.output_voltage * platformInterface.request_usb_power_notification.output_current;

//            if (platformInterface.request_usb_power_notification.port === portNumber){
//                if (theInputPower == 0){    //division by 0 would normally give "nan"
//                    return "—"
//                }
//                else{
//                    //return Math.round((theOutputPower/theInputPower)*100)/100
//                    return "—"
//                }
//            }
//            else{
//                return portInfo.efficency;
//            }
//        }
    }



    Rectangle{
        id:graphAndCapibilitiesRect
        anchors.left: portInfo.right
        anchors.verticalCenter: portInfo.verticalCenter
        anchors.verticalCenterOffset: 2

        height:225
        width:310

        SGLayoutDivider {
            position: "left"
        }


        Text {
            id: advertisedVoltagesText
            text: "<b>Advertised Voltages</b>"
            font {
                pixelSize: 16
            }
            anchors {
                bottom: faultProtectionButtonStrip.top
                bottomMargin: 10
                left: graphAndCapibilitiesRect.left
                leftMargin: 10
            }
        }

        SGSegmentedButtonStrip {
            id: faultProtectionButtonStrip
            anchors {
                left: graphAndCapibilitiesRect.left
                leftMargin: 10
                bottom: graphAndCapibilitiesRect.verticalCenter
                bottomMargin: 15
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            hoverEnabled: false
            buttonImplicitWidth:0   //minimize width of the buttons

            property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

            onSourceCapabilitiesChanged:{

                //the strip's first child is the Grid layout. The children of that layout are the buttons in
                //question. This makes accessing the buttons a little bit cumbersome since they're loaded dynamically.
                if (platformInterface.usb_pd_advertised_voltages_notification.port === portNumber){
                    //console.log("updating advertised voltages for port ",portNumber)
                    //disable all the possibilities
                    faultProtectionButtonStrip.buttonList[0].children[6].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[5].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[4].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[3].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[2].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[1].enabled = false;
                    faultProtectionButtonStrip.buttonList[0].children[0].enabled = false;

                    var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
                    if (numberOfSettings >= 7){
                        faultProtectionButtonStrip.buttonList[0].children[6].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[6].text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[6].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[6].text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[6].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[6].text = "NA";
                    }

                    if (numberOfSettings >= 6){
                        faultProtectionButtonStrip.buttonList[0].children[5].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[5].text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[5].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[5].text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[5].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[5].text = "NA";
                    }

                    if (numberOfSettings >= 5){
                        faultProtectionButtonStrip.buttonList[0].children[4].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[4].text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[4].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[4].text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[4].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[4].text = "NA";
                    }

                    if (numberOfSettings >= 4){
                        faultProtectionButtonStrip.buttonList[0].children[3].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[3].text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[3].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[3].text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[3].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[3].text = "NA";
                    }

                    if (numberOfSettings >= 3){
                        faultProtectionButtonStrip.buttonList[0].children[2].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[2].text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[2].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[2].text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[2].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[2].text = "NA";
                    }

                    if (numberOfSettings >= 2){
                        faultProtectionButtonStrip.buttonList[0].children[1].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[1].text = platformInterface.usb_pd_advertised_voltages_notification.settings[1].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[1].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[1].text += platformInterface.usb_pd_advertised_voltages_notification.settings[1].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[1].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[1].text = "NA";
                    }

                    if (numberOfSettings >= 1){
                        faultProtectionButtonStrip.buttonList[0].children[0].enabled = true;
                        faultProtectionButtonStrip.buttonList[0].children[0].text = platformInterface.usb_pd_advertised_voltages_notification.settings[0].voltage;
                        faultProtectionButtonStrip.buttonList[0].children[0].text += "V\n ";
                        faultProtectionButtonStrip.buttonList[0].children[0].text += platformInterface.usb_pd_advertised_voltages_notification.settings[0].maximum_current;
                        faultProtectionButtonStrip.buttonList[0].children[0].text += "A";
                    }
                    else{
                        faultProtectionButtonStrip.buttonList[0].children[1].text = "NA";
                    }

                }
            }

            segmentedButtons: GridLayout {
                id:advertisedVoltageGridLayout
                columnSpacing: 2

                SGSegmentedButton{
                    id: setting1
                    //text: qsTr("5V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id: setting2
                    //text: qsTr("7V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting3
                    //text: qsTr("8V, 3A")
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting4
                    //text: qsTr("9V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting5
                    //text: qsTr("12V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting6
                    //text: qsTr("15V, 3A")
                    //enabled: false
                    checkable: false
                }

                SGSegmentedButton{
                    id:setting7
                    //text: qsTr("20V, 3A")
                    //enabled: false
                    checkable: false
                }
            }
        }

        SGSegmentedButtonStrip {
            id: graphSelector
            label: "<b>Show Graphs</b>"
            labelLeft: false
            labelFontSize: 16
            anchors {
                top: graphAndCapibilitiesRect.verticalCenter
                topMargin: 15
                left: graphAndCapibilitiesRect.left
                leftMargin: 10
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            exclusive: false
            buttonImplicitWidth: 0
            enabled: root.portConnected
            property int howManyChecked: 0

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                SGSegmentedButton{
                    text: qsTr("Vout")
                    enabled: root.portConnected
                    onCheckedChanged: {
                        if (checked) {
                            graph1.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph1.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Iout")
                    enabled: root.portConnected
                    onCheckedChanged: {
                        if (checked) {
                            graph2.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph2.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Iin")
                    enabled: root.portConnected
                    onCheckedChanged: {
                        if (checked) {
                            graph3.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph3.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Pout")
                    enabled: root.portConnected
                    onCheckedChanged: {
                        if (checked) {
                            graph4.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph4.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
               }

                SGSegmentedButton{
                    text: qsTr("Pin")
                    enabled: root.portConnected
                    onCheckedChanged: {
                        if (checked) {
                            graph5.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph5.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

//                SGSegmentedButton{
//                    text: qsTr("η")
//                    enabled: root.portConnected
//                    onCheckedChanged: {
//                        if (checked) {
//                            graph6.visible = true
//                            graphSelector.howManyChecked++
//                        } else {
//                            graph6.visible = false
//                            graphSelector.howManyChecked--
//                        }
//                    }
//                }
            }


        }
    }


    PortSettings {
        id: portSettings
        anchors {
            left: graphAndCapibilitiesRect.right
            top: graphAndCapibilitiesRect.top
            right: root.right
        }
        height: 225

        SGLayoutDivider {
            position: "left"
        }
    }

    Row {
        id: portGraphs
        anchors {
            top: portSettings.bottom
            topMargin: 15
            left: root.left
            right: root.right
        }
        height:250

        SGGraph {
            id: graph1
            title: "Voltage Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "V"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 22                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_voltage
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraph {
            id: graph2
            title: "Current Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph1.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 6                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraph {
            id: graph3
            title: "Current In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph2.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "A"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 6                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.input_current
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraph {
            id: graph4
            title: "Power Out"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph3.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 110                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.output_voltage *
                            platformInterface.request_usb_power_notification.output_current;
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraph {
            id: graph5
            title: "Power In"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
//                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "W"
            xAxisTitle: "Seconds"
            minYValue: 0                    // Default: 0
            maxYValue: 110                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    stream = platformInterface.request_usb_power_notification.input_voltage *
                            platformInterface.request_usb_power_notification.input_current;
                }
            }

            inputData: stream          // Set the graph's data source here
        }

        SGGraph {
            id: graph6
            title: "Efficiency"
            visible: false
            anchors {
                top: portGraphs.top
                bottom: portGraphs.bottom
                //                left: graph4.right
            }
            width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
            yAxisTitle: "Percent"
            xAxisTitle: "Seconds"

            minYValue: 0                    // Default: 0
            maxYValue: 100                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 5                    // Default: 10

            property real stream: 0
            property real count: 0
            property real interval: 10 // 10 Hz?
            property real inputPower: 0
            property real outputPower: 0

            property var powerInfo: platformInterface.request_usb_power_notification.output_voltage
            onPowerInfoChanged:{
                //console.log("new power notification for port ",portNumber);
                if (platformInterface.request_usb_power_notification.port === portNumber){
                    //console.log("voltage=",platformInterface.request_usb_power_notification.output_voltage," count=",count);
                    count += interval;
                    inputPower = platformInterface.request_usb_power_notification.input_voltage *
                            platformInterface.request_usb_power_notification.input_current;
                    outputPower = platformInterface.request_usb_power_notification.output_voltage *
                            platformInterface.request_usb_power_notification.output_current;
                    //console.log("inputPower=",inputPower," outputPower=",outputPower,(outputPower/inputPower)*100);
                    if (inputPower == 0)
                        stream = 0;
                    else{
                        stream = (outputPower/inputPower)*100;
                    }
                }
            }

            inputData: stream          // Set the graph's data source here
        }
    }

}
