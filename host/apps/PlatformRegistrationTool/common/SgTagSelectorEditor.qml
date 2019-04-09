import QtQuick 2.12

SgBaseEditor {
    id: root

    property variant tagModel
    property int itemWidth: 200
    property color tagColor

    editor: SgTagSelector {
        width: root.itemWidth
        tagModel: root.tagModel
        tagColor: root.tagColor
        isValid: root.validStatus !== SgBaseEditor.Invalid
    }
}
