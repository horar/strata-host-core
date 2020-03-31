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
        Help.registerTarget(navTabs, "Using these two tabs, you may select between basic and advanced controls.", 0, "controlHelp")
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
                basic.visible = true
                advanced.visible = false
                efficiency.visible = false
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Protection & Dropout")
            onClicked: {
                basic.visible = false
                advanced.visible = true
                efficiency.visible = false
            }
        }

        TabButton {
            id: systemEfficiencyButton
            text: qsTr("System Efficiency")
            onClicked: {

                basic.visible = false
                advanced.visible = false
                efficiency.visible = true
            }
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        BasicControl {
            id: basic

            visible: true

        }

        AdvancedControl {
            id: advanced

            visible: false

        }

        SystemEfficiency {
            id: efficiency
            visible:  false
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
                // Make sure view is set to Basic before starting tour
                if(basic.visible)
                    Help.startHelpTour("AdjLDOBasicHelp")
                if(advanced.visible)
                    Help.startHelpTour("AdjLDOAdvanceHelp")
                if(efficiency.visible)
                     Help.startHelpTour("AdjLDOSystemEfficiencyHelp")
            }
            hoverEnabled: true
        }
    }

}
