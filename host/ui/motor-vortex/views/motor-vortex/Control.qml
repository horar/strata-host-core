import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
//import tech.spyglass. 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/motor-vortex/sgwidgets"

Rectangle {
    id: controlNavigation
    anchors {
        fill: parent
    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: controlContainer.currentIndex = 0
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: controlContainer.currentIndex = 1
        }

        TabButton {
            id: faeButton
            text: qsTr("FAE Only")
            onClicked: controlContainer.currentIndex = 2
            background: Rectangle {
                color: faeButton.down ? "#eeeeee" : faeButton.checked ? "white" : "tomato"
            }
        }
    }

    SwipeView {
        id: controlContainer

        currentIndex: 0
        interactive: false
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        Item {
            id: basicControl
            BasicControl {

            }
        }

        Item {
            id: advancedControl
            AdvancedControl {

            }

        }

        Item {
            id: faeControl
            FAEControl {

            }
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

