import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id:root

    property real slideDuration: 200
    property real menuWidth: 450
    property real hintWidth: 0 //20
    property alias state: menuContainer.state

    anchors {
        fill: parent
    }

    Rectangle {
        id: menuContainer
        width: root.menuWidth
        height: root.height
        x: root.width-hintWidth
        z: 3
        color: "#282a2b"

        MouseArea {
            // This blocks all mouseEvents from propagating through the menu to stuff below
            anchors { fill: parent }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }

        Column  {
            id: menuItems
            width: parent.width
            anchors { verticalCenter: parent.verticalCenter }
            visible: false
        }

        Text {
            id: hintIcon
            text: "\ue811"
            color: "#ddd"
            font {
                pixelSize: 25
                family: sgicons.name
            }
            anchors {
                verticalCenter: menuContainer.verticalCenter
                left: menuContainer.left
            }
            Behavior on opacity { NumberAnimation { duration: root.slideDuration } }
        }

        MouseArea{
            id: menuHover
            anchors {
                fill:parent
            }
            hoverEnabled: true
            onEntered: {
                menuContainer.state = "open"
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
                    target: menuContainer
                    property: "x"
                    duration: root.slideDuration
                    from: menuContainer.x
                    to: root.width - root.menuWidth
                }
                NumberAnimation {
                    target: hintIcon
                    property: "opacity"
                    duration: root.slideDuration
                    from: 1
                    to: 0
                }
                NumberAnimation {
                    target: modalArea
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0
                    to: 0.2
                }
                onRunningChanged: {
                    if (!running){
                        menuHover.visible = false
                        remainderHover.visible = true
                    } else {
                        menuItems.visible = true
                    }
                }
            },
            Transition {
                from: "open"
                to: "closed"
                NumberAnimation {
                    target: menuContainer
                    property: "x"
                    duration: root.slideDuration
                    to: root.width - root.hintWidth
                    from: menuContainer.x
                }
                NumberAnimation {
                    target: hintIcon
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0
                    to: 1
                }
                NumberAnimation {
                    target: modalArea
                    property: "opacity"
                    duration: root.slideDuration
                    from: 0.2
                    to: 0
                }
                onRunningChanged: {
                    if (!running){
                        menuHover.visible = true
                        remainderHover.visible = false
                        menuItems.visible = false
                    }
                }
            }
        ]

        Text {
            text: "<b>Graphs Here</b>"
            font {
                pixelSize: 50
            }
            color: "#fff"
            anchors {
                centerIn: parent
            }
        }
    }

    MouseArea{
        id: remainderHover
        anchors {
            left: root.left
            top: root.top
            bottom: root.bottom
            right: menuContainer.left
        }
        //hoverEnabled: true
        visible: false
        onClicked: {
            menuContainer.state = "closed"
            //drawerMenuItems.closer()
        }
    }

    Rectangle {
        id: modalArea
        color: "#000"
        opacity: 0
        z: 1
        anchors {
            fill: remainderHover
        }
    }

    FontLoader {
        id: sgicons
        source: "/sgwidgets/fonts/sgicons.ttf"
    }
}
