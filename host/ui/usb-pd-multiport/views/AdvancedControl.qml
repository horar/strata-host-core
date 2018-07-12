import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/advanced-partial-views"

Item {
    id: root

    property bool debugLayout: false

    anchors {
        fill: parent
    }

    SGAccordion {
        id: settingsAccordion
        anchors {
            fill: root
        }

        accordionItems: Column {
            SGAccordionItem {
                title: "<b>Overview</b>"
                open: false
                contents: Item {}
            }

            SGAccordionItem {
                title: "<b>System Settings</b>"
                open: true
                contents: System {
                    //
                }
            }

            SGAccordionItem {
                title: "<b>Port 1</b>"
                open: true
                contents: Port {
                    //
                }
            }

            SGAccordionItem {
                title: "<b>Port 2</b>"
                contents: Port {
                    //
                }
            }

            SGAccordionItem {
                title: "<b>Port 3</b>"
                contents: Port {
                    //
                }
            }

            SGAccordionItem {
                title: "<b>Port 4</b>"
                contents: Port {
                    //
                }
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
