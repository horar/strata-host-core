import QtQuick 2.9
import QtQuick.Layouts 1.3

// SGAccordionItem is a clickable title bar that drops down an area that can be filled with items

Rectangle {
    id: root
    height: titleBar.height + contentContainer.height + divider.height
    width: scrollContainerWidth
    clip: true

    property alias contents: contents.sourceComponent

    property string title: "Default Title Text"
    property bool open: false
    property int openCloseTime: accordionOpenCloseTime
    property string statusIcon: accordionStatusIcon
    property color textOpenColor: accordionTextOpenColor
    property color textClosedColor: accordionTextClosedColor
    property color contentsColor: accordionContentsColor
    property color headerOpenColor: accordionHeaderOpenColor
    property color headerClosedColor: accordionHeaderClosedColor

    Rectangle {
        id: titleBar
        width: root.width
        height: 32
        color: root.open ? headerOpenColor : headerClosedColor

        Text {
            id: titleText
            text: title
            elide: Text.ElideRight
            color: root.open ? root.textOpenColor : root.textClosedColor
            anchors {
                verticalCenter: titleBar.verticalCenter
                left: titleBar.left
                leftMargin: 10
                right: minMaxContainer.left
            }
        }

        Item {
            id: minMaxContainer
            width: titleBar.height
            height: width
            anchors {
               right: titleBar.right
            }

            Text {
                id: minMaxIcon
                color: root.open ? root.textOpenColor : root.textClosedColor
                text: statusIcon
                rotation: root.open ? 180 : 0
                anchors {
                    verticalCenter: minMaxContainer.verticalCenter
                    horizontalCenter: minMaxContainer.horizontalCenter
                }
            }
        }

        MouseArea {
            id: titleBarClick
            anchors { fill: parent }
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.open = !root.open
                if (!root.open) {
                    closeContent.start()
                } else {
                    openContent.start()
                }
            }
        }
    }

    Rectangle {
        id: contentContainer
        width: root.width
        height: root.open ? contents.height : 0
        color: root.contentsColor
        anchors {
            top: titleBar.bottom
        }
        Component.onCompleted: { height = height } // Unbind so animations work after first load

        Loader {
            id: contents
            anchors {
                top: contentContainer.top
                left: contentContainer.left
                right: contentContainer.right
            }
        }
    }

    Rectangle {
        id: divider
        anchors { bottom: root.bottom }
        width: root.width
        height: 1
        color: "#fff"
    }

    NumberAnimation {
        id: closeContent
        target: contentContainer
        property: "height"
        from: contentContainer.height
        to: 0
        duration: openCloseTime
        onStopped: {
            contentContainer.height = 0 // Break binding so it stays 0 when closed
        }
    }

    NumberAnimation {
        id: openContent
        target: contentContainer
        property: "height"
        from: 0
        to: contents.height
        duration: openCloseTime
        onStopped: {
            contentContainer.height = Qt.binding(function() { return contents.height })  // Rebind contentContainer.height to contents height since animations break this and the contents may change height
        }
    }
}
