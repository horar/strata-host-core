import QtQuick.Controls 2.12
import QtQuick 2.12
import "./Colors.js" as Colors

SpinBox {
    id: control

    editable: true
    focus: true

    property bool isValid: true
    property bool activeEditing: timerIsRunning
    property bool validationReady: false
    property bool timerIsRunning: false

    onValueChanged: {
        validationReady = true
        timerIsRunning = true
        activeEditingTimer.restart()
    }

    onActiveFocusChanged: {
        if (!activeFocus){
            validationReady = true
        }
    }

    Timer {
        id: activeEditingTimer
        interval: 1000
        onTriggered: {
            timerIsRunning = false
        }
    }

    contentItem: TextInput {
        z: 2
        text: control.displayText

        font: control.font
        color: control.palette.text
        selectionColor: control.palette.highlight
        selectedTextColor: control.palette.highlightedText
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter

        readOnly: !control.editable
        validator: control.validator
        inputMethodHints: control.inputMethodHints

        Rectangle {
            x: -6 - (down.indicator ? 1 : 0)
            y: -6
            width: control.width - (up.indicator ? up.indicator.width - 1 : 0) - (down.indicator ? down.indicator.width - 1 : 0)
            height: control.height
            visible: control.activeFocus || !isValid
            color: "transparent"

            border.width: control.activeFocus ? 2 : 1
            border.color: {
                if (control.activeFocus) {
                    control.palette.highlight
                } else {
                    return Colors.ERROR_COLOR
                }
            }
        }
    }
}
