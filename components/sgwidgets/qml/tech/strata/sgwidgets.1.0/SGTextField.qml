import QtQuick.Controls 2.12
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp

TextField {
    id: control

    property bool isValid: true
    property bool activeEditing: timerIsRunning
    property bool activeEditingEnabled: true
    property bool validationReady: false
    property bool timerIsRunning: false
    property bool isValidAffectsBackground: false
    property alias leftIconColor: leftIconItem.iconColor
    property alias leftIconSource: leftIconItem.source
    property alias rightIconSource: rightIconItem.source
    property alias rightIconColor: rightIconItem.iconColor
    property bool darkMode: false
    property bool showCursorPosition: false
    property bool showClearButton: false
    property bool passwordMode: false
    property bool busyIndicatorRunning: false
    property bool contextMenuEnabled: false

    /* properties for suggestion list */
    property bool showSuggestionButton: false
    property variant suggestionListModel
    property Component suggestionListDelegate
    property string suggestionModelTextRole
    property int suggestionPosition: Item.Bottom
    property string suggestionEmptyModelText: "No Suggestion"
    property string suggestionHeaderText
    property bool suggestionCloseWithArrowKey: false
    property bool suggestionCloseOnMouseSelection: false
    property bool suggestionOpenWithAnyKey: true
    property int suggestionMaxHeight: 120
    property bool suggestionDelegateNumbering: false
    property bool suggestionDelegateRemovable: false
    property alias suggestionPopup: suggestionPopupLoader.item
    property bool suggestionHighlightResults: false
    property string suggestionFilterPattern: ""
    property variant suggestionFilterPatternSyntax: CommonCpp.SGTextHighlighter.RegExp
    property bool suggestionCaseSensitive: false

    signal suggestionDelegateSelected(int index)
    signal suggestionDelegateRemoveRequested(int index)

    /*private*/
    property bool hasRightIcons: (cursorInfoLoader !== null && cursorInfoLoader.status === Loader.Ready)
                                 || (revelPasswordLoader !== null && revelPasswordLoader.status ===  Loader.Ready)
                                 || (clearButtonLoader !== null && clearButtonLoader.status === Loader.Ready)
                                 || (showSuggestionLoader !== null && showSuggestionLoader.status === Loader.Ready)
                                 || (rightIconItem !== null && rightIconItem.source)

    property bool revealPassword: false

    placeholderText: "Input..."
    selectByMouse: true
    focus: true
    persistentSelection: contextMenuEnabled
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
        if (activeEditingEnabled) {
            timerIsRunning = true
            activeEditingTimer.restart()
        }
    }

    onActiveFocusChanged: {
        if ((contextMenuEnabled === true) && (activeFocus === false) && (contextMenuPopupLoader.item.contextMenuPopupVisible === false)) {
            control.deselect()
        }
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
                return Qt.lighter(Theme.palette.error, 1.9)
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
                return Theme.palette.error
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
            opacity: busyIndicatorRunning ? 0 : 1
            Behavior on opacity { OpacityAnimator { duration: 250} }
        }

        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: leftIconItem
            height: parent.height - 4
            width: height

            running: busyIndicatorRunning
        }

        Loader {
            id: contextMenuPopupLoader
            active: contextMenuEnabled
            anchors.fill: parent

            sourceComponent: Item {
                property alias contextMenuPopupVisible: contextMenuPopup.visible

                SGWidgets.SGContextMenuEditActions {
                    id: contextMenuPopup
                    textEditor: control
                    copyEnabled: control.echoMode !== TextField.Password
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.RightButton

                    onReleased: {
                        if (containsMouse) {
                            contextMenuPopup.popup(null)
                        }
                    }

                    onClicked: {
                        control.forceActiveFocus()
                    }
                }
            }
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
                id: clearButtonLoader
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: showClearButton && control.text.length > 0 ? clearButtonComponent : undefined
            }

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

            Loader {
                id: showSuggestionLoader
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: (showSuggestionButton && (suggestionListModel !== undefined)) ? showSuggestionComponent : undefined
            }

            SGWidgets.SGIcon {
                id: rightIconItem
                anchors.verticalCenter: parent.verticalCenter
                width: leftIconItem.width
                height: leftIconItem.height
                iconColor: "darkgray"
                visible: source.toString().length > 0
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
            parent: control
            textEditor: control
            model: suggestionListModel
            delegate: control.suggestionListDelegate ? control.suggestionListDelegate : implicitDelegate
            textRole: suggestionModelTextRole
            controlWithSpace: false
            position: suggestionPosition
            emptyModelText: suggestionEmptyModelText
            headerText: suggestionHeaderText
            closeWithArrowKey: suggestionCloseWithArrowKey
            closeOnMouseSelection: suggestionCloseOnMouseSelection
            maxHeight: suggestionMaxHeight
            delegateNumbering: suggestionDelegateNumbering
            delegateRemovable: suggestionDelegateRemovable
            highlightResults: suggestionHighlightResults
            highlightFilterPattern: suggestionFilterPattern
            highlightFilterPatternSyntax: suggestionFilterPatternSyntax
            highlightCaseSensitive: suggestionCaseSensitive

            onDelegateSelected: {
                control.suggestionDelegateSelected(index)
            }

            onRemoveRequested: {
                control.suggestionDelegateRemoveRequested(index)
            }
        }
    }

    Component {
        id: cursorInfoComponent

        SGWidgets.SGTag {
            text: control.cursorPosition
            color: "#b2b2b2"
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

    Component {
        id: clearButtonComponent

        SGWidgets.SGIconButton {
            iconColor: pressed ? "#828282" : "#b2b2b2"
            backgroundOnlyOnHovered: false
            highlightImplicitColor: "transparent"
            iconSize: control.background.height - 16
            icon.source: "qrc:/sgimages/times-circle.svg"
            onClicked: {
                control.forceActiveFocus()
                control.clear()
            }
        }
    }

    Component {
        id: showSuggestionComponent

        SGWidgets.SGIconButton {
            rotation: (suggestionPopupLoader.status === Loader.Ready) && (suggestionPopupLoader.item.opened === true) ? 180 : 0
            iconColor: pressed ? "lightgray" : "darkgray"
            backgroundOnlyOnHovered: false
            highlightImplicitColor: "transparent"
            iconSize: control.background.height - 20
            icon.source: "qrc:/sgimages/chevron-down.svg"
            onClicked: {
                if (suggestionPopupLoader.status === Loader.Ready) {
                    if (suggestionPopupLoader.item.opened === false) {
                        suggestionPopupLoader.item.open()
                    } else {
                        suggestionPopupLoader.item.close()
                    }
                }
            }
        }
    }
}
