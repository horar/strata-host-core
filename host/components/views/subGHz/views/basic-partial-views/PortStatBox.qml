import QtQuick 2.9
//import "qrc:/views/led/sgwidgets"

Rectangle {
    id: root
    height: 49
    width: parent.width
    clip: true
    color: "#f4f4f4"

    property string label: "VOLTAGE"
    property string value: "20"
    property string unit: "V"
    property string icon: "../images/icon-voltage.svg"
    property real labelSize: 9
    property real valueSize: 22
    property real unitSize: 12
    property real bottomMargin: 0
    property color textColor: "#555"
    property color portColor: "#2eb457"



//    Rectangle{
//        color:"#555"
//        anchors.left:iconImage.left
//        anchors.leftMargin: 1
//        anchors.top:iconImage.top
//        anchors.topMargin: 1
//        anchors.right:iconImage.right
//        anchors.rightMargin:1
//        anchors.bottom:iconImage.bottom
//        anchors.bottomMargin: 1
//        radius:height/2
//    }

//    Image {
//        id: iconImage
//        source: root.icon
//        opacity: (root.icon=="") ? 0 :.5
//        height: root.height * 0.9
//        width: height
//        anchors {
//            verticalCenter: root.verticalCenter
//            right: root.right
//            rightMargin: root.height * 0.05
//        }
//        mipmap: true
//    }

    Item {
        id: labelBar
        width: parent.width
        height: labelText.height + 4

        Text {
            id: labelText
            color: "#777"
            text: root.label
            horizontalAlignment :Text.Text.AlignHCenter
            anchors {
                top: labelBar.top
                topMargin: 2
                left: labelBar.left
                leftMargin: 3
                right:labelBar.right
                rightMargin:3
            }
            font {
                pixelSize: root.labelSize

            }
        }

    }

    Text {
        id: valueText
        color: textColor
        text: "<b>" + root.value + "</b>"
        horizontalAlignment :Text.Text.AlignRight
        width: parent.width -10
        anchors {
            top: labelBar.bottom
            topMargin: 0
            left: root.left
            leftMargin: 5
        }
        font {
            pixelSize: root.valueSize
            family:"helvetica"
            weight:Font.ExtraLight
        }
    }

    Text {
        id: unitText
        color: "#aaa"
        text: root.unit
        anchors {
            bottom: root.bottom
            bottomMargin: 5
            right: root.right
            rightMargin: 5
        }
        font {
            pixelSize: root.unitSize
        }
    }
}
