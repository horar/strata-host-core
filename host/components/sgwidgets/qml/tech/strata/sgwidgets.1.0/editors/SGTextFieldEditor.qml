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
    property bool textFieldBusyIndicatorRunning: false
    property alias contextMenuEnabled: editorItem.contextMenuEnabled

    editor: SGWidgets.SGTextField {
        id: editorItem
        width: root.itemWidth

        text: root.text
        isValid: root.validStatus !== SGWidgets.SGBaseEditor.Invalid
        suggestionListModel: root.suggestionListModel
        suggestionModelTextRole: root.suggestionModelTextRole
        validator: root.validator
        placeholderText: root.placeholderText
        showCursorPosition: root.showCursorPosition
        passwordMode: root.passwordMode
        leftIconSource: root.textFieldLeftIconSource
        busyIndicatorRunning: root.textFieldBusyIndicatorRunning

        onTextChanged: root.text = text
        Binding {
            target: root
            property: "text"
            value: editorItem.text
        }
    }
}
