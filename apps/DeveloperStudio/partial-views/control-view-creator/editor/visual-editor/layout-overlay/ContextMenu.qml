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
import QtGraphicalEffects 1.0
import QtQml 2.12

Menu {
    id: contextMenu
    implicitWidth: 150
    delegate: MenuItem {
        implicitHeight: 25
    }

    property bool multipleItemsSelected

    onOpened: {
        multipleItemsSelected = visualEditor.selectedMultiObjectsUuid.length > 1
    }

    onClosed: {
        contextLoader.active = false
    }

    Action {
        text: "Set ID"

        onTriggered: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/layout-popup-context/TextPopup.qml")
            menuLoader.active = true
            menuLoader.item.text = layoutOverlayRoot.objectName
            menuLoader.item.validator = menuLoader.item.regExpValidator
            menuLoader.item.label = "Ensure all ID's are unique. ID's must start with lower case letter or underscore, and contain only letters, numbers and underscores."
            menuLoader.item.sourceProperty = "id"
            menuLoader.item.isString = false
            menuLoader.item.mustNotBeEmpty = true

            // Find all existing ID's (except current object's ID) and set as invalidInputs
            let invalidInputs = []
            // Returns all strings containing object ID's
            const existingIDs = visualEditor.functions.getAllObjectIds()
            for (let indexID = 0; indexID < existingIDs.length; ++indexID) {
                // Isolate each <id> from string containing the ID
                const id = existingIDs[indexID].split(":").slice(-1).toString().trim()
                if (id != layoutOverlayRoot.objectName) {
                    invalidInputs.push(id)
                }
            }
            menuLoader.item.invalidInputs = invalidInputs

            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Action {
        text: multipleItemsSelected ? "Duplicate Selected" : "Duplicate"

        onTriggered: {
            visualEditor.functions.duplicateControlSelected()
            contextMenu.close()
        }
    }

    Action {
        text: multipleItemsSelected ? "Bring Selected To Front" : "Bring To Front"

        onTriggered: {
            visualEditor.functions.bringToFrontSelected()
            contextMenu.close()
        }
    }

    Action {
        text: multipleItemsSelected ? "Delete Selected" : "Delete"

        onTriggered: {
            visualEditor.functions.removeControlSelected()
            contextMenu.close()
        }
    }

    Action {
        text: "Go to Code"

        onTriggered: {
            visualEditor.functions.passUUID(layoutOverlayRoot.layoutInfo.uuid)
            contextMenu.close()
        }
    }

    Action {
        text: "Go to Documentation"

        onTriggered: {
            Qt.openUrlExternally(`https://confluence.onsemi.com/display/BSK/${layoutOverlayRoot.type}`)
            contextMenu.close()
        }
    }

    Menu {
        id: objectAlignButton
        title: "Object Alignment"
        implicitWidth: 170
        delegate: MenuItem {
            implicitHeight: 25
        }

        property bool isExactHorizontal: false
        property bool isExactVertical: false

        Component.onCompleted: {
            isExactHorizontal = visualEditor.functions.exactCenterCheck(layoutOverlayRoot.layoutInfo.uuid, "horizontal")
            isExactVertical = visualEditor.functions.exactCenterCheck(layoutOverlayRoot.layoutInfo.uuid, "vertical")
        }

        Action {
            text: objectAlignButton.isExactHorizontal ? "Horizontal Center" : "Horizontal Center (appx.)"

            onTriggered: {
                visualEditor.functions.alignItem("horCenter", layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        Action {
            text: objectAlignButton.isExactVertical ? "Vertical Center" : "Vertical Center (appx.)"

            onTriggered: {
                visualEditor.functions.alignItem("verCenter", layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }
    }

    Loader {
        sourceComponent: MenuSeparator { }
        active: extraContextLoader.source.toString() !== "" // don't show divider when no extraContent loaded
    }

    Loader {
        id: extraContextLoader
        source: {
            switch (layoutOverlayRoot.type) {
            case "LayoutRectangle":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGRectangleContextMenu.qml"
            case "LayoutSGIcon":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGIconContextMenu.qml"
            case "LayoutSGGraph":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGGraphContextMenu.qml"
            case "LayoutButton":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGButtonContextMenu.qml"
            case "LayoutText":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGTextContextMenu.qml"
            case "LayoutSGSwitch":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGSwitchContextMenu.qml"
            case "LayoutDivider":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGDividerContextMenu.qml"
            case "LayoutSGInfoBox":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGInfoBoxContextMenu.qml"
            case "LayoutSGSlider":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGSliderContextMenu.qml"
            case "LayoutSGCircularGauge":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGGaugeContextMenu.qml"
            case "LayoutSGStatusLight":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGStatusLightContextMenu.qml"
            case "LayoutRadioButtons":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGRadioButtonsContextMenu.qml"
            case "LayoutSGButtonStrip":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGButtonStripContextMenu.qml"
            case "LayoutSGStatusLogBox":
                return "qrc:/partial-views/control-view-creator/editor/visual-editor/layout-overlay/type-context-menus/SGStatusLogBoxContextMenu.qml"
            default:
                return ""
            }
        }

        onItemChanged: {
            for (let i = 0; i < item.actions.length; i++) {
                contextMenu.addAction(item.actions[i])
            }
        }
    }
}

