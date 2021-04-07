import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {


    property alias placeholderText: textFieldObject.placeholderText
    property alias text: textFieldObject.text

    property alias isValid: textFieldObject.isValid

    property alias activeEditing: textFieldObject.activeEditing
    property alias validationReady: textFieldObject.validationReady
    property alias timerIsRunning: textFieldObject.timerIsRunning
    property alias isValidAffectsBackground: textFieldObject.isValidAffectsBackground
    property alias leftIconColor: textFieldObject.leftIconColor
    property alias leftIconSource: textFieldObject.leftIconSource
    property alias darkMode: textFieldObject.darkMode
    property alias showCursorPosition: textFieldObject.showCursorPosition
    property alias showClearButton: textFieldObject.showClearButton
    property alias passwordMode: textFieldObject.passwordMode
    property alias busyIndicatorRunning: textFieldObject.busyIndicatorRunning
    property alias contextMenuEnabled: textFieldObject.contextMenuEnabled

    /* properties for suggestion list */
    property variant suggestionListModel
    property Component suggestionListDelegate
    property alias suggestionModelTextRole: textFieldObject.suggestionModelTextRole
    property alias suggestionPosition: textFieldObject.suggestionPosition
    property alias suggestionEmptyModelText: textFieldObject.suggestionEmptyModelText
    property alias suggestionHeaderText: textFieldObject.suggestionHeaderText
    property alias suggestionCloseOnDown: textFieldObject.suggestionCloseOnDown
    property alias suggestionOpenWithAnyKey: textFieldObject.suggestionOpenWithAnyKey
    property alias suggestionMaxHeight: textFieldObject.suggestionMaxHeight
    property alias suggestionDelegateNumbering: textFieldObject.suggestionDelegateNumbering
    property alias suggestionDelegateRemovable: textFieldObject.suggestionDelegateRemovable
    property alias suggestionDelegateTextWrap: textFieldObject.suggestionDelegateTextWrap
    property alias suggestionPopup: textFieldObject.suggestionPopup

    signal accepted()
    SGTextField {
        id: textFieldObject
        suggestionListModel: parent.suggestionListModel
        suggestionListDelegate: parent.suggestionListDelegate

        onAccepted: {
            parent.accepted()
        }


    }
}

