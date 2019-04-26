import QtQuick 2.9

Rectangle {
    id: root
    anchors {
        left: parent.left
        right: parent.right
    }
    height: 30
    color: "#ddd"
    border {
        color: "#bbb"
        width: 0
    }

    property alias title: title.text
    property alias horizontalAlignment: title.horizontalAlignment
    property alias pixelSize: title.font.pixelSize
    property alias bold: title.font.bold

    Text {
        id: title
        text: qsTr("Title")
        anchors {
            verticalCenter: root.verticalCenter
            left: root.left
            leftMargin: 10
            right: root.right
            rightMargin: 10
        }
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
    }
}
