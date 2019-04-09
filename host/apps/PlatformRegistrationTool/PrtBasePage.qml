import QtQuick 2.12
import QtQuick.Controls 2.12

import "./common" as Common
import "./common/Colors.js" as Colors

Page {
    id: page

    property QtObject prtModel
    property bool hasBack: true
    property variant footerButtonModel

    signal footerButtonClicked(string id);

    function goBack() {
        StackView.view.pop()
    }

    background: Rectangle {
        color: "#eeeeee"
    }

    header: Item {
        height: label.paintedHeight + 16

        Rectangle {
            anchors.fill: parent
            color: Colors.STRATA_BLUE
        }

        Common.SgPressable {
            anchors {
                left: parent.left
                leftMargin: 4+4
                verticalCenter: parent.verticalCenter
            }

            height: backImage.height + 4
            width: height

            radius: Math.round(width/2)
            visible: hasBack
            onClicked: goBack()

            Common.SgIcon {
                id: backImage
                anchors {
                    centerIn: parent
                    horizontalCenterOffset: -3
                }
                sourceSize.height: 36
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/chevron-left.svg"
                iconColor: "white"
            }
        }

        Common.SgText {
            id: label
            anchors {
                centerIn: parent
            }

            text: page.title
            fontSizeMultiplier: 2.0
            hasAlternativeColor: true
        }
    }

    footer: Item {
        height: footerButtonRow.height + 6 + 6

        visible: footerRepeater.count

        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.1
        }

        Row {
            id: footerButtonRow
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }

            spacing: 6

            Repeater {
                id: footerRepeater
                model: footerButtonModel

                delegate: Common.SgButton {
                    text: modelData.text
                    onClicked: {
                        footerButtonClicked(modelData.id)
                    }
                }
            }
        }
    }
}
