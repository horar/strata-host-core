import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    property alias class_id: efuseClassID.class_id // passed in when created by SGPlatformView

    PlatformInterface {
        id: platformInterface
    }

    MutiplePlatform {
        id: efuseClassID
    }
    //Signal to open the popup warning message to show the help
    Connections {
        target: Help.utility
        onInternal_tour_indexChanged: {
            if(Help.current_tour_targets[index]["target"] === advanced.warningBackground){
                advanced.warningBox.visible = true
                advanced.warningBackground.visible = true
                advanced.resetButton.enabled = false
                Help.current_tour_targets[index]["helpObject"].restoreFocus()
            }
            else {
                advanced.warningBox.close()
                advanced.warningBox.visible = false
                advanced.warningBackground.visible = false
                advanced.resetButton.enabled = true
            }
        }
    }
    //Signal to track when the help tour is done.
    Connections {
        target: Help.utility
        onTour_runningChanged: {
            console.log("in tour")
            if(tour_running === false) {
                advanced.warningBox.close()
                advanced.warningBox.visible = false
                advanced.warningBackground.visible = false
                advanced.resetButton.enabled = true
            }
        }
    }


    Component.onCompleted: {
        platformInterface.get_enable_status.update()
        efuseClassID.check_class_id()
        Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "basicHelp")
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
            text: qsTr("Basic")
            onClicked: {
                controlContainer.currentIndex = 0
            }
        }

        TabButton {
            id: advancedButton
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
            top: controlContainer.top
            margins: 20
        }
        source: "control-views/question-circle-solid.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 40
        width: 40
        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {

                if(basic.visible === true) {
                    Help.startHelpTour("basicHelp")
                }

                else if(advanced.visible === true) {
                    advanced.warningBox.open()
                    advanced.warningBox.modal = false
                    advanced.warningBox.visible = false
                    advanced.warningBackground.visible = false
                    advanced.resetButton.enabled = true
                    Help.startHelpTour("advanceHelp")
                }
                else console.log("help not available")

            }
            hoverEnabled: true
        }
    }
}
