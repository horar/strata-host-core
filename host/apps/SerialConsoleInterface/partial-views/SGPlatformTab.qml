import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Controls.impl 2.3
import "qrc:/partial-views/"

import fonts 1.0

TabButton {
    id: control
    width: Math.min(implicitWidth, tabBar.width/tabBar.count) // makes buttons not expand to fill tabBar
    text: platformInterface.platformList[boardId].name
    property string boardId: "default"
    property var content
    property int tabNumber
    property alias tabImage: tabImage

    implicitWidth: Math.min(200, Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding))
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             contentItem.implicitHeight + topPadding + bottomPadding)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 6
    rightPadding: tabBar.height * 0.75 + padding * 2
    spacing: 6

    hoverEnabled: tabBar.count > 1 // can't close if this is only tab in bar
    onHoveredChanged: {
        if (hovered) {
            tabImage.opacity = 0
        } else {
            tabImage.opacity = 1
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        color: checked ? control.palette.windowText : control.palette.brightText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        id: backgroundRect
        implicitHeight: tabBar.height
        implicitWidth: 130
        color: control.checked ? control.palette.window : "#444"

        Rectangle {
            id: closer
            color: backgroundRect.color
            width: backgroundRect.height * 0.75
            height: width
            anchors {
                verticalCenter: backgroundRect.verticalCenter
                right: backgroundRect.right
                rightMargin: backgroundRect.height * 0.125
            }

            Text {
                id: closerIcon
                text: "\ue805"
                anchors {
                    centerIn: closer
                }
                font {
                    family: Fonts.sgicons
                    pixelSize: 20
                }
                color: "lightgrey"
            }

            MouseArea {
                id: closerHoverClick
                hoverEnabled: true
                anchors {
                    fill: closer
                }
                enabled: control.hoverEnabled // can't close if this is only tab in bar

                onClicked: {
                    content.destroy()
                    tabBar.removeItem(control)
                    delete platformInterface.platformList[boardId]
                }

                onEntered: closerIcon.color = "grey"
                onExited: closerIcon.color = "lightgrey"
            }

            SGStatusLight {
                id: tabImage
                lightSize: closer.height
                anchors {
                    top: closer.top
                    right: closer.right
                }
                status: "red" // platformInterface.platformList[boardId].connected ? "green" : "red"  // signal doesn't fire for this (?)

                Connections {   // Hacky solution for above
                    target: platformInterface
                    onStatusImageUpdate: {
                        // continue if platform matches this particular tab
                        if (platformInterface.platformList[boardId].tabNumber === tabNumber) {
                            tabImage.status = platformInterface.platformList[boardId].connected ? "green" : "red"
                        }
                    }
                }

                Behavior on opacity {
                    PropertyAnimation {
                        duration: 50
                    }
                }
            }
        }
    }
}
