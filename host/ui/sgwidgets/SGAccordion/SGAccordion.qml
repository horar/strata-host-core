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

    property string dividerColor: "#dddddd"
    property int dividerHeight: 1
    property int openCloseTime: 0
    property string statusIcon: "\u25B2"
    property string textColor: "#000000"
    property string bodyColor: "#ffffff"
    property string headerOpenColorTop: "#dbeffc"
    property string headerOpenColorBottom: "#bcdcf2"
    property string headerClosedColorTop: "#fcfcfc"
    property string headerClosedColorBottom: "#f1f1f1"

    // Loads user defined AccordionItems
    Loader {
        id: accordionItems
        width: scrollContainer.width

        // Passthrough properties so AccordionItems can get these
        property real scrollContainerWidth: scrollContainer.width
        property string accordionDividerColor: dividerColor
        property int accordionDividerHeight: dividerHeight
        property int accordionOpenCloseTime: openCloseTime
        property string accordionStatusIcon: statusIcon
        property string accordionTextColor: textColor
        property string accordionBodyColor: bodyColor
        property string accordionHeaderOpenColorTop: headerOpenColorTop
        property string accordionHeaderOpenColorBottom: headerOpenColorBottom
        property string accordionHeaderClosedColorTop: headerClosedColorTop
        property string accordionHeaderClosedColorBottom: headerClosedColorBottom
    }
}


