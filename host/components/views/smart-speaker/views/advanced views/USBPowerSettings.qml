import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"

    property bool isConnected: platformInterface.usb_pd_port_connect.connection_state === "connected"

    Rectangle{
        id:notConnectedScrim
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.bottom:parent.bottom
        anchors.right:parent.right
        color:"transparent"
        visible:!isConnected
        Text{
            id:notConnectedText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: parent.height/8
            text:"not \nconnected"
            horizontalAlignment: Text.AlignHCenter
            color:hightlightColor
            font.pixelSize: 72
            opacity:.75
        }
    }

    Text{
        id:sinkCapLabel
        font.pixelSize: 18
        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: parent.top
        text:"Sink capabilities:"
        color: "black"
        visible:isConnected
    }



    SGSegmentedButtonStrip {
        id: sinkCapabilitiesButtonStrip

        anchors.left:parent.left
        anchors.leftMargin:10
        anchors.top: sinkCapLabel.bottom
        anchors.topMargin: 10

        buttonImplicitWidth:0   //minimize width of the buttons
        textColor: "#444"
        activeTextColor: "white"
        radius: buttonHeight/2
        buttonHeight: 20
        exclusive: true
        //buttonImplicitWidth: 50
        hoverEnabled:false
        visible:isConnected

        property var sourceCapabilities: platformInterface.usb_pd_advertised_voltages_notification.settings

        onSourceCapabilitiesChanged:{

          if (sinkCapabilitiesButtonStrip.buttonList[0]){
            //disable all the possibilities
            sinkCapabilitiesButtonStrip.buttonList[0].children[6].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[5].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[4].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[3].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[2].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[1].enabled = false;
            sinkCapabilitiesButtonStrip.buttonList[0].children[0].enabled = false;

            var numberOfSettings = platformInterface.usb_pd_advertised_voltages_notification.number_of_settings;
            if (numberOfSettings >= 7){
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].text = platformInterface.usb_pd_advertised_voltages_notification.settings[6].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].text += platformInterface.usb_pd_advertised_voltages_notification.settings[6].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[6].text += "A";
            }
            else{
                faultProtectionButtonStrip.buttonList[0].children[6].text = "NA";
            }

            if (numberOfSettings >= 6){
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].text = platformInterface.usb_pd_advertised_voltages_notification.settings[5].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].text += platformInterface.usb_pd_advertised_voltages_notification.settings[5].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[5].text += "A";
            }
            else{
                faultProtectionButtonStrip.buttonList[0].children[5].text = "NA";
            }

            if (numberOfSettings >= 5){
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].text = platformInterface.usb_pd_advertised_voltages_notification.settings[4].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].text += platformInterface.usb_pd_advertised_voltages_notification.settings[4].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].text += "A";
            }
            else{
                sinkCapabilitiesButtonStrip.buttonList[0].children[4].text = "NA";
            }

            if (numberOfSettings >= 4){
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].text = platformInterface.usb_pd_advertised_voltages_notification.settings[3].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].text += platformInterface.usb_pd_advertised_voltages_notification.settings[3].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[3].text += "A";
            }
            else{
                faultProtectionButtonStrip.buttonList[0].children[3].text = "NA";
            }

            if (numberOfSettings >= 3){
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].text = platformInterface.usb_pd_advertised_voltages_notification.settings[2].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].text += platformInterface.usb_pd_advertised_voltages_notification.settings[2].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].text += "A";
            }
            else{
                sinkCapabilitiesButtonStrip.buttonList[0].children[2].text = "NA";
            }

            if (numberOfSettings >= 2){
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[1].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text = platformInterface.usb_pd_advertised_voltages_notification.settings[1].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text += platformInterface.usb_pd_advertised_voltages_notification.settings[1].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text += "A";
            }
            else{
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text = "NA";
            }

            if (numberOfSettings >= 1){
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].enabled = true;
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].voltage = platformInterface.usb_pd_advertised_voltages_notification.settings[0].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].text = platformInterface.usb_pd_advertised_voltages_notification.settings[0].voltage;
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].text += "V\n ";
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].text += platformInterface.usb_pd_advertised_voltages_notification.settings[0].maximum_current;
                sinkCapabilitiesButtonStrip.buttonList[0].children[0].text += "A";
            }
            else{
                sinkCapabilitiesButtonStrip.buttonList[0].children[1].text = "NA";
            }
          }

        }

        segmentedButtons: GridLayout {
            id:advertisedVoltageGridLayout
            columnSpacing: 2

            SGSegmentedButton{
                id: setting1
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting1.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id: setting2
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting2.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id:setting3
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting3.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id:setting4
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting4.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id:setting5
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting5.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id:setting6
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting6.voltage,"usb")
                }
            }

            SGSegmentedButton{
                id:setting7
                activeColor: buttonSelectedColor
                inactiveColor: "white"
                checked: true
                text:"N/A"
                property double voltage:0;

                onClicked: {
                    platformInterface.set_audio_amp_voltage.update(setting7.voltage,"usb")
                }
            }
        }
    }
}
