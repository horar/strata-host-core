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

    ColumnLayout {
        spacing: 1

        ContextMenuButton {
            text: "Set ID"
            onClicked: {
                renamePopup.text = layoutOverlayRoot.objectName
                renamePopup.open()
            }
        }

        ContextMenuButton {
            text: "Duplicate"
            onClicked: {
                visualEditor.functions.duplicateControl(layoutOverlayRoot.layoutInfo.uuid)
            }
        }

        ContextMenuButton {
            text: "Bring To Front"
            onClicked: {
                visualEditor.functions.bringToFront(layoutOverlayRoot.layoutInfo.uuid)
            }
        }

        ContextMenuButton {
            text: "Delete"
            onClicked: {
                visualEditor.functions.removeControl(layoutOverlayRoot.layoutInfo.uuid)
            }
        }
    }
}
