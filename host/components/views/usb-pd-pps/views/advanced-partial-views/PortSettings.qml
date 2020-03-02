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
            model: ["16","30", "45", "60"]
            anchors {
                left: parent.left
                leftMargin: 140
                top: parent.top
                topMargin:75
            }

            //when changing the value
            onActivated: {
                console.log("setting max power to ",maxPowerOutput.comboBox.currentText);
                platformInterface.set_usb_pd_maximum_power.update(portNumber,maxPowerOutput.comboBox.currentText)
            }

            //notification of a change from elsewhere
            property var currentMaximumPower: platformInterface.usb_pd_maximum_power.current_max_power
            onCurrentMaximumPowerChanged: {
                if (platformInterface.usb_pd_maximum_power.port === portNumber){
                    maxPowerOutput.currentIndex = maxPowerOutput.find( (platformInterface.usb_pd_maximum_power.current_max_power).toFixed(0))
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
