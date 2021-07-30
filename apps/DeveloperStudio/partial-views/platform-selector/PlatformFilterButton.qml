import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/platform_filters.js" as PlatformFilters

Item {
    id: root
    implicitHeight: iconContainer.implicitHeight
    implicitWidth: Math.min(iconContainer.width + (textColumn.anchors.margins * 2) + textMetrics.wideWidth, flow.width)

    onYChanged: {
        if (parent === flow) {
            model.row = Math.ceil(y/(segmentCategoryList.delegateHeight + flow.spacing))
        }
    }

    Rectangle {
        id: textArea
        color: Theme.palette.green
        height: 30
        anchors {
            verticalCenter: parent.verticalCenter
            left: iconContainer.horizontalCenter
            right: parent.right
        }
        radius: 5
    }

    Rectangle {
        id: iconContainer
        color: "black"
        radius: implicitHeight/2
        implicitHeight: segmentCategoryList.delegateHeight
        implicitWidth: implicitHeight

        SGIcon {
            source: model.iconSource
            implicitHeight: iconContainer.height * .8
            implicitWidth: implicitHeight
            iconColor: "white"
            anchors {
                centerIn: parent
            }
        }
    }

    ColumnLayout {
        id: textColumn
        anchors {
            verticalCenter: textArea.verticalCenter
            left: iconContainer.right
            right: textArea.right
            margins: 5
        }
        spacing: 1

        SGText {
            id: mainText
            text: model.text
            elide: Text.ElideRight
            Layout.fillWidth: true
            font.underline: filterLinkMouse.containsMouse
            color: "white"
            fontSizeMultiplier: .9

            MouseArea {
                id: filterLinkMouse
                anchors {
                    fill: parent
                }
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked:  {
                    PlatformFilters.setFilterActive(model.filterName, true)
                }

                ToolTip {
                    delay: 1000
                    visible: parent.containsMouse
                    text: {
                        if (model.type === "category") {
                            return "Filter platforms in this category"
                        } else {
                            return "Filter platforms in this Segment"
                        }
                    }
                }
            }

            TextMetrics {
                id: textMetrics
                text: model.text
                font: mainText.font

                property real wideWidth: width + 5 // +5 to make sure elide isn't prematurely applied due to rounding
            }
        }

        SGText {
            text: model.type
            elide: Text.ElideRight
            Layout.fillWidth: true
            fontSizeMultiplier: .5
            font.capitalization: Font.AllUppercase
            color: "white"
        }
    }
}
