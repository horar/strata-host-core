import QtQuick 2.9
import QtQuick.Layouts 1.3

// SGAccordionItem is a clickable title bar that drops down an area that can be filled with items

Rectangle {
    id: root
    height: root.open ? titleBar.height + contentContainer.height + divider.height : titleBar.height + divider.height
    width: scrollContainerWidth
    clip: true

    property alias contents: contents.sourceComponent

    property string title: "Default Title Text"
    property bool open: false
    property bool firstLoad: true
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
                //Unbind root.height after initial load so animations work
                if (root.firstLoad) {
                    root.height = root.height
                    root.firstLoad = false
                }
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
        height: root.open? contents.height : 0
        color: root.contentsColor
        anchors {
            top: titleBar.bottom
        }

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
        anchors { bottom: root.bottom}
        width: root.width
        height: 1
        color: headerOpenColor
    }

    NumberAnimation {
        id: closeContent
        target: root
        property: "height"
        from: root.height
        to: titleBar.height + divider.height
        duration: openCloseTime
    }

    NumberAnimation {
        id: openContent
        target: root
        property: "height"
        from: root.height
        to: titleBar.height + contentContainer.height + divider.height
        duration: openCloseTime
    }
}
