import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "qrc:/views/subGHz/sgwidgets"
import "qrc:/views/subGHz/views"

Item {
    id: controlView
    objectName: "control"
    anchors { fill: parent }

    PlatformInterface {
        id: platformInterface
    }

    property bool basicControlIsVisible: true
    property bool advancedControlIsVisible: false

    Item {
        id: controlContainer
        anchors {
            top: controlView.top
            bottom: controlView.bottom
            right: controlView.right
            left: controlView.left
        }

        BasicControl {
            id: basicControl
            visible: true
            property real initialAspectRatio
        }


    }

    Component.onCompleted: {
        basicControl.initialAspectRatio = controlContainer.width / controlContainer.height

        //console.log("Requesting platform Refresh")
        //platformInterface.refresh.send() //ask the platform for all the current values

        //console.log("Enabling periodic notifications")
        //platformInterface.enable_power_telemetry.update(true);

    }
}
