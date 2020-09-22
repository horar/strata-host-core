import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        Help.registerTarget(navTabs, "Using these three tabs, you can view basic controls, advanced controls or the SGUserSettings demo.", 0, "controlHelp")
    }

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            KeyNavigation.right: this
            KeyNavigation.left: this
            text: qsTr("Basic")
            onClicked: {
                controlContainer.currentIndex = 0
            }
        }

        TabButton {
            id: advancedButton
            KeyNavigation.right: this
            KeyNavigation.left: this
            text: qsTr("Advanced")
            onClicked: {
                controlContainer.currentIndex = 1
            }
        }

        TabButton {
            id: userSettingsButton
            KeyNavigation.right: this
            KeyNavigation.left: this
            text: qsTr("User Settings")
            onClicked: {
                controlContainer.currentIndex = 2
            }
        }
    }

    StackLayout {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        BasicControl {
            id: basic
        }

        AdvancedControl {
            id: advanced
        }

        UserSettingsControl {
            id: userSettings
        }
    }

    SGIcon {
        id: helpIcon
        anchors {
            right: controlContainer.right
            top: controlContainer.top
            margins: 20
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 40
        width: 40

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {
                // Make sure view is set to Basic before starting tour
                navTabs.currentIndex = 0
                controlContainer.currentIndex = 0
                basicButton.clicked()
                Help.startHelpTour("controlHelp")
            }
            hoverEnabled: true
        }
    }

    DebugMenu {
        // See description in control-views/DebugMenu.qml
        anchors {
            right: controlContainer.right
            bottom: controlContainer.bottom
        }
    }
}
