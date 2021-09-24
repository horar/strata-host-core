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
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

FocusScope {

    ListModel {
        id: commoncppModel

        ListElement {
            name: "SGJsonSyntaxHighlighter"
            page: "ExSGJsonSyntaxHighlighter.qml"
        }

        ListElement {
            name: "SGSortFilterProxyModel"
            page: "ExSGSortFilterProxyModel.qml"
        }

        ListElement {
            name: "SGTextHighlighter"
            page: "ExSGTextHighlighter.qml"
        }
    }

    Component.onCompleted: {
        //select the first example by default
        buttonRepeater.itemAt(0).checked = true
        setPage(0)
    }

    Item {
        id: header
        height: headerText.contentHeight + 10
        anchors {
            left: parent.left
            right: parent.right
        }

        Item {
            id: goBackWrapper
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }

            width: sidePane.width
            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: Theme.palette.darkBlue
            }

            SGWidgets.SGIconButton {
                id: goBackButtom
                anchors {
                    left: parent.left
                    leftMargin: 4
                    verticalCenter: parent.verticalCenter
                }

                icon.source: "qrc:/sgimages/chevron-left.svg"
                backgroundOnlyOnHovered: true
                iconColor: "white"
                highlightImplicitColor: Theme.palette.green

                onClicked: {
                    pop()
                }
            }

            SGWidgets.SGText {
                anchors {
                    left: goBackButtom.right
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                text: "CommonCpp 1.0"
                fontSizeMultiplier: 1.4
                color: "white"
            }
        }

        Item {
            anchors {
                left: goBackWrapper.right
                leftMargin: 1
                right: parent.right
            }

            height: parent.height

            Rectangle {
                anchors.fill: parent
                color: Theme.palette.darkBlue
            }

            SGWidgets.SGText {
                id: headerText
                anchors.centerIn: parent

                fontSizeMultiplier: 2.0
                color: "white"
            }
        }
    }

    FocusScope {
        id: sidePane
        width: flick.width
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
        }

        ButtonGroup {
            id: group
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.palette.darkBlue
        }

        Flickable {
            id: flick
            width: commoncppList.width
            anchors {
                top: parent.top
                bottom: parent.bottom
                margins: 6
            }

            contentWidth: commoncppList.width
            contentHeight: commoncppList.height
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                visible: flick.height < flick.contentHeight
            }

            clip: true

            Column {
                id:  commoncppList

                spacing: 4

                Repeater {
                    id: buttonRepeater
                    model: commoncppModel

                    delegate: Item {
                        id: delegate

                        width: delegateButton.width + 12
                        height: delegateButton.height

                        property alias checked: delegateButton.checked

                        SGWidgets.SGButton {
                            id: delegateButton
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                            }

                            text: model.name
                            fontSizeMultiplier: 1.5
                            checkable: true
                            ButtonGroup.group: group
                            minimumContentWidth: 240
                            color: Theme.palette.green

                            onClicked: {
                                setPage(index)
                            }
                        }
                    }
                }
            }
        }
    }

    Flickable {
        id: flickWrapper
        anchors {
            left: sidePane.right
            leftMargin: 10
            right: parent.right
            top: header.bottom
            topMargin: 10
            bottom: parent.bottom
            margins: 4
        }

        contentWidth: pageLoader.width
        contentHeight: pageLoader.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AlwaysOn
            visible: flickWrapper.height < flickWrapper.contentHeight
        }

        ScrollBar.horizontal: ScrollBar {
            policy: ScrollBar.AlwaysOn
            visible: flickWrapper.width < flickWrapper.contentWidth
        }

        Loader {
            id: pageLoader
        }
    }

    function setPage(index) {
        var item = commoncppModel.get(index)
        headerText.text = item.name
        pageLoader.source =  item.page
    }

    function pop() {
        StackView.view.pop()
    }
}
