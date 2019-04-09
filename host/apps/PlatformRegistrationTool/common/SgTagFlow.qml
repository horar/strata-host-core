import QtQuick 2.12
import "./SgUtils.js" as SgUtils

Flow {
    id: control

    property alias model: repeater.model
    property bool deletable: false
    property string valueRole: "value"
    property color tagColor

    signal deleteRequested(int index)

    spacing: 2

    Repeater {
        id: repeater

        delegate: SgTag {
            property string valueData: model[valueRole] ? model[valueRole] : modelData

            text: valueData ? SgUtils.resolveTag(valueData, "text") : ""
            icon: valueData ? SgUtils.resolveTag(valueData, "icon") : ""

            deletable: control.deletable
            tagColor: control.tagColor

            onDeleteRequested: {
                control.deleteRequested(index)
            }
        }
    }
}
