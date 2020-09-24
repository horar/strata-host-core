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
    property alias leftIconColor: leftIconItem.iconColor
    property alias leftIconSource: leftIconItem.source
    property bool darkMode: false
    property bool showCursorPosition: false
    property bool passwordMode: false

    /* properties for suggestion list */
    property variant suggestionListModel
    property string suggestionModelTextRole
    property int suggestionPosition: Item.Bottom
    property string suggestionEmptyModelText: "No Suggestion"
    property string suggestionHeaderText
    property bool suggestionCloseOnDown: false
    property bool suggestionOpenWithAnyKey: true
    property int suggestionMaxHeight: 120
    property bool suggestionDelegateNumbering: false
    property bool suggestionDelegateRemovable: false
    property alias suggestionPopup: suggestionPopupLoader.item

    signal suggestionDelegateSelected(int index)
    signal suggestionDelegateRemoveRequested(int index)

    /*private*/
    property bool hasRightIcons: cursorInfoLoader.status === Loader.Ready
                                 || revelPasswordLoader.status ===  Loader.Ready

    property bool revealPassword: false

    placeholderText: "Input..."
    selectByMouse: true
    focus: true
    Keys.forwardTo: suggestionPopupLoader.status === Loader.Ready ? suggestionPopupLoader.item.contentItem : []
    Keys.priority: Keys.BeforeItem
    font.pixelSize: SGWidgets.SGSettings.fontPixelSize
    leftPadding: leftIconSource.toString() ? leftIconItem.height + 16 : 10
    rightPadding: hasRightIcons ? rightIcons.width + 16 : 10
    color: darkMode ? "white" : control.palette.text
    opacity: control.darkMode && control.enabled === false ? 0.5 : 1

    echoMode: {
        if (passwordMode && revealPassword === false) {
            return TextField.Password
        }

        return TextField.Normal
    }

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

            return darkMode ? "#5e5e5e" : control.palette.base
        }
        border.width: control.activeFocus ? 2 : 1
        border.color: {
            if (control.activeFocus) {
                return control.palette.highlight
            } else if (isValid) {
                return darkMode ? "black" : control.palette.mid
            } else {
                return SGWidgets.SGColorsJS.ERROR_COLOR
            }
        }

        SGWidgets.SGIcon {
            id: leftIconItem
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: height
            height: parent.height - 2*10
            iconColor: "darkgray"
        }

        Row {
            id: rightIcons
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            spacing: 4

            Loader {
                id: cursorInfoLoader
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: showCursorPosition ? cursorInfoComponent : undefined
            }

            Loader {
                id: revelPasswordLoader
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: passwordMode ? revealPasswordComponent : undefined
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
            delegateRemovable: suggestionDelegateRemovable

            onDelegateSelected: {
                control.suggestionDelegateSelected(index)
            }

            onRemoveRequested: {
                suggestionDelegateRemoveRequested(index)
            }
        }
    }

    Component {
        id: cursorInfoComponent

        SGWidgets.SGTag {
            text: control.cursorPosition
            color: Qt.rgba(0, 0, 0, 0.3)
            textColor: "white"
            horizontalPadding: 2
            verticalPadding: 2
            font: control.font
        }
    }

    Component {
        id: revealPasswordComponent

        SGWidgets.SGIconButton {
            iconColor: control.palette.text
            backgroundOnlyOnHovered: false
            highlightImplicitColor: "transparent"
            iconSize: control.background.height - 16
            icon.source: pressed ? "qrc:/sgimages/eye.svg" : "qrc:/sgimages/eye-slash.svg"
            onClicked: control.forceActiveFocus()
            onPressedChanged: {
                revealPassword = pressed
            }
        }
    }
}
