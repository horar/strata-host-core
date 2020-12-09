import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2
import Qt.labs.folderlistmodel 2.12
import Qt.labs.settings 1.1 as QtLabsSettings

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/restclient.js" as Rest
import "qrc:/js/constants.js" as Constants
import "qrc:/js/platform_selection.js" as PlatformSelection

Item {
    id: root

    property string testAuthServer: "http://18.191.108.5/"
    property bool recompileRequested: false

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
                        // Here we remove the "views-" portion from the filename and also removes the .rcc from the filename
                        let folder = viewFolderModel.get(currentIndex, "fileName");
                        if (folder !== undefined) {
                            displayText = folder
                        }
                    }

                    FolderListModel {
                        id: viewFolderModel
                        showDirs: true
                        folder: sdsModel.resourceLoader.getStaticViewsPhysicalPathUrl()

                        onCountChanged: {
                            viewCombobox.currentIndex = viewFolderModel.count - 1
                        }

                        onStatusChanged: {
                            if (viewFolderModel.status === FolderListModel.Ready) {
                                // [LC] - this FolderListModel is from Lab; a side effects in 5.12
                                //      - if 'folder' url doesn't exists the it loads app folder content
                                comboboxRow.visible = true
                            }
                        }
                    }

                    Component {
                        id: viewButtonDelegate

                        Button {
                            id: selectButton
                            width: viewCombobox.width
                            height: 20
                            // The below line gets the substring that is between "views-" and ".rcc". Ex) "views-template.rcc" = "template"
                            text: model.fileName
                            hoverEnabled: true
                            background: Rectangle {
                                color: hovered ? "white" : "lightgrey"
                            }

                            onClicked: {
                                // Todo: change this combobox to browse/scan qrc's in the components/views directories
                                // and then open them/load the RCC applicable. https://ons-sec.atlassian.net/browse/CS-1301
                                let name = selectButton.text;
                                viewCombobox.currentIndex = index
                                recompileRequested = true
                                let path = sdsModel.resourceLoader.returnQrcPath(model.filePath);
                                sdsModel.resourceLoader.recompileControlViewQrc(path);
                                stackContainer.currentIndex = stackContainer.count - 1

                            }
                        }
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
                    Signals.serverChanged()
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
                    target: Signals
                    onServerChanged: {
                        serverChange.setButtonText()
                    }
                }
            }

            SGLogLevelSelector {
            }

            Button {
                text: "Control View Dev"

                onClicked: {
                    controlViewDevDialog.setVisible(true)
                    controlViewDevDialog.raise()
                }
            }

            SGControlViewDevPopup {
                id: controlViewDevDialog
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

        onCheckedChanged: {
            if (checked) {
                qmlErrorListPopUp.open()
                stopAnimation()
            } else {
                qmlErrorListPopUp.close()
                startAnimation()
            }
        }

        ListModel {
            id: qmlErrorModel
        }

        Connections {
            target: sdsModel
            onNotifyQmlError: {
                qmlErrorModel.append({"data" : notifyQmlError})
            }
        }

        Connections {
            target: sdsModel.resourceLoader

            onFinishedRecompiling: {
                if (recompileRequested) {
                    recompileRequested = false;
                    if (filepath !== '') {
                        loadDebugView(filepath)
                    } else {
                        let error_str = sdsModel.resourceLoader.getLastLoggedError()
                        controlViewDevContainer.setSource(NavigationControl.screens.LOAD_ERROR, {"error_message": error_str})
                    }
                }
            }
        }
    }

    SGQmlErrorListPopUp {
        id: qmlErrorListPopUp

        topMargin: 32
        leftMargin: 32
        topPadding: errorListDetailsChecked ? undefined : 1
        bottomPadding: errorListDetailsChecked ? undefined : 1

        anchors.centerIn: errorListDetailsChecked ? ApplicationWindow.overlay : undefined
        opacity: errorListDetailsChecked ? 0.9 : 0.7

        title: qmlErrorListButton.text


        qmlErrorListModel: qmlErrorModel
    }

    function loadDebugView(path) {
        controlViewDevContainer.setSource("")

        let uniquePrefix = new Date().getTime().valueOf()
        uniquePrefix = "/" + uniquePrefix

        // Register debug control view object
        if (!sdsModel.resourceLoader.registerResource(path, uniquePrefix)) {
            console.error("Failed to register resource")
            return
        }

        let qml_control = "qrc:" + uniquePrefix + "/Control.qml"
        controlViewDevContainer.setSource(qml_control);
    }
}
