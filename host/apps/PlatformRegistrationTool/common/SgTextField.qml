import QtQuick.Controls 2.12
import QtQuick 2.12
import "./Colors.js" as Colors

TextField {
    id: control

    property variant suggestionListModel
    property string suggestionModelTextRole
    property bool isValid: true
    property bool activeEditing: timerIsRunning
    property bool validationReady: false
    property bool timerIsRunning: false

    signal suggestionDelegateSelected(int index)

    placeholderText: "Input..."
    selectByMouse: true
    focus: true
    Keys.forwardTo: suggestionPopipLoader.status === Loader.Ready ? suggestionPopipLoader.item.contentItem : []
    Keys.priority: Keys.BeforeItem

    Keys.onPressed: {
        if (suggestionPopipLoader.status === Loader.Ready) {
            if (!suggestionPopipLoader.item.opened) {
                suggestionPopipLoader.item.open()
            }
        }
    }

    onTextChanged: {
        validationReady = true
        timerIsRunning = true
        activeEditingTimer.restart()
    }

    Timer {
        id: activeEditingTimer
        interval: 1000
        onTriggered: {
            timerIsRunning = false
        }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 40
        color: control.palette.base
        border.width: control.activeFocus ? 2 : 1
        border.color: {
            if (control.activeFocus) {
                return control.palette.highlight
            } else if (isValid) {
                return control.palette.mid
            } else {
                return Colors.ERROR_COLOR
            }
        }
    }

    Loader {
        id: suggestionPopipLoader
        sourceComponent: suggestionListModel === undefined ? undefined : suggestionListComponent
    }

    Component {
        id: suggestionListComponent

        SgSuggestionPopup {
            textEditor: control
            model: suggestionListModel
            textRole: suggestionModelTextRole
            controlWithSpace: false

            onDelegateSelected: {
                control.suggestionDelegateSelected(index)
            }
        }
    }
}
