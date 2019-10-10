import QtQuick 2.9
import QtQuick.Layouts 1.3

// SGAccordionItem is a clickable title bar that drops down an area that can be filled with items

Rectangle {
    id: root
    height: contentContainer.height
    width: parent.width
    clip: true

    property alias contents: contents.sourceComponent
    property Item contentItem: contents.item

    property string title: "Default Title Text"
    property bool open: false
    property int openCloseTime: 80
    property string statusIcon: "\u25B2"
    property color contentsColor: "#fff"
    property color textOpenColor: "#000"
    property color textClosedColor: "#666"

    Rectangle {
        id: contentContainer
        width: root.width
        height: 0
        color: root.contentsColor
        anchors {
            top: root.top
        }

        Component.onCompleted: {
            if (root.open) {
                bindHeight()  // If open, bind height to contents.height so contents can dynamically resize the accordionItem
            }
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

    NumberAnimation {
        id: closeContent
        target: contentContainer
        property: "height"
        from: contentContainer.height
        to: 0
        duration: openCloseTime
        onStopped: {
            contentContainer.height = 0  // Bind height to 0 so any content resizing while closed doesn't resize the accordionItem
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
            bindHeight()  // Rebind to contents.height while open so contents can dynamically resize the accordionItem
        }
    }

    function bindHeight() {
        contentContainer.height = Qt.binding(function() { return contents.height })
        return
    }

    function openClose() {
        if (root.open) {
            closeContent.start()
            root.open = !root.open
        } else {
            openContent.start()
            root.open = !root.open
        }
    }
}
