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
import "qrc:/js/restclient.js" as Rest
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

            // starta view debug button chooser
//            RowLayout {
//                id: comboboxRow

//                Label {
//                    text: qsTr("View:")
//                    leftPadding: 10
//                }

//                ComboBox {
//                    id: viewCombobox
//                    delegate: viewButtonDelegate
//                    model: viewFolderModel
//                    textRole: "fileName"

//                    onCurrentIndexChanged: {
//                        // Here we remove the "views-" portion from the filename and also removes the .rcc from the filename
//                        let folder = viewFolderModel.get(currentIndex, "fileName");
//                        if (folder !== undefined) {
//                            displayText = folder
//                        }

//                    }

//                    FolderListModel {
//                        id: viewFolderModel
//                        showDirs: true
//                        folder: sdsModel.resourceLoader.getStaticViewsPhysicalPathUrl()

//                        onCountChanged: {
//                            viewCombobox.currentIndex = viewFolderModel.count - 1
//                        }

//                        onStatusChanged: {
//                            if (viewFolderModel.status === FolderListModel.Ready) {
//                                // [LC] - this FolderListModel is from Lab; a side effects in 5.12
//                                //      - if 'folder' url doesn't exists the it loads app folder content
//                                comboboxRow.visible = true
//                            }
//                        }
//                    }

////                    Component {
////                        id: viewButtonDelegate

////                        Button {
////                            id: selectButton
////                            width: viewCombobox.width
////                            height: 20
////                            // The below line gets the substring that is between "views-" and ".rcc". Ex) "views-template.rcc" = "template"
////                            text: model.fileName
////                            hoverEnabled: true
////                            background: Rectangle {
////                                color: hovered ? "white" : "lightgrey"
////                            }

////                            onClicked: {
////                                console.log("modelFilePath", model.filePath)
////                                var path = sdsModel.resourceLoader.returnQrcPath(model.filePath);
////                                var path2 = "file:///Users/zbd8dm/strata-root/strata-platform-control-views/views/MDK-Template2/qml-views-MDK-Template2.qrc"
////                                //                                controlViewDevDialog.visible = true
////                                //                                controlViewDevDialog.qrcFilePath = path
////                                //                                controlViewDevDialog.compileRCCFromPath()

////                                //sdsModel.resourceLoader.getStaticViewsPhysicalPathUrl() = file:///Users/zbd8dm/strata-root/build-spyglass-Desktop_Qt_5_12_9_clang_64bit-Debug/bin/views

////                                console.log("test", path/*sdsModel.resourceLoader.getStaticViewsPhysicalPathUrl()*/)
////                                Signals.loadCVC()
////                                Signals.openControlView(path2)

////                            }
////                        }
////                    }
//                }
//            }

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

            Button {
                id: serverChange
                enabled: sdsModel.urls.testAuthServer !== ""
                onClicked: {
                    if (Rest.url !== sdsModel.urls.authServer) {
                        Rest.url = sdsModel.urls.authServer
                    } else {
                        Rest.url = sdsModel.urls.testAuthServer
                    }
                    Signals.serverChanged()
                }

                Component.onCompleted: {
                    setButtonText()
                }

                function setButtonText () {
                    if (Rest.url !== sdsModel.urls.authServer ) {
                        text = "Switch to Prod Auth Server"
                    } else {
                        text = "Switch to Test Auth Server"
                    }
                }

                Connections {
                    target: Signals
                    onServerChanged: {
                        serverChange.setButtonText()
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
                qmlErrorModel.append({"data" : notifyQmlError})
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
