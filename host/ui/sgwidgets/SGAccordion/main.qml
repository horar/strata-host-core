import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("SGAccordion 2")

    SGAccordion {
        anchors {
            fill: parent
        }

        // Optional Configuration:
        openCloseTime: 80           // Default: 80 (how fast the sliders pop open)
        statusIcon: "\u25B2"        // Default: "\u25B2" (triangle char)
        contentsColor: "#fff"       // Default: "white"
        textOpenColor: "#fff"       // Default: "white"
        textClosedColor: "#000"     // Default: "black"
        headerOpenColor: "#666"     // Default: "#666" (dark gray)
        headerClosedColor: "#eee"   // Default: "#eee" (light gray)
        dividerColor: "#fff"        // Default: "#fff" (white)

        accordionItems: Column {
            SGAccordionItem {

                // Optional Configuration for individual accordionItems:
                title: "This is a Title"

                contents: Item {
                    height: text.contentHeight + 20
                    width: parent.width

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
