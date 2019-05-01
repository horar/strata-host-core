import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3  //for gridLayout
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id:advanceControlsView

    function transitionToAdvancedView(){
        //set the opacity of the view to be seen, but set the opacity of the parts to 0
        advanceControlsView.opacity = 1;
        topDivider.opacity = 0;
        maxOutputPower.opacity = 0;
        currentLimitText.opacity = 0;
        currentLimitSlider.opacity = 0
        cableCompensationHeaderText.opacity = 0

        showGraphText.opacity = 0;
        graphSelector.opacity = 0;
        sourceCapabilitiesText.opacity = 0;
        sourceCapabilitiesButtonStrip.opacity = 0;

        advancedPortControlsBuildIn.start()
    }

    SequentialAnimation{
        id: advancedPortControlsBuildIn
        running: false

        PropertyAnimation {
            targets: [topDivider, maxOutputPower, currentLimitText, currentLimitSlider ]
            property: "opacity"
            from: 0
            to: 1
            duration: advancedControlBuildInTime
        }

        PropertyAnimation {
            targets: [cableCompensationHeaderText]
            property: "opacity"
            to: 1
            duration: advancedControlBuildInTime
        }

        PropertyAnimation {
            id: fadeInGraphsSection
            targets: [showGraphText,graphSelector]
            property: "opacity"
            to: 1
            duration: advancedControlBuildInTime
        }
        PropertyAnimation {
            id: fadeInSourceCapibilitiesSection
            targets: [sourceCapabilitiesText,sourceCapabilitiesButtonStrip]
            property: "opacity"
            to: 1
            duration: advancedControlBuildInTime
        }

        onStopped: {
            //console.log("finished advanced build-in")
        }

    }

    function transitionToBasicView(){
        //set the opacity of the view to be seen, but set the opacity of the parts to 0
        advanceControlsView.opacity = 0;
        topDivider.opacity = 0;
        maxOutputPower.opacity = 0;
        currentLimitText.opacity = 0;
        currentLimitSlider.opacity = 0
        cableCompensationText.opacity = 0
        outputBiasText.opacity = 0;
        cableCompensationDivider.opacity = 0;
        cableCompensationHeaderText.opacity = 0
        cableCompensationIncrementSlider.opacity = 0
        outputBiasSlider.opacity = 1;

        showGraphText.opacity = 0;
        graphSelector.opacity = 0;
        capabilitiesDivider.opacity = 0;
        sourceCapabilitiesText.opacity = 0;
        sourceCapabilitiesButtonStrip.opacity = 0;

        //do we want a build-out here?
        //advancedPortControlsBuildIn.start()
    }

    Rectangle{
        id:topDivider
        anchors.left: advanceControlsView.left
        anchors.right:advanceControlsView.right
        anchors.top: advanceControlsView.top
        anchors.topMargin: 10
        height: 1
        color:"grey"
    }

    SGComboBox {
        id: maxOutputPower
        label: "Max Output Power:"
        model: ["15","27", "36", "45","60","100"]
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
            top: topDivider.bottom
            topMargin: 5
        }
        comboBoxWidth: 70
        comboBoxHeight: 25
        //when changing the value
        onActivated: {
            //console.log("setting input power foldback to ",limitOutput.comboBox.currentText);
            platformInterface.set_usb_pd_maximum_power.update(portNumber,
                                                              maxOutputPower.comboBox.currentText)
        }

        property var currentFoldbackOuput: platformInterface.usb_pd_maximum_power.commanded_max_power
        onCurrentFoldbackOuputChanged: {
            //console.log("got a new min power setting",platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power);
            if (platformInterface.usb_pd_maximum_power.port === portNumber){
                maxOutputPower.currentIndex = maxOutputPower.comboBox.find( parseInt (platformInterface.usb_pd_maximum_power.commanded_max_power))
            }
        }


    }

    Text{
        id:currentLimitText
        text:"Current Limit:"
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: maxOutputPower.bottom
            topMargin: 5
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSlider {
        id: currentLimitSlider
        //value: platformInterface.request_over_current_protection_notification.current_limit
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: currentLimitText.bottom
            topMargin: 3
            right: advanceControlsView.right
            rightMargin: 10
        }
        from: 0
        to: 100
        startLabel: "0A"
        endLabel: "5A"

        property  var overCurrentProtection: platformInterface.request_over_current_protection_notification

        onOverCurrentProtectionChanged: {
            if (platformInterface.request_over_current_protection_notification.port === portNumber){
                value = platformInterface.request_over_current_protection_notification.current_limit
            }
        }

        //copy the current values for other stuff, and add the new slider value for the limit.
        onMoved: platformInterface.set_over_current_protection.update(portNumber, true,
                         value)
    }


    Text{
        id:cableCompensationHeaderText
        text:"CABLE COMPENSATION"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: currentLimitSlider.bottom
            topMargin: 15
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSegmentedButtonStrip {
        id: cableCompensationButtonStrip
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
            top: cableCompensationHeaderText.bottom
            topMargin: 5
        }
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 25
        hoverEnabled: false

        property var cableLoss: platformInterface.get_cable_loss_compensation

        onCableLossChanged: {
            if (platformInterface.get_cable_loss_compensation.port === portNumber){
                console.log("cable compensation for port ",portNumber,"set to",platformInterface.get_cable_loss_compensation.bias_voltage*1000)
                if (platformInterface.get_cable_loss_compensation.bias_voltage === 0){
                    cableCompensationButtonStrip.buttonList[0].children[0].checked = true;
                }
                else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 100){
                    console.log("setting cable compensation for port",portNumber,"to 100");
                    cableCompensationButtonStrip.buttonList[0].children[1].checked = true;
                }
                else if (platformInterface.get_cable_loss_compensation.bias_voltage * 1000 == 200){
                    cableCompensationButtonStrip.buttonList[0].children[2].checked = true;
                }
            }
        }

        segmentedButtons: GridLayout {
            id:cableCompensationGridLayout
            columnSpacing: 2

            SGSegmentedButton{
                id: cableCompensationSetting1
                text: qsTr("Off")
                checkable: true

                onClicked:{
                    platformInterface.set_cable_compensation.update(portNumber,
                                           1,
                                           0);
                }
            }

            SGSegmentedButton{
                id: cableCompensationSetting2
                text: qsTr("100 mv/A")
                checkable: true

                onClicked:{
                    platformInterface.set_cable_compensation.update(portNumber,
                                           1,
                                           100/1000);
                }
            }

            SGSegmentedButton{
                id:cableCompensationSetting3
                text: qsTr("200 mv/A")
                checkable: true

                onClicked:{
                    platformInterface.set_cable_compensation.update(portNumber,
                                           1,
                                           200/1000);
                }
            }
        }
    }



    Text{
        id:showGraphText
        text:"GRAPHS"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: cableCompensationButtonStrip.bottom
            topMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    PortGraphWindow{
        id:portGraphWindow
        title: "<b>Port " + portNumber + "</b>"
        windowWidth:800
        windowHeight:300

        onWindowClosed: {
            //when the window closes, the buttons corresonding to the graphs in that window
            //should turn off
            graphSelector.deselectAllButtons();
        }
    }

    SGSegmentedButtonStrip {
        id: graphSelector
        labelLeft: false
        anchors {
            top: showGraphText.bottom
            topMargin: 5
            horizontalCenter: advanceControlsView.horizontalCenter
        }
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 25
        exclusive: false
        buttonImplicitWidth: 5
        enabled: root.portConnected
        property int howManyChecked: 0

        function deselectAllButtons() {
           console.log("deselect buttons called")

            for (var child_id in graphSelector.buttonList[0].children) {
                graphSelector.buttonList[0].children[child_id].checked = false;
            }
        }

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            property alias vOut: voutButton
            property alias iOutButton: iOutButton
            property alias iInButton: iInButton
            property alias pOutButton: pOutButton
            property alias pInButton: pInButton
            property alias efficiencyButton: efficiencyButton

            SGSegmentedButton{
                id:voutButton
                text: qsTr("Vout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph1.visible = true;
                        portGraphWindow.howManyChecked++;
                    } else {
                        portGraphWindow.graph1.visible = false;
                        portGraphWindow.howManyChecked--;
                    }
                }
            }

            SGSegmentedButton{
                id:iOutButton
                text: qsTr("Iout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph2.visible = true
                        portGraphWindow.howManyChecked++
                    } else {
                        portGraphWindow.graph2.visible = false
                        portGraphWindow.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                id:iInButton
                text: qsTr("Iin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph3.visible = true
                        portGraphWindow.howManyChecked++
                    } else {
                        portGraphWindow.graph3.visible = false
                        portGraphWindow.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                id:pOutButton
                text: qsTr("Pout")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph4.visible = true
                        portGraphWindow.howManyChecked++
                    } else {
                        portGraphWindow.graph4.visible = false
                        portGraphWindow.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                id:pInButton
                text: qsTr("Pin")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph5.visible = true
                        portGraphWindow.howManyChecked++
                    } else {
                        portGraphWindow.graph5.visible = false
                        portGraphWindow.howManyChecked--
                    }
                }
            }

            SGSegmentedButton{
                id:efficiencyButton
                text: qsTr("η")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        portGraphWindow.open = true;
                        portGraphWindow.graph6.visible = true
                        portGraphWindow.howManyChecked++
                    } else {
                        portGraphWindow.graph6.visible = false
                        portGraphWindow.howManyChecked--
                    }
                }
            }
        }
    }



    Text{
        id:sourceCapabilitiesText
        text:"SOURCE CAPABILITIES"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: graphSelector.bottom
            topMargin: 15
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSegmentedButtonStrip {
        id: sourceCapabilitiesButtonStrip
        anchors {
            left: advanceControlsView.left
            top: sourceCapabilitiesText.bottom
            topMargin: 3
            verticalCenter: advanceControlsView.verticalCenter
        }
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 30
        buttonImplicitWidth: 15
        hoverEnabled: false

        property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

        onSourceCapabilitiesChanged:{

            //the strip's first child is the Grid layout. The children of that layout are the buttons in
            //question. This makes accessing the buttons a little bit cumbersome since they're loaded dynamically.
            if (platformInterface.usb_pd_advertised_voltages_notification.port === portNumber){
                //console.log("updating advertised voltages for port ",portNumber)
                //disable all the possibilities
                sourceCapabilitiesButtonStrip.buttonList[0].children[6].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[5].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[4].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[3].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[2].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[1].enabled = false;
                sourceCapabilitiesButtonStrip.buttonList[0].children[0].enabled = false;

                var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
                if (numberOfSettings >= 7){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[6].text = "NA";
                }

                if (numberOfSettings >= 6){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[5].text = "NA";
                }

                if (numberOfSettings >= 5){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[4].text = "NA";
                }

                if (numberOfSettings >= 4){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[3].text = "NA";
                }

                if (numberOfSettings >= 3){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[2].text = "NA";
                }

                if (numberOfSettings >= 2){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text = platformInterface.usb_pd_advertised_voltages_notification.settings[1].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text += platformInterface.usb_pd_advertised_voltages_notification.settings[1].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text = "NA";
                }

                if (numberOfSettings >= 1){
                    sourceCapabilitiesButtonStrip.buttonList[0].children[0].enabled = true;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[0].text = platformInterface.usb_pd_advertised_voltages_notification.settings[0].voltage;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[0].text += "V, ";
                    sourceCapabilitiesButtonStrip.buttonList[0].children[0].text += platformInterface.usb_pd_advertised_voltages_notification.settings[0].maximum_current;
                    sourceCapabilitiesButtonStrip.buttonList[0].children[0].text += "A";
                }
                else{
                    sourceCapabilitiesButtonStrip.buttonList[0].children[1].text = "NA";
                }

            }
        }

        segmentedButtons: GridLayout {
            id:advertisedVoltageGridLayout
            columnSpacing: 2

            SGSegmentedButton{
                id: setting1
                text: qsTr("5V\n3A")
                checkable: false
            }

            SGSegmentedButton{
                id: setting2
                text: qsTr("7V\n3A")
                checkable: false
            }

            SGSegmentedButton{
                id:setting3
                text: qsTr("8V\n3A")
                checkable: false
            }

            SGSegmentedButton{
                id:setting4
                text: qsTr("9V\n3A")
                //enabled: false
                checkable: false
            }

            SGSegmentedButton{
                id:setting5
                text: qsTr("12V\n3A")
                enabled: false
                checkable: false
            }

            SGSegmentedButton{
                id:setting6
                text: qsTr("15V\n3A")
                enabled: false
                checkable: false
            }

            SGSegmentedButton{
                id:setting7
                text: qsTr("20V\n3A")
                enabled: false
                checkable: false
            }
        }
    }

}
