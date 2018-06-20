import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root

    signal activated(int index)
    signal highlighted(int index)

    property alias currentIndex: comboBox.currentIndex
    property alias currentText: comboBox.currentText
    property alias model: comboBox.model

    property color textColor: "black"
    property color indicatorColor: "#aaa"
    property color borderColor: "#aaa"
    property color boxColor: "white"
    property bool dividers: false

    height: 32
    width: 120

    ComboBox {
        id: comboBox

        onActivated: root.activated(index)
        onHighlighted: root.highlighted(index)

        model: ["First", "Second", "Third"]
        height: root.height

        indicator: Text {
            text: comboBox.popup.visible ? "\ue813" : "\ue810"
            font.family: sgicons.name
            color: comboBox.pressed ? colorMod(root.indicatorColor, .25) : root.indicatorColor
            x: comboBox.width - width/2 - comboBox.height/2
            //y: comboBox.topPadding + (comboBox.availableHeight - height) / 2
            anchors {
                verticalCenter: comboBox.verticalCenter
            }
        }

        contentItem: Text {
            leftPadding: 13
            rightPadding: comboBox.indicator.width + comboBox.spacing
            text: comboBox.displayText
            font: comboBox.font
            color: comboBox.pressed ? colorMod(root.textColor, .5) : root.textColor
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: root.width
            height: root.height
            border.color: comboBox.pressed ? colorMod(root.borderColor, .25) : root.borderColor
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

        delegate: ItemDelegate {
            id: delegate
            width: comboBox.width
            height: root.height
            contentItem: Text {
                text: modelData
                color: root.textColor
                font: comboBox.font
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            highlighted: comboBox.highlightedIndex === index

            background: Rectangle {
                implicitWidth: comboBox.width
                implicitHeight: root.height
                color: delegate.highlighted ? colorMod(root.boxColor, -0.05) : root.boxColor

                Rectangle {
                    id: delegateDivider
                    visible: root.dividers
                    width: parent.width - 20
                    height: 1
                    color: colorMod(root.boxColor, -0.05)
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            }

        }
    }

    FontLoader {
        id: sgicons
        source: "fonts/sgicons.ttf"
    }

    // Add increment to color (within range of 0-1)
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
