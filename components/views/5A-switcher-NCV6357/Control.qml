import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: controlNavigation
    objectName: "control"

    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(navTabs, "The user can switch between the basic or advanced views of the UI using these two tabs.", 0,"basic5AHelp")
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
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = true
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
    }

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
            source: "question-circle-solid.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            sourceSize.height: 40
            visible: true

            MouseArea {
                id: helpMouse
                anchors {
                    fill: helpIcon
                }
                onClicked: {
                    if(basicControl.visible === true) {
                        Help.startHelpTour("basic5AHelp")
                    }

                    else if(advancedControl.visible === true) {
                        Help.startHelpTour("advance5AHelp")
                    }
                    else console.log("help not available")
                }
                hoverEnabled: true
            }
        }
    }
}
