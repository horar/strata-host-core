import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    PlatformInterface {
        id: platformInterface
    }

    RowLayout {
        anchors {
            fill: parent
        }
        spacing: 0

        SideBar {
            id: sideBar
        }

        ColumnLayout {
            spacing: 0

            TabBar {
                id: navTabs
                Layout.fillWidth: true

                TabButton {
                    id: basicButton
                    text: qsTr("Basic")
                }

                TabButton {
                    id: advancedButton
                    text: qsTr("Advanced")
                }
            }

            Loader {
                Layout.fillHeight: true
                Layout.fillWidth: true
                
                source: {
                    switch (navTabs.currentIndex) {
                        case 0:
                            return "qrc:/control-views/BasicControl.qml"
                        case 1:
                            return "qrc:/control-views/AdvancedControl.qml"
                    }
                }
            }
        }
    }
}
