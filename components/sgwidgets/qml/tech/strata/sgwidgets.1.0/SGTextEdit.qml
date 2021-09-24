/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

TextEdit {
    id: control
    persistentSelection: contextMenuEnabled

    property real fontSizeMultiplier: 1.0
    property bool contextMenuEnabled: false

    font.pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier

    onActiveFocusChanged: {
        if ((contextMenuEnabled === true) && (activeFocus === false) && (contextMenuPopupLoader.item.contextMenuPopupVisible === false)) {
            control.deselect()
        }
    }

    Loader {
        id: contextMenuPopupLoader
        active: contextMenuEnabled
        anchors.fill: parent

        sourceComponent: Item {
            property alias contextMenuPopupVisible: contextMenuPopup.visible

            SGWidgets.SGContextMenuEditActions {
                id: contextMenuPopup
                textEditor: control
            }

            MouseArea {
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
            }
        }
    }
}
