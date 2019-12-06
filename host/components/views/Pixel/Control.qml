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
            id: controlButton2
            text: qsTr("Pixel Control")
            onClicked: {
                controlContainer.currentIndex = 0
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                platformInterface.clear_intensity_slider_led1 = true
                platformInterface.clear_intensity_slider_led2 = true
                platformInterface.clear_intensity_slider_led3 = true
                platformInterface.clear_demo_setup = false
            }
        }

        TabButton {
            id: demoButton
            text: qsTr("Pixel Demo")
            onClicked: {
                controlContainer.currentIndex = 1
                controldemo.handlar_start_control()
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = true
            }
        }

        TabButton {
            id: diagButton
            text: qsTr("diagnostic information")
            onClicked: {
                controlContainer.currentIndex = 2
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = false
            }
        }

        TabButton {
            id: setupButton
            text: qsTr("Boost and Buck IC setup")
            onClicked: {
                controlContainer.currentIndex = 3
                controldemo.handlar_stop_control()
                platformInterface.pxn_datasend_all.update(0)
                platformInterface.clear_intensity_slider_led1 = false
                platformInterface.clear_intensity_slider_led2 = false
                platformInterface.clear_intensity_slider_led3 = false
                platformInterface.clear_demo_setup = false
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

        IntensityControl {
            id: intensitycontrol
        }

        ControlDemo {
            id: controldemo
        }

        DiagWindow {
            id:diagwindow
        }

        SetupControl {
            id: setupcontrol
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
                       else if(diagwindow.visible === true) {
                           Help.startHelpTour("Help2")
                       }
                       else if(intensitycontrol.visible === true) {
                           Help.startHelpTour("Help3")
                       }
                       else if(controldemo.visible === true) {
                           Help.startHelpTour("Help4")
                       }
                   }
                   hoverEnabled: true
               }
           }
       }

}
