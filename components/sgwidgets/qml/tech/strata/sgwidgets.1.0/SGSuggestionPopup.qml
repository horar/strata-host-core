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
import QtQml.Models 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp

Popup {
    id: popup

    property Item textEditor
    property variant model
    property Component delegate: implicitDelegate
    property Component header: headerComponent
    property alias footer: view.footer
    property string textRole: "text"
    property int listSpacing: 0
    property bool controlWithSpace: false
    property bool closeOnSelection: true
    property bool closeOnMouseSelection: false
    property bool closeWithArrowKey: false
    property bool openOnActiveFocus: false
    property int maxHeight: 120
    property int position: Item.Bottom
    property int verticalLayoutDirection: ListView.TopToBottom
    property string emptyModelText: "No suggestions."
    property string headerText
    property bool delegateNumbering: false
    property bool delegateRemovable: false
    property bool highlightResults: false
    property string highlightFilterPattern: ""
    property variant highlightFilterPatternSyntax: CommonCpp.SGTextHighlighter.RegExp
    property bool highlightCaseSensitive: false

    readonly property Component implicitDelegate: delegateComponent

    signal delegateSelected(int index)
    signal removeRequested(int index)

    x: {
        if (!textEditor) {
            return 0
        }

        /* this is to trigger calculation when positions changes */
        var calculatePositionAgain = popup.parent.x + textEditor.x

        var pos = textEditor.mapToItem(popup.parent, 0, 0)
        return  pos.x
    }
    y: {
        if (!textEditor) {
            return 0
        }

        /* this is to trigger calculation when position changes */
        var calculatePositionAgain = popup.parent.y + textEditor.y + textEditor.height

        var deltaY = 0

        if (position === Item.Bottom) {
            deltaY = textEditor.height
        }

        if (position === Item.Top) {
            deltaY = -popup.contentItem.height - popup.topPadding - popup.bottomPadding
        }

        var pos = textEditor.mapToItem(popup.parent, 0, deltaY)
        return  pos.y
    }

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    padding: 2
    implicitWidth: textEditor ? textEditor.width : 0

    onAboutToShow: {
        if (position === Item.Bottom) {
            view.currentIndex = 0
            view.positionViewAtBeginning()
        } else if (position === Item.Top) {
            view.currentIndex = view.count - 1
            view.positionViewAtEnd()
        }
    }

    Connections {
        target: textEditor
        onActiveFocusChanged: {
            if (textEditor.activeFocus) {
                if (openOnActiveFocus) {
                    popup.open()
                }
            } else {
                popup.close()
            }
        }
    }

    Control {
        id: dummyControl
    }

    contentItem: Item {
        id: wrapper

        implicitHeight: Math.min(view.y + view.contentHeight, maxHeight)
        implicitWidth: view.width

        Keys.onPressed: {
            if (event.key === Qt.Key_Up) {
                if (closeWithArrowKey && position === Item.Bottom) {
                    if (view.currentIndex === 0) {
                        popup.close()
                    }
                }

                view.decrementCurrentIndex()
            } else if (event.key === Qt.Key_Down) {
                if (closeWithArrowKey && position === Item.Top) {
                    if (view.currentIndex === view.count - 1) {
                        popup.close()
                    }
                }

                view.incrementCurrentIndex()
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                if (popup.opened) {
                    delegateSelected(view.currentIndex)
                    if (closeOnSelection) {
                        popup.close()
                    }
                }
            } else if (controlWithSpace && event.key === Qt.Key_Space) {
                if (popup.opened) {
                    popup.close()
                } else {
                    popup.open()
                }
            } else if (delegateNumbering && event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
                var effectiveIndex = toModelIndex(event.key - Qt.Key_0)
                if (effectiveIndex >= 0) {
                    view.currentIndex = effectiveIndex
                }
            } else {
                return
            }

            event.accepted = true
        }

        Loader {
            id: headerLoader
            anchors {
                top: parent.topt
            }
            width: view.width

            sourceComponent: headerText ? headerComponent : null
        }

        ListView {
            id: view
            width: textEditor ? textEditor.width - popup.leftPadding - popup.rightPadding : 0
            height: parent.height - headerLoader.height
            anchors {
                top: headerLoader.bottom
            }

            model: popup.model
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            delegate: popup.delegate
            spacing: popup.spacing
            header: count > 0 ? null : emptyModelComponent

            ScrollBar.vertical: ScrollBar {
                anchors {
                    top: view.top
                    bottom: view.bottom
                    right: view.right
                    rightMargin: 2
                }

                policy: ScrollBar.AlwaysOn
                interactive: false
                width: 8
                visible: view.height < view.contentHeight
            }
        }
    }

    background: Item {
        RectangularGlow {
            id: effect
            anchors {
                fill: parent
                topMargin: position === Item.Bottom ? glowRadius - 2 : 0
                bottomMargin: position === Item.Top ? glowRadius - 2 : 0
            }
            glowRadius: 8
            color: dummyControl.palette.mid
        }

        Rectangle {
            anchors.fill: parent
            color: "white"
            border.color: dummyControl.palette.mid
            border.width: 1
        }
    }

    Component {
        id: emptyModelComponent

        Item {
            width: ListView.view ? ListView.view.width : 0
            height: text.paintedHeight + 6

            SGWidgets.SGText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                text: emptyModelText
                font.italic: true
            }
        }
    }

    Component {
        id: delegateComponent

        Item {
            width: ListView.view.width
            height: text.paintedHeight + 10

            Rectangle {
                anchors.fill: parent
                color: {
                    if (parent.ListView.isCurrentItem) {
                        return dummyControl.palette.highlight
                    } else if (delegateMouseArea.containsMouse || removeBtn.hovered) {
                        return Qt.lighter(dummyControl.palette.highlight, 1.9)
                    }

                    return "transparent"
                }
            }

            Loader {
                sourceComponent: highlightResults ? highlightComponent : null
            }

            Component {
                id: highlightComponent
                CommonCpp.SGTextHighlighter {
                    textDocument: text.textDocument
                    filterPattern: highlightFilterPattern
                    filterPatternSyntax: highlightFilterPatternSyntax
                    caseSensitive: highlightCaseSensitive
                }
            }

            Item {
                id: delegateNumberWrapper
                width: 15
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    left: parent.left
                }

                visible: delegateNumbering

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.05
                }

                SGWidgets.SGText {
                    id: delegateNumberText
                    anchors.centerIn: parent

                    color: text.color
                    opacity: 0.7
                    text: {
                        var number = fromModelIndex(model.index)
                        if (number > 10) {
                            return ""
                        }

                        return number % 10
                    }
                }
            }

            SGWidgets.SGTextEdit {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: delegateNumberWrapper.visible ? delegateNumberWrapper.right : parent.left
                    leftMargin: 4
                    right: removeBtn.left
                    rightMargin: 4
                }

                textFormat: Text.PlainText
                readOnly: true
                text: popup.textRole ? model[popup.textRole] : modelData
                color: parent.ListView.isCurrentItem ? "white" : "black"
            }

            MouseArea {
                id: delegateMouseArea
                anchors.fill: parent
                hoverEnabled: true

                onClicked: {
                    view.currentIndex = index
                    delegateSelected(index)
                    if (closeOnMouseSelection) {
                        popup.close()
                    }
                }
            }

            SGWidgets.SGIconButton {
                id: removeBtn
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 2 + 8
                }

                iconSize: delegateNumberText.height
                hintText: qsTr("Remove")
                visible: delegateRemovable
                         && (delegateMouseArea.containsMouse
                             || removeBtn.hovered
                             || parent.ListView.isCurrentItem)

                iconColor: "white"
                icon.source: "qrc:/sgimages/times.svg"
                highlightImplicitColor: Theme.palette.error
                onClicked: {
                    removeRequested(index)
                }
            }
        }
    }

    Component {
        id: headerComponent

        Item {
            height: text.paintedHeight + 6

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.05
            }

            SGWidgets.SGText {
                id: text
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 2
                    right: parent.right
                    rightMargin: 2 + 8
                }

                fontSizeMultiplier: 1.1
                font.bold: true
                text: headerText
            }
        }
    }

    function toModelIndex(number) {
        if (number === 0) {
            number = 10
        }

        if (position === Item.Top) {
            return model.count - number
        }


        return number - 1
    }

    function fromModelIndex(index) {
        if (position === Item.Top) {
            return model.count - index
        }

        return index + 1
    }
}
