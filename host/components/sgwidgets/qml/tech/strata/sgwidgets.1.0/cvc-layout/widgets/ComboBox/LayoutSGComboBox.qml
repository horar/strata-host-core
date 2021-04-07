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

    property alias model: comboBoxObject.model
    property alias currentIndex: comboBoxObject.currentIndex
    property alias currentText: comboBoxObject.currentText


    // private members for advanced customization
    property alias iconImage: comboBoxObject.iconImage
    property alias textField: comboBoxObject.textField
    property alias textFieldBackground: comboBoxObject.textFieldBackground
    property alias backgroundItem: comboBoxObject.backgroundItem
    property alias popupItem: comboBoxObject.popupItem
    property alias popupBackground: comboBoxObject.popupBackground

    signal activated()

     SGComboBox {
         id: comboBoxObject
         onActivated: parent.activated()
     }

}

