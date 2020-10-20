import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

// SGAccordion is a vertically scrollable accordion with expandable dropdown SGAccordionItems
Item {
    id: root
    implicitHeight: 300
    implicitWidth: 300

    property alias accordionItems : accordionItems.sourceComponent

    property int openCloseTime: 80
    property string statusIcon: "\u25B2"
    property color contentsColor: "#fff"
    property color textOpenColor: "#fff"
    property color textClosedColor: "#000"
    property color headerOpenColor: "#666"
    property color headerClosedColor: "#eee"
    property color dividerColor: "#fff"
    property int scrollBarPolicy: ScrollBar.AlwaysOn

    ScrollView {
        id: scrollContainer
        height: root.height
        width: root.width
        contentWidth: width
        contentHeight: accordionItems.height
        clip: true
        ScrollBar.vertical.policy: scrollBarPolicy

        // Loads user defined AccordionItems
        Loader {
            id: accordionItems
            width: scrollContainer.width

            // Passthrough properties so AccordionItems can get these
            property real scrollContainerWidth: scrollContainer.width
            property int accordionOpenCloseTime: openCloseTime
            property string accordionStatusIcon: statusIcon
            property color accordionTextOpenColor: textOpenColor
            property color accordionTextClosedColor: textClosedColor
            property color accordionContentsColor: contentsColor
            property color accordionHeaderOpenColor: headerOpenColor
            property color accordionHeaderClosedColor: headerClosedColor
            property color accordionDividerColor: dividerColor
        }
    }
}
