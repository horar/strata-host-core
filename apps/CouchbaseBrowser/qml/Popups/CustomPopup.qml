/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0

import "../Components"

Popup {
    id: root
    width: maximized ? parent.width : defaultWidth
    height: maximized ? parent.height : defaultHeight
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2

    visible: false
    padding: 1
    closePolicy: Popup.CloseOnEscape
    modal: true

    property bool showMaximizedBtn: false
    property bool maximized: false
    property real defaultWidth: 500
    property real defaultHeight: 600
    property alias popupStatus: statusBar
    property alias content: content.contentItem

    signal submit()
    signal clearFailedMessage()

    ColumnLayout {
        id: container
        anchors.fill: parent

        spacing: 0

        Rectangle {
            id: content
            Layout.fillHeight: true
            Layout.fillWidth: true

            color: "#222831"

            property Item contentItem
            onContentItemChanged: contentItem.parent = content

            Button {
                id: closeBtn
                height: 20
                width: 20
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: 20
                    rightMargin: 20
                }

                onClicked: root.close()
                background: Rectangle {
                    height: parent.height + 6
                    width: parent.width + 6
                    anchors.centerIn: parent

                    radius: width/2
                    color: closeBtn.hovered ? "white" : "transparent"
                    SGIcon {
                        id: icon
                        height: closeBtn.height
                        width: closeBtn.width
                        anchors.centerIn: parent

                        fillMode: Image.PreserveAspectFit
                        iconColor: "#b55400"
                        source: "qrc:/qml/Images/circle-with-x-icon.svg"
                    }
                }
            }

            Button {
                id: maximizeBtn
                height: 20
                width: 20
                anchors {
                    top: parent.top
                    right: closeBtn.left
                    topMargin: 20
                    rightMargin: 10
                }

                visible: showMaximizedBtn
                onClicked: maximized = !maximized
                background: Rectangle {
                    height: parent.height + 6
                    width: parent.width + 6
                    anchors.centerIn: parent

                    radius: 3
                    color: maximizeBtn.hovered ? "white" : "transparent"
                    SGIcon {
                        height: maximizeBtn.height
                        width: maximizeBtn.width
                        anchors.centerIn: parent

                        iconColor: "#b55400"
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/qml/Images/fullscreen-icon.svg"
                    }
                }
            }
        }

        StatusBar {
            id: statusBar
            Layout.fillHeight: false
            Layout.fillWidth: true
            Layout.preferredHeight: 25
        }
    }

    DropShadow {
        anchors.fill: container

        source: container
        horizontalOffset: 7
        verticalOffset: 7
        spread: 0
        radius: 20
        samples: 41
        color: "#aa000000"
    }
}
