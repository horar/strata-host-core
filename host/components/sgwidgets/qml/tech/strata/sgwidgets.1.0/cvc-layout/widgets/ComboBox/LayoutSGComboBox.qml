import QtQuick 2.12
import tech.strata.sgwidgets 1.0

import "../../"

LayoutContainer {

    property color textColor: "black"
    property color indicatorColor: "#B3B3B3"
    property color borderColor: "#B3B3B3"
    property color borderColorFocused: "#219647"
    property color boxColor: "white"
    property bool dividers: false
    property real popupHeight: 300 * fontSizeMultiplier
    property real fontSizeMultiplier: 1.0
    property string placeholderText
    property real modelWidth: comboBoxObject.modelWidth

    // private members for advanced customization
    property alias iconImage: comboBoxObject.iconImage
    property alias textField: comboBoxObject.textField
    property alias textFieldBackground: comboBoxObject.textFieldBackground
    property alias backgroundItem: comboBoxObject.backgroundItem
    property alias popupItem: comboBoxObject.popupItem
    property alias popupBackground: comboBoxObject.popupBackground

     SGComboBox {
         id: comboBoxObject
     }

}

