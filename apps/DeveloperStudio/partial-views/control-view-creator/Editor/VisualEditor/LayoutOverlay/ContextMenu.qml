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
                renameLoader.active = true
                renameLoader.item.text = layoutOverlayRoot.objectName
                renameLoader.item.open()
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
            text: "Delete"
            onClicked: {
                visualEditor.functions.removeControl(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
            }
        }

         ContextMenuButton {
            text: "Go to code"
            onClicked : {
                visualEditor.functions.passUUID(layoutOverlayRoot.layoutInfo.uuid)
                contextMenu.close()
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
            source: {
                switch (layoutOverlayRoot.type) {
                case "LayoutRectangle":
                    return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/RectangleContextMenu.qml"
                case "LayoutSGIcon":
                    return "qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/TypeContextMenus/SGIconContextMenu.qml"
                default:
                    return ""
                }
            }
        }
    }
}
