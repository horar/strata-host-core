import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ComboBox {
    id: propertyType
    Layout.preferredWidth: 200
    Layout.preferredHeight: 30
    model: [
        { name: "Int", value: "int", description: "Type int" },
        { name: "Double", value: "double", description: "Type double" },
        { name: "String", value: "string", description: "Type string" },
        { name: "Bool", value: "bool", description: "Type bool" },
        { name: "Array - Static Sized", value: "array", description: "With this you are able to listen to each changes made to each individual element in the array" },
        { name: "Array - Dynamic Sized", value: "array-dynamic", description: "With this you are unable to listen to changes to the individual elements in the array. You are only able to listen to when the entire array changes" },
        { name: "Object - Known Properties", value: "object", description: "With this you are able to listen to changes made to individual properties in the object" },
        { name: "Object - Unknown Properties", value: "object-dynamic", description: "With this you are unable to listen to changes made to individual properties in the object. You are only able to listen to when the entire object changes." }
    ]
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
