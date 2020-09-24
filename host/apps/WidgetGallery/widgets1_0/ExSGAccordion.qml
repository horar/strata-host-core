import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import tech.strata.fonts 1.0

Rectangle {
    width: 500
    height: 200
    color: "transparent"

    SGAccordion {
        id: accordion
        anchors.fill: parent

        // Optional Configuration:
        openCloseTime: 80           // Default: 80 (how fast the sliders pop open)
        statusIcon: "\u25B2"        // Default: "\u25B2" (triangle char)
        contentsColor: "#fff"       // Default: "white"
        textOpenColor: "#fff"       // Default: "white"
        textClosedColor: "#000"     // Default: "black"
        headerOpenColor: "#666"     // Default: "#666" (dark gray)
        headerClosedColor: "#eee"   // Default: "#eee" (light gray)
        dividerColor: "#fff"        // Default: "#fff" (white)
        exclusive: false            // Default: false (indicates whether only 1 or many accordionItems can be open)

        accordionItems: Column {
            property alias accordionItemAlias: accordionItem

            SGAccordionItem {
                id: accordionItem
                // Optional Configuration for individual accordionItems:
                title: "Default SGAccordion"
                open: true

                contents: Item {
                    height: text.contentHeight + 20
                    width: parent.width
                    property alias accordionItemText: text

                    Text {
                        id: text
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: parent.width - 20
                        wrapMode: Text.WordWrap
                        text: qsTr("This is an example of a text-only accordion element with 10 px margins around the text box.")
                    }
                }

                // Useful signals:
                onOpenChanged: { console.log(open ? "open" : "closed") }
            }

            SGAccordionItem {
                contents: Switch{ } // This switch is an example of containing a widget
            }
        }
    }

}
