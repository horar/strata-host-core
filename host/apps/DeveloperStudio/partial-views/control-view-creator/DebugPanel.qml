import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root

    implicitWidth: mainContainer.width
    visible: debugMenuSource.toString() !== ""

    readonly property bool expanded: mainContainer.width > 0 && visible
    property url debugMenuSource: editor.fileTreeModel.debugMenuSource
    property int expandWidth: 500
    property alias mainContainer: mainContainer

    Button {
        id: expandButton
        height: 40
        width: 20
        x: -20
        y: (parent.height - height) / 2
        z: 100

        background: Rectangle {
            color: "lightgrey"
            radius: 1
        }

        contentItem: Text {
            text: root.expanded ? "\u25b6" : "\u25c0"
            font.pointSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                if (root.expanded) {
                    collapse()
                } else {
                    expand()
                }
            }
        }
    }


    Rectangle {
        id: mainContainer
        width: 0
        height: parent.height
        anchors.left: parent.left
        color: "lightgrey"
        visible: width > 0

        Loader {
            anchors.fill: parent
            source: root.debugMenuSource
        }
    }


    NumberAnimation {
        id: collapseAnimation
        target: mainContainer
        property: "width"
        duration: 200
        easing.type: Easing.InOutQuad
        to: 0
    }


    NumberAnimation {
        id: expandAnimation
        target: mainContainer
        property: "width"
        duration: 200
        easing.type: Easing.InOutQuad
        to: root.expandWidth
    }

    function expand() {
        expandAnimation.start()
    }

    function collapse() {
        collapseAnimation.start()
    }
}
