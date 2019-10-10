import QtQuick 2.0

Item {
    id: textButton
    property alias color: background.color
    property alias text: label.text

    property int fontSize: Math.round(textButton.height / 4)

    Rectangle{
        width: parent.width
        height: parent.height
        id: background
        //anchors.centerIn: parent
        color: "transparent"
        border.color: "black"
        radius: 16
    }

    Text {
        id: label
        anchors.centerIn: parent
        text:"foo"
        font.family: "helvetica"
        //paintedWidth Returns the width of the text
        font.pixelSize: (label.paintedWidth > parent.width) ? (parent.width / label.paintedWidth) * fontSize
                                                            : fontSize
    }

    MouseArea {
           anchors.fill: parent
           onClicked: console.log(text + " clicked")
       }
}
