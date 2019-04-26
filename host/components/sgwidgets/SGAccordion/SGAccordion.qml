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
    property alias contentItem: accordionItems.item

    property int openCloseTime: 80
    property string statusIcon: "\u25B2"
    property bool exclusive: false
    property color contentsColor: "#fff"
    property color textOpenColor: "#fff"
    property color textClosedColor: "#000"
    property color headerOpenColor: "#666"
    property color headerClosedColor: "#eee"
    property color dividerColor: "#fff"

    ScrollView {
        id: scrollContainer
        height: root.height
        width: root.width
        contentWidth: width
        contentHeight: accordionItems.height
        clip: true

        // Loads user defined AccordionItems
        Loader {
            id: accordionItems
            width: scrollContainer.width

            // Passthrough properties so AccordionItems can get these
            property alias scrollContainerWidth: scrollContainer.width
            property alias accordionOpenCloseTime: root.openCloseTime
            property alias accordionStatusIcon: root.statusIcon
            property alias accordionExclusive: root.exclusive
            property alias accordionTextOpenColor: root.textOpenColor
            property alias accordionTextClosedColor: root.textClosedColor
            property alias accordionContentsColor: root.contentsColor
            property alias accordionHeaderOpenColor: root.headerOpenColor
            property alias accordionHeaderClosedColor: root.headerClosedColor
            property alias accordionDividerColor: root.dividerColor
        }
    }
}
