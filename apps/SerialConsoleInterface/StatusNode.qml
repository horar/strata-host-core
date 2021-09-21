/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: statusNode

    width: childrenRect.width
    height: childrenRect.height

    property alias text: nodeText.text
    property alias subText: nodeSubtext.text
    property bool highlight: false

    property int nodeState: StatusNode.NotSet

    property bool isFirst: false
    property bool isFinal: false
    property bool isLast: isFinal
    property int offset: 0
    property int baseNodeDiameter: 24
    property int highlightAddition: 6
    property int highlightEnlargeAddition: highlightAddition + 16
    property int lineWidth: 2
    property int overlap: highlightEnlargeAddition + 1
    property color color: "#555555"
    property color highlightColor: "black"
    property url succeedIcon: "qrc:/sgimages/check.svg"
    property url failedIcon: "qrc:/sgimages/times.svg"

    enum FinishState {
        NotSet,
        Succeed,
        SucceedWithWarning,
        Failed
    }

    TextMetrics {
        id: textMetrics
        text: "base text "
    }

    Rectangle {
        id: topLine
        width: lineWidth
        height: visible ? offset + overlap : 0
        anchors {
            horizontalCenter: nodeWrapper.horizontalCenter
        }

        visible: isFirst === false
        color: statusNode.color
    }

    Rectangle {
        id: bottomLine
        width: lineWidth
        height: visible ? offset + overlap : 0
        anchors {
            horizontalCenter: nodeWrapper.horizontalCenter
            top: nodeWrapper.bottom
            topMargin: -overlap
        }

        visible: isLast === false
        color: statusNode.color
    }

    Item {
        id: nodeWrapper
        anchors {
            left: parent.left
            top: topLine.bottom
            topMargin: topLine.visible ? -overlap : 0
        }

        width: baseNodeDiameter + highlightEnlargeAddition
        height: width

        Rectangle {
            id: node
            anchors.centerIn: parent
            width: {
                var w = baseNodeDiameter
                if (highlight) {
                    if (isFinal) {
                        w += highlightEnlargeAddition
                    } else {
                        w += highlightAddition
                    }
                }

                return w
            }
            height: width

            radius: Math.round(width/2)
            border.width: lineWidth
            border.color: highlight ? statusNode.highlightColor : statusNode.color

            color: "white"

            Rectangle {
                id: filling
                anchors.centerIn: parent
                width: parent.width - lineWidth - 4
                height: width
                radius: Math.round(width/2)
                color: {
                    if (nodeState === StatusNode.Succeed) {
                        return Theme.palette.green
                    } else if (nodeState === StatusNode.Failed) {
                        return TangoTheme.palette.error
                    } else if (nodeState === StatusNode.SucceedWithWarning) {
                        return TangoTheme.palette.warning
                    }

                    return "transparent"
                }
                visible: isFinal
            }

            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: baseNodeDiameter - lineWidth - 12 + (highlight ? highlightAddition : 0)
                height: width
                radius: Math.round(width/2)
                color: {
                    if (highlight) {
                        return statusNode.highlightColor
                    }
                    return statusNode.color
                }
                visible: nodeState === StatusNode.NotSet
            }

            SGWidgets.SGIcon {
                id: statusIcon
                anchors.centerIn: parent
                width: Math.round(parent.width*0.6) - lineWidth
                height: width

                iconColor: {
                    if (isFinal) {
                        return "white"
                    } else if (nodeState === StatusNode.Succeed) {
                        return Theme.palette.green
                    } else if (nodeState === StatusNode.SucceedWithWarning) {
                        return TangoTheme.palette.warning
                    } else if (nodeState === StatusNode.Failed) {
                        return TangoTheme.palette.error
                    }

                    return "grey"
                }

                source: {
                    if (nodeState === StatusNode.Succeed || nodeState === StatusNode.SucceedWithWarning) {
                        return succeedIcon
                    } else if (nodeState === StatusNode.Failed) {
                        return failedIcon
                    }

                    return ""
                }
            }
        }
    }

    Column {
        anchors {
            left: nodeWrapper.right
            leftMargin: 4
            verticalCenter: nodeWrapper.verticalCenter
        }

        SGWidgets.SGText {
            id: nodeText
            font.bold: statusNode.highlight
            fontSizeMultiplier: statusNode.highlight ? 1.4 : 1.2
        }

        SGWidgets.SGTag {
            id: nodeSubtext
            color: nodeState === StatusNode.Failed && isFinal === false ? TangoTheme.palette.error : "transparent"
            textColor: nodeState === StatusNode.Failed && isFinal === false ? "white" : "black"
            visible: text.length > 0
            verticalPadding: 2
            horizontalPadding: isFinal ? 0 : 2
            font.bold: nodeState === StatusNode.Failed && isFinal === false
        }
    }
}
