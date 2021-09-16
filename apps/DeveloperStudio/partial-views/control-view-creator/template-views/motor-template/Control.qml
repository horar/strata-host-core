import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.sgwidgets 1.0
import "control-views"

Item {
    id: controlViewRoot
    property string class_id

    Component.onCompleted: {

        // ------------------------ Help Messages ------------------------ //
        Help.registerTarget(tabBar, "Use these tabs to navigate between other views. The Advanced view is disabled by default.", 0, "BasicControlHelp")
        
    }

    RowLayout {
        
        anchors.fill: parent
        spacing: 0

        PlatformInterface {
            id: platformInterface
        }

        SideBar {
            id: sideBar
        }

        ColumnLayout {
            spacing: 0

            TabBar {
                id: tabBar
                Layout.fillWidth: true

                TabButton {
                    id: basicTab
                    text: "Basic"
                }

                TabButton {
                    id: advancedTab
                    text: "Advanced"
                    enabled: false
                }

            }

            StackLayout {
                currentIndex: tabBar.currentIndex

                Basic {
                    id: basic
                }

                Advanced {
                    id: advanced
                }
            }
        }        
    }

    // Enabled or disable Advanced view tab
    // {"notification":{"value":"advanced_view_tab","payload":{"value":false}}}
    Connections {
        target: platformInterface.notifications.advanced_view_tab
        onNotificationFinished: {
            advancedTab.enabled = platformInterface.notifications.advanced_view_tab.value
            if (advancedTab.enabled === false) {
                tabBar.currentIndex = 0
            }
            
        }
    }

}