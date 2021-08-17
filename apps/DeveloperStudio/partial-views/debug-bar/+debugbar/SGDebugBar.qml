import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.12
import Qt.labs.settings 1.1 as QtLabsSettings
import tech.strata.sgwidgets 1.0 as SGWidgets

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.notifications 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/uuid_map.js" as UuidMap
import "qrc:/js/constants.js" as Constants
import "qrc:/js/platform_selection.js" as PlatformSelection

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

            // strata view debug button chooser
            RowLayout {
                id: comboboxRow

                onXChanged: {
                    if (visible) {
                        viewDebugPopup.updatePos()
                    }
                }

                Label {
                    text: qsTr("View:")
                    leftPadding: 10
                }

                ComboBox {
                    id: viewCombobox
                    delegate: viewButtonDelegate
                    model: viewFolderModel
                    popup: viewDebugPopup
                    textRole: "fileName"

                    onCurrentIndexChanged: {
                        // Here we remove the "views-" portion from the filename and also removes the .rcc from the filename
                        if (currentText === "") {
                            let fileName = viewFolderModel.get(currentIndex, "fileName");
                            if (fileName !== undefined) {
                                displayText = viewFolderModel.get(currentIndex, "fileName").replace("views-", "").slice(0, -4)
                            }
                        } else {
                            displayText = currentText.replace("views-", "").slice(0, -4)
                        }
                    }

                    Popup {
                        id: viewDebugPopup                      
                        width: commandBar.width
                        y: viewCombobox.height
                        padding: 0
                        background: Rectangle {
                            color: "dimgrey"
                        }

                        onVisibleChanged: {
                            updatePos()
                        }

                        function updatePos() {
                            let pos = viewCombobox.mapToItem(commandBar, 0, 0)
                            x = -pos.x
                        }

                        contentItem: GridView {
                            cellHeight: 25
                            cellWidth: (commandBar.width / 7) - 0.1
                            implicitHeight: contentHeight
                            model: viewCombobox.popup.visible ? viewCombobox.delegateModel : null
                            currentIndex: viewCombobox.highlightedIndex
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
                            width: viewDebugPopup.contentItem.cellWidth - 1
                            height: viewDebugPopup.contentItem.cellHeight - 1
                            // The below line gets the substring that is between "views-" and ".rcc". Ex) "views-template.rcc" = "template"
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
                                let repeaterCount = platformViewRepeater.count
                                PlatformSelection.openPlatformView(data)
                                viewCombobox.currentIndex = index
                                // new tab is always added to the end of the repeater
                                // in case it was indeed added (did not existed yet), initialize it
                                if (platformViewRepeater.count > repeaterCount) {
                                    platformViewRepeater.itemAt(repeaterCount).platformMetaDataInitialized = true
                                }
                            }
                        }
                    }
                }
            }

            Button {
                text: "Log Viewer App"

                onClicked: {
                    var errMessage = sdsModel.openLogViewer()
                    if (errMessage !== "") {
                        SGWidgets.SGDialogJS.showMessageDialog(
                            ApplicationWindow.window,
                            SGWidgets.SGMessageDialog.Error,
                            qsTr("Log Viewer can't be opened."),
                            errMessage)
                    }
                }
            }

            Button {
                text: "Platform List Controls"

                onClicked: {
                    localPlatformListDialog.setVisible(true)
                    localPlatformListDialog.raise()
                }
            }

            SGLocalPlatformListPopup {
                id: localPlatformListDialog
            }

            Button {
                text: "Reset Window Size"
                onClicked: mainWindow.resetWindowSize()
            }

            Button {
                text: "Login as Guest"
                onClicked: {
                    if (NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE) {
                        Notifications.currentUser = Constants.GUEST_USER_ID
                        NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                    }
                }
            }

            CheckBox {
                id: alwaysLogin
                text: "Always Login as Guest"
                onCheckedChanged: {
                    if (checked && NavigationControl.navigation_state_ !== NavigationControl.states.CONTROL_STATE && sdsModel.hcsConnected) {
                        Notifications.currentUser = Constants.GUEST_USER_ID
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
                            Notifications.currentUser = Constants.GUEST_USER_ID
                            NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, { "user_id": Constants.GUEST_USER_ID, "first_name": Constants.GUEST_FIRST_NAME, "last_name": Constants.GUEST_LAST_NAME } )
                        }
                    }
                }
            }

            RowLayout {
                Label {
                    text: qsTr("Log level:")
                }

                SGWidgets.SGLogLevelSelector {
                }
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

    SGQmlErrorListButton {
        id: qmlErrorListButton

        visible: qmlErrorModel.count !== 0
        text: qsTr("%1 QML warnings").arg(qmlErrorModel.count)
        checked: qmlErrorListPopUp.visible

        onCheckedChanged: checked ? qmlErrorListPopUp.open() : qmlErrorListPopUp.close()

        ListModel {
            id: qmlErrorModel
        }

        Connections {
            target: sdsModel
            onNotifyQmlError: {
                if (sdsModel.qtLogger.visualEditorReloading === false) {
                    qmlErrorModel.append({"data" : notifyQmlError})
                }
            }
        }
    }

    SGQmlErrorListPopUp {
        id: qmlErrorListPopUp
        topMargin: 32
        leftMargin: 32
        anchors.centerIn: ApplicationWindow.overlay
        title: qmlErrorListButton.text
        qmlErrorListModel: qmlErrorModel
    }
}
