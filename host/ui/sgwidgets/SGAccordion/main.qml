import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

// A few example SGAccordion usages in a segmented window.

Window {
    id: mainWindow
    visible: true
    width: 500
    height: 480

    // Custom styled Accordion with demo and default values for SGAccordion and SGAccordionItem
    SGAccordion {
        id: accordion1
        width: mainWindow.width/2 // Required
        height: mainWindow.height // Required

        // Accordion optional settings:
        openCloseTime: 100              // default: 0 (instant open/closed)
        statusIcon: "^"                 // default: "\u25B2"
        textColor: "#000000"            // default: "#000000" (black)
        bodyColor: "#edf7ff"            // default: "#ffffff" (white)
        dividerColor: "#000000"         // default: "#dddddd" (grey)
        dividerHeight: 1                // default: 1 (0 for no divider between SGAccordionItems)
        headerOpenColorTop: "#eafffb"   // default: "#dbeffc" (light blue)
        headerOpenColorBottom: "#c0e0db"   // default: "#bcdcf2" (darker blue)
        headerClosedColorTop: "#ffffff" // default: "#fcfcfc" (light grey)
        headerClosedColorBottom: "#f9f9f9" // default: "#f1f1f1" (darker grey)

        // accordionItems contains a ColumnLayout as a container for SGAccordionItems
        accordionItems:   ColumnLayout { // must have ColumnLayout as container since loader works only with single widgets
            spacing: 0

            SGAccordionItem {
                // SGAccordionItem settings:
                title: "Custom Accordion Style 1"
                open: true

                // SGAccordionItem optional settings: (these default to the Accordion's settings but can be overridden per AccordionItem)
//                openCloseTime:
//                statusIcon:
//                textColor:
//                bodyColor:
//                dividerColor:
//                dividerHeight:
//                headerOpenColorTop:
//                headerOpenColorBottom:
//                headerClosedColorTop:
//                headerClosedColorBottom:

                // body contains SGAccordionItem content
                body: Item {  // must have some Item as container for multiple widgets since loader only works with single widgets
                    height: childrenRect.height

                    Text {
                        id: text1
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }

                    Text {
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        anchors.top: text1.bottom
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("DUMMY TEXT 2, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "Default Accordion Style 1"

                body: Item{
                    height: childrenRect.height

                    Text {
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }
                }
            }
        }
    }

    // Default styled Accordion and SGAccordionItems
    SGAccordion {
        id: accordion2
        width: mainWindow.width/2  // Required
        height: mainWindow.height  // Required
        x: (mainWindow.width/2)+1

        // accordionItems contains a ColumnLayout as a container for SGAccordionItems
        accordionItems:   ColumnLayout { // must have ColumnLayout as container since loader works only with single widgets
            spacing: 0

            SGAccordionItem {
                title: "Default Accordion Style 1"
                open: true

                // body contains SGAccordionItem content
                body: Item {  // must have some Item as container for multiple widgets since loader only works with single widgets
                    height: childrenRect.height

                    Text {
                        id: text21
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }

                    Text {
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        anchors.top: text21.bottom
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("DUMMY TEXT 2, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }
                }
            }

            SGAccordionItem {
                open: false
                title: "Default Accordion Style 1"

                body: Item{
                    height: childrenRect.height

                    Text {
                        height: contentHeight + topPadding + bottomPadding
                        width: parent.width
                        z: 1
                        padding: 10
                        wrapMode: Text.WordWrap
                        text: qsTr("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur nec enim non tellus tincidunt iaculis. Suspendisse at aliquet nulla. Vivamus a metus malesuada, finibus odio a.")
                    }
                }
            }
        }
    }

    Rectangle{
        id: verticalDivider
        width:1
        color:"black"
        height: mainWindow.height
        x: mainWindow.width/2
    }

//    Window {
//        id: debug
//        visible: true
//        width: 400
//        height: 250
//        x:2000
//        y:500
//        Text{
//            text: "accordion2 width: " + accordion2.width
//                  + "\naccordionflickable width: " + accordion2.children[0].width
//                  + "\naccordionquickitem width: " + accordion2.children[0].children[0].width
//                  + "\naccColumnLayout width: " + accordion2.children[0].children[0].children[0].width
//                  + "\naccItemLoader width: " + accordion2.children[0].children[0].children[0].children[0].width
//                  + "\naccordionitem width: " + accordion2.children[0].children[0].children[0].children[0].children[0].width
//                  + "\n\naccordionitem height: " + accordion2.children[0].children[0].children[0].children[0].children[0].height
//                  + "\naccordionitem height: " + accordion2.children[0].children[0].children[0].children[0].children[0].children[1].children[0].children[0].children[0].height
//            + "\naccordionitem height: " + accordion2.children[0].children[0].children[0].children[0].children[0].children[1].children[0].children[0].children[1].height;
//        }
//    }
}
