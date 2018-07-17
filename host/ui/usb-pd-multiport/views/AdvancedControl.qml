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
                contents: SystemSettings {
                    //
                }
            }

            SGAccordionItem {
                title: "<b>Port 1</b>"
                open: true
                contents: Port {
                    portNumber: 1
                    portColor: "#30a2db"
                }
            }

//            SGAccordionItem {
//                title: "<b>Port 2</b>"
//                open: true
//                contents: SGPopout {
//                    id: popout3
//                    title: "Popout 3"
////                    overlaycolor: "lightgreen"
//                    unpoppedWidth: parent.width
////                    unpoppedHeight:
//                    content: Port {
//                        portNumber: 2
//                        portColor: "#3bb539"
//                    }
//                }
//            }

            SGAccordionItem {
                title: "<b>Port 2</b>"
                open: true
                contents: Port {
                    portNumber: 2
                    portColor: "#3bb539"
                }
            }

            SGAccordionItem {
                title: "<b>Port 3</b>"
                open: true
                contents: Port {
                    portNumber: 3
                    portColor: "#d68f14"
                }
            }

            SGAccordionItem {
                title: "<b>Port 4</b>"
                open: true
                contents: Port {
                    portNumber: 4
                    portConnected: false
                    portColor: "#2348cd"
                }
            }
        }

        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
