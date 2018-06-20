import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root

    property alias currentIndex: comboBox.currentIndex

    property color textColor: "black"
    property color indicatorColor: "#aaa"
    property color borderColor: "#aaa"



    ComboBox {
        id: comboBox
        model: ["First", "Second", "Third"]


        onCurrentTextChanged: console.log(currentText)

        delegate: ItemDelegate {
            width: comboBox.width
            contentItem: Text {
                text: modelData
                color: root.textColor
                font: comboBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: comboBox.highlightedIndex === index
        }

        indicator: Text {
            text: "\ue810"
            font.family: sgicons.name
            color: root.indicatorColor
            x: comboBox.width - width - comboBox.rightPadding
            y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
        }

        contentItem: Text {
            leftPadding: 15
            rightPadding: comboBox.indicator.width + comboBox.spacing

            text: comboBox.displayText
            font: comboBox.font
            color: comboBox.pressed ? "#17a81a" : root.textColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 120
            implicitHeight: 40
            border.color: comboBox.pressed ? "#17a81a" : root.borderColor
            border.width: comboBox.visualFocus ? 2 : 1
            radius: 2
        }

        popup: Popup {
            y: comboBox.height - 1
            width: comboBox.width
            implicitHeight: contentItem.implicitHeight + ( 2 * padding )
            padding: 1

            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboBox.popup.visible ? comboBox.delegateModel : null
                currentIndex: comboBox.highlightedIndex

                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                border.color: root.borderColor
                radius: 2
            }
        }

        FontLoader {
            id: sgicons
            source: "fonts/sgicons.ttf"
        }
    }

    function colorMod (color, factor) {
        return Qt.rgba(color.r/factor, color.g/factor, color.b/factor, 1 )
    }
}
