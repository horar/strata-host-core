import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/restclient.js" as Rest
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/constants.js" as Constants
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/uuid_map.js" as UuidMap

Item {
    id: root

    property string testAuthServer: "http://18.191.108.5/"

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

                    onCurrentIndexChanged: {
                        if (currentText === "") {
                            displayText = viewFolderModel.get(currentIndex, "fileName").replace("views-", "").slice(0, -4)
                        } else {
                            displayText = currentText.replace("views-", "").slice(0, -4)
                        }
                    }

                    FolderListModel {
                        id: viewFolderModel
                        showDirs: false
                        showFiles: true
                        nameFilters: "views-*.rcc"
                        folder: sdsModel.resourceLoader.getStaticResourcesUrl()

                        onCountChanged: {
                            viewCombobox.currentIndex = viewFolderModel.count - 1
                        }

                        onStatusChanged: {
                            if (viewFolderModel.status === FolderListModel.Ready) {
                                // [LC] - this FolderListModel is from Lab; a side effects in 5.12
                                //      - if 'folder' url doesn't exists the it loads app folder content
                                comboboxRow.visible = (viewFolderModel.folder.toString() === sdsModel.resourceLoader.getStaticResourcesUrl().toString())
                            }
                        }
                    }

                    Component {
                        id: viewButtonDelegate

                        Button {
                            id: selectButton
                            width: viewCombobox.width
                            height: 20
                            text: model.fileName.substring(6, model.fileName.indexOf(".rcc"))
                            hoverEnabled: true
                            background: Rectangle {
                                color: hovered ? "white" : "lightgrey"
                            }

                            onClicked: {
                                if (NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE) {
                                    NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                                }

                                let name = selectButton.text;
                                let class_id;
                                for (let key of Object.keys(UuidMap.uuid_map)) {
                                    if (UuidMap.uuid_map[key] === name) {
                                        class_id = key;
                                        break;
                                    }
                                }

                                let data = {
                                    "device_id": Constants.DEBUG_DEVICE_ID,
                                    "class_id": class_id,
                                    "name": name,
                                    "index": null,
                                    "view": "control",
                                    "connected": true,
                                    "available": {
                                        "control": true,
                                        "documents": true,
                                        "unlisted": false,
                                        "order": false
                                    },
                                    "firmware_version": ""
                                }

                                PlatformSelection.openPlatformView(data)
                                viewCombobox.currentIndex = index
                            }
                        }
                    }
                }
            }

            Button {
                text: "Platform List Controls"

                onClicked: {
                    localPlatformListDialog.setVisible(true)
                }
            }

            SGLocalPlatformListPopup {
                id: localPlatformListDialog
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
                    if (NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE) {
                        NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                    }
                }
            }

            CheckBox {
                id: alwaysLogin
                text: "Always Login as Guest"
                onCheckedChanged: {
                    if (checked && NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE && sdsModel.hcsConnected) {
                        NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                    }
                }

                QtLabsSettings.Settings {
                    id: settings
                    category: "Login"
                    property alias loginAsGuest: alwaysLogin.checked
                }

                Connections {
                    target: sdsModel
                    onHcsConnectedChanged: {
                        if (sdsModel.hcsConnected && alwaysLogin.checked) {
                            NavigationControl.updateState(NavigationControl.events.CONNECTION_ESTABLISHED_EVENT)
                            NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                        }
                    }
                }
            }

            Button {
                id: serverChange
                onClicked: {
                    if (Rest.url !== Constants.PRODUCTION_AUTH_SERVER) {
                        Rest.url = Constants.PRODUCTION_AUTH_SERVER
                    } else {
                        Rest.url = root.testAuthServer
                    }
                    Authenticator.signals.serverChanged()
                }

                Component.onCompleted: {
                    setButtonText()
                }

                function setButtonText () {
                    if (Rest.url !== Constants.PRODUCTION_AUTH_SERVER) {
                        text = "Switch to Prod Auth Server"
                    } else {
                        text = "Switch to Test Auth Server"
                    }
                }

                Connections {
                    target: Authenticator.signals
                    onServerChanged: {
                        serverChange.setButtonText()
                    }
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
