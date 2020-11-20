import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ComboBox {
    id: propertyType
    Layout.preferredWidth: 150
    Layout.preferredHeight: 30
    model: ["int", "double", "string", "bool", "array", "object"]
}
