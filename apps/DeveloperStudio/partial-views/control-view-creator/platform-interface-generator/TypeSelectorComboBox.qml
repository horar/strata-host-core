import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ComboBox {
    id: propertyType

    property var items: [
        { name: "Int", value: sdsModel.platformInterfaceGenerator.TYPE_INT, description: "Type int" },
        { name: "Double", value: sdsModel.platformInterfaceGenerator.TYPE_DOUBLE, description: "Type double" },
        { name: "String", value: sdsModel.platformInterfaceGenerator.TYPE_STRING, description: "Type string" },
        { name: "Bool", value: sdsModel.platformInterfaceGenerator.TYPE_BOOL, description: "Type bool" },
        { name: "Array - Static Sized", value: sdsModel.platformInterfaceGenerator.TYPE_ARRAY_STATIC, description: "With this you are able to listen to changes made to each individual element in the array" },
        { name: "Array - Dynamic Sized", value: sdsModel.platformInterfaceGenerator.TYPE_ARRAY_DYNAMIC, description: "With this you are unable to listen to changes to the individual elements in the array. You are only able to listen to when the entire array changes" },
        { name: "Object - Known Properties", value: sdsModel.platformInterfaceGenerator.TYPE_OBJECT_STATIC, description: "With this you are able to listen to changes made to individual properties in the object" },
        { name: "Object - Unknown Properties", value: sdsModel.platformInterfaceGenerator.TYPE_OBJECT_DYNAMIC, description: "With this you are unable to listen to changes made to individual properties in the object. You are only able to listen to when the entire object changes." }
    ]

    function getIndexOfType(text) {
        for (let i = 0; i < items.length; i++) {
            if (items[i]["value"] === text) {
                return i;
            }
        }

        return -1;
    }

    Layout.preferredWidth: 220
    Layout.preferredHeight: 30
    model: items
    textRole: "name"

    delegate: ItemDelegate {
        width: propertyType.width
        contentItem: Text {
            text: modelData.name
            font: propertyType.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter

            ToolTip.visible: hovered
            ToolTip.text: modelData.description
            ToolTip.delay: 500
        }
        highlighted: propertyType.highlightedIndex === index
    }
}
