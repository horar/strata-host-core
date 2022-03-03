/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtQuick.Controls 2.3

// This allows responsively sized content with a minimum height/width.
// When the minimum is reached, the content will turn into a scroll view.
//
// To use, set your content's parent to this contentItem and 'anchors.fill: parent'

Item {
    id: root
    clip: true

    property real minimumHeight: 800
    property real minimumWidth: 1000
    property alias contentItem : contentItem
    property color scrollBarColor: "white"

    ScrollView {
        id: scrollView
        anchors {
            fill: root
        }

        contentWidth: contentItem.width
        contentHeight: contentItem.height

        ScrollBar.vertical: ScrollBar {
            visible: contentItem.height !== scrollView.height
            interactive: visible
            parent: scrollView
            anchors {
                right: scrollView.right
                top: scrollView.top
                bottom: scrollView.bottom
            }
            contentItem: Rectangle {
                implicitWidth: 15
                implicitHeight: 15
                radius: width / 2
                color: root.scrollBarColor
            }
        }

        ScrollBar.horizontal: ScrollBar {
            visible: contentItem.width !== scrollView.width
            interactive: visible
            parent: scrollView
            anchors {
                bottom: scrollView.bottom
                right: scrollView.right
                left: scrollView.left
            }
            contentItem: Rectangle {
                implicitWidth: 15
                implicitHeight: 15
                radius: height / 2
                color: root.scrollBarColor
            }
        }

        Item {
            id: contentItem
            width: root.width < root.minimumWidth ? root.minimumWidth : root.width
            height: root.height < root.minimumHeight ? root.minimumHeight : root.height
        }
    }
}
