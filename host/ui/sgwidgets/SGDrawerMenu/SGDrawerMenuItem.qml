import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

Item {
    id: root

    signal opened(string label, real width)
    signal closed()

    property alias menuItem: menuItem
    property alias contentDrawerWidth: contentDrawer.width
    property alias drawerVisible: contentDrawer.visible
    property alias drawerContent: drawerContent.sourceComponent
    property alias fadeTri: fadeTri
    property alias triOpacity: triangle.opacity

    property color drawerColor: "skyblue"
    property string icon: "\ue800"
    property string label: "Settings"
    property bool divider: true

    anchors {
        fill: parent
    }

    Rectangle {
        id: menuItem

        width: parent.width // must be parent here because parent is changed
        height: 80
        color: menuItemMouse.containsMouse ? "#333" : colorMod(menuContainerColor, -triangle.opacity / 30)

        Canvas {
            id: triangle
            anchors {
                left: menuItem.left
                verticalCenter: menuItem.verticalCenter
            }
            z:50
            opacity: 0
            width: 10
            height: 20
            contextType: "2d"

            onPaint: {
                var context = getContext("2d")
                context.reset();
                context.beginPath();
                context.moveTo(0, 0);
                context.lineTo(width, height/2);
                context.lineTo(0, height);
                context.closePath();
                context.fillStyle = root.drawerColor;
                context.fill();
            }
        }

        Item {
            id: menuItemIcon
            width: iconImage.width
            height: iconImage.height
            anchors {
                top: menuItem.top
                topMargin: 10
                horizontalCenter: menuItem.horizontalCenter
            }

            Image {
                id: iconImage
                visible: false
                fillMode: Image.PreserveAspectFit
                source: root.icon
                sourceSize.height: 40
            }

            ColorOverlay {
                id: overlay
                anchors.fill: iconImage
                source: iconImage
                visible: true
                color: "#bbb"
            }
        }

        Text {
            id: menuItemText
            text: root.label
            color: "#bbb"
            anchors {
                top: menuItemIcon.bottom
                topMargin: 5
            }
            width: menuItem.width
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            color: "#444"
            anchors {
                bottom: menuItem.bottom
                horizontalCenter: menuItem.horizontalCenter
            }
            width: menuItem.width - 20
            height: 1
            visible: root.divider
        }

        MouseArea {
            id: menuItemMouse
            anchors { fill: menuItem }
            hoverEnabled: true
            onClicked: {
                if (root.state === "open") {
                    root.closed()
                } else {
                    root.opened(root.label, contentDrawer.width)
                }
            }
        }
    }

    Rectangle {
        id: contentDrawer
        color: root.drawerColor
        width: 300
        height: root.height
        visible: false

        MouseArea {
            // This blocks all mouseEvents from propagating through the menu to stuff below
            anchors { fill: contentDrawer }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }

        Loader {
            id: drawerContent
            anchors {
                fill: contentDrawer
            }
        }
    }

    states: [
        State {
            name: "open"
            PropertyChanges {
                target: contentDrawer
                visible: true
            }
        },
        State {
            name: "closed"
            PropertyChanges {
                target: contentDrawer
                visible: false
            }
        }
    ]

    transitions: [ Transition {
            from: "*"
            to: "open"
            NumberAnimation {
                target: triangle
                property: "opacity"
                duration: slideDuration
                to: 1
                from: triangle.opacity
            }
        }
    ]

    NumberAnimation {
        id: fadeTri
        target: triangle
        property: "opacity"
        duration: slideDuration
        to: 0
        from: triangle.opacity
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
