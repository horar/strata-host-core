import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root

    implicitWidth: expandButtonColumn.width + mainContainer.width
    visible: debugMenuSource.toString() !== ""

    property bool expanded: mainContainer.width > 0
    property url debugMenuSource: editor.fileTreeModel.debugMenuSource
    property int expandWidth: 400

    Item {
        id: expandButtonColumn
        width: 20
        height: parent.height
        anchors.left: parent.left

        Button {
            height: 40
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter

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
    }

    Rectangle {
        id: mainContainer
        width: 0
        height: parent.height
        anchors.left: expandButtonColumn.right
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
