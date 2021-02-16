import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

TextEdit {
    id: control
    persistentSelection: contextMenuEnabled

    property real fontSizeMultiplier: 1.0
    property bool contextMenuEnabled: false

    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier

    onActiveFocusChanged: {
        if ((contextMenuEnabled === true) && (activeFocus === false) && (contextMenuPopup.visible === false)) {
            control.deselect()
        }
    }

    Loader {
        id: contextMenuPopupLoader
        active: contextMenuEnabled
        sourceComponent: MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            acceptedButtons: Qt.RightButton

            onReleased: {
                if (containsMouse) {
                    contextMenuPopup.popup(null)
                }
            }

            onClicked: {
                control.forceActiveFocus()
            }

            SGWidgets.SGContextMenuEdit {
                id: contextMenuPopup
                textEditor: control
            }
        }
    }
}
