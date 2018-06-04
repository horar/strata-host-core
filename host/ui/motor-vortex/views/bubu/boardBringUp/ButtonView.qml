import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4


Rectangle {

    id:buttonViewContainer
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;
    property string upChevron: "\u25b2"
     property variant holdDisableBits: [ ]

    function checkBits(index) {
        for(var i = 0; i < holdDisableBits.length; ++i){
            if(index === holdDisableBits[i]){
                return true;
            }
        }

        return false;
    }
    ScrollView {
        width: 1000; height: 500
        anchors.centerIn: parent
        clip: true
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn


        ListView {
            model: 16
            header: Rectangle {
                width: 1000; height: 50
                color: "light gray"
                RowLayout {
                    id: headersForSetting
                    width: 1000; height: 40
                    spacing: 6

                    Rectangle {
                        id: bitLabel
                        width: 95
                        height: 25
                        color: "transparent"
                        Text {
                            width: 94
                            height: 24
                            text: qsTr("Bit")
                            font.family: "helvetica"
                            font.pointSize: largeFontSize
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Rectangle {
                        id: settingLabel
                        width: 95
                        height: 25
                        color: "transparent"
                        Text {
                            width: 94
                            height: 24
                            text: qsTr("Direction")
                            font.pointSize: largeFontSize
                            font.family: "helvetica"
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }
                    Rectangle {
                        id: controlLabel
                        width: 95
                        height: 25
                        color: "transparent"
                        Text {
                            width: 94
                            height: 24
                            text: qsTr("Control")
                            font.pointSize: largeFontSize
                            font.family: "helvetica"
                            horizontalAlignment: Text.AlignHCenter
                        }

                    }

                    Label {
                        id: statusLabel
                        text: qsTr("Status")
                        font.pointSize: largeFontSize
                        font.family: "helvetica"
                    }
                }
            }

            footer: Rectangle {
                width: 1000; height: 50
                color: "light gray"
                Text {
                    text: upChevron
                    anchors.centerIn: parent
                }
            }

            delegate:
                SingleBitSettings { bitNum: index; portsDisabled: checkBits(index)  }

        }
    }
}

