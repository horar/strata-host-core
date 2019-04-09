import QtQuick 2.12
import "./Colors.js" as Colors

Item {
    id: control

    width: bg.width
    height: bg.height

    property alias text: textItem.text
    property alias color: textItem.color
    property alias tagColor: bg.color
    property alias icon: iconImage.source
    property bool deletable: false
    property bool hasIcon: iconImage.status != Image.Null

    signal deleteRequested()

    Rectangle {
        id: bg
        anchors {
            fill: row
            topMargin: -2
            bottomMargin: -2
            leftMargin: -4
            rightMargin: -4
        }

        color: Colors.STRATA_GREEN
        radius: 4
    }

    Row {
        id: row
        x: 4
        y: 2

        spacing: 2

        Image {
            id: iconImage
            width: 30
            height: width

            fillMode: Image.PreserveAspectFit
            visible: control.hasIcon
        }

        SgText {
            id: textItem
            anchors {
                verticalCenter: parent.verticalCenter
            }

            hasAlternativeColor: true
            font.bold: true
        }

        Item {
            id: spacer
            visible: deleteButton.visible
            height: 1
            width: 1
        }

        SgPressable {
            id: deleteButton
            anchors {
                verticalCenter: parent.verticalCenter
            }

            width: deleteMark.paintedWidth + 4
            height: width

            radius: 2
            visible: deletable
            onClicked: deleteRequested()

            SgIcon {
                id: deleteMark
                anchors.centerIn: parent
                sourceSize.height: 16
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/times.svg"
                iconColor: "white"
            }
        }
    }
}
