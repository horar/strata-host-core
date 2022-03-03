/*
 * Copyright (c) 2018-2022 onsemi.
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
        text: "Set Border Width"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.border.width
            menuLoader.item.sourceProperty = "border.width"
            menuLoader.item.intValidator.bottom = 0
            menuLoader.item.intValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.intValidator
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the border width. A width of 1 creates a thin line. For no line, use a width of 0. Must be a positive whole number."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set Border Color"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "border.color"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.border.color
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set Color"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "color"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.color
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set radius"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.radius
            menuLoader.item.sourceProperty = "radius"
            menuLoader.item.doubleValidator.bottom = 0
            menuLoader.item.doubleValidator.top = 2147483647
            menuLoader.item.validator = menuLoader.item.doubleValidator
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true
            menuLoader.item.label = "Enter the corner radius used to draw a rounded rectangle. If radius is non-zero, the rectangle will be painted as a rounded rectangle, otherwise it will be painted as a normal rectangle. Must be a positive whole or decimal number."
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
