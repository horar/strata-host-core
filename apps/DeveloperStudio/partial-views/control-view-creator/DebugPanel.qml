import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Rectangle {
    id: root

    width: 0
    visible: debugMenuSource.toString() !== ""

    readonly property bool expanded: width > 0 && visible
    readonly property int minimumExpandWidth: 400

    property url debugMenuSource: editor.fileTreeModel.debugMenuSource
    property int expandWidth: minimumExpandWidth
    property alias mainContainer: mainContainer

    Rectangle {
        id: mainContainer
        width: parent.width
        height: parent.height
        anchors.left: parent.left
        color: "lightgrey"
        visible: width > 0
        clip: true

        Loader {
            anchors.fill: parent
            source: root.debugMenuSource
        }
    }

    NumberAnimation {
        id: collapseAnimation
        target: root
        property: "width"
        duration: 200
        easing.type: Easing.InOutQuad
        to: 0
    }

    NumberAnimation {
        id: expandAnimation
        target: root
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
