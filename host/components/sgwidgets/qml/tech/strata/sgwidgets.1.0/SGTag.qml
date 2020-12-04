import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: control

    width: (sizeByMask ? metrics.boundingRect.width: tagText.contentWidth) + 2*horizontalPadding
    height: (sizeByMask ? metrics.boundingRect.height : tagText.contentHeight) + 2*verticalPadding

    property alias text: tagText.text
    property alias textColor: tagText.color
    property alias implicitTextColor: tagText.implicitColor
    property alias radius: tagBackground.radius
    property alias color: tagBackground.color
    property alias font: tagText.font
    property alias fontSizeMultiplier: tagText.fontSizeMultiplier
    property alias horizontalAlignment: tagText.horizontalAlignment

    property bool sizeByMask: false
    property alias mask: metrics.text

    property int horizontalPadding: 4
    property int verticalPadding: 2

    TextMetrics {
        id: metrics
        font: tagText.font
    }

    Rectangle {
        id: tagBackground
        anchors.fill: parent
        radius: 2
        color: TangoTheme.palette.butter
        visible: tagText.text.length > 0
    }

    SGWidgets.SGText {
        id: tagText
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: horizontalPadding
        }
    }
}
