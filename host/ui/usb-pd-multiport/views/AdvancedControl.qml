import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/advanced-partial-views"

Item {
    id: root

    property bool debugLayout: false

    anchors {
        fill: parent
    }

    Overview {
        id: overview
        height: 310

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

        accordionItems: Column {
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
                    portNumber: 1
                }
            }

            SGAccordionItem {
                title: "<b>Port 2</b>"
                open: true
                contents: Port {
                    portNumber: 2
                }
            }

            SGAccordionItem {
                title: "<b>Port 3</b>"
                open: true
                contents: Port {
                    portNumber: 3
                }
            }

            SGAccordionItem {
                title: "<b>Port 4</b>"
                open: true
                contents: Port {
                    portNumber: 4
                    portConnected: false
                }
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
