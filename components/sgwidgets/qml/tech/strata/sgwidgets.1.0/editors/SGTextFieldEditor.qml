/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGBaseEditor {
    id: root

    property int itemWidth: 200
    property variant suggestionListModel
    property string suggestionModelTextRole
    property string text
    property QtObject validator: null
    property string placeholderText
    property bool showCursorPosition: false
    property bool passwordMode: false
    property string textFieldLeftIconSource
    property string textFieldRightIconSource
    property bool textFieldShowSuggestionButton: false
    property bool textFieldBusyIndicatorRunning: false
    property bool textFieldSuggestionDelegateRemovable: false
    property bool textFieldSuggestionCloseWithArrowKey: false
    property bool textFieldSuggestionCloseOnMouseSelection: false
    property int textFieldSuggestionMaxHeight: 120
    property bool contextMenuEnabled: false
    property bool activeEditing: false
    property bool textFieldActiveEditingEnabled: true

    signal textFieldSuggestionDelegateSelected(int index)
    signal textFieldSuggestionDelegateRemoveRequested(int index)

    editor: SGWidgets.SGTextField {
        id: editorItem
        width: root.itemWidth
        contextMenuEnabled: root.contextMenuEnabled

        text: root.text
        isValid: root.validStatus !== SGWidgets.SGBaseEditor.Invalid
        suggestionListModel: root.suggestionListModel
        suggestionModelTextRole: root.suggestionModelTextRole
        validator: root.validator
        placeholderText: root.placeholderText
        showCursorPosition: root.showCursorPosition
        passwordMode: root.passwordMode
        leftIconSource: root.textFieldLeftIconSource
        rightIconSource: root.textFieldRightIconSource
        busyIndicatorRunning: root.textFieldBusyIndicatorRunning
        showSuggestionButton: root.textFieldShowSuggestionButton
        suggestionDelegateRemovable: root.textFieldSuggestionDelegateRemovable
        suggestionCloseWithArrowKey: root.textFieldSuggestionCloseWithArrowKey
        suggestionCloseOnMouseSelection: root.textFieldSuggestionCloseOnMouseSelection
        suggestionMaxHeight: root.textFieldSuggestionMaxHeight
        activeEditingEnabled: root.textFieldActiveEditingEnabled

        onTextChanged: root.text = text
        Binding {
            target: root
            property: "text"
            value: editorItem.text
        }

        onActiveEditingChanged: root.activeEditing = activeEditing

        onSuggestionDelegateSelected: textFieldSuggestionDelegateSelected(index)
        onSuggestionDelegateRemoveRequested: textFieldSuggestionDelegateRemoveRequested(index)
    }
}
