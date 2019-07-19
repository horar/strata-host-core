import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

ComboBox {
    id: root
    height: 32 * fontSizeMultiplier
    implicitWidth: modelWidth + height + contentItem.leftPadding
    font.pixelSize: Qt.application.font.pixelSize * root.fontSizeMultiplier
    model: ["First", "Second", "Third"]

    property color textColor: "black"
    property color indicatorColor: "#B3B3B3"
    property color borderColor: "#B3B3B3"
    property color boxColor: "white"
    property bool dividers: false
    property real popupHeight: 300 * fontSizeMultiplier
    property real fontSizeMultiplier: 1.0
    property string placeholderText
    property real modelWidth: 0

    signal activated(int index)
    signal highlighted(int index)
    signal editTextChanged(string editText)

    onActivated: root.activated(index)
    onHighlighted: root.highlighted(index)
    onEditTextChanged: root.editTextChanged(editText)

    Component.onCompleted: findWidth()

    indicator: SGIcon {
        id: iconImage
        rotation: root.popup.visible ? 180 : 0
        anchors {
            verticalCenter: root.verticalCenter
            right: root.right
            rightMargin: root.height/2 - width/2
        }

        iconColor: root.pressed ? colorMod(root.indicatorColor, .25) : root.indicatorColor
        source: "qrc:/sgimages/chevron-down.svg"
        width: height
        height: root.height/2
    }

    contentItem: TextField {
        id: textField
        anchors {
            fill: parent
            rightMargin: root.height
        }
        leftPadding: 10
        rightPadding: 0

        text: root.editable ? root.editText : root.displayText
        enabled: root.enabled && root.editable
        autoScroll: root.editable
        readOnly: root.down
        font: root.font
        //            inputMethodHints: root.inputMethodHints
        //            validator: root.validator
        placeholderText: root.placeholderText

        color: root.textColor
        selectionColor: root.palette.highlight
        selectedTextColor: root.palette.highlightedText
        verticalAlignment: Text.AlignVCenter

        background: Rectangle {
            visible: root.enabled && root.editable && !root.flat
            border.width: parent && parent.activeFocus && !parent.readOnly ? 2 : 1
            border.color: parent && parent.activeFocus && !parent.readOnly ? "#219647" : root.borderColor
            color: root.boxColor
        }
        onAccepted: parent.focus = false
        Keys.forwardTo: root
    }

    background: Rectangle {
        implicitWidth: root.width
        height: root.height
        border.color: root.pressed ? colorMod(root.borderColor, .25) : root.borderColor
        border.width: root.visualFocus ? 2 : 1
        radius: 2
    }

    popup: Popup {
        y: root.height - 1
        width: root.width
        implicitHeight: Math.min(contentItem.implicitHeight + ( 2 * padding ), root.popupHeight)
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex

            ScrollIndicator.vertical: ScrollIndicator {
                active: true
            }
        }

        background: Rectangle {
            border.color: root.borderColor
            radius: 2
        }

        opacity: root.delegateModel.count > 0 ? 1 : 0
    }

    delegate: ItemDelegate {
        id: delegate
        width: root.width
        height: Math.max (root.height, contentItem.implicitHeight + 10)  // Add/Subtract from this to modify list item heights in popup
        topPadding: 0
        bottomPadding: 0
        contentItem: SGText {
            text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) : modelData
            implicitColor: root.textColor
            font: textField.font
            //                elide: Text.ElideRight
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: root.highlightedIndex === index

        background: Rectangle {
            id: delegateBackground
            implicitWidth: root.width
            color: delegate.highlighted ? colorMod(root.boxColor, -0.05) : root.boxColor

            Rectangle {
                id: delegateDivider
                visible: root.dividers && index !== root.count - 1
                width: delegateBackground.width - 20
                height: 1
                color: colorMod(root.boxColor, -0.05)
                anchors {
                    bottom: delegateBackground.bottom
                    horizontalCenter: delegateBackground.horizontalCenter
                }
            }
        }
    }

    TextMetrics {
        id: textMetrics
        font: root.font
    }

    function findWidth () {
        modelWidth = 0
        for (var i = 0; i < model.length; i++) {
            textMetrics.text = model[i]
            modelWidth = Math.max(textMetrics.width, modelWidth)
        }
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
