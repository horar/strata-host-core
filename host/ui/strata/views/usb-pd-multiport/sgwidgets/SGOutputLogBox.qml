import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    color: outputBoxColor
    border {
        color: outputBoxBorderColor
        width: 1
    }

    property string input: ""
    property string title: qsTr("")
    property color titleTextColor: "#000000"
    property color titleBoxColor: "#eeeeee"
    property color titleBoxBorderColor: "#dddddd"
    property color outputTextColor: "#000000"
    property color outputBoxColor: "#ffffff"
    property color outputBoxBorderColor: "#dddddd"
    property bool running: true

    implicitHeight: 200
    implicitWidth: 300

    Rectangle {
        id: titleArea
        anchors {
            left: root.left
            right: root.right
            top: root.top
        }
        implicitHeight: visible ? 35 : 0
        color: root.titleBoxColor
        border {
            color: root.titleBoxBorderColor
            width: 1
        }

        Text {
            id: title
            text: root.title
            color: root.titleTextColor
            anchors {
                fill: parent
            }
            padding: 10
//            font.family: sgicons.name
        }

        Component.onCompleted: {
            if (title.text === ""){ titleArea.visible = false }
        }
    }

    ScrollView {
        id: flickableContainer
        clip: true
        anchors {
            left: root.left
            right: root.right
            top: titleArea.bottom
            bottom: root.bottom
        }

        Flickable {
            id: transcriptContainer

            anchors { fill:parent }
            contentHeight: transcript.height
            contentWidth: transcript.width

            TextEdit {
                id: transcript
                height: contentHeight + padding * 2
                width: transcriptContainer.width
                readOnly: true
                selectByMouse: true
                selectByKeyboard: true
                font.family: "Courier"
                wrapMode: TextEdit.Wrap
                textFormat: Text.RichText
                text: ""
                padding: 10
            }
        }
    }

    onInputChanged: {
        if (running) {append(outputTextColor, input)}
    }

    // Appends message in color to transcript
    function append(color, message) {
        transcript.insert(transcript.length, (transcript.cursorPosition == 0 ? "" :"<br>") + "<span style='color:" + color + ";'>" + message +"</span>");
        scroll();
    }

    // Make sure focus follows current transcript messages when window is full
    function scroll() {
        if (transcript.contentHeight > transcriptContainer.height && transcriptContainer.contentY > (transcript.height - transcriptContainer.height - 50))
        {
            transcriptContainer.contentY = transcript.height - transcriptContainer.height;
        }
    }



    // Debug button to start/stop logging data
    FontLoader {
        id: sgicons
        source: "fonts/sgicons.ttf"
    }

    Button {
        visible: true
        width: 30
        height: 30
        flat: true
        text: "\ue800"
        font.family: sgicons.name
        anchors {
            right: flickableContainer.right
            top: flickableContainer.top
        }
        checkable: true
        onClicked: root.running = !root.running
    }
}
