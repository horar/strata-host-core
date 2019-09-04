import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import Qt.labs.folderlistmodel 2.12

import "qrc:/js/navigation_control.js" as NavigationControl

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
            spacing: 2

            // starta view debug button chooser
            RowLayout {
                id: comboboxRow

                Label {
                    text: qsTr("View:")
                    leftPadding: 10
                }

                ComboBox {
                    id: viewCombobox
                    delegate: viewButtonDelegate
                    model: viewFolderModel
                    textRole: "fileName"

                    FolderListModel {
                        id: viewFolderModel
                        showDirs: true
                        showFiles: false
                        folder: "qrc:///views/"

                        onCountChanged: {
                            viewCombobox.currentIndex = viewFolderModel.count - 1
                        }

                        onStatusChanged: {
                            if (viewFolderModel.status === FolderListModel.Ready) {
                                // [LC] - this FolderListModel is from Lab; a side effects in 5.12
                                //      - if 'folder' url doesn't exists the it loads app folder content
                                comboboxRow.visible = (viewFolderModel.folder.toString() === "qrc:///views/")
                            }
                        }
                    }

                    Component {
                        id: viewButtonDelegate

                        Button {
                            width: viewCombobox.width
                            height: 20
                            text: model.fileName
                            hoverEnabled: true
                            background: Rectangle {
                                color: hovered ? "white" : "lightgrey"
                            }

                            onClicked: {
                                if (NavigationControl.context.is_logged_in == false) {
                                    NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { user_id: "Guest" } )
                                }

                                // Mock NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT)
                                NavigationControl.context.class_id = "debug"
                                NavigationControl.context.platform_state = true;
                                NavigationControl.createView("qrc" + filePath + "/Control.qml", NavigationControl.control_container_)
                                NavigationControl.createView("qrc" + filePath + "/Content.qml", NavigationControl.content_container_)

                                viewCombobox.currentIndex = index
                            }
                        }
                    }
                }
            }

            Button {
                text: "FAN 6500XX"
                onClicked: {
                    var data = { class_id: "241"}
                    NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
                }
            }

            // UI events
            Button {
                text: "Statusbar Debug"
                onClicked: {
                    statusBarContainer.showDebug = !statusBarContainer.showDebug
                }
            }

            Button {
                text: "Reset Window Size"
                onClicked: {
                    mainWindow.height = 900
                    mainWindow.width = 1200
                }
            }

            Button {
                text: "Login as Guest"
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
