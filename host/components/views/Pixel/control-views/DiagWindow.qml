import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: root
    property alias accordion: accordion

    SGAccordion {
        id: accordion
        anchors.fill: parent
        anchors.topMargin: 0

        accordionItems: Column {
            SGAccordionItem {
                id: diagInfo
                title: "<b>Diagnostic information</b>"
                open: true
                contents: DiagInfo {
                    height: text1.contentHeight + 600
                    width: parent.width


                    Text {
                        id: text1
                        anchors.fill: parent
                    }
                }
                onOpenChanged: {
                    if(open){
                        openContent.start();
                    } else {
                        closeContent.start();
                    }
                }
            }

            SGAccordionItem {
                id: diagMonitor
                title: "<b>Monitor information</b>"
                open: true
                contents: DiagMonitor {
                    height: text2.contentHeight + 700
                    width: parent.width

                    Text {
                        id: text2
                        anchors.fill: parent
                    }
                }
                onOpenChanged: {
                    if(open){
                        openContent.start();
                    } else {
                        closeContent.start();
                    }
                }
            }
        }
    }
}
