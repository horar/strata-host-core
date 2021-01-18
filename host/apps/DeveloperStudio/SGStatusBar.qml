import QtQuick 2.10 // to support scale animator
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtQuick.Window 2.3 // for debug window, can be cut out for release
import QtGraphicalEffects 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters
import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/constants.js" as Constants
import "qrc:/partial-views"
import "qrc:/partial-views/status-bar"
import "qrc:/partial-views/help-tour"
import "qrc:/partial-views/about-popup"
import "qrc:/partial-views/profile-popup"
import "qrc:/js/help_layout_manager.js" as Help
import "partial-views/control-view-creator"

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Rectangle {
    id: container
    anchors { fill: parent }
    color: "black"

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property string first_name: ""
    property string last_name: ""

    property color backgroundColor: "#3a3a3a"
    property color menuColor: Theme.palette.green
    property color alternateColor1: "#575757"

    property alias platformTabListView: platformTabListView

    Component.onCompleted: {
        // Initialize main help tour- NavigationControl loads this before PlatformSelector
        Help.setClassId("strataMain")
        Help.registerTarget(helpTab, "When a platform has been selected, this button will allow you to navigate between its control and content views.", 2, "selectorHelp")
        userSettings.loadSettings()
    }

    // Navigation_control calls this after login when statusbar AND platformSelector are all complete
    function loginSuccessful() {
        PlatformSelection.getPlatformList()
    }

    Component.onDestruction: {
        Help.destroyHelp()
    }

    RowLayout {
        id: tabRow
        anchors {
            left: container.left
            right: profileIconContainer.left
        }
        spacing: 1

    	Item {
        	id: logoContainer
        	Layout.preferredHeight: container.height
        	Layout.preferredWidth: 70

        	Image {
            	source: "qrc:/images/strata-logo-reverse.svg"
            	height: 30
            	width: 60
            	mipmap: true
            	anchors {
                	centerIn: logoContainer
            	}
        	}
    	}

        Rectangle {
            id: platformSelector
            Layout.preferredHeight:40
            Layout.preferredWidth: 120

            color: platformSelectorMouse.containsMouse ? Qt.darker(Theme.palette.green, 1.15) : NavigationControl.stack_container_.currentIndex === 0 ? Theme.palette.green : "#444"

            property color menuColor: Theme.palette.green

            SGText {
                color: "white"
                text: "Platform Selector"
                anchors {
                    centerIn: parent
                    verticalCenterOffset: 2
                }
                font.family: Fonts.franklinGothicBook
            }

            MouseArea {
                id: platformSelectorMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    let data = {"index": 0}
                    NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            id: platformLeftArrow
            Layout.preferredHeight: 40
            Layout.preferredWidth: 20

            property bool leftArrowActive: platformTabListView.contentX > 0

            visible: platformTabListView.contentWidth > platformTabListView.width

            color: leftArrowMouse.containsMouse && leftArrowActive ? Qt.darker(Theme.palette.green, 1.15) : "#444"

            Timer {
                id: leftArrowTimer
                interval: 10
                running: false
                repeat: true
                onTriggered:  {
                    platformTabListView.setPlatformTabContentX(-30)
                }
            }

            SGIcon {
                id: leftArrowIcon
                height: width
                width: parent.width - 4
                anchors {
                    centerIn: parent
                }
                source: "qrc:/sgimages/chevron-left.svg"
                iconColor : "white"
                opacity: parent.leftArrowActive ? 1 : 0.4
            }

            MouseArea {
                id: leftArrowMouse
                anchors.fill: parent
                hoverEnabled: true
                pressAndHoldInterval: 300
                onClicked: {
                    platformTabListView.setPlatformTabContentX(-100)
                }
                onPressAndHold: {
                    leftArrowTimer.start()
                }
                onReleased: {
                    leftArrowTimer.stop()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        ListView {
            id: platformTabListView
            Layout.fillHeight: true
            Layout.fillWidth: true

            property int platformTabWidth: ((count > 0) && (width > count)) ?
                    Math.max(Math.min(Math.floor((width - count) / count), 250), 140) : 250

            property int platformTabWidthRemainder : (platformTabWidth < 250) ?
                    Math.max(width - ((platformTabWidth * count) + count), 0) : 0

            delegate: SGPlatformTab {
                width: platformTabListView.platformTabWidth +
                       (index == (platformTabListView.count - 1) ? platformTabListView.platformTabWidthRemainder : 0)
            }
            orientation: ListView.Horizontal
            spacing: 1
            clip: true

            highlightMoveDuration: 200
            highlightMoveVelocity: -1

            model: NavigationControl.platform_view_model_

            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds

            Behavior on contentX {
                NumberAnimation {
                    id: platformTabAnimation
                    duration: 100
                    easing.type: Easing.Linear

                    property int animationContentX: 0   // to facilitate smooth mouse movements
                }
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: {
                    let movementDelta = 0
                    if (wheel.pixelDelta != null) {
                        // as input we have pixelDelta which is how many pixels we have to move in this scroll step
                        if (Math.abs(wheel.pixelDelta.x) > Math.abs(wheel.pixelDelta.y)) {
                            movementDelta = wheel.pixelDelta.x
                        } else {
                            movementDelta = wheel.pixelDelta.y
                        }
                    }

                    if (wheel.angleDelta != null && movementDelta === 0) {
                        // as input we have angleDelta which is in multiples of 120, where 120 is one scroll step
                        if (Math.abs(wheel.angleDelta.x) > Math.abs(wheel.angleDelta.y)) {
                            movementDelta = wheel.angleDelta.x
                        } else {
                            movementDelta = wheel.angleDelta.y
                        }
                        // we make it so that 10 scrolls will move 1 page
                        movementDelta = ((movementDelta / 120.0) * (platformTabListView.width / 10.0))
                    }

                    if (movementDelta !== 0) {
                        platformTabListView.setPlatformTabContentX(-movementDelta)
                    }
                    wheel.accepted = true
                }
            }

            function setPlatformTabContentX(val) {
                if (platformTabAnimation.running == false) {
                    platformTabAnimation.animationContentX = platformTabListView.contentX
                }
                platformTabAnimation.animationContentX += val
                if (platformTabAnimation.animationContentX < 0) {
                    platformTabAnimation.animationContentX = 0
                } else {
                    let maxContentX = Math.max(platformTabListView.contentWidth - platformTabListView.width, 0)
                    if (platformTabAnimation.animationContentX > maxContentX) {
                        platformTabAnimation.animationContentX = maxContentX
                    }
                }
                platformTabListView.contentX = platformTabAnimation.animationContentX
            }
        }

        Rectangle {
            id: platformRightArrow
            Layout.preferredHeight: 40
            Layout.preferredWidth: 20

            property bool rightArrowActive: platformTabListView.contentX < Math.max(platformTabListView.contentWidth - platformTabListView.width, 0)

            visible: platformTabListView.contentWidth > platformTabListView.width

            color: rightArrowMouse.containsMouse && rightArrowActive ? Qt.darker(Theme.palette.green, 1.15) : "#444"

            Timer {
                id: rightArrowTimer
                interval: 10
                running: false
                repeat: true
                onTriggered:  {
                    platformTabListView.setPlatformTabContentX(30)
                }
            }

            SGIcon {
                id: rightArrowIcon
                height: width
                width: parent.width - 4
                anchors {
                    centerIn: parent
                }
                source: "qrc:/sgimages/chevron-right.svg"
                iconColor : "white"
                opacity: parent.rightArrowActive ? 1 : 0.4
            }

            MouseArea {
                id: rightArrowMouse
                anchors.fill: parent
                hoverEnabled: true
                pressAndHoldInterval: 300
                onClicked: {
                    platformTabListView.setPlatformTabContentX(100)
                }
                onPressAndHold: {
                    rightArrowTimer.start()
                }
                onReleased: {
                    rightArrowTimer.stop()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        CVCButton {
            id: cvcButton
            visible: false
        }

        SGPlatformTab {
            // demonstration tab set for help tour
            id: helpTab
            class_id: "0"
            device_id: Constants.NULL_DEVICE_ID
            view: "control"
            index: 0
            connected: true
            name: "Help Example"
            visible: false
            onXChanged: {
                if (visible) {
                    Help.refreshView(Help.internal_tour_index)
                }
            }
            available: {
                "documents": true,
                "control": true
            }

            Connections {
                target: Help.utility
                onInternal_tour_indexChanged:{
                    if (Help.current_tour_targets[index]["target"] === helpTab) {
                        helpTab.visible = true
                    } else {
                        helpTab.visible = false
                    }
                }
                onTour_runningChanged: {
                    helpTab.visible = false
                }
            }
        }
    }

    Item {
        id: profileIconContainer
        width: height

        anchors {
            right: container.right
            rightMargin: 2
            top: container.top
            bottom: container.bottom
        }

        Rectangle {
            id: profileIcon
            anchors {
                centerIn: profileIconContainer
            }
            height: profileIconHover.containsMouse ? profileIconContainer.height : profileIconContainer.height - 6
            width: height
            radius: height / 2
            color: Theme.palette.green

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

        Rectangle {
            id: alertIconContainer
            visible: false

            anchors {
                top: parent.top
                horizontalCenter: parent.left
                topMargin: 5
            }

            height: 12
            width: height
            radius: height / 2
            color: Theme.palette.green

            SGIcon {
                id: alertIcon
                height: 15
                width: height
                anchors {
                    centerIn: parent
                }
                source: "qrc:/sgimages/exclamation-circle.svg"
                iconColor : "white"
            }
        }

        MouseArea {
            id: profileIconHover
            hoverEnabled: true
            anchors {
                fill: profileIconContainer
            }
            cursorShape: Qt.PointingHandCursor
            Accessible.role: Accessible.Button
            Accessible.name: "User Icon"
            Accessible.description: "User menu button."
            Accessible.onPressAction: pressAction()
            onPressed: pressAction()

            function pressAction() {
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
                    context.fillStyle = Theme.palette.green;
                    context.fill();
                }
            }

            contentItem:
                Column {
                id: profileColumn
                width: profileMenu.width

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
                        feedLoader.active = true
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("Profile")
                    onClicked: {
                        profileMenu.close()
                        profileLoader.active = true
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("Settings")
                    onClicked: {
                        profileMenu.close()
                        settingsLoader.active = true
                    }
                    width: profileMenu.width
                }

                SGMenuItem {
                    text: qsTr("CVC")
                    visible: cvcButton.state === "debug"
                    width: profileMenu.width

                    onClicked: {
                        cvcButton.toggleVisibility()
                    }
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
                        PlatformSelection.logout()
                        sdsModel.coreInterface.unregisterClient()
                    }
                    width: profileMenu.width
                }
            }
        }
    }

    Loader {
        id: feedLoader
        source: "qrc:/partial-views/status-bar/SGFeedbackPopup.qml"
        active: false
    }

    Loader {
        id: profileLoader
        source: "qrc:/partial-views/profile-popup/SGProfilePopup.qml"
        active: false
    }

    Loader {
        id: settingsLoader
        source: "qrc:/partial-views/status-bar/SGSettingsPopup.qml"
        active: false
    }

    SGUserSettings {
        id: userSettings
        classId: "general-settings"
        user: NavigationControl.context.user_id

        property bool autoOpenView: false
        property bool closeOnDisconnect: false
        property bool notifyOnFirmwareUpdate: false

        property int selectedDistributionPortal: 0

        function loadSettings() {
            const settings = readFile("general-settings.json")
            if (settings.hasOwnProperty("autoOpenView")) {
                autoOpenView = settings.autoOpenView
                closeOnDisconnect = settings.closeOnDisconnect
                notifyOnFirmwareUpdate = settings.notifyOnFirmwareUpdate
                selectedDistributionPortal = settings.selectedDistributionPortal
            }
            NavigationControl.userSettings = userSettings
        }

        function saveSettings() {
            const settings = {
                autoOpenView: autoOpenView,
                closeOnDisconnect: closeOnDisconnect,
                notifyOnFirmwareUpdate: notifyOnFirmwareUpdate,
                selectedDistributionPortal: selectedDistributionPortal
            }
            userSettings.writeFile("general-settings.json", settings)
        }
    }

    function showAboutWindow(){
        SGDialogJS.createDialog(container, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }
}
