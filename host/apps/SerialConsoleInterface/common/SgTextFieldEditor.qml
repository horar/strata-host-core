import QtQuick 2.12

SgBaseEditor {
    id: root

    property int itemWidth: 200
    property variant suggestionListModel
    property string suggestionModelTextRole
    property string text
    property QtObject validator: null
    property string placeholderText

    signal suggestionDelegateSelected(int index)

    editor: SgTextField {
        id: editorItem
        width: root.itemWidth

        text: root.text
        isValid: root.validStatus !== SgBaseEditor.Invalid
        suggestionListModel: root.suggestionListModel
        suggestionModelTextRole: root.suggestionModelTextRole
        validator: root.validator
        placeholderText: root.placeholderText

        onSuggestionDelegateSelected: {
             root.suggestionDelegateSelected(index)
        }

        onTextChanged: root.text = text
        Binding {
            target: root
            property: "text"
            value: editorItem.text
        }
    }
}
