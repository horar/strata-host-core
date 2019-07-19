import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGStatusLight Demo")

    SGAlignedLabel {
        id: demoLabel
        target: sgStatusLight
        text: "Status:"

        SGStatusLight {
            id: sgStatusLight

            // Optional Configuration:
            status: SGStatusLight.Off   // Default: "SGStatusLight.Off"
            // width: 100
            // customColor: "pink"      // Default: white (must set the status to SGStatusLight.CustomColor to use this color)

            // Useful Signals:
            onStatusChanged: console.log("Changed to " + status)
        }
    }

    Button {
        id: switchStatus
        anchors {
            top: demoLabel.bottom
            topMargin: 50
        }
        text: "Switch Status"
        onClicked: {
            if (sgStatusLight.status > 5) { sgStatusLight.status = 0 } else { sgStatusLight.status++ }
        }
    }
}
