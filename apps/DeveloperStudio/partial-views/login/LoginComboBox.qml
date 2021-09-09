import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

ComboBox {
    id: root
    height: 32 * fontSizeMultiplier
    implicitWidth: modelWidth + height + contentItem.leftPadding
    font.pixelSize: SGSettings.fontPixelSize * fontSizeMultiplier
    model: ["First", "Second", "Third"]

    property color textColor: "black"
    property color indicatorColor: "#B3B3B3"
    property color borderColor: "#B3B3B3"
    property color borderColorFocused: "#219647"
    property color boxColor: "white"
    property bool dividers: false
    property real popupHeight: 300 * fontSizeMultiplier
    property real fontSizeMultiplier: 1.0
    property string placeholderText
    property real modelWidth: textMetrics.contentWidth

    Component.onCompleted: findWidth()
    onModelChanged: findWidth()

    Connections{
        target: Array.isArray(model)? null : model
        onCountChanged: {
            findWidth()
        }
    }

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

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onPressed: mouse.accepted = false
            cursorShape: Qt.PointingHandCursor
        }
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
        placeholderText: root.placeholderText
        color: root.textColor
        selectionColor: "lightgrey"
        selectedTextColor: root.palette.highlightedText
        verticalAlignment: Text.AlignVCenter
        selectByMouse: true

        background: Rectangle {
            visible: root.enabled && root.editable && !root.flat
            color: root.boxColor
            border.width: root.activeFocus ? 1 : 0
            border.color:  root.activeFocus ? Theme.palette.onsemiOrange : "#40000000"
        }
        onAccepted: parent.focus = false
        Keys.forwardTo: root
        persistentSelection: true   // must deselect manually

        onActiveFocusChanged: {
            if ((activeFocus === false) && (contextMenuPopup.visible === false)) {
                textField.deselect()
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.RightButton
            onClicked: {
                textField.forceActiveFocus()
            }
            onReleased: {
                if (containsMouse) {
                    contextMenuPopup.popup(null)
                }
            }
        }

        SGContextMenuEditActions {
            id: contextMenuPopup
            textEditor: textField
        }
    }

    background: Item {
        id: backgroundContainer
        implicitHeight: 32
        implicitWidth: root.width
        height: root.height


        Rectangle {
            id: background
            anchors.fill: backgroundContainer
            visible: false
        }

        DropShadow {
            anchors.fill: background
            source: background
            horizontalOffset: 0
            verticalOffset: 2
            radius: 5.0
            samples: 10
            color: "#40000000"
        }
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
            border.color: "#ddd"
            border.width: 1
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
        highlighted: root.highlightedIndex === index
        contentItem: SGText {
            text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) : modelData
            implicitColor: root.textColor
            font: textField.font
            //                elide: Text.ElideRight
            wrapMode: Text.Wrap
            verticalAlignment: Text.AlignVCenter
        }

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

    Text {
        // using Text instead of TextMetrics due to font rendering bug related to OSX default SF font tracking
        id: textMetrics
        visible: false
        font: root.font
    }

    function findWidth () {
        // calculates implicitWidth of comboBox based on the widest text in the given model
        var width = 0
        var widestIndex = 0
        if (Array.isArray(root.model)) {
            if (model.length <= 0) return
            for (var i = 0; i < model.length; i++) {
                textMetrics.text = root.textRole ? model[i][root.textRole] : model[i]
                if (textMetrics.contentWidth > width) {
                    widestIndex = i
                    width = textMetrics.contentWidth
                }
            }
            textMetrics.text = root.textRole ? model[widestIndex][root.textRole] : model[widestIndex]
        } else {
            if (root.textRole) {
                if (model.count <= 0) return
                for (var j = 0; j < model.count; j++) {
                    textMetrics.text = model.get(j)[root.textRole]
                    if (textMetrics.contentWidth > width) {
                        widestIndex = j
                        width = textMetrics.contentWidth
                    }
                }
                textMetrics.text = model.get(widestIndex)[root.textRole]
            } else {
                console.log("Must assign textRole to use width auto-adjustment")
            }
        }
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
