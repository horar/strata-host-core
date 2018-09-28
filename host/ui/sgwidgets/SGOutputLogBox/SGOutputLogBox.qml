import QtQuick 2.11
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
    property alias titleTextColor: title.color
    property alias titleBoxColor: titleArea.color
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
        height: visible ? 35 : 0
        color: "#eeeeee"
        border {
            color: root.titleBoxBorderColor
            width: 1
        }
        visible: title.text !== ""

        Text {
            id: title
            text: root.title
            color: "#000000"
            anchors {
                fill: titleArea
            }
            padding: 10
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

            anchors { fill: flickableContainer }
            contentHeight: transcript.height
            contentWidth: transcript.width

            TextEdit {
                id: transcript
                height: contentHeight + padding * 2
                width: root.parent.width
                readOnly: true
                selectByMouse: true
                selectByKeyboard: true
                font {
                    family: inconsolata.name // inconsolata is monospaced and has clear chars for O/0 etc
                    pixelSize: (Qt.platform.os === "osx") ? 12 : 10;
                }
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

    FontLoader {
        id: sgicons
        source: "fonts/sgicons.ttf"
    }

    FontLoader {
        id: inconsolata
        source: "fonts/Inconsolata.otf"
    }
}
