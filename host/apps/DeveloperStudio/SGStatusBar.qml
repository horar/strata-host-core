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
        }
    }

    function showAboutWindow() {
        SGDialogJS.createDialog(container, "qrc:partial-views/about-popup/DevStudioAboutWindow.qml")
    }
}
