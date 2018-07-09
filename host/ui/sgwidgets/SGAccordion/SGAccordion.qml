import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls 2.2

// SGAccordion is a vertically scrollable accordion with expandable dropdown SGAccordionItems

ScrollView {
    id: scrollContainer
    contentWidth: width
    contentHeight: accordionItems.height
    implicitHeight: 200
    implicitWidth: 200
    clip: true

    property alias accordionItems : accordionItems.sourceComponent

    property color dividerColor: "#dddddd"
    property int dividerHeight: 1
    property int openCloseTime: 0
    property string statusIcon: "\u25B2"
    property color textColor: "#000000"
    property color bodyColor: "#ffffff"
    property color headerOpenColorTop: "#dbeffc"
    property color headerOpenColorBottom: "#bcdcf2"
    property color headerClosedColorTop: "#fcfcfc"
    property color headerClosedColorBottom: "#f1f1f1"

    // Loads user defined AccordionItems
    Loader {
        id: accordionItems
        width: scrollContainer.width

        // Passthrough properties so AccordionItems can get these
        property real scrollContainerWidth: scrollContainer.width
        property color accordionDividerColor: dividerColor
        property int accordionDividerHeight: dividerHeight
        property int accordionOpenCloseTime: openCloseTime
        property string accordionStatusIcon: statusIcon
        property color accordionTextColor: textColor
        property color accordionBodyColor: bodyColor
        property color accordionHeaderOpenColorTop: headerOpenColorTop
        property color accordionHeaderOpenColorBottom: headerOpenColorBottom
        property color accordionHeaderClosedColorTop: headerClosedColorTop
        property color accordionHeaderClosedColorBottom: headerClosedColorBottom
    }
}


