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
import tech.strata.theme 1.0

Item {
    id: delegate

    height: contentLoader.y + contentLoader.height + bottomPadding

    property int bottomPadding: 1
    property bool pressable: true
    property bool checked: false
    property bool uncheckable: false
    property bool whiteBgWhenSelected: true
    property alias headerSourceComponent: headerLoader.sourceComponent
    property alias contentSourceComponent: contentLoader.sourceComponent
    signal categorySelected()


    Loader {
        id: headerLoader
        anchors {
            top: parent.top
        }

        width: parent.width
    }

    Rectangle {
        id: bg
        anchors {
            top: headerLoader.bottom
            left: parent.left
            right: parent.right
            bottom: contentLoader.bottom
        }

        color: {
            if (mouseArea.pressed && delegate.pressable) {
                return Theme.palette.darkGray
            }

            if (delegate.checked && whiteBgWhenSelected) {
                return Theme.palette.gray
            }

            if (mouseArea.containsMouse) {
                return Theme.palette.lightGray
            }

            return Theme.palette.white
        }
    }


    MouseArea {
        id: mouseArea
        anchors.fill: bg
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked:  {
            categorySelected()
            if (delegate.pressable == false) {
                return
            }
            if (delegate.checked) {
                if (uncheckable) {
                    delegate.checked = false
                }
            } else {
                delegate.checked = true
            }
        }
    }

    Loader {
        id: contentLoader

        anchors {
            top: headerLoader.bottom
            left: parent.left
            right: parent.right
        }
    }
}
