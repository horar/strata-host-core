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
        text: "Set Text"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.text
            menuLoader.item.sourceProperty = "text"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set PlaceholderText"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.sourceItem.placeholderText
            menuLoader.item.sourceProperty = "placeholderText"
            menuLoader.item.label = "Enter the desired placeholder text."
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: "Set TextColor"
        
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
        text: "Set BoxColor"
        
        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.sourceProperty = "boxColor"
            menuLoader.item.color = layoutOverlayRoot.sourceItem.boxColor
            menuLoader.item.open()
            contextMenu.close()
        }
    }
}
