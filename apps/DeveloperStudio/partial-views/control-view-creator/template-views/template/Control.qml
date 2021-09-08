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

    property string class_id // automatically populated for use when the control view is created with a connected board

    PlatformInterface {
        id: platformInterface
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
            text: qsTr("Commands and Notifications")
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
    }

    SGIcon {
        id: helpIcon
        anchors {
            right: controlContainer.right
            rightMargin: 15
            top: controlContainer.top
            margins: 10
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 25
        width: 25

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {
                // Make sure view is set to Basic before starting tour
                if(controlContainer.currentIndex === 0) {
                    Help.startHelpTour("BasicControlHelp")
                }
                if(controlContainer.currentIndex === 1) {
                    Help.startHelpTour("AdvanceControlHelp")
                }
            }
            hoverEnabled: true
        }
    }
}
