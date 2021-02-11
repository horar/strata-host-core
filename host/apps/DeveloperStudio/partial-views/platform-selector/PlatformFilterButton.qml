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
    Layout.fillWidth: true

    Rectangle {
        id: iconContainer
        color: "black"
        radius: implicitHeight/2
        implicitHeight: 35
        implicitWidth: implicitHeight
        z:1

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

    Rectangle {
        color: Theme.palette.green
        height: 30
        width: Math.min(textColumn.implicitWidth + (iconContainer.width / 2) + 10, root.width - (iconContainer.width / 2))
        anchors {
            verticalCenter: parent.verticalCenter
            left: iconContainer.horizontalCenter
        }
        radius: 5

        ColumnLayout {
            id: textColumn
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
                leftMargin: (iconContainer.width / 2) + 5
            }
            width: parent.width - 10 - (iconContainer.width / 2)
            spacing: 1

            SGText {
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
}
