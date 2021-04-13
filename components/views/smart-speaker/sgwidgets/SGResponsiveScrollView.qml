import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root
    clip: true

    property real minimumHeight: 800
    property real minimumWidth: 1000
    property alias contentItem : content.sourceComponent

    ScrollView {
        id: scrollView
        anchors {
            fill: root
        }

        contentWidth: content.width
        contentHeight: content.height

        ScrollBar.vertical: ScrollBar {
            visible: content.height !== scrollView.height
            interactive: visible
            z: 100
            parent: scrollView
            anchors {
                right: scrollView.right
                top: scrollView.top
                bottom: scrollView.bottom
            }
            contentItem: Rectangle {
                implicitWidth: 15
                implicitHeight: 15
                radius: width / 2
                color: "white"
            }
        }

        ScrollBar.horizontal: ScrollBar {
            visible: content.width !== scrollView.width
            interactive: visible
            z: 100
            parent: scrollView
            anchors {
                bottom: scrollView.bottom
                right: scrollView.right
                left: scrollView.left
            }
            contentItem: Rectangle {
                implicitWidth: 15
                implicitHeight: 15
                radius: height / 2
                color: "white"
            }
        }

        Loader {
            id: content

            width: root.width < root.minimumWidth ? root.minimumWidth : root.width
            height: root.height < root.minimumHeight ? root.minimumHeight : root.height
        }
    }
}
