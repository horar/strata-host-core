import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

ListView {
    id: root
    property alias model: root.model
    property alias exclusive: buttonGroup.exclusive
    property color textColor: "#000000"
    property color radioColor: "#000000"
    property color highlightColor: "transparent"
    property color backgroundColor: "#000000"

    implicitWidth: children[0].childrenRect.width
    implicitHeight: children[0].childrenRect.height

    model: ["Option 1", "Option 2", "Option 3"]
    Component.onCompleted: console.log(children[0] === radioDelegate)
    interactive: false

    delegate: RadioDelegate {
        id: radioDelegate
        text: model.name
        checked: model.checked
        enabled: !model.disabled
        ButtonGroup.group: buttonGroup
//        Component.onCompleted: console.log(childrenRect.height)

        contentItem: Text {
            anchors.left: radioDelegate.indicator.right
            leftPadding: radioDelegate.spacing //+ radioDelegate.indicator.width
            rightPadding: radioDelegate.spacing *2
            text: radioDelegate.text
            font: radioDelegate.font
            opacity: enabled ? 1.0 : 0.3
            color: root.textColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        indicator: Rectangle {
            implicitWidth: 26
            implicitHeight: 26
            x: radioDelegate.spacing
            //x: radioDelegate.width - width - radioDelegate.rightPadding
            y: parent.height / 2 - height / 2
            radius: 13
            color: "transparent"
            opacity: enabled ? 1.0 : 0.3
            border.color: radioDelegate.down ? radioColor : radioColor

            Rectangle {
                width: 14
                height: 14
                x: 6
                y: 6
                radius: 7
                opacity: enabled ? 1.0 : 0.3
                color: radioDelegate.down ? radioColor : radioColor
                visible: radioDelegate.checked
            }
        }

        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 40
            visible: radioDelegate.down || radioDelegate.highlighted
            color: highlightColor
        }
    }

    ButtonGroup {
        id: buttonGroup
    }

    Rectangle {  // Background for whole
        z: -1
        anchors {
            fill: parent
        }
        color: root.backgroundColor
    }
}









//GroupBox {
//    anchors.fill: parent

//    //set flat to be true, and fill with a white rectangle to hide the GroupBox background
//    Rectangle {
//        anchors.fill:parent
//        color: "white"
//        border.color: "black"
//    }

//    ColumnLayout {
//        id: container
//        anchors { centerIn: parent }

//        ButtonGroup { buttons: container.children }
//        RadioButton {
//            text: "5 V"
//            id: button
//            checked: true
//        }
//        RadioButton {
//            text: "9 V"

//        }
//        RadioButton {
//            text: "12 V"

//        }
//        RadioButton {
//            text: "15 V"
//            checkable: false
//        }
//    }
//}
