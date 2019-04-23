import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {
    id:root

    property alias drawerMenuItems: drawerMenuItems.sourceComponent

    property real slideDuration: 200
    property real menuWidth: 100
    property real hintWidth: 20

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
            anchors { fill: menuContainer }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }

        Column  {
            id: menuItems
            width: menuContainer.width
            anchors { verticalCenter: menuContainer.verticalCenter }
            visible: false
        }

        Item {
            id: hintIcon
            width: iconImage.width
            height: iconImage.height
            anchors {
                verticalCenter: menuContainer.verticalCenter
                left: menuContainer.left
                leftMargin: 2
            }
            Behavior on opacity { NumberAnimation { duration: root.slideDuration } }

            Image {
                id: iconImage
                visible: false
                fillMode: Image.PreserveAspectFit
                source: "icons/angle-left-solid.svg"
                sourceSize.height: 30
            }

            ColorOverlay {
                id: overlay
                anchors.fill: iconImage
                source: iconImage
                visible: true
                color: "#ddd"
            }
        }

        MouseArea{
            id: menuHover
            anchors {
                fill: menuContainer
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
    }

    Loader {
        id: drawerMenuItems

        property color menuContainerColor: menuContainer.color
        property real slideDuration: root.slideDuration

        height: root.height
        x: menuContainer.x
        z: 2

        Component.onCompleted: {
            for (var child_id in drawerMenuItems.children[0].children) {
                drawerMenuItems.children[0].children[child_id].menuItem.parent = menuItems
                drawerMenuItems.children[0].children[child_id].opened.connect(opener)
                drawerMenuItems.children[0].children[child_id].closed.connect(closer)
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
                    target: drawerMenuItems
                    property: "x"
                    duration: root.slideDuration
                    from: drawerMenuItems.x
                    to: menuContainer.x - drawerMenuItems.width
                }
                onRunningChanged: {
                    if (running){
                        //
                    }
                }
            },
            Transition {
                from: "open"
                to: "closed"
                NumberAnimation {
                    target: drawerMenuItems
                    property: "x"
                    duration: root.slideDuration
                    to: root.width-hintWidth
                    from: drawerMenuItems.x
                }
                onRunningChanged: {
                    if (!running){
                        for (var child_id in drawerMenuItems.children[0].children) {
                            drawerMenuItems.children[0].children[child_id].state = "closed"
                        }
                        drawerMenuItems.x = Qt.binding(function() { return menuContainer.x})
                    }
                }
            }
        ]

        // Function called on opened() from menuItems, closes all other menuItems
        function opener(label, width){
            drawerMenuItems.width = width
            if (drawerMenuItems.state === "open") {
                drawerMenuItems.x = menuContainer.x - drawerMenuItems.width
            } else {
                drawerMenuItems.state = "open"
            }
            for (var child_id in drawerMenuItems.children[0].children) {
                if (drawerMenuItems.children[0].children[child_id].label !== label){
                    drawerMenuItems.children[0].children[child_id].state = "closed"
                    drawerMenuItems.children[0].children[child_id].triOpacity = 0
                } else {
                    drawerMenuItems.children[0].children[child_id].state = "open"
                }
            }
        }

        // Function called on closed() from menuItems, closes all menuItems
        function closer(){
            drawerMenuItems.state = "closed"
            for (var child_id in drawerMenuItems.children[0].children) {
                    drawerMenuItems.children[0].children[child_id].fadeTri.start()
            }
        }
    }

    MouseArea{
        id: remainderHover
        anchors {
            left: root.left
            top: root.top
            bottom: root.bottom
            right: drawerMenuItems.left
        }
        hoverEnabled: true
        visible: false
        onEntered: {
            menuContainer.state = "closed"
            drawerMenuItems.closer()
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
}
