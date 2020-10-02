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

Rectangle {
    id: controlNavigation
    objectName: "control"

    anchors {
        fill: parent
    }

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
                loader.sourceComponent = basicComponent
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                loader.sourceComponent = advComponent
            }
        }

        TabButton {
            id: trendButton
            text: qsTr("Real-time Trend Analysis")
            onClicked: {
                loader.sourceComponent = trendComponent
            }
        }

        TabButton {
            id: loadTransientButton
            text: qsTr("Load Transient")
            onClicked: {
                loader.sourceComponent = loadComponent
            }
        }

        TabButton {
            id: messagesButton
            text: qsTr("Core Messages")
            onClicked: {
                loader.sourceComponent = coreComponent
            }
        }
    }

    Item {
        anchors {
            top: navTabs.bottom
            bottom: controlNavigation.bottom
            right: controlNavigation.right
            left: controlNavigation.left
        }

        Loader {
            id: loader
            width: parent.width
            height: parent.height
            sourceComponent: basicComponent
        }
    }

    Component {
        id: basicComponent

        BasicControl {
            id: basicControl
            visible: true
        }
    }

    Component {
        id: advComponent

        AdvancedControl {
            id: advancedControl
        }
    }

    Component {
        id: trendComponent

        TrendControl {
            id: trendControl
        }
    }

    Component {
        id: loadComponent

        LoadTransientControl {
            id: loadTransientControl
        }
    }

    Component {
        id: coreComponent

        CoreControl {
            id: coreControl
        }
    }

    SGIcon {
        id: helpIcon
        anchors {
            right: parent.right
            rightMargin: 20
            top: parent.top
            topMargin: 50
        }
        source: "question-circle-solid.svg"
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
                if(loader.sourceComponent === basicComponent) {
                    Help.startHelpTour("basicHelp")
                }
                else if(loader.sourceComponent === advComponent) {
                    Help.startHelpTour("advanceHelp")
                }
                else if(loader.sourceComponent === trendComponent) {
                    Help.startHelpTour("trendHelp")
                }
                else if(loader.sourceComponent === loadComponent) {
                    Help.startHelpTour("loadTransientHelp")
                }
                else if(loader.sourceComponent === coreComponent) {
                    Help.startHelpTour("coreControlHelp")
                }
                else console.log("help not available")
            }
            hoverEnabled: true
        }
    }
}
