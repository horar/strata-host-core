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
import QtQml 2.12

import "../../"

LayoutContainer {
    id: buttonStripContainer

    // pass through all properties
    property alias model: buttonStripObject.model
    readonly property alias count: buttonStripObject.count
    property alias exclusive: buttonStripObject.exclusive
    property alias orientation: buttonStripObject.orientation
    property alias checkedIndices: buttonStripObject.checkedIndices

    signal clicked (int index)

    function isChecked(index) {
        return buttonStripObject.isChecked(index)
    }

    function color(button) {
        if (button.checked) {
            if (button.down) {
                return "#79797a"
            } else {
                return "#353637"
            }
        } else {
            if (button.down) {
                return "#cfcfcf"
            } else {
                return "#e0e0e0"
            }
        }
    }

    function textColor(button) {
        if (button.checked) {
            if (button.enabled) {
                return "#ffffff"
            } else {
                return "#4dffffff"
            }
        } else {
            if (button.enabled) {
                return "#26282a"
            } else {
                return "#4d26282a"
            }
        }
    }

    contentItem: SGButtonStrip {
        id: buttonStripObject
        onClicked: {
            parent.clicked(index)
        }
    }
}

