import QtQuick.Controls 2.12
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

TextField {
    id: control

    property bool isValid: true
    property bool activeEditing: timerIsRunning
    property bool validationReady: false
    property bool timerIsRunning: false
    property bool isValidAffectsBackground: false

    /* properties for suggestion list */
    property variant suggestionListModel
    property string suggestionModelTextRole
    property int suggestionPosition: Item.Bottom
    property string suggestionEmptyModelText
    property string suggestionHeaderText
    property bool suggestionCloseOnDown: false
    property bool suggestionOpenWithAnyKey: true
    property int suggestionMaxHeight: 120
    property bool suggestionDelegateNumbering: false
    property alias suggestionPopup: suggestionPopupLoader.item

    signal suggestionDelegateSelected(int index)

    placeholderText: "Input..."
    selectByMouse: true
    focus: true
    Keys.forwardTo: suggestionPopupLoader.status === Loader.Ready ? suggestionPopupLoader.item.contentItem : []
    Keys.priority: Keys.BeforeItem
    font.pixelSize: SGWidgets.SGSettings.fontPixelSize

    Keys.onPressed: {
        if (suggestionOpenWithAnyKey && suggestionPopupLoader.status === Loader.Ready) {
            if (!suggestionPopupLoader.item.opened) {
                suggestionPopupLoader.item.open()
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
        color: {
            if (isValidAffectsBackground && !isValid) {
                return Qt.lighter(SGWidgets.SGColorsJS.ERROR_COLOR, 1.9)
            }

            return control.palette.base
        }
        border.width: control.activeFocus ? 2 : 1
        border.color: {
            if (control.activeFocus) {
                return control.palette.highlight
            } else if (isValid) {
                return control.palette.mid
            } else {
                return SGWidgets.SGColorsJS.ERROR_COLOR
            }
        }
    }

    Loader {
        id: suggestionPopupLoader
        sourceComponent: suggestionListModel === undefined ? undefined : suggestionListComponent
    }

    Component {
        id: suggestionListComponent

        SGWidgets.SGSuggestionPopup {
            textEditor: control
            model: suggestionListModel
            textRole: suggestionModelTextRole
            controlWithSpace: false
            position: suggestionPosition
            emptyModelText: suggestionEmptyModelText
            headerText: suggestionHeaderText
            closeOnDown: suggestionCloseOnDown
            maxHeight: suggestionMaxHeight
            delegateNumbering: suggestionDelegateNumbering

            onDelegateSelected: {
                control.suggestionDelegateSelected(index)
            }
        }
    }
}
