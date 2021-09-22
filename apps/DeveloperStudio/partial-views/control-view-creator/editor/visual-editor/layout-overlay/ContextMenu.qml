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
import QtGraphicalEffects 1.0

Popup {
    id: contextMenu
    padding: 0
    background: Rectangle {
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 1
            verticalOffset: 3
            radius: 6.0
            samples: 12
            color: "#99000000"
        }
    }

    property bool multipleItemsSelected

    onOpened: {
        multipleItemsSelected = visualEditor.selectedMultiObjectsUuid.length > 1
    }

    onClosed: {
        contextLoader.active = false
    }

    ColumnLayout {
        spacing: 1

        ContextMenuButton {
            text: "Set ID"
            onClicked: {
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

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            text: multipleItemsSelected ? "Duplicate Selected" : "Duplicate"
            onClicked: {
                visualEditor.functions.duplicateControlSelected()
                contextMenu.close()
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            text: multipleItemsSelected ? "Bring Selected To Front" : "Bring To Front"
            onClicked: {
                visualEditor.functions.bringToFrontSelected()
                contextMenu.close()
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            text: multipleItemsSelected ? "Delete Selected" : "Delete"
            onClicked: {
                visualEditor.functions.removeControlSelected()
                contextMenu.close()
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            text: "Go to Code"
            onClicked : {
                visualEditor.functions.passUUID(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            text: "Go to Documentation"
            onClicked: {
                Qt.openUrlExternally(`https://confluence.onsemi.com/display/BSK/${layoutOverlayRoot.type}`)
                contextMenu.close()
            }

            onContainsMouseChanged: {
                if (containsMouse) {
                    objectAlignButton.content.close()
                }
            }
        }

        ContextMenuButton {
            id: objectAlignButton
            text: "Object Alignment"
            chevron: true

            subMenu: ColumnLayout {
                spacing: 0

                ContextMenuButton {
                    text: "Horizontal Center (approx.)"

                    onClicked: {
                        visualEditor.functions.alignItem("horCenter", layoutOverlayRoot.layoutInfo.uuid)
                        contextMenu.close()
                    }
                }

                ContextMenuButton {
                    text: "Vertical Center (approx.)"

                    onClicked: {
                        visualEditor.functions.alignItem("verCenter", layoutOverlayRoot.layoutInfo.uuid)
                        contextMenu.close()
                    }
                }
            }
        }

        Rectangle {
            // divider
            color: "grey"
            Layout.fillWidth: true
            implicitHeight: 1
            visible: extraContextLoader.source !== ""

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onEntered: {
                    objectAlignButton.content.close()
                }
            }
        }

        Loader {
            id: extraContextLoader
            Layout.fillWidth: true
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

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                onContainsMouseChanged: {
                    if (containsMouse) {
                        objectAlignButton.content.close()
                    }
                }
            }
        }
    }
}
