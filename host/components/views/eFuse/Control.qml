import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "content-views/content-widgets"
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

    Component.onCompleted: {
        platformInterface.get_board_id.update()
        platformInterface.get_status.update()
        efuseClassID.check_class_id()
        platformInterface.get_enable_status.update()
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
                    Help.startHelpTour("advanceHelp")
                }
                else console.log("help not available")

            }
            hoverEnabled: true
        }
    }

}
