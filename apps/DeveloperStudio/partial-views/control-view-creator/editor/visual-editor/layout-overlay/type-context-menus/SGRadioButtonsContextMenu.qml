/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."
import "../layout-popup-context"

ActionGroup {

    Action {
        text: "Set Orientation"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ComboBoxPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "orientation"
            menuLoader.item.open()
            menuLoader.item.label = "Select the orientation."
            contextMenu.close()
        }
    }

    Action {
        text: "Set RadioButton Color"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "radioColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.radioColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set Text Color"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "textColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.textColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set radioSize"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "radioSize"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.radioSize
            menuLoader.item.open()
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.label = "Enter a radioSize. Must be a whole number."
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }

    Action {
        text: "Set fontSizeMultiplier"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "fontSizeMultiplier"
            menuLoader.item.text = layoutOverlayRoot.sourceItem.fontSizeMultiplier
            menuLoader.item.open()
            menuLoader.item.doubleValidator.bottom = 0
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.label = "Enter a fontSizeMultiplier of the labels. Must be a positive whole or decimal number."
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            contextMenu.close()
        }
    }
}
