import QtQuick 2.9
import "qrc:/sgwidgets"
import "qrc:/views/advanced-partial-views"

Item {
    id: root

    property bool debugLayout: true

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

            SGAccordionItem {
            //
            }
            SGAccordionItem {
                //
            }
            SGAccordionItem {
                //
            }
            SGAccordionItem {
                //
            }
            SGAccordionItem {
                //
            }
        }

        SGLayoutDebug {
            visible: debugLayout
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
