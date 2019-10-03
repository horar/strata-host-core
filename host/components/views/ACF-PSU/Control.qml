import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

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
    }

    StackLayout {
        id: controlContainer
        anchors {
            top: controlNavigation.top
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        BasicControl {
            id: mainmenu
        }
    }

//HELP ICON TO BE IMPLEMENTED
    Rectangle {
        width: 40
        height: 40
        anchors {
            right: parent.right
            rightMargin: 6
            top: navTabs.bottom
            topMargin: 20
        }
        color: "transparent"
        SGIcon {
            id: helpIcon
            anchors.fill: parent
            source: "control-views/question-circle-solid.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            sourceSize.height: 40
            visible: true
            MouseArea {
                id: helpMouse
                anchors {
                    fill: helpIcon
                }
                onClicked: {
                    Help.startHelpTour("Help1")
                }
                hoverEnabled: true
            }
        }
    }
}

