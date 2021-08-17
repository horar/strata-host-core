import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlViewRoot
    anchors.fill: parent

    property alias tabBar: tabBar
    property string class_id // automatically populated for use when the control view is created with a connected board

    ColumnLayout {
        anchors.fill: parent
        Layout.fillWidth: true
        Layout.fillHeight: true

        PlatformInterface {
            id: platformInterface
        }

        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                id: basicButton
                text: "Commands and Notifications"
            }

            TabButton {
                id: advancedButton
                text: "Advanced View"
            }
        }

        StackLayout {
            id: controlContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            BasicControl {
                id: basic
            }

            AdvancedControl {
                id: advanced
            }
        }
    }

    SGIcon {
        id: helpIcon
        anchors {
            left: controlViewRoot.left
            leftMargin: 15
            bottom: controlViewRoot.bottom
            margins: 10
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "dimgrey" : "grey"
        height: 25
        width: height

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

