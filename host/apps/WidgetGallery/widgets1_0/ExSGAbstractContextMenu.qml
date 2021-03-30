import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.logger 1.0

// Notes to consider during design of custom menus
//
//    The custom options should follow existing terminologies in other applications (if applicable).
//
//    When defining custom context menus, consider implementing also keyboard shortcuts that can invoke said functionality.
//        For example the TextField, TextInput, TextEdit, TextArea natively come with Edit shortcuts:
//            Undo (Ctrl + Z)
//            Redo (Ctrl + Y)
//            Cut (Ctrl + X)
//            Copy (Ctrl + C)
//            Paste (Ctrl + V)
//            Select All (Ctrl + A)

Item {

    width: contentColumn.width
    height: editEnabledCheckBox.y + editEnabledCheckBox.height

    Shortcut {
        sequence: "Ctrl+R"
        onActivated: {
            // execute action when user triggers the shortcut
            console.log("Activated shortcut: " + sequence)
            redAction.trigger(null)
        }
    }

    Shortcut {
        sequence: "Ctrl+G"
        onActivated: {
            // execute action when user triggers the shortcut
            console.log("Activated shortcut: " + sequence)
            greenAction.trigger(null)
        }
    }

    Shortcut {
        sequence: "Ctrl+B"
        enabled: false
        onActivated: {
            // execute action when user triggers the shortcut
            console.log("Activated shortcut: " + sequence)
            blueAction.trigger(null)
        }
    }

    Shortcut {
        sequence: "Ctrl+D"
        onActivated: {
            // execute action when user triggers the shortcut
            console.log("Activated shortcut: " + sequence)
            defaultAction.trigger(null)
        }
    }

    Column {
        id: contentColumn
        spacing: 20
        enabled: editEnabledCheckBox.checked

        Column {
            SGWidgets.SGText {
                text: "Sample box with context menu for selecting color"
                fontSizeMultiplier: 1.3
            }

            Rectangle {
                id: contentRectangle
                implicitWidth: 200
                implicitHeight: 200
                border.width: 1
                border.color: Theme.palette.black
                color: currentColor
                opacity: enabled ? 1 : 0.3

                property color defaultColor: Theme.palette.lightGray
                property color currentColor: defaultColor

                SGWidgets.SGAbstractContextMenu {
                    id: contextMenuPopup

                    Action {
                        id: redAction
                        text: "Red"
                        onTriggered: {
                            // execute action when user clicks the option
                            console.log("Selected: " + text)
                            contentRectangle.currentColor = Theme.palette.red
                        }
                    }

                    Action {
                        id: greenAction
                        text: "Green"
                        onTriggered: {
                            // execute action when user clicks the option
                            console.log("Selected: " + text)
                            contentRectangle.currentColor = Theme.palette.green
                        }
                    }

                    Action {
                        id: blueAction
                        text: "Blue"
                        enabled: false
                        onTriggered: {
                            // execute action when user clicks the option
                            console.log("Selected: " + text)
                            contentRectangle.currentColor = Theme.palette.lightBlue
                        }
                    }

                    MenuSeparator { } // horizontal line separating actions

                    Action {
                        id: defaultAction
                        text: "Reset to default"
                        onTriggered: {
                            // execute action when user clicks the option
                            console.log("Selected: " + text)
                            contentRectangle.currentColor = contentRectangle.defaultColor
                        }
                    }

                    onOpened: {
                        console.log("Context menu opened")
                    }

                    onClosed: {
                        // optional, do something when popup is closed (i.e. force focus back to original element if applicable)
                        // note that context menu popup will steal focus and it should be returned back in this function if it is necessary to be somewhere
                        console.log("Context menu closed")
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.RightButton // if reusing existing MouseArea, use Qt.LeftButton | Qt.RightButton

                    // Using onReleased provided best behavior during testing
                    onReleased: {
                        // add (mouse.button === Qt.RightButton) in case multiple buttons are used in the MouseArea
                        if (containsMouse) {
                            contextMenuPopup.popup(null) // will create context menu at cursor position
                        }
                    }
                }
            }
        }
    }

    SGWidgets.SGCheckBox {
        id: editEnabledCheckBox
        anchors {
            top: contentColumn.bottom
            topMargin: 20
        }

        text: "Everything enabled"
        checked: true
    }
}
