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
import tech.strata.commoncpp 1.0 as CommonCpp

FocusScope {
    id: messageQueueView

    property int baseSpacing: 16
    property int contentSpacing: 8
    property int delegateBaseSpacing: 4
    property QtObject messageQueueModel

    SGWidgets.SGText {
        id: dummyNumberText
        visible: false
        text: "#0".repeat(queueListView.count.toString().length)
        font.family: "monospace"
    }

    FocusScope {
        id: content
        anchors {
            fill: parent
            margins: baseSpacing
        }

        SGWidgets.SGText {
            id: titleText
            anchors {
                top: parent.top
                left: parent.left
            }

            text: "Message Queue"
            fontSizeMultiplier: 2.0
            font.bold: true
        }

        Rectangle {
            id: queueListViewBg
            anchors {
                top: titleText.bottom
                topMargin: contentSpacing
                bottom: btnBack.top
                bottomMargin: contentSpacing
                left: parent.left
                right: parent.right
            }

            color: TangoTheme.palette.componentBase
            border {
                width: 1
                color: TangoTheme.palette.componentBorder
            }
        }

        ListView {
            id: queueListView
            anchors {
                fill: queueListViewBg
                margins: 1
            }

            model: messageQueueModel
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                id: verticalScrollbar
                anchors {
                    right: queueListView.right
                    rightMargin: 0
                }
                width: visible ? 8 : 0

                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: queueListView.height < queueListView.contentHeight
                Behavior on width { NumberAnimation {}}
            }

            delegate: Item {
                id: delegate
                width: ListView.view.width
                height: divider.y + divider.height

                property color helperTextColor: "#333333"
                property bool isHighlighted: delegateMouseArea.containsMouse
                                           || btnShiftUp.hovered
                                           || btnShiftDown.hovered
                                           || btnRemove.hovered

                CommonCpp.SGJsonSyntaxHighlighter {
                    textDocument: model.isJsonValid ? messageText.textDocument : null
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Rectangle {
                    anchors.fill: parent
                    color: {
                        if (delegate.isHighlighted) {
                            return Qt.lighter(TangoTheme.palette.highlight, 1.9)
                        }

                        return "transparent"
                    }
                }

                SGWidgets.SGText {
                    id: numberText
                    width: dummyNumberText.width
                    anchors {
                        top: parent.top
                        topMargin: delegateBaseSpacing
                        left: parent.left
                        leftMargin: delegateBaseSpacing
                    }

                    text: "#"+ (index + 1)
                    horizontalAlignment: Text.AlignLeft
                    fontSizeMultiplier: dummyNumberText.fontSizeMultiplier
                    font.family: dummyNumberText.font.family
                    color: delegate.helperTextColor
                }

                SGWidgets.SGTextEdit {
                    id: messageText
                    anchors {
                        top: numberText.top
                        left: numberText.right
                        leftMargin: 3*delegateBaseSpacing
                        right: rightButtonRow.left
                        rightMargin: delegateBaseSpacing
                    }

                    textFormat: Text.PlainText
                    enabled: false
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    text: model.expandedMessage
                }

                Row {
                    id: rightButtonRow
                    anchors {
                        top: numberText.top
                        right: parent.right
                        rightMargin: delegateBaseSpacing + verticalScrollbar.width
                    }

                    spacing: 6

                    SGWidgets.SGIconButton {
                        id: btnShiftUp
                        iconSize: SGWidgets.SGSettings.fontPixelSize + 8
                        hintText: qsTr("Shift Up")
                        opacity: delegate.isHighlighted ? 1 : 0.1
                        icon.source: "qrc:/sgimages/chevron-up.svg"
                        onClicked: {
                            messageQueueModel.decrementPosition(index)
                        }
                    }

                    SGWidgets.SGIconButton {
                        id: btnShiftDown
                        iconSize: btnShiftUp.iconSize
                        hintText: qsTr("Shift Down")
                        opacity: btnShiftUp.opacity
                        icon.source: "qrc:/sgimages/chevron-down.svg"
                        onClicked: {
                            messageQueueModel.incrementPosition(index)
                        }
                    }

                    SGWidgets.SGIconButton {
                        id: btnRemove
                        iconSize: btnShiftUp.iconSize
                        hintText: qsTr("Remove")
                        opacity: btnShiftUp.opacity
                        iconColor: hovered ? "white" : "black"
                        icon.source: "qrc:/sgimages/times-thin.svg"
                        highlightImplicitColor: Theme.palette.error
                        onClicked: {
                            messageQueueModel.remove(index)
                        }
                    }
                }

                Rectangle {
                    id: divider
                    height: 1
                    y: numberText.y + Math.max(messageText.height, rightButtonRow.height) + delegateBaseSpacing
                    anchors {
                        left: parent.left
                        right: parent.right
                    }

                    color: "black"
                    opacity: 0.2
                }
            }
        }

        SGWidgets.SGText {
            anchors.centerIn: queueListViewBg
            text: "Message queue is empty"
            font.italic: true
            fontSizeMultiplier: 2.0
            opacity: 0.6
            visible: queueListView.count === 0
        }

        SGWidgets.SGButton {
            id: btnBack
            anchors {
                left: parent.left
                bottom: parent.bottom
            }

            text: "Back"
            icon.source: "qrc:/sgimages/chevron-left.svg"
            onClicked: {
                closeView()
            }
        }
    }

    function closeView() {
        StackView.view.pop();
    }
}
