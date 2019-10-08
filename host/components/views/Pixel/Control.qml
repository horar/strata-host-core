import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help
//import "qrc:/statusbar-partial-views/help-tour"

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
            id: setupButton
            text: qsTr("Boost and Buck IC setup")
            onClicked: {
                controlContainer.currentIndex = 0
                controldemo.handlar_stop_control()
            }
        }

        TabButton {
            id: diagButton
            text: qsTr("diagnostic information")
            onClicked: {
                controlContainer.currentIndex = 1
<<<<<<< HEAD
                controldemo.handlar_stop_control()
            }
        }

        TabButton {
            id: controlButton
            text: qsTr("Pixel Control")
            onClicked: {
                controlContainer.currentIndex = 2
=======
>>>>>>> d1ff819ab2e0494e1532f002815c96746e6add73
                controldemo.handlar_stop_control()
            }
        }

        TabButton {
            id: controlButton2
            text: qsTr("Pixel Control 2")
            onClicked: {
<<<<<<< HEAD
                controlContainer.currentIndex = 4
=======
                controlContainer.currentIndex = 2
>>>>>>> d1ff819ab2e0494e1532f002815c96746e6add73
                controldemo.handlar_stop_control()
            }
        }

        TabButton {
            id: demoButton
            text: qsTr("Pixel Demo")
            onClicked: {
                controlContainer.currentIndex = 3
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

        SetupControl {
            id: setupcontrol
        }

        DiagWindow {
            id:diagwindow
        }

        IntensityControl {
            id: intensitycontrol
        }

        ControlDemo {
            id: controldemo
        }

<<<<<<< HEAD
        IntensityControl_new {
            id: intensitycontrol_new
        }

=======
>>>>>>> d1ff819ab2e0494e1532f002815c96746e6add73
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
                       if(setupcontrol.visible === true) {
                           Help.startHelpTour("Help1")
                       }
                       else if(intensitycontrol.visible === true) {
                           Help.startHelpTour("Help2")
                       }
                       else if(controldemo.visible === true) {
                           Help.startHelpTour("Help3")
                       }
                       else console.log("help not available")
                   }
                   hoverEnabled: true
               }
           }
       }

}
