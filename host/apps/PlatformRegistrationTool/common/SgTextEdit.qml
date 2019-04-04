import QtQuick 2.12
import QtQuick.Controls 2.12
import "./Colors.js" as Colors

FocusScope {
    id: control

    implicitWidth: 100
    implicitHeight: resolveBaseHeight()
    focus: true

    property alias text: edit.text
    property alias font: edit.font
    property alias placeholderText: placeholderTextItem.text
    property int minimumLineCount: 3
    property int maximumLineCount: minimumLineCount
    property bool tabAllowed: false
    property alias readOnly: edit.readOnly
    property bool keepCursorAtEnd: false
    property bool isValid: true
    property bool activeEditing: timerIsRunning
    property bool validationReady: false
    property bool timerIsRunning: false

    // This is to match look and feel of other controls
    Control {
        id: dummyControl
    }

    FontMetrics {
        id: font_metrics
        font: edit.font
    }

    Timer {
        id: activeEditingTimer
        interval: 1000
        onTriggered: {
            timerIsRunning = false
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent

        color: dummyControl.palette.base
        border {
            width: control.activeFocus ? 2 : 1
            color: {
                if (control.activeFocus) {
                    return dummyControl.palette.highlight
                } else if (isValid) {
                    return dummyControl.palette.mid
                } else {
                    return Colors.ERROR_COLOR
                }
            }
        }
    }

    Flickable {
        id: flick
        anchors.fill: parent

        clip: true
        interactive: true
        contentHeight: edit.height
        contentWidth: edit.width
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        ScrollBar.vertical: ScrollBar {
            anchors {
                top: flick.top
                bottom: flick.bottom
                right: flick.right
                rightMargin: 1
            }

            policy: ScrollBar.AlwaysOn
            interactive: false
            width: 8
            visible: flick.height < flick.contentHeight
        }

        function ensureVisible(r) {
            if (contentX >= r.x) {
                contentX = r.x;
            } else if (contentX+width <= r.x+r.width) {
                contentX = r.x + r.width - width;
            } if (contentY >= r.y - edit.topPadding) {
                contentY = r.y - edit.topPadding;
            } else if (contentY + height <= r.y + r.height + edit.bottomPadding ) {
                contentY = r.y + r.height - height + edit.bottomPadding;
            }
        }

        TextEdit {
            id: edit
            width: flick.width

            wrapMode: TextEdit.Wrap
            padding: 6 + 6
            color: dummyControl.palette.text
            selectionColor: dummyControl.palette.highlight
            selectedTextColor: dummyControl.palette.highlightedText
            font: dummyControl.font
            selectByMouse: true
            selectByKeyboard: true
            activeFocusOnTab: true

            Keys.onPressed: {
                validationReady = true
                if (event.key === Qt.Key_Tab) {
                    if (!tabAllowed) {
                        nextItemInFocusChain().forceActiveFocus(Qt.TabFocusReason)
                        event.accepted = true
                    }
                } else {
                    timerIsRunning = true
                    activeEditingTimer.restart()
                }
            }

            onTextChanged: {
                if (readOnly && keepCursorAtEnd) {
                    cursorPosition = text.length
                }
            }

            onCursorRectangleChanged: {
                flick.ensureVisible(cursorRectangle)
            }

            Text {
                id: placeholderTextItem
                anchors {
                    fill: parent
                    margins: edit.padding
                }

                text: "Input..."
                visible: edit.text.length === 0
                color: dummyControl.palette.text
                opacity: edit.enabled ? 0.5 : 1
                font: dummyControl.font
                elide: Text.ElideRight
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }

    function resolveBaseHeight() {
        var lines = Math.max(minimumLineCount, Math.min(maximumLineCount, edit.lineCount))

        var firstLineHeight = font_metrics.height
        var otherLinesHeight = lines > 0 ? (lines - 1) * (font_metrics.lineSpacing + 1) : 0

        var h = firstLineHeight + otherLinesHeight + edit.topPadding + edit.bottomPadding

        return  Math.ceil(h)
    }
}
