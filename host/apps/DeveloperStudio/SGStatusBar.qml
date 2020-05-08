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

    property color backgroundColor: "#3a3a3a"
    property color menuColor: "#33b13b"
    property color alternateColor1: "#575757"

    Component.onCompleted: {
        // Initialize main help tour- NavigationControl loads this before PlatformSelector
        Help.setClassId("strataMain")
        Help.registerTarget(helpTab.close, "When a platform view is open use this button to close it and return to the platform selection view.", 2, "selectorHelp")
        Help.registerTarget(helpTab.control, "When a platform view is open and platform is connected, this button will show the control view.", 3, "selectorHelp")
        Help.registerTarget(helpTab.content, "When a platform view is open, this button will show the content view.", 4, "selectorHelp")
    }

    // Navigation_control calls this after login when statusbar AND platformSelector are all complete
    function loginSuccessful() {
        PlatformSelection.getPlatformList()
    }

    Component.onDestruction: {
        Help.destroyHelp()
    }

    Item {
        id: logoContainer
        height: container.height
        width: 70

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

    Row {
        id: tabRow
        anchors {
            left: logoContainer.right
        }

        Repeater {
            id: platformTabRepeater
            delegate: SGPlatformTab {}
            model: NavigationControl.platform_view_model_
        }

        SGPlatformTab {
            // demonstration tab set for help tour
            id: helpTab
            visible: false
            class_id: "0"
            view: "control"
            index: 0
            connected: true

            Connections {
                target: Help.utility
                onInternal_tour_indexChanged:{
                    if (Help.current_tour_targets[index]["target"] === helpTab.close ||
                            Help.current_tour_targets[index]["target"] === helpTab.control ||
                            Help.current_tour_targets[index]["target"] === helpTab.content ) {
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
            cursorShape: Qt.PointingHandCursor

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
        }
    }

    function showAboutWindow() {
        SGDialogJS.createDialog(container, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }
}
