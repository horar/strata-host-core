import QtQuick 2.12

SgBaseEditor {
    id: root

    property int from: 0
    property int to: 99
    property int value

    editor: SgSpinBox {
        id: editorItem
        editable: true
        from: root.from
        to: root.to

        isValid: root.validStatus !== SgBaseEditor.Invalid

        Binding {
            target: root
            property: "value"
            value: editorItem.value
        }
    }
}
