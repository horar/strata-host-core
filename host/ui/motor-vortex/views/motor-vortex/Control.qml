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
//        top: parent.top
//        left: parent.left
//        right: parent.right
//        bottom: parent.bottom
    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            text: qsTr("Basic")
            onClicked: controlContainer.currentIndex = 1
        }
        TabButton {
            text: qsTr("Advanced")
            onClicked: controlContainer.currentIndex = 2
        }
        TabButton {
            text: qsTr("FAE Only")
            onClicked: controlContainer.currentIndex = 3
        }
    }

    SwipeView {
        id: controlContainer

        currentIndex: 1
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        Item {
            id: firstPage
            Rectangle {
                color: "tomato"
                opacity: .15
                anchors.fill: parent
                z:20
                Component.onCompleted: console.log("height: " + height + "\n     width:  " + width)

            }
        }

        Item {
            id: secondPage
        }

        Item {
            id: thirdPage
        }
    }

    Image {
        id: flipButton
        source:"./images/icons/infoIcon.svg"
        anchors { bottom: parent.bottom; right: parent.right }
        height: 40;width:40
    }
    MouseArea {
        width: flipButton.width; height: flipButton.height
        anchors { bottom: controlPage.bottom; right: controlPage.right }
        visible: true
        onClicked: {
            NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
        }
    }
}

