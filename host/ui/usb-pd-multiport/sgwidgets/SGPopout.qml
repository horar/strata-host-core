import QtQuick 2.9
import QtQuick.Window 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

Rectangle {
    id: root

    property alias content: content.sourceComponent

    property real unpoppedWidth: 200
    property real unpoppedHeight: 100
    property string title: "Popout Container"
    property color overlaycolor: "tomato"
    property variant clickPos: "1,1" // @disable-check M311 // Ignore 'use string' (M311) QtCreator warning
    property bool firstPop: true
    property bool popped: false

    implicitWidth: unpoppedWidth
    implicitHeight: unpoppedHeight

    Rectangle {
        id: popout
        anchors {
            fill: parent
        }
        color: "#eee"
        border {
            width: 1
            color: "#ccc"
        }

        // TODO - Faller : remove this overlay that is just to highlight each popout box by color
        Rectangle {
            color: root.overlaycolor
            opacity: .05
            anchors {
                fill: parent
            }
            z:20
        }

        states: [
            State {
                name: "unpopped"
                ParentChange {
                    target: popout
                    parent: root
                }
            },
            State {
                name: "popped"
                ParentChange {
                    target: popout
                    parent: poppedWindow
                    x: 0
                    y: 0
                }
            }
        ]

        transitions: [
            Transition {
                id: popoutAnimation
                from: "*"
                to: "popped"
                NumberAnimation {
                    target: root
                    property: "height"
                    from: root.height
                    to: 0
                    duration: 200
                }
                NumberAnimation {
                    target: root
                    property: "width"
                    from: root.width
                    to: 0
                    duration: 200
                }
                onRunningChanged: {
                    if (popoutAnimation.running){
                        root.popped = true
                    }
                }
            },
            Transition {
                id: popinAnimation
                from: "popped"
                to: "unpopped"
                NumberAnimation {
                    target: root
                    property: "height"
                    from: root.height
                    to: root.unpoppedHeight
                    duration: 200
                }
                NumberAnimation {
                    target: root
                    property: "width"
                    from: root.width
                    to: root.unpoppedWidth
                    duration: 200
                }
                onRunningChanged: {
                    if (popinAnimation.running){
                        root.popped = false
                    } else {
                        root.width = Qt.binding(function() { return root.unpoppedWidth})  // Rebind unpopped dims after animation - numberAnimation is a shallow reference that does not override a propertyChange in the state (probable bug)
                        root.height = Qt.binding(function() { return root.unpoppedHeight})
                    }
                }
            }
        ]

        Rectangle {
            id: topBar
            anchors {
                top: parent.top
                left: parent.left
            }
            width: parent.width
            height: 32
            color: popout.color
            border {
                width: 1
                color: "#ccc"
            }

            Text {
                id: title
                text: root.title
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 13
                }
            }

            MouseArea {
                enabled: popout.state === "popped"
                anchors {
                    fill: parent
                }

                onPressed: {
                    root.clickPos = Qt.point(mouse.x,mouse.y)
                }

                onPositionChanged: {
                    var delta = Qt.point(mouse.x-root.clickPos.x, mouse.y-root.clickPos.y)
                    popoutWindow.x += delta.x;
                    popoutWindow.y += delta.y;
                }
            }

            Rectangle {
                id: popper
                height: topBar.height
                width: height
                anchors {
                    verticalCenter: topBar.verticalCenter
                    right: topBar.right
                }
                color: "#eee"
                border {
                    width: 1
                    color: "#ccc"
                }

                Text {
                    id: popperIcon
                    rotation: popout.state === "unpopped" | popout.state === ""  ? 0 : 180
                    text: popout.state === "unpopped" | popout.state === ""  ? "\u0038" : "\u0037"
                    font {
                        pixelSize: 18
                        family: sgicons.name
                    }
                    anchors {
                        centerIn: parent
                    }
                    color: "#888"
                }

                MouseArea {
                    anchors.fill: parent;
                    onClicked: {
                        if (popout.state === "unpopped" | popout.state === "" ){
                            if (root.firstPop) {
                                popoutWindow.width = root.unpoppedWidth
                                popoutWindow.height = root.unpoppedHeight
                                var globalPosition = mapToGlobal(mouse.x, mouse.y)
                                popoutWindow.x = globalPosition.x - popoutWindow.width / 2;
                                popoutWindow.y = globalPosition.y - topBar.height / 2;
                                root.firstPop = false
                            }
                            popout.state = "popped"
                            popoutWindow.visible = true
                        } else {
                            popout.state = "unpopped"
                            popoutWindow.visible = false
                        }
                    }
                }
            }
        }

        Rectangle {
            id: popoutContent
            color: popout.color
            anchors {
                top: topBar.bottom
                left: popout.left
                right: popout.right
                bottom: popout.bottom
                margins: 1
            }

            Loader {
                id: content
                anchors {
                    fill: parent
                }
            }
        }
    }

    Window {
        id: popoutWindow
        visible: false
        flags: Qt.Tool | Qt.FramelessWindowHint

        Rectangle {
            id: poppedWindow
            anchors {
                fill: parent
            }
            color: "white"
        }

        MouseArea {
            id: resize
            anchors {
                right: parent.right
                bottom: parent.bottom
            }
            width: 15
            height: 15
            enabled: popout.state === "popped"
            cursorShape: Qt.SizeFDiagCursor

            onPressed: {
                root.clickPos  = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-root.clickPos.x, mouse.y-root.clickPos.y)
                popoutWindow.width += delta.x;
                popoutWindow.height += delta.y;
            }

            Text {
                id: resizeHint
                text: "\u0023"
                rotation: -45
                opacity: 0.15
                anchors {
                    right: parent.right
                    rightMargin: 4
                    bottom: parent.bottom
                }
                font {
                    pixelSize: 18
                    family: sgicons.name
                }
            }
        }
    }

    FontLoader {
        id: sgicons
        source: "fonts/sgicons.ttf"
    }
}
