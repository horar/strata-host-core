import QtQuick 2.9
import QtQuick.Controls 2.2

import fonts 1.0

Item {
    id:root

    property alias drawerMenuItems: drawerMenuItems.sourceComponent

    property real slideDuration: 200
    property alias menuWidth: menuContainer.width
    property real hintWidth: 20

    width: hintWidth
    clip: true

    Rectangle {
        id: menuContainer
        width: 200
        height: root.height
        anchors {
            left: root.left
        }
        state: "closed"
        color: "#282a2b"

        MouseArea {
            // This blocks all mouseEvents from propagating through the menu to stuff below
            anchors { fill: menuContainer }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }


        Text {
            id: hintIcon
            text: "\ue811"
            color: enabled ? menuHover.containsMouse ? "#ddd" : "#aaa" : "#484a4b"
            font {
                pixelSize: 25
                family: Fonts.sgicons
            }
            anchors {
                verticalCenter: menuContainer.verticalCenter
                left: menuContainer.left
                leftMargin: menuContainer.state === "open" ? 5 : 0
            }
            Behavior on opacity { NumberAnimation { duration: root.slideDuration } }
        }

        Loader {
            id: drawerMenuItems

            property color menuContainerColor: menuContainer.color
            property real slideDuration: root.slideDuration

            anchors {
                top: menuContainer.top
                left: menuContainer.left
                right: menuContainer.right
                bottom: menuContainer.bottom
                leftMargin: hintWidth
            }
        }

        states: [
            State {
                name: "open"
            },
            State {
                name: "closed"
            }
        ]

        transitions: [ Transition {
                from: "*"
                to: "open"
                NumberAnimation {
                    target: root
                    property: "width"
                    duration: root.slideDuration
                    from: root.hintWidth
                    to: root.menuWidth
                }
                NumberAnimation {
                    target: hintIcon
                    property: "rotation"
                    duration: root.slideDuration
                    from: 0
                    to: 180
                }

            },
            Transition {
                from: "open"
                to: "closed"
                NumberAnimation {
                    target: root
                    property: "width"
                    duration: root.slideDuration
                    to: root.hintWidth
                    from: root.menuWidth
                }
                NumberAnimation {
                    target: hintIcon
                    property: "rotation"
                    duration: root.slideDuration
                    from: 180
                    to: 0
                }
            }
        ]
    }

    MouseArea{
        id: menuHover
        anchors {
            left: root.left
            top: root.top
            bottom: root.bottom
        }
        width: root.hintWidth
        hoverEnabled: true

        onClicked: {
            if (menuContainer.state === "open"){
                menuContainer.state = "closed"
            } else {
                menuContainer.state = "open"
            }
        }
    }
}
