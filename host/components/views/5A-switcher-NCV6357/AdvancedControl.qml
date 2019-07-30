import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help


Rectangle {
    id: root

    property bool debugLayout: false
    anchors.fill: parent

    Component.onCompleted: {
        platformInterface.read_initial_status.update()
    }

    Telemetry {
        id: overview
        height: 350

        SGLayoutDivider {
            position: "bottom"
        }
    }

    SGAccordion {
        id: settingsAccordion
        anchors {
            top: overview.bottom
            bottom: root.bottom
        }
        width: root.width
        //scrollBarPolicy: ScrollBar.AlwaysOn
        accordionItems: Column {
            SGAccordionItem {
                id: systemSettings
                title: "<b>System Settings</b>"
                open: true
                contents: SystemSettings { }
            }

            SGAccordionItem {
                id: miscellanesous
                title: "<b>Miscellaneous</b>"
                open: false
                contents: TimeAndWarningSettings { }
            }

            SGAccordionItem {
                id: diagnotics
                title: "<b>Diagnostics</b>"
                open: false
                contents: Diagnotics { }

            }
        }
    }
}
