import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4


Rectangle {

    id: container
    property variant holdDisableBits: [ ]
    property int smallFontSize: (Qt.platform.os === "osx") ? 12  : 10;
    property int mediumFontSize: (Qt.platform.os === "osx") ? 15  : 12;
    property int largeFontSize: (Qt.platform.os === "osx") ? 24  : 20;
    property int extraLargeFontSize: (Qt.platform.os === "osx") ? 36  : 24;
    property string upChevron: "\u25b2"

    /*
      checks if the bit is in disabled list
    */
    function checkBits(index) {
        for(var i = 0; i < holdDisableBits.length; ++i){
            if(index === holdDisableBits[i]){
                return false;
            }
        }
        return true;
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
                        id: frequencyLabel
                        width: 95
                        height: 25
                        color: "transparent"
                        Text {
                            width: 94
                            height: 24
                            text: qsTr("Frequency (HZ)")
                            font.pointSize: largeFontSize
                            font.family: "helvetica"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Rectangle {
                        id: dutyCycleLabel
                        width: 95
                        height: 25
                        color: "transparent"

                        Text {
                            id: statusLabel
                            text: qsTr("Duty Cycle")
                            font.pointSize: largeFontSize
                            font.family: "helvetica"
                            horizontalAlignment: Text.AlignHCenter

                        }
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
                SingleBitPWMsettings { bitNum: index; portsDisabled: checkBits(index) }
        }
    }
}
