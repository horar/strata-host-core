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
        height: label.text.length > 0 ? label.paintedHeight + 16 : 0

        Rectangle {
            anchors.fill: parent
            color: Colors.STRATA_BLUE
        }

        Common.SgIconButton {
            width: parent.height - 8
            height: width
            anchors {
                left: parent.left
                leftMargin: 4
                verticalCenter: parent.verticalCenter
            }

            source: "qrc:/images/chevron-left.svg"
            color: "white"
            visible: hasBack
            onClicked: goBack()
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

                delegate: Button {
                    text: modelData.text
                    onClicked: {
                        footerButtonClicked(modelData.id)
                    }
                }
            }
        }
    }
}
