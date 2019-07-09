import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    color: statusBoxColor
    border {
        color: statusBoxBorderColor
        width: 1
    }

    property alias model: statusList.model

    property string input: ""
    property string title: qsTr("")
    property color titleTextColor: "#000000"
    property color titleBoxColor: "#eeeeee"
    property color titleBoxBorderColor: "#dddddd"
    property color statusTextColor: "#000000"
    property color statusBoxColor: "#ffffff"
    property color statusBoxBorderColor: "#dddddd"

    property bool running: true

    Rectangle {
        id: titleArea
        anchors {
            left: root.left
            right: root.right
            top: root.top
        }
        implicitHeight: 35
        color: root.titleBoxColor
        border {
            color: root.titleBoxBorderColor
            width: 1
        }

        Text {
            id: title
            text: root.title
            color: root.titleTextColor
            anchors.fill: titleArea
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            padding: 10
        }

    }


    ListView {
        id: statusList
        implicitWidth: contentItem.childrenRect.width
        implicitHeight: contentItem.childrenRect.height
        //interactive: false
        clip: true
        flickableDirection: Flickable.VerticalFlick

        anchors {
            left: root.left
            right: root.right
            top: titleArea.visible ? titleArea.bottom : root.top
            bottom: root.bottom
            margins: 20
        }

        delegate: Text {
            text: model.status // modelData
            color: root.statusTextColor
            font.family: "Courier"
            font.pixelSize: 15
        }

        highlightFollowsCurrentItem: true
        ScrollBar.vertical: ScrollBar {
            clip: true

        }

    }

    // Make sure focus follows current transcript messages when window is full
    function scroll() {
        if (statusList.contentHeight > statusList.height && statusList.contentY > (statusList.contentHeight - statusList.height - 50))
        {
            statusList.contentY = statusList.contentHeight - statusList.height;
        }
    }

    // Debug button to start/stop logging data
//    FontLoader {
//        id: sgicons
//        source: "fonts/sgicons.ttf"
//    }

//    Button {
//        visible: false
//        width: 30
//        height: 30
//        flat: true
//        text: "\ue800"
//        font.family: sgicons.name
//        anchors {
//            right: flickableContainer.right
//            top: flickableContainer.top
//        }
//        checkable: true
//        onClicked: root.running = !root.running
//    }
}
