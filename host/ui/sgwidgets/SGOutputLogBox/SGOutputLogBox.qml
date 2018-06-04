import QtQuick 2.11
import QtQuick.Controls 2.2

Item {
    id: root
    anchors { fill: parent }

    property string input: ""
    property string title: qsTr("")

    Rectangle {
        id: titleArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        height: 35
        width: 40
        border {
            color: "#dddddd"
            width: 1
        }

        Text {
            id: title
            text: root.title
            anchors {
                fill: parent
            }
            padding: 10
        }

        Component.onCompleted: {
            if (title.text === ""){ titleArea.visible = false }
        }
    }

    ScrollView {
        clip: true
        anchors {
            left: parent.left
            right: parent.right
            top: titleArea.visible ? titleArea.bottom : parent.top
            bottom: parent.bottom
        }

        Flickable {
            id: transcriptContainer

            anchors { fill:parent }
            contentHeight: transcript.contentHeight
            contentWidth: transcript.contentWidth

            TextEdit {
                id: transcript

                width: 770
                readOnly: true
                selectByMouse: true
                selectByKeyboard: true
                font.family: "Helvetica"
                font.pointSize: 13
                wrapMode: TextEdit.Wrap
                textFormat: Text.RichText
                text: ""
            }
        }
    }

    onInputChanged: {
        append( "red", input);
    }

    // Appends message in color to transcript
    function append(color, message) {
        transcript.insert(transcript.length, "<span style='color:" + color + ";'>" + message +"</span><br>");
        scroll();
    }

    // Make sure focus follows current transcript messages when window is full
    function scroll() {
        if (transcript.contentHeight > transcriptContainer.height && transcriptContainer.atYEnd)
        {
            transcriptContainer.contentY = transcript.contentHeight-transcriptContainer.height;
        }
    }
}
