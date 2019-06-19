import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: root

    implicitHeight: row.height
    implicitWidth: row.width

    property int status: SGStatusLight.Off
    property int lightSize: 50
    property alias spacing: row.spacing
    property alias label: textItem.text
    property alias labelColor: textItem.color
    property alias labelFontSizeMultiplier: textItem.fontSizeMultiplier
    property alias labelFont: textItem.font
    property int labelPosition: Item.Right

    enum IconStatus {
        Green,
        Red,
        Yellow,
        Orange,
        Off
    }

    Row {
        id: row

        spacing: 8
        layoutDirection: {
            if (labelPosition === Item.Left) {
                return Qt.RightToLeft
            }

            return Qt.LeftToRight
        }

        Image {
            id: itemItem
            width: lightSize
            height: lightSize
            anchors.verticalCenter: parent.verticalCenter

            fillMode: Image.PreserveAspectFit
            mipmap: true

            source: {
                switch(root.status) {
                case SGWidgets.SGStatusLight.Green: return "qrc:/sgimages/statusLightGreen.svg"
                case SGWidgets.SGStatusLight.Red: return "qrc:/sgimages/statusLightRed.svg"
                case SGWidgets.SGStatusLight.Yellow: return "qrc:/sgimages/statusLightYellow.svg"
                case SGWidgets.SGStatusLight.Orange: return "qrc:/sgimages/statusLightOrange.svg"
                default: return "qrc:/sgimages/statusLightOff.svg"
                }
            }
        }

        SGWidgets.SGText {
            id: textItem
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
