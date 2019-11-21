import QtQuick 2.9
import QtQuick.Controls 2.3
import tech.strata.theme 1.0

// This allows responsively sized content with a minimum height/width.
// When the minimum is reached, the content will turn into a scroll view.
//
// To use, set your content's parent to this contentItem and 'anchors.fill: parent'

Item {
    id: root
    clip: true

    property real minimumHeight: 800
    property real minimumWidth: 1000
    property alias contentItem : contentItem
    property color scrollBarColor: "#D9D9D9"
    property real scrollBarWidth: 12
    property real scrollBarRadius: scrollBarWidth/2

    ScrollView {
        id: scrollView
        anchors {
            fill: root
        }

        contentWidth: contentItem.width
        contentHeight: contentItem.height

        ScrollBar.vertical: ScrollBar {
            visible: contentItem.height !== scrollView.height
            interactive: visible
            z: 100
            parent: scrollView
            anchors {
                right: scrollView.right
                top: scrollView.top
                bottom: scrollView.bottom
            }
            contentItem: Rectangle {
                implicitWidth: root.scrollBarWidth
                implicitHeight: root.scrollBarWidth
                radius: root.scrollBarRadius
                color: root.scrollBarColor
            }
        }

        ScrollBar.horizontal: ScrollBar {
            visible: contentItem.width !== scrollView.width
            interactive: visible
            z: 100
            parent: scrollView
            anchors {
                bottom: scrollView.bottom
                right: scrollView.right
                left: scrollView.left
            }
            contentItem: Rectangle {
                implicitWidth: root.scrollBarWidth
                implicitHeight: root.scrollBarWidth
                radius: root.scrollBarRadius
                color: root.scrollBarColor
            }
        }

        Item {
            id: contentItem
            width: root.width < root.minimumWidth ? root.minimumWidth : root.width
            height: root.height < root.minimumHeight ? root.minimumHeight : root.height
        }
    }
}
