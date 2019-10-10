import QtQuick 2.9
//import "qrc:/views/usb-pd-multiport/sgwidgets"

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
    //property real valueSize: 22
    property real valueSize: root.height/2
    property real unitSize: 12
    property real bottomMargin: 0
    property color textColor: "#555"
    property color portColor: "#2eb457"

     function transitionToAdvancedView(){
         shrinkIcon.start()
     }

     ParallelAnimation{
         id: shrinkIcon
         running: false

         PropertyAnimation {
             target: iconImage
             property: "height"
             to: root.height * 0.60
             duration: basicToAdvancedTransitionTime
         }

         PropertyAnimation {
             target: iconImage
             property: "anchors.verticalCenterOffset"
             to: 5
             duration: basicToAdvancedTransitionTime
         }
     }

     function transitionToBasicView(){
         enlargeIcon.start()
     }

     ParallelAnimation{
         id: enlargeIcon
         running: false

         PropertyAnimation {
             target: iconImage
             property: "height"
             to: root.height * 0.75
             duration: advancedToBasicTransitionTime
         }

         PropertyAnimation {
             target: iconImage
             property: "anchors.verticalCenterOffset"
             to: 0
             duration: advancedToBasicTransitionTime
         }
     }

    Image {
        id: iconImage
        source: root.icon
        opacity: 0.1
        height: root.height * 0.75
        width: height
        anchors {
            verticalCenter: root.verticalCenter
            right: root.right
            rightMargin: root.height * 0.05
        }
        mipmap: true
    }

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
                left: labelBar.left
                leftMargin: 3
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
            }
        }
    }

    Text {
        id: valueText
        color: textColor
        text: "<b>" + root.value + "</b>"
        anchors {
            bottom: root.bottom
            bottomMargin: root.bottomMargin
            left: root.left
            leftMargin: 5
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
            left: valueText.right
            leftMargin: 5
        }
        font {
            pixelSize: root.unitSize
        }
    }
}
