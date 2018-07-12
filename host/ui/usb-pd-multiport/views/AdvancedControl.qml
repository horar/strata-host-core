import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/advanced-partial-views"

Item {
    id: root

    property bool debugLayout: false

    anchors {
        fill: parent
    }

    Item {
        id: leftColumn
        height: parent.height
        width: 400

        SGAccordion {
            id: settingsAccordion
            anchors {
                left: leftColumn.left
                right: leftColumn.right
                top: leftColumn.top
            }
            height: leftColumn.height * 0.75

            accordionItems: Column {
                SGAccordionItem {
                    title: "System Settings"
                    open: true
                    contents: SystemSettings {
                        //
                    }
                }

                SGAccordionItem {
                    title: "Port 1 Settings"
                    open: true
                    contents: PortSettings {
                        //
                    }
                }

                SGAccordionItem {
                    title: "Port 2 Settings"
                    contents: PortSettings {
                        //
                    }
                }

                SGAccordionItem {
                    title: "Port 3 Settings"
                    contents: PortSettings {
                        //
                    }
                }

                SGAccordionItem {
                    title: "Port 4 Settings"
                    contents: PortSettings {
                        //
                    }
                }
            }

            SGLayoutDebug {
                visible: debugLayout
            }


            SGDivider {
                placement: "bottom"
            }
        }

        Item {
            id: messagesContainer
            anchors {
                top: settingsAccordion.bottom
                left: leftColumn.left
                right: leftColumn.right
                bottom: leftColumn.bottom
            }



            SGLayoutDebug {
                visible: debugLayout
            }
        }

        SGDivider {
            placement: "right"
        }
    }

    Item {
        id: rightColumn
        anchors {
            left: leftColumn.right
            right: root.right
            top: root.top
            bottom: root.bottom
        }


        SGLayoutDebug {
            visible: debugLayout
        }
    }
}
