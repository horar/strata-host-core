import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9
import tech.strata.sgwidgets 1.0 as Widget10

Rectangle {
    id: controlNavigation
    objectName: "control"

    anchors.fill: parent


     property alias class_id: multiplePlatform.class_id

    PlatformInterface {
        id: platformInterface
    }

    MultiplePlatform{
        id: multiplePlatform
    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0,"basicHelp")
        // This is a HACK implementation
        // Windows Serial Mouse Issue fix
        platformInterface.pause_periodic.update(false)
    }

    // This is a HACK implementation
    // Windows Serial Mouse Issue fix
    Component.onDestruction:  {
        platformInterface.pause_periodic.update(true)
    }

    TabBar {
        id: navTabs
        anchors {
            top: controlNavigation.top
            left: controlNavigation.left
            right: controlNavigation.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: {
                basicControl.visible = true
                advancedControl.visible = false
                trendControl.visible = false
                loadTransientControl.visible = false
                coreControl.visible = false
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = true
                trendControl.visible = false
                loadTransientControl.visible = false
                coreControl.visible = false
            }
        }

        TabButton {
            id: trendButton
            text: qsTr("Real-time Trend Analysis")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = false
                trendControl.visible = true
                loadTransientControl.visible = false
                coreControl.visible = false
            }
        }

        TabButton {
            id: loadTransientButton
            text: qsTr("Load Transient")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = false
                trendControl.visible = false
                loadTransientControl.visible = true
                coreControl.visible = false
            }
        }

        TabButton {
            id: messagesButton
            text: qsTr("Core Messages")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = false
                trendControl.visible = false
                loadTransientControl.visible = false
                coreControl.visible = true
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

        currentIndex: navTabs.currentIndex

        Rectangle {
            width: parent.width
            height: parent.height

            BasicControl {
                id: basicControl
                visible: true
                width: parent.width
                height: parent.height
            }
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "light gray"

            AdvancedControl {
                id: advancedControl
                visible: false
                width: parent.width
                height: parent.height

            }
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "light gray"

            TrendControl {
                id: trendControl
                visible: false
                width: parent.width
                height: parent.height

            }
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "light gray"

            LoadTransientControl {
                id: loadTransientControl
                visible: false
                width: parent.width
                height: parent.height

            }
        }

        Rectangle {
            width: parent.width
            height: parent.height
            color: "light gray"

            CoreControl {
                id: coreControl
                visible: false
                width: parent.width
                height: parent.height

            }
        }
    }

    Widget10.SGIcon {
        id: helpIcon
        anchors {
            right: parent.right
            rightMargin: 20
            top: parent.top
            topMargin: 50
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 40
        width: 40
        visible: true

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {

                if(basicControl.visible === true) {
                    Help.startHelpTour("basicHelp")
                }

                else if(advancedControl.visible === true) {
                    Help.startHelpTour("advanceHelp")
                }
                else if(trendControl.visible === true) {
                    Help.startHelpTour("trendHelp")
                }
                else if(loadTransientControl.visible === true) {
                    Help.startHelpTour("loadTransientHelp")
                }
                else if(coreControl.visible === true) {
                    Help.startHelpTour("coreControlHelp")
                }
                else console.log("help not available")
            }
            hoverEnabled: true
        }
    }
}
