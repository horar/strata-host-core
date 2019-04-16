import QtQuick 2.12

SgBaseEditor {
    id: root

    property int itemWidth: 200
    property int minimumLineCount: 3
    property int maximumLineCount: heightByLines
    property bool readOnly: false
    property bool keepCursorAtEnd: false
    property string text

    editor: SgTextEdit {
        id: editorItem
        width: root.itemWidth

        minimumLineCount: root.minimumLineCount
        maximumLineCount: root.maximumLineCount
        text: root.text
        isValid: root.validStatus !== SgBaseEditor.Invalid
        readOnly: root.readOnly
        keepCursorAtEnd: root.keepCursorAtEnd
        onTextChanged: root.text = text

        Binding {
            target: root
            property: "text"
            value: editorItem.text
        }
    }
}
