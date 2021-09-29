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
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    implicitHeight: 20
    Layout.fillWidth: true
    implicitWidth: Math.max(100, buttonContent.implicitWidth + 10)
    color: mouse.containsMouse || content.visible ? "white" : "lightgrey"

    property alias text: buttonText.text
    property alias chevron: chevron.visible
    property alias containsMouse: mouse.containsMouse
    property alias subMenu: content.sourceComponent
    property alias content: content

    signal clicked()

    RowLayout {
        id: buttonContent
        anchors {
            centerIn: parent
        }

        Text {
            id: buttonText
        }

        SGIcon {
            id: chevron
            visible: false
            source: "qrc:/sgimages/chevron-right.svg"
            Layout.preferredHeight: 15
            Layout.preferredWidth: height
        }
    }

    MouseArea {
        id: mouse
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            if (chevron.visible) {
                // if popup will spawn past edge of window, place it on the opposite side of the click
                if((content.width + root.width + mouse.x + layoutOverlayRoot.x) > (layoutOverlayRoot.parent.width - content.width)) {
                    content.x = root.x - content.width
                } else {
                    content.x = root.width
                }

                content.open()
            }
        }

        onClicked: {
            root.clicked()
            if (content.visible) {
                content.close()
            }
        }
    }

    Loader {
        id: content
        active: chevron.visible
        visible: false
        anchors.top: parent.top

        signal open()
        signal close()

        onOpen: {
            visible = true
        }

        onClose: {
            visible = false
        }
    }
}
