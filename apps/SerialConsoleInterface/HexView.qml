/*
 * Copyright (c) 2018-2022 onsemi.
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
import tech.strata.sci 1.0 as Sci

FocusScope {
    id: hexView

    width: verticalScrollbar.x + verticalScrollbar.width

    property alias content: hexModel.content
    property int bytesInRow: 8
    property int currentIndex
    property int currentRow: Math.floor(currentIndex / bytesInRow)
    property int cellHeigh: Math.round(textMetrics.height) + 4
    property int digitCellWidth: 3*Math.round(textMetrics.width) + 4
    property int charCellWidth: 1*Math.round(textMetrics.width) + 6
    property color highlightNoFocusColor: "#aaaaaa"

    property int fullDigitTextLength: {
        if (numeralSystemSelector.checkedIndices === 1) {
            return 3
        } else if (numeralSystemSelector.checkedIndices === 2) {
            return 3
        } else if (numeralSystemSelector.checkedIndices === 4) {
            return 2
        }

        return 0
    }

    onCurrentIndexChanged: {
        digitGrid.currentIndex = currentIndex
        charGrid.currentIndex = currentIndex
    }

    Sci.HexModel {
        id: hexModel

        onModelReset: {
            currentIndex = -1
        }
    }

    TextMetrics {
        id: textMetrics
        font.pixelSize: SGWidgets.SGSettings.fontPixelSize
        font.family: "monospace"
        text: "A"
    }

    Rectangle {
        anchors {
            top: digitGrid.top
            bottom: digitGrid.bottom
            left: digitGrid.left
            right: verticalScrollbar.right
        }

        color: TangoTheme.palette.componentBase

        border {
            width: 1
            color: TangoTheme.palette.componentBorder
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up) {
            digitGrid.moveCurrentIndexUp()
        } else if (event.key === Qt.Key_Down) {
            if (currentIndex < (digitGrid.count - digitGrid.count % bytesInRow)) {
                var index = Math.min(digitGrid.count - 1, currentIndex + bytesInRow)
                digitGrid.currentIndex = index
            }
        } else if (event.key === Qt.Key_Left) {
            digitGrid.moveCurrentIndexLeft()
        } else if (event.key === Qt.Key_Right) {
            digitGrid.moveCurrentIndexRight()
        } else {
            return
        }

        event.accepted = true
    }

    GridView {
        id: digitGrid
        width: bytesInRow*cellWidth + 6
        anchors {
            top: parent.top
            bottom: numeralSystemSelector.top
            bottomMargin: 4
            left: parent.left
        }

        cellWidth: hexView.digitCellWidth
        cellHeight: hexView.cellHeigh
        model: hexModel
        clip: true
        ScrollBar.vertical: verticalScrollbar
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false
        focus: true

        onCurrentIndexChanged: {
            hexView.currentIndex = currentIndex
        }

        delegate: Item {
            id: digitDelegate
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight


            property int row: Math.floor(index / bytesInRow)

            Rectangle {
                anchors.fill: parent
                color: {
                    if (digitDelegate.GridView.isCurrentItem) {
                        if (hexView.activeFocus) {
                            return TangoTheme.palette.highlight
                        } else {
                            return highlightNoFocusColor
                        }
                    }

                    return "transparent"
                }
            }

            Row {
                id: textRow
                anchors.centerIn: parent

                property string baseString: {
                    if (numeralSystemSelector.checkedIndices === 1) {
                        return model.octValue.toString().toUpperCase()
                    } else if (numeralSystemSelector.checkedIndices === 2) {
                        return model.decValue.toString().toUpperCase()
                    } else if (numeralSystemSelector.checkedIndices === 4) {
                        return model.hexValue.toString().toUpperCase()
                    }

                    return ""
                }

                SGWidgets.SGText {
                    id: paddedText

                    font.family: "monospace"
                    text: "0".repeat(Math.max(0, fullDigitTextLength - textRow.baseString.length))
                    color: baseText.color
                    opacity: 0.5
                }

                SGWidgets.SGText {
                    id: baseText

                    font.family: "monospace"
                    text: textRow.baseString
                    alternativeColorEnabled: digitDelegate.GridView.isCurrentItem
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    digitGrid.forceActiveFocus()
                    hexView.currentIndex = index
                }
            }
        }
    }

    GridView {
        id: charGrid
        width: bytesInRow*cellWidth
        height: digitGrid.height
        anchors {
            top: digitGrid.top
            left: digitGrid.right
        }

        cellWidth: hexView.charCellWidth
        cellHeight: hexView.cellHeigh
        model: hexModel
        clip: digitGrid.clip
        ScrollBar.vertical: verticalScrollbar
        boundsBehavior: digitGrid.boundsBehavior
        keyNavigationEnabled: digitGrid.keyNavigationEnabled
        focus: false

        onCurrentIndexChanged: {
            hexView.currentIndex = currentIndex
        }

        delegate: Item {
            id: charDelegate
            width: GridView.view.cellWidth
            height: GridView.view.cellHeight

            property int row: Math.floor(index / bytesInRow)
            property bool isPrint: model.charValue >= 32 && model.charValue <= 126

            Rectangle {
                anchors.fill: parent
                color: {
                    if (charDelegate.GridView.isCurrentItem) {
                        if (hexView.activeFocus) {
                            return TangoTheme.palette.highlight
                        } else {
                            return highlightNoFocusColor
                        }
                    }

                    return "transparent"
                }
            }

            Rectangle {
                id: unknownCharBg
                anchors {
                    fill: parent
                    margins: 1
                }
                color: "#dddddd"
                visible: charDelegate.isPrint === false
            }

            SGWidgets.SGIcon {
                width: parent.width - 6
                height: width
                anchors.centerIn: parent

                iconColor: TangoTheme.palette.orange2
                visible: charDelegate.isPrint === false
                source: {
                    if (model.charValue === 10) {
                        return "qrc:/images/return.svg"
                    } else {
                        return "qrc:/images/question.svg"
                    }
                }
            }

            SGWidgets.SGText {
                id: textItem
                anchors.centerIn: parent

                font.family: "monospace"
                visible: charDelegate.isPrint
                text: String.fromCharCode(model.decValue)
                alternativeColorEnabled: charDelegate.GridView.isCurrentItem
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    digitGrid.forceActiveFocus()
                    digitGrid.currentIndex = index
                }
            }
        }
    }

    SGWidgets.SGButtonStrip {
        id: numeralSystemSelector
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        model: ["8"," 10 "," 16 "]
        scaleToFit: true
        minimumButtonWidth: 3*textMetrics.width
        checkedIndices: 4
    }

    ScrollBar {
        id: verticalScrollbar
        width: 8
        anchors {
            top: charGrid.top
            bottom: charGrid.bottom
            left: charGrid.right
        }

        orientation: Qt.Vertical
        visible: digitGrid.contentHeight > digitGrid.height
        policy: ScrollBar.AlwaysOn
    }
}
