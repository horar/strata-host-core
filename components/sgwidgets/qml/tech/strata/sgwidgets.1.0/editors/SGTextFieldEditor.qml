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
    property bool textFieldBusyIndicatorRunning: false
    property bool textFieldSuggestionDelegateRemovable: false
    property bool textFieldSuggestionCloseWithArrowKey: false
    property int textFieldSuggestionMaxHeight: 120
    property bool contextMenuEnabled: false
    property bool activeEditing: false

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
        suggestionDelegateRemovable: root.textFieldSuggestionDelegateRemovable
        suggestionCloseWithArrowKey: root.textFieldSuggestionCloseWithArrowKey
        suggestionMaxHeight: root.textFieldSuggestionMaxHeight

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