import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

MouseArea {
    id: speedMouse
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    implicitHeight: targetColumn.implicitHeight
    Layout.fillWidth: true

    onClicked:  {
        speedpop.visible = !speedpop.visible
    }

    ColumnLayout {
        id: targetColumn
        width: parent.width
        spacing: 0

        SGIcon {
            source: "qrc:/images/tach.svg"
            iconColor: "white"
            Layout.fillWidth: true
            Layout.preferredHeight: width
            opacity: speedpop.visible ? .5 : 1
        }

        SGText {
            color: "white"
            text: targetSlider.value.toFixed(0)
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        SGText {
            color: "white"
            text: "RPM"
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Popup {
            id: speedpop
            height: parent.height
            x: parent.width + 10 // margin from above column
            background: Rectangle {
                color: sideBar.color

                Rectangle {
                    width: 1
                    height: parent.height
                    color: Qt.darker(parent.color)
                }
            }
            closePolicy: Popup.NoAutoClose

            Connections {
                target: speedMouse
                onVisibleChanged: {
                    if (visible === false) {
                        speedpop.close()
                    }
                }
            }

            RowLayout {
                height: parent.height
                spacing:10

                SGText {
                    text: "Target Speed"
                    font.bold: true
                    color: "white"
                    fontSizeMultiplier: 1.25
                }

                SGSlider {
                    id: targetSlider
                    Layout.preferredWidth: 300
                    Layout.fillWidth: true
                    from: 0
                    to: 10000
                    value: 1234
                    inputBox.unit: "RPM"
                    inputBox.boxColor: "#222"
                    inputBoxWidth: 100
                    textColor: "white"
                }
            }
        }
    }
}
