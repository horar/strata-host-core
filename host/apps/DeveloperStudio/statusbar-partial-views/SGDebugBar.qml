import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import "qrc:/js/navigation_control.js" as NavigationControl

import Qt.labs.folderlistmodel 2.12

Item {
    id: root

    Rectangle {
        id: commandBar
        visible: false
        width: parent.width
        height: flow.height
        color: "lightgrey"
        anchors {
            bottom: parent.bottom
        }

        // Buttons for event simulation
        Flow {
            id: flow
            anchors {
                left: commandBar.left
                right: commandBar.right
            }
            layoutDirection: Qt.RightToLeft


            // starta view debug button chooser
            RowLayout {
                Label {
                    text: qsTr("View:")
                    leftPadding: 10
                }
                ComboBox {
                    id: viewCombobox

                    FolderListModel {
                        id: viewFolderModel

                        showDirs: true
                        showFiles: false
                        folder: "qrc:///views/"
                    }
                    textRole: "fileName"

                    Component {
                        id: viewButtonDelegate

                        Loader {
                            id: viewButtonLoader
                            width: viewCombobox.width
                            source: "qrc" + filePath + "/Button.qml"

                            Connections {
                                target: viewButtonLoader.item

                                onClicked: {
                                    viewCombobox.currentIndex = index
                                }
                            }
                        }
                    }

                    model: viewFolderModel
                    delegate: viewButtonDelegate

                    Component.onCompleted: viewCombobox.currentIndex = viewFolderModel.count
                }
            }


            // UI events
            Button {
                text: "Toggle Content/Control"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                }
            }

            Button {
                text: "Statusbar Debug"
                onClicked: {
                    statusBarContainer.showDebug = !statusBarContainer.showDebug
                }
            }

            Button {
                text: "Reset Window"
                onClicked: {
                    mainWindow.height = 900
                    mainWindow.width = 1200
                }
            }

            Button {
                text: "Login as guest"
                onClicked: {
                    var data = { user_id: "Guest" }
                    NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT,data)
                }
            }

            SGLogLevelSelector {
            }
        }
    }


    MouseArea {
        id: debugCloser
        visible: commandBar.visible
        anchors {
            left: commandBar.left
            right: commandBar.right
            bottom: commandBar.top
            bottomMargin: 40
            top: parent.top
        }
        hoverEnabled: true
        onContainsMouseChanged: {
            if (containsMouse) {
                commandBar.visible = false
            }
        }
    }

    Rectangle {
        id: debugButton
        enabled: false
        height: 30
        width: 70
        visible: debugMouse.containsMouse
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        color: "#666"

        Text {
            text: qsTr("DEBUG")
            anchors.centerIn: debugButton
            color: "white"
        }
    }

    MouseArea {
        id: debugMouse
        visible: !commandBar.visible
        anchors {
            fill: debugButton
        }
        hoverEnabled: !commandBar.visible
        onClicked: {
            commandBar.visible = true
        }
    }
}
