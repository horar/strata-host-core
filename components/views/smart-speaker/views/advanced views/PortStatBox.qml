import QtQuick 2.10

Rectangle {
    id: root
    height: 49
    width: parent.width
    clip: true
    color: "#f4f4f4"

    property string label: "VOLTAGE"
    property string value: "20"
    property string unit: "V"
    property alias unitColor: unitText.color
//    //property string icon: "../images/icon-voltage.svg"
    property real labelSize: 9
    property real valueSize: 22
    property real unitSize: 12
    property real bottomMargin: 0
    property color textColor: "#555"
    property alias labelColor: labelText.color
    property alias underlineWidth: underline.width
//    property real imageHeightPercentage: .8




//    Image {
//        id: iconImage
//        source: root.icon
//        opacity: .5
//        height: root.height * imageHeightPercentage
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
            text: "<b>" + root.label + "</b>"
            anchors {
                top: labelBar.top
                topMargin: 2
                left:parent.left
                leftMargin:5
            }
            font {
                pixelSize: root.labelSize
            }
        }

        Rectangle {
            id: underline
            color: "#ccc"
            height: 1
            width: labelText.width + 6
            anchors {
                bottom: labelBar.bottom
                left:parent.left
                leftMargin:5
            }
        }
    }

    Text {
        id: valueText
        color: textColor
        text: "<b>" + root.value + "</b>"
        horizontalAlignment: Text.AlignRight
        anchors {
            bottom: root.bottom
            bottomMargin: root.bottomMargin
            right: unitText.left
            rightMargin: 0
        }
        font {
            pixelSize: root.valueSize
        }
    }

    Text {
        id: unitText
        color: "#aaa"
        text: root.unit

        anchors {
            bottom: valueText.bottom
            bottomMargin: 2
            right: parent.right
            rightMargin: 5
        }
        font {
            pixelSize: root.unitSize
        }
    }
}
