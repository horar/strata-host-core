import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "content-views/content-widgets"
import "qrc:/statusbar-partial-views"
import "qrc:/statusbar-partial-views/help-tour"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

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
            }
            else {
                advanced.warningBox.close()
                advanced.warningBox.visible = false
                advanced.warningBackground.visible = false
            }
        }
    }
    //Signal to track when the help tour is done.
    Connections {
        target: Help.utility2
        onInternal_tour_endChanged: {
            if(tour_status === false) {
                advanced.warningBox.close()
                advanced.warningBox.visible = false
                advanced.warningBackground.visible = false
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
        sourceSize.height: 40
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
                    Help.startHelpTour("advanceHelp")
                }
                else console.log("help not available")

            }
            hoverEnabled: true
        }
    }
}
