import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3  //for gridLayout
import "qrc:/views/usb-pd-multiport/sgwidgets"

Item {
    id:advanceControlsView

    property int buildInTime: 500

    function transitionToAdvancedView(){
        //set the opacity of the view to be seen, but set the opacity of the parts to 0
        advanceControlsView.opacity = 1;
        topDivider.opacity = 0;
        maxOutputPower.opacity = 0;
        currentLimitText.opacity = 0;
        currentLimitSlider.opacity = 0
        cableCompensationText.opacity = 0
        outputBiasText.opacity = 0;
        cableCompensationDivider.opacity = 0;
        cableCompensationHeaderText.opacity = 0
        cableCompensationIncrementSlider.opacity = 0
        outputBiasSlider.opacity = 0;

        graphDivider.opacity = 0
        showGraphText.opacity = 0;
        graphSelector.opacity = 0;
        capabilitiesDivider.opacity = 0;
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
            duration: buildInTime
        }

        PropertyAnimation {
            targets: [cableCompensationDivider,cableCompensationHeaderText,cableCompensationText, outputBiasText, cableCompensationIncrementSlider,outputBiasSlider]
            property: "opacity"
            to: 1
            duration: buildInTime
        }

        PropertyAnimation {
            id: fadeInGraphsSection
            targets: [graphDivider,showGraphText,graphSelector]
            property: "opacity"
            to: 1
            duration: buildInTime
        }
        PropertyAnimation {
            id: fadeInSourceCapibilitiesSection
            targets: [capabilitiesDivider,sourceCapabilitiesText,sourceCapabilitiesButtonStrip]
            property: "opacity"
            to: 1
            duration: buildInTime
        }

        onStopped: {
            //console.log("finished advanced build-in")
        }

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
            console.log("setting input power foldback to ",limitOutput.comboBox.currentText);
            //platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
           //                                                     platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage,
            //                                                             limitOutput.comboBox.currentText)
        }

        property var currentFoldbackOuput: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power
        onCurrentFoldbackOuputChanged: {
            //console.log("got a new min power setting",platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power);
            //limitOutput.currentIndex = limitOutput.comboBox.find( parseInt (platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power))
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
        //value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
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
        endLabel: "100V"
        //copy the current values for other stuff, and add the new slider value for the limit.
        onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                         value,
                        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
    }

    Rectangle{
        id:cableCompensationDivider
        anchors.left: advanceControlsView.left
        anchors.right:advanceControlsView.right
        anchors.top: currentLimitSlider.bottom
        anchors.topMargin: 3
        height: 1
        color:"grey"
    }

    Text{
        id:cableCompensationHeaderText
        text:"CABLE COMPENSATION"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: cableCompensationDivider.bottom
            topMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    Text{
        id:cableCompensationText
        text:"For every increment of:"
        anchors {
            left: advanceControlsView.left
            leftMargin: 20
            top: cableCompensationHeaderText.bottom
            topMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSlider {
        id: cableCompensationIncrementSlider
        //value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
        anchors {
            left: advanceControlsView.left
            leftMargin: 20
            top: cableCompensationText.bottom
            topMargin: 5
            right: advanceControlsView.right
            rightMargin: 10
        }
        from: 0
        to: 100
        startLabel: "0A"
        endLabel: "100V"
        //copy the current values for other stuff, and add the new slider value for the limit.
        onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                         value,
                        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
    }

    Text{
        id:outputBiasText
        text:"Bias output by:"
        anchors {
            left: advanceControlsView.left
            leftMargin: 20
            top: cableCompensationIncrementSlider.bottom
            topMargin: 10
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSlider {
        id: outputBiasSlider
        //value: platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage
        anchors {
            left: advanceControlsView.left
            leftMargin: 20
            top: outputBiasText.bottom
            topMargin: 5
            right: advanceControlsView.right
            rightMargin: 10
        }
        from: 0
        to: 100
        startLabel: "0A"
        endLabel: "100V"
        //copy the current values for other stuff, and add the new slider value for the limit.
        onMoved: platformInterface.set_input_voltage_foldback.update(platformInterface.foldback_input_voltage_limiting_event.input_voltage_foldback_enabled,
                         value,
                        platformInterface.foldback_input_voltage_limiting_event.foldback_minimum_voltage_power)
    }

    Rectangle{
        id:graphDivider
        anchors.left: advanceControlsView.left
        anchors.right:advanceControlsView.right
        anchors.top: outputBiasSlider.bottom
        anchors.topMargin: 3
        height: 1
        color:"grey"
    }

    Text{
        id:showGraphText
        text:"GRAPHS:"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: graphDivider.bottom
            topMargin: 3
            right: advanceControlsView.right
            rightMargin: 10
        }
    }

    SGSegmentedButtonStrip {
        id: graphSelector
        //label: "<b>Show Graphs:</b>"
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

            SGSegmentedButton{
                text: qsTr("η")
                enabled: root.portConnected
                onCheckedChanged: {
                    if (checked) {
                        graph6.visible = true
                        graphSelector.howManyChecked++
                    } else {
                        graph6.visible = false
                        graphSelector.howManyChecked--
                    }
                }
            }
        }
    }

    Rectangle{
        id:capabilitiesDivider
        anchors.left: advanceControlsView.left
        anchors.right:advanceControlsView.right
        anchors.top: graphSelector.bottom
        anchors.topMargin: 3
        height: 1
        color:"grey"
    }

    Text{
        id:sourceCapabilitiesText
        text:"SOURCE CAPABILITIES:"
        font.bold:true
        anchors {
            left: advanceControlsView.left
            leftMargin: 10
            top: capabilitiesDivider.bottom
            topMargin: 3
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
