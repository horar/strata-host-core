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

    onClosed: {
        contextLoader.active = false
    }

    ColumnLayout {
        spacing: 1

        ContextMenuButton {
            text: "Set ID"
            onClicked: {
                menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/TextPopup.qml")
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

        ContextMenuButton {
            text: "Duplicate"
            onClicked: {
                visualEditor.functions.duplicateControl(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Bring To Front"
            onClicked: {
                visualEditor.functions.bringToFront(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Send To Back"
            onClicked: {
                visualEditor.functions.sendToBack(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Delete"
            onClicked: {
                visualEditor.functions.removeControl(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Go to Code"
            onClicked : {
                visualEditor.functions.passUUID(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Go to Documentation"
            onClicked: {
                Qt.openUrlExternally(`https://confluence.onsemi.com/display/BSK/${layoutOverlayRoot.type}`)
                contextMenu.close()
            }
        }

        ContextMenuButton {
            text: "Object Alignment"
            onClicked: {
                alignmentPopup.open()
            }

            Popup {
                id: alignmentPopup
                x: parent.width
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

                ColumnLayout {
                    id: alignmentColumn
                    spacing: 1

                    ContextMenuButton {
                        text: "Bottom"

                        onClicked: {
                            visualEditor.functions.alignItem("bottom", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
                    }

                    ContextMenuButton {
                        text: "Horizontal Center"

                        onClicked: {
                            visualEditor.functions.alignItem("horCenter", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
                    }

                    ContextMenuButton {
                        text: "Left"

                        onClicked: {
                            visualEditor.functions.alignItem("left", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
                    }

                    ContextMenuButton {
                        text: "Right"

                        onClicked: {
                            visualEditor.functions.alignItem("right", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
                    }

                    ContextMenuButton {
                        text: "Top"

                        onClicked: {
                            visualEditor.functions.alignItem("top", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
                    }

                    ContextMenuButton {
                        text: "Vertical Center"

                        onClicked: {
                            visualEditor.functions.alignItem("verCenter", layoutOverlayRoot.layoutInfo.uuid)
                            contextMenu.close()
                        }
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
        }

        Loader {
            id: extraContextLoader
            Layout.fillWidth: true
            source: {
                switch (layoutOverlayRoot.type) {
                    case "LayoutRectangle":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGRectangleContextMenu.qml"
                    case "LayoutSGIcon":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGIconContextMenu.qml"
                    case "LayoutSGGraph":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGGraphContextMenu.qml"
                    case "LayoutButton":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGButtonContextMenu.qml"
                    case "LayoutText":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGTextContextMenu.qml"
                    case "LayoutSGSwitch":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGSwitchContextMenu.qml"
                    case "LayoutDivider":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGDividerContextMenu.qml"
                    case "LayoutSGInfoBox":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGInfoBoxContextMenu.qml"
                    case "LayoutSGSlider":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGSliderContextMenu.qml"
                    case "LayoutSGCircularGauge":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGGaugeContextMenu.qml"
                    case "LayoutSGStatusLight":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGStatusLightContextMenu.qml"
                    case "LayoutRadioButtons":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGRadioButtonsContextMenu.qml"
                    case "LayoutSGButtonStrip":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGButtonStripContextMenu.qml"
                    case "LayoutSGStatusLogBox":
                        return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGStatusLogBoxContextMenu.qml"
                    default:
                        return ""
                }
            }
        }
    }
}
