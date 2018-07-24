import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"
import "qrc:/views/motor-vortex/Control.js" as MotorControl
Rectangle {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    SGHueSlider {
        id: singleColorSlider

        label: "Entice Color Selector"
        labelLeft: true
        value: 0

        anchors.centerIn: parent
        width: 500; height: 40

        onValueChanged: {
            console.log("color=", color, ", value=", color_value)
            platformInterface.set_rgb_color.set(color_value, color_value);
        }
    }

    Image {
        id: flipButton
        source:"./images/icons/infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40; width:40
    }

    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { fill: flipButton }
        visible: true
        z: 20
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}
