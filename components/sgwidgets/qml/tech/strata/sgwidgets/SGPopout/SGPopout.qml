import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

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
            fill: parent  // must fill parent because the parentChange is how this works
        }
        color: "#eee"
        border {
            width: 1
            color: "#ccc"
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
                top: popout.top
                left: popout.left
            }
            width: popout.width
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
                    verticalCenter: topBar.verticalCenter
                    left: topBar.left
                    leftMargin: 13
                }
            }

            MouseArea {
                enabled: popout.state === "popped"
                anchors {
                    fill: topBar
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

                Item {
                    id: popperIcon
                    width: iconImage.width
                    height: iconImage.height
                    rotation: popout.state === "unpopped" | popout.state === ""  ? 0 : 180
                    anchors {
                        centerIn: popper
                    }

                    Image {
                        id: iconImage
                        visible: false
                        fillMode: Image.PreserveAspectFit
                        source: popout.state === "unpopped" | popout.state === ""  ? "icons/sign-in-alt-solid.svg" : "icons/sign-out-alt-solid.svg"
                        sourceSize.height: 18
                    }

                    ColorOverlay {
                        id: overlay
                        anchors.fill: iconImage
                        source: iconImage
                        visible: true
                        color: "#888"
                    }
                }

                MouseArea {
                    anchors.fill: popper;
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
                    fill: popoutContent
                }
            }
        }

        // TODO - Faller : remove this overlay that is just to highlight each popout box by color
        Rectangle {
            color: root.overlaycolor
            opacity: .05
            anchors {
                fill: popout
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
                fill: parent  // must fill parent because window
            }
            color: "white"
        }

        MouseArea {
            id: resize
            anchors {
                right: poppedWindow.right
                bottom: poppedWindow.bottom
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

            Item {
                id: resizeHint
                rotation: -45
                width: iconImage1.width
                height: iconImage1.height
                anchors {
                    right: resize.right
                    rightMargin: 4
                    bottom: resize.bottom
                }
                opacity: 0.15

                Image {
                    id: iconImage1
                    visible: false
                    fillMode: Image.PreserveAspectFit
                    source: "icons/double-caret.svg"
                    sourceSize.height: 18
                }

                ColorOverlay {
                    id: overlay1
                    anchors.fill: iconImage1
                    source: iconImage1
                    visible: true
                    color: "black"
                }
            }
        }
    }
}
