import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root

    property alias outputVoltage: outputVoltageBox.value
    property alias inputVoltage: inputVoltageBox.value
    property alias inputCurrent: inputCurrentBox.value
    property alias outputCurrent: outputCurrentBox.value
    property alias temperature: temperatureBox.value
    //property alias efficiency: efficiencyBox.value

    property int boxHeight: root.height/5
    property int statBoxValueSize: 24
    property int statBoxUnitSize: 15

    color: "dimgray"
    radius: 10
    //border.color:"white"
    width: 400

    Column {
        id: column1

        width: root.width/3-1
        spacing: 3
        anchors.left:parent.left
        anchors.leftMargin:50

        PortStatBox{
            id:inputVoltageBox
            anchors.left:column1.left
            anchors.topMargin: 8
            anchors.right: column1.right
            height:boxHeight
            label: "VOLTAGE IN"
            labelColor: "white"
            color:"transparent"
            icon: "../images/icon-voltage.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
        }

        PortStatBox{
            id:inputCurrentBox
            anchors.left:column1.left
            anchors.topMargin: 8
            anchors.right: column1.right
            height:boxHeight
            label: "CURRENT IN"
            labelColor: "white"
            unit: "mA"
            color:"transparent"
            icon: "../images/icon-voltage.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
        }

        PortStatBox{
            id:efficiencyBox
            anchors.left:column1.left
            anchors.topMargin: 8
            anchors.right: column1.right
            height:boxHeight
            label: "EFFICIENCY"
            labelColor: "white"
            unit:"%"
            color:"transparent"
            icon: "../images/icon-efficiency.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
            opacity:0
        }

    }

    Column {
        id: column2
        anchors {
            //left: column1.right
            //leftMargin: root.width/3
            right:parent.right
            rightMargin:50
            verticalCenter: column1.verticalCenter
        }
        spacing: column1.spacing
        width: root.width/3 - 2

        PortStatBox{
            id:outputVoltageBox
            anchors.left:column2.left
            anchors.topMargin: 8
            anchors.right: column2.right
            height:boxHeight
            label: "???????"
            labelColor: "white"
            unit: "V"
            color:"transparent"
            icon: "../images/icon-voltage.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
        }

        PortStatBox{
            id:outputCurrentBox
            anchors.left:column2.left
            anchors.topMargin: 8
            anchors.right: column2.right
            height:boxHeight
            label: "CURRENT OUT"
            labelColor: "white"
            unit:"mA"
            color:"transparent"
            icon: "../images/icon-voltage.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
        }

        PortStatBox{
            id:temperatureBox
            anchors.left:column2.left
            anchors.topMargin: 8
            anchors.right: column2.right
            height:boxHeight
            label: "TEMPERATURE"
            labelColor: "white"
            unit:"°C"
            color:"transparent"
            icon: "../images/icon-temp.svg"
            valueSize:statBoxValueSize
            unitSize:statBoxUnitSize
            textColor: "#FFF"
        }
    }

    Text{
        id:sourceCapabilitiesText
        text:"SOURCE CAPABILITIES"
        color:"white"
        font.bold:true
        anchors {
            left: PortInfo.left
            leftMargin: 10
            top: column2.bottom
            topMargin: 10
//            right: advanceControlsView.right
//            rightMargin: 10
        }
    }

    SGSegmentedButtonStrip {
        id: sourceCapabilitiesButtonStrip
        anchors {
            top: sourceCapabilitiesText.bottom
            topMargin: 3
//            verticalCenter: advanceControlsView.verticalCenter
//            horizontalCenter: advanceControlsView.horizontalCenter
              left: PortInfo.left
              leftMargin: 10

        }
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 30
        buttonImplicitWidth: root.width/7 -3   //deduct the spacing between columns
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

            property int sidePadding: 5

            SGSegmentedButton{
                id: setting1
                text: qsTr("5V\n3A")
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id: setting2
                text: qsTr("7V\n3A")
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id:setting3
                text: qsTr("8V\n3A")
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id:setting4
                text: qsTr("9V\n3A")
                //enabled: false
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id:setting5
                text: qsTr("12V\n3A")
                enabled: false
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id:setting6
                text: qsTr("15V\n3A")
                enabled: false
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }

            SGSegmentedButton{
                id:setting7
                text: qsTr("20V\n3A")
                enabled: false
                checkable: false
                leftPadding:sidePadding
                rightPadding:sidePadding
            }
        }
    } //source capabilities segmented button strip
}



