import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: root

    SGAccordion {
        id: accordion
        anchors.fill: parent
        anchors.topMargin: 0

        accordionItems: Column {
            SGAccordionItem {
                id: diagpxnInfo
                title: "<b>Pixel diagnostic information</b>"
                open: true
                contents: DiagPxnInfo {
                    height: text1.contentHeight + 600
                    width: parent.width


                    Text {
                        id: text1
                        anchors.fill: parent
                    }
                }
            }

//            SGAccordionItem {
//                id: diagMonitor
//                title: "<b>Monitor information</b>"
//                open: true
//                contents: DiagMonitor {
//                    height: text2.contentHeight + 700
//                    width: parent.width

//                    Text {
//                        id: text2
//                        anchors.fill: parent
//                    }
//                }
//            }
        }
    }
}
