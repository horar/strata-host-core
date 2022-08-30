/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.3
import QtQuick.Controls 2.3
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: root
    implicitHeight: root.childrenRect.height
    width: 360

    property int index: 0
    property alias description: description.text
    property real fontSizeMultiplier: 1

    signal close()
    onClose: Help.closeTour()

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus(); // focus on this to catch Keys below
        } else if (focus){
            focus = false
        }
    }

    Keys.onPressed: {
        if(event.key === Qt.Key_Escape){
            close()
            Help.closeTour()
        } else if(event.key === Qt.Key_Left){
            if (root.index > 0) {
                Help.prev(root.index)
            }
        } else if(event.key === Qt.Key_Right){
            Help.next(root.index)
        }
    }

    Keys.onTabPressed: {}
    Keys.onBacktabPressed: {}

    SGIcon {
        id: closer
        source: "qrc:/sgimages/times.svg"
        anchors {
            top: root.top
            right: root.right
            rightMargin: 2
        }
        iconColor: closerMouse.containsMouse ? "lightgrey" : "grey"
        height: 18
        width: height

        MouseArea {
            id: closerMouse
            anchors {
                fill: closer
            }
            onClicked: root.close()
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
        }
    }

    Column {
        id: column
        width: root.width

        SGText {
            id: helpText
            color:"grey"
            fontSizeMultiplier: 1.25 //* root.fontSizeMultiplier
            text: (root.index + 1) + "/" + Help.tour_count
            anchors {
                horizontalCenter: column.horizontalCenter
            }
        }

        Item {
            height: 15
            width: 15
        }

        Rectangle {
            width: root.width - 40
            height: 1
            color: "darkgrey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
        }

        Item {
            height: 15
            width: 15
        }

        SGTextEdit {
            id: description
            text: "Placeholder Text"
            width: root.width - 20
            color: "grey"
            anchors {
                horizontalCenter: column.horizontalCenter
            }
            readOnly: true
            wrapMode: TextEdit.Wrap
            fontSizeMultiplier: root.fontSizeMultiplier
        }

        Item {
            height: 15
            width: 15
        }

        Row {
            anchors {
                horizontalCenter: column.horizontalCenter
            }

            Button {
                id: prevButton
                text: "Prev"
                onClicked: {
                    Help.prev(root.index)
                }
                enabled: root.index !== 0

                property bool showToolTip: false

                onHoveredChanged: {
                    if (prevButton.enabled){
                        if (hovered) {
                            prevButtonTimer.start()
                        } else {
                            prevButton.showToolTip = false; prevButtonTimer.stop();
                        }
                    }
                }

                Timer {
                    id: prevButtonTimer
                    interval: 500
                    onTriggered: prevButton.showToolTip = true;
                }

                ToolTip {
                    text: "Hotkey: ←"
                    visible: prevButton.showToolTip
                }

                MouseArea {
                    id: buttonCursor
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }
            }

            Item {
                height: 15
                width: 15
            }

            Button {
                id: nextButton
                text: (root.index + 1) === Help.tour_count ? "End Tour" : "Next"

                property bool showToolTip: false

                onClicked: {
                    Help.next(root.index)
                }

                onHoveredChanged: {
                    if (hovered) {
                        nextButtonTimer.start()
                    } else {
                        nextButton.showToolTip = false; nextButtonTimer.stop();
                    }
                }

                Timer {
                    id: nextButtonTimer
                    interval: 500
                    onTriggered: nextButton.showToolTip = true;
                }

                ToolTip {
                    text: "Hotkey: →"
                    visible: nextButton.showToolTip
                }

                MouseArea {
                    id: buttonCursor1
                    anchors.fill: parent
                    onPressed:  mouse.accepted = false
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
