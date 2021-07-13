import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: control
    width: content.width + 2*horizontalPadding
    height: content.height + 2*verticalPadding

    property alias text: tagText.text
    property alias textColor: tagText.color
    property alias implicitTextColor: tagText.implicitColor
    property alias radius: tagBackground.radius
    property alias color: tagBackground.color
    property alias font: tagText.font
    property alias fontSizeMultiplier: tagText.fontSizeMultiplier
    property alias horizontalAlignment: tagText.horizontalAlignment
    property alias iconSource: tagIcon.source
    property alias iconColor: tagIcon.iconColor

    property bool sizeByMask: false
    property alias mask: metrics.text

    property int horizontalPadding: 4
    property int verticalPadding: 2
    property int spacing: 2

    TextMetrics {
        id: metrics
        font: tagText.font
    }

    Rectangle {
        id: tagBackground
        anchors.fill: parent
        radius: 2
        color: TangoTheme.palette.butter1
        visible: tagText.text.length > 0
    }

    Row {
        id: content
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: horizontalPadding
        }

        spacing: control.spacing

        SGWidgets.SGIcon {
            id: tagIcon
            height: source.toString().length > 0 ? Math.floor(0.8 * tagTextWrapper.height) : 0
            width: height
            anchors {
                verticalCenter: parent.verticalCenter
            }
        }

        Item {
            id: tagTextWrapper
            height: sizeByMask ? metrics.boundingRect.height : tagText.contentHeight
            width: sizeByMask ? metrics.boundingRect.width : tagText.contentWidth
            anchors {
                verticalCenter: parent.verticalCenter
            }

            SGWidgets.SGText {
                id: tagText
                anchors {
                    left: parent.left
                }
            }
        }
    }
}
