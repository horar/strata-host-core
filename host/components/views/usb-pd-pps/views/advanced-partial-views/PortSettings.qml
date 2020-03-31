import QtQuick 2.12
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets09
Item {
    id: root

    Item {
        id: controlMargins
        anchors {
            fill: parent
            margins: 15
        }

        Text{
            id:maxPowerOutputText
            anchors.right: maxPowerOutput.left
            anchors.rightMargin: 5
            anchors.verticalCenter: maxPowerOutput.verticalCenter
            text:"Max Power Output:"
        }

        SGComboBox {
            id: maxPowerOutput
            model: ["30","60"]
            anchors {
                left: parent.left
                leftMargin: 140
                top: parent.top
                topMargin:75
            }

            //when changing the value
            onActivated: {
                console.log("setting max power to ",maxPowerOutput.currentText);
                platformInterface.set_usb_pd_maximum_power.update(portNumber,maxPowerOutput.currentText)
            }

            //notification of a change from elsewhere
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.watts
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port == portNumber){
                    maxPowerOutput.currentIndex = maxPowerOutput.find( (Math.trunc(platformInterface.usb_pd_maximum_power.watts)))
                }

            }

        }
        Text{
            id:maxPowerOutputUnitText
            anchors.left: maxPowerOutput.right
            anchors.leftMargin: 5
            anchors.verticalCenter: maxPowerOutput.verticalCenter
            text:"W"
        }






    }
}
