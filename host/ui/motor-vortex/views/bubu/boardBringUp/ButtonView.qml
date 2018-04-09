import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4

Rectangle {

    id:buttonViewContainer
    anchors.fill:parent

    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;


    Column {
        spacing: 12
        anchors { horizontalCenter: buttonViewContainer.horizontalCenter }


        Row {
            id: headersForSetting
            width: 1000; height: 40

            Rectangle {width: 1000; height: 50; color: lightGreyColor

                Label {
                    id: bitLabel
                    text: qsTr("Bit")
                    font.pointSize: largeFontSize
                    font.family: "helvetica"
                    width: 58
                    height: 25
                    anchors { left: parent.left
                        leftMargin: 50 }
                }
                Label {
                    id: settingLabel
                    text: qsTr("Setting")
                    font.pointSize: largeFontSize
                    font.family: "helvetica"
                    anchors { left : bitLabel.right
                        leftMargin: 50
                    }

                }
                Label {
                    id: controlLabel
                    text: qsTr("Control")
                    font.pointSize: largeFontSize
                    font.family: "helvetica"
                    anchors { left : settingLabel.right
                        leftMargin: 200
                    }

                }

                Label {
                    id: statusLabel
                    text: qsTr("Status")
                    font.pointSize: largeFontSize
                    font.family: "helvetica"
                    anchors { left : controlLabel.right
                        leftMargin: 200
                    }

                }
            }
        }

        SingleBitSettings { bitNum: 0}
        SingleBitSettings { bitNum: 1}
        SingleBitSettings { bitNum: 2}
        SingleBitSettings { bitNum: 3}
        SingleBitSettings { bitNum: 4}
        SingleBitSettings { bitNum: 5}
        SingleBitSettings { bitNum: 6}
        SingleBitSettings { bitNum: 7}

    }
}



