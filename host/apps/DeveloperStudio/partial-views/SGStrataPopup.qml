import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Dialog {
    id: dialog
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 10
    visible: false

    property string headerText
    property color glowColor: "#bbb"

    background: Item {
        RectangularGlow {
            id: effect
            anchors {
                fill: parent
            }
            glowRadius: 8
            color: dialog.glowColor
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: "#ccc"
            border.width: 1

            Image {
                anchors.fill: parent
                anchors.margins: 1
                source: "qrc:/images/circuits-background-tiled.svg"
                fillMode: Image.Tile
                opacity: 0.5
            }
        }
    }

    header: Rectangle {
        id: headerContainer
        implicitHeight: title.paintedHeight * 2
        color: "#999"

        RowLayout {
            anchors.fill: parent

            SGText {
                id: title
                Layout.leftMargin: 10
                Layout.fillWidth: true
                font.bold: true
                text: dialog.headerText
                color: "white"
                fontSizeMultiplier: 1.25
            }

            Rectangle {
                Accessible.role: Accessible.Button
                Accessible.name: "ClosePopup"
                Accessible.onPressAction: function() {
                    dialog.close()
                }

                id: closerBackground
                color: mouseClose.containsMouse ? Qt.darker(headerContainer.color, 1.1) : "transparent"
                radius: width/2
                Layout.preferredWidth: closer.height * 1.5
                Layout.preferredHeight: Layout.preferredWidth
                Layout.rightMargin: 5

                SGIcon {
                    id: closer
                    anchors.centerIn: closerBackground
                    anchors.horizontalCenterOffset: .5
                    anchors.verticalCenterOffset: .5
                    source: "qrc:/sgimages/times.svg"
                    height: title.paintedHeight
                    width: height
                    iconColor: "white"
                }

                MouseArea {
                    id: mouseClose
                    anchors.fill: closerBackground
                    onClicked: dialog.close()
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                }
            }
        }
    }
}
