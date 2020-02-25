import QtQuick 2.10 // to support scale animator
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Window 2.3 // for debug window, can be cut out for release
import QtGraphicalEffects 1.0
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/partial-views"
import "qrc:/partial-views/status-bar"
import "qrc:/partial-views/help-tour"
import "qrc:/partial-views/about-popup"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: container
    anchors { fill: parent }
    color: "black"

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property string first_name: ""
    property string last_name: ""
    property bool is_logged_in: false
    property bool is_remote_connected: false
    property bool is_remote_advertised: false
    property string generalTitle: "Guest"
    property color backgroundColor: "#3a3a3a"
    property color menuColor: "#33b13b"
    property color alternateColor1: "#575757"

    Component.onCompleted: {
        Help.registerTarget(platformSelectionButton, "Use button to open the platform selector view.", 0, "statusHelp")
        Help.registerTarget(platformControlsButton, "Use this button to select the platform control view. Only available when platform is connected", 1, "statusHelp")
        Help.registerTarget(platformContentButton, "Use this button to select the content view for the selected platform.", 2, "statusHelp")
    }

    // Navigation_control calls this after login when statusbar AND control/content components are all complete
    function loginSuccessful() {
        PlatformSelection.getPlatformList()
    }

    Component.onDestruction: {
        Help.destroyHelp()
    }

    function generateToken(n) {
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        var token = '';
        for(var i = 0; i < n; i++) {
            token += chars[Math.floor(Math.random() * chars.length)];
        }
        return token;
    }

    function find(model, remote_user_name) {
        for(var i = 0; i < model.count; ++i) {
            if (remote_user_name === model.get(i).name) {
                return i
            }
        }
        return null
    }


    Connections {
        target: coreInterface
        onRemoteUserAdded: {
            remoteUserModel.append({"name":user_name, "active":false})
        }
    }

    Connections {
        target: coreInterface
        onRemoteUserRemoved: {
            remoteUserModel.remove(find(remoteUserModel, user_disconnected))
        }
    }

    Connections {
        target: coreInterface
        onPlatformStateChanged: {
            //resetting the remote connection state
            is_remote_connected = false;
            tokenField.text = "";
            // send "close remote advertise to hcs to close the remote socket"
            if (remoteToggle.checked) {
                remoteToggle.checked = false;
                var remote_json = {
                    "hcs::cmd":"advertise",
                    "payload": {
                        "advertise_platforms":false
                    }
                }
                console.log(Logger.devStudioCategory, "asking hcs to advertise the platforms",JSON.stringify(remote_json))
                coreInterface.sendCommand(JSON.stringify(remote_json))
            }
        }
    }

    SGIcon {
        id: remote_activity_icon
        source: "images/icons/wifi.svg"
        anchors {
            left: remote_user_icons.right
            leftMargin: 15
            verticalCenter: container.verticalCenter
        }
        iconColor: "#00b842"
        height: 20
        width: height
        visible: remote_activity_label.visible
    }

    Label {
        id:remote_activity_label
        anchors {
            left: remote_activity_icon.right
            leftMargin: 5
            verticalCenter: container.verticalCenter
        }
        text: ""
        visible: false
        color: "white"
    }

    Connections {
        target: coreInterface
        onRemoteActivityChanged: {
            remote_activity_label.visible = true;
            remote_activity_label.text= "Controlled by "+ coreInterface.remote_user_activity_;
            activityMonitorTimer.start();
        }
    }

    Timer {
        // 3 second timeout for response
        id: activityMonitorTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            remote_activity_label.visible = false;
        }
    }

    ToolBar {
        id: toolBar
        anchors {
            left: container.left
        }
        background: Rectangle {
            color: container.color
            height: container.height
        }

        Row {
            Item {
                id: logoContainer
                height: toolBar.height
                width: 65

                Image {
                    source: "qrc:/images/strata-logo-reverse.svg"
                    height: 30
                    width: 60
                    mipmap: true
                    anchors {
                        verticalCenter: logoContainer.verticalCenter
                        right: logoContainer.right
                    }
                }
            }

            SGToolButton {
                id: platformSelectionButton
                text: qsTr("Platform Selection")
                width: 150
                buttonColor: hovered || PlatformSelection.platformListModel.selectedConnection === "" ? menuColor : container.color
                onClicked: {
                    if (NavigationControl.context["platform_state"] || NavigationControl.context["class_id"] !== "") {
                        coreInterface.disconnectPlatform() // cancels any active collateral downloads
                        PlatformSelection.deselectPlatform()
                    }
                }
                iconSource: "images/icons/th-list.svg"
            }

            Rectangle {
                id: buttonDivider1
                width: 1
                height: toolBar.height
                color: container.color
            }

            SGToolButton {
                id: platformControlsButton
                text: qsTr("Platform Controls")
                width: 150
                buttonColor: hovered || (PlatformSelection.platformListModel.selectedConnection !== "" && !NavigationControl.flipable_parent_.flipped) ? menuColor : container.color
                enabled: PlatformSelection.platformListModel.selectedConnection !== "view" && PlatformSelection.platformListModel.selectedConnection !== ""
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.SHOW_CONTROL)
                }
                iconSource: "images/icons/sliders-h.svg"
            }

            Rectangle {
                id: buttonDivider2
                width: 1
                height: toolBar.height
                color: container.color
            }

            SGToolButton {
                id: platformContentButton
                text: qsTr("Platform Content")
                width: 150
                buttonColor: hovered || (PlatformSelection.platformListModel.selectedConnection !== "" && NavigationControl.flipable_parent_.flipped) ? menuColor : container.color
                enabled: PlatformSelection.platformListModel.selectedConnection !== ""
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.SHOW_CONTENT)
                }
                iconSource: "images/icons/file.svg"
            }

            Rectangle {
                id: buttonDivider3
                width: 1
                height: toolBar.height
                color: container.color
            }

            SGToolButton {
                id: remoteSupportButton

                visible: false
                enabled: false

                text: qsTr("Remote Support")
                width: 150
                onPressed: {
                    remoteSupportMenu.open()
                }
                buttonColor: remoteSupportButton.hovered || remoteSupportMenu.visible ? menuColor : container.color
                iconSource: "images/icons/user-plus.svg"

                SGIcon {
                    id: remoteSupportPopupIndicator
                    source: "images/icons/angle-down.svg"
                    visible: remoteSupportMenu.visible
                    anchors {
                        bottom: remoteSupportButton.bottom
                        bottomMargin: -5
                        horizontalCenter: remoteSupportButton.horizontalCenter
                    }
                    iconColor: "white"
                    height: 20
                    width: height
                }

                SGRemoteSupportPopup{
                    id: remoteSupportMenu
                    y: remoteSupportButton.height
                    x: container.width > toolBar.x + remoteSupportButton.x + width ? 0 : container.width > toolBar.x + remoteSupportButton.x + remoteSupportButton.width ? container.width - toolBar.x -remoteSupportButton.x - width/*- (width / 2) + (remoteSupportButton.width / 2)*/ : - width + remoteSupportButton.width
                }
            }
        }
    }


    Component {
        id: remoteUserIconDelegate

        Item {
            id: remote_icon_container
            width: remote_user_hover.containsMouse ? remote_user_img.width + 18 : remote_user_img.width
            height: 40
            clip: false

            Behavior on width { NumberAnimation {
                    duration: 50
                }
            }

            Image {
                id: remote_user_img
                sourceSize.height: 40
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/blank_avatar.png"
                visible: false
                anchors {
                    right: remote_icon_container.right
                }
            }

            Rectangle {
                id: mask
                width: remote_user_img.width
                height: width
                radius: width/2
                visible: false
                anchors {
                    right: remote_icon_container.right
                }
            }

            OpacityMask {
                height: mask.width
                width: mask.height
                source: remote_user_img
                maskSource: mask
                anchors {
                    right: remote_icon_container.right
                }

                ToolTip {
                    text: model.name
                    visible: remote_user_hover.containsMouse
                }
            }

            MouseArea {
                id: remote_user_hover
                anchors {
                    fill: remote_icon_container
                }
                hoverEnabled: true
            }
        }
    }

    Row {
        id: remote_user_icons
        anchors {
            left: toolBar.right
            leftMargin: 18
        }
        width: icon_repeater.count * 19 + 16
        height: 40
        y: 2
        spacing: -16
        layoutDirection: Qt.RightToLeft
        clip: false

        Repeater {
            id: icon_repeater
            model: remoteSupportMenu.remoteUserModel
            delegate: remoteUserIconDelegate
        }
    }

    Item {
        id: profileIconContainer
        anchors {
            right: container.right
            rightMargin: 2
            top: container.top
            bottom: container.bottom
        }
        width: height

        Rectangle {
            id: profileIcon
            anchors {
                centerIn: profileIconContainer
            }
            height: profileIconHover.containsMouse ? profileIconContainer.height : profileIconContainer.height - 6
            width: height
            radius: height / 2
            color: "#00b842"

            Text {
                id: profileInitial
                text: first_name.charAt(0)
                color: "white"
                anchors {
                    centerIn: profileIcon
                }
                font {
                    family: Fonts.franklinGothicBold
                    pixelSize: profileIconHover.containsMouse ? 24 : 20
                }
            }
        }

        MouseArea {
            id: profileIconHover
            hoverEnabled: true
            anchors {
                fill: profileIconContainer
            }
            onPressed: {
                profileMenu.open()
            }
        }

        Popup {
            id: profileMenu
            x: -width + profileIconContainer.width
            y: profileIconContainer.height
            padding: 0
            topPadding: 10
            width: 100
            background: Canvas {
                width: profileMenu.width
                height: profileMenu.contentItem.height + 10

                onPaint: {
                    var context = getContext("2d");
                    context.reset();
                    context.beginPath();
                    context.moveTo(0, 10);
                    context.lineTo(width - (profileIconContainer.width/2)-10, 10);
                    context.lineTo(width - profileIconContainer.width/2, 0);
                    context.lineTo(width - (profileIconContainer.width/2)+10, 10);
                    context.lineTo(width, 10);
                    context.lineTo(width, height);
                    context.lineTo(0, height);
                    context.closePath();
                    context.fillStyle = "#00b842";
                    context.fill();
                }
            }

            contentItem:
                Column {
                id: profileColumn
                width: profileMenu.width

                SGMenuItem {

                    visible: false
                    enabled: false

                    text: qsTr("My Profile")
                    onClicked: {
                        profileMenu.close()
                        profilePopup.open();
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("About")
                    onClicked: {
                        profileMenu.close()
                        showAboutWindow()
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("Feedback")
                    onClicked: {
                        profileMenu.close()
                        feedbackPopup.open();
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("Help")
                    onClicked: {
                        profileMenu.close()
                        Help.startHelpTour("statusHelp", "strataMain")
                    }
                    width: profileMenu.width
                }

                Rectangle {
                    id: menuDivider
                    color: "white"
                    opacity: .4
                    height: 1
                    width: profileMenu.width - 20
                    anchors {
                        horizontalCenter: profileColumn.horizontalCenter
                    }
                }

                SGMenuItem {
                    text: qsTr("Log Out")
                    onClicked: {
                        profileMenu.close()

                        PlatformFilters.clearActiveFilters()
                        NavigationControl.updateState(NavigationControl.events.LOGOUT_EVENT)
                        Authenticator.logout()
                        coreInterface.disconnectPlatform()
                    }
                    width: profileMenu.width
                }
            }
        }
    }

    SGFeedbackPopup {
        id: feedbackPopup
        width: Math.max(container.width * 0.8, 600)
        x: container.width/2 - feedbackPopup.width/2
        y: container.parent.windowHeight/2 - feedbackPopup.height/2
    }

    Window {
        id: debugWindow
        visible: container.parent.showDebug
        height: 200
        width: 300
        x: 1620
        y: 500
        title: "SGStatusBar.qml Debug Controls"

        Column {
            id: debug1
            Button {
                text: "Toggle Content/Control"
                onClicked: {
                    NavigationControl.updateState(NavigationControl.events.TOGGLE_CONTROL_CONTENT)
                }
            }
            Button {
                text: "add user to model"
                onClicked: {
                    remoteUserModel.append({"name":"David Faller" })
                }
            }
            Button {
                text: "clear model"
                onClicked: {
                    remoteUserModel.clear()
                }
            }
            Button {
                text: "remote activity"
                onClicked: {
                    remote_activity_label.visible = true;
                    remote_activity_label.text= "Controlled by David Faller";
                    activityMonitorTimer.start();
                }
            }
            Button {
                text: "add plat to combobox"
                onClicked: {
                    var platform_info = {
                        "text" : "Fake Platform 9000 (Connected)",
                        "verbose" : "Fake Platform 9000 (Connected)",
                        "name" : "motor-vortex",
                        "connection" : "connected",
                        "uuid" : "SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3"
                    }
                    PlatformSelection.platformListModel.append(platform_info)
                }
            }
        }

        Column {
            id: debug2
            anchors {
                left: debug1.right
                leftMargin: 10
            }

            Button {
                text: "spoof plat list, autoconnect"
                onClicked: {
                    var data = '{
                        "list":
                            [ { "connection":"view",
                                "uuid":"P2.2018.1.1.0.0.c9060ff8-5c5e-4295-b95a-d857ee9a3671",
                                "verbose":"USB PD Load Board"},
                              { "connection":"view",
                                "uuid":"P2.2017.1.1.0.0.cbde0519-0f42-4431-a379-caee4a1494af",
                                "verbose":"USB PD"},
                              { "connection":"view",
                                "uuid":"SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3",
                                "verbose":"Vortex Fountain Motor Platform Board"},
                              '+/*{ "connection":"connected",
                                "uuid":"SEC.2017.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3",
                                "verbose":"Fake Motor Vortex AutoConnect"}*/'
                              { "connection":"connected",
                                "uuid":"SEC.2016.004.2.0.0.1c9f3822-b865-11e8-b42a-47f5c5ed4fc3",
                                "verbose":"Unknown Board"}
                               ]
                        }'


                    PlatformSelection.populatePlatforms(data)
                }
            }
            Text {
                id: name
                text: qsTr(PlatformSelection.platformListModel.selectedConnection)
            }
        }
    }

    function showAboutWindow() {
        SGDialogJS.createDialog(container, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }

}
