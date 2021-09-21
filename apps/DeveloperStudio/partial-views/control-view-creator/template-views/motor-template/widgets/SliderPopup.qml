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
import tech.strata.sgwidgets 1.0

Popup {
    id: sliderPopup
    closePolicy: Popup.NoAutoClose
    property alias value: targetSlider.value
    property string unit
    property alias from: targetSlider.from
    property alias to: targetSlider.to
    property alias stepSize: targetSlider.stepSize
    property alias title: title.text

    signal userSet(real value)
    Connections {
        target: parent
        onVisibleChanged: {
            if (parent.visible === false) {
                sliderPopup.close()
            }
        }
    }
    background: Rectangle {
        color: sideBar.color
        Rectangle {
            width: 1
            height: parent.height
            color: Qt.darker(parent.color)
        }
    }
    RowLayout {
        height: parent.height
        spacing:10
        SGText {
            id: title
            font.bold: true
            color: "white"
            fontSizeMultiplier: 1.25
        }
        SGSlider {
            id: targetSlider
            Layout.preferredWidth: 300
            Layout.fillWidth: true
            inputBox.unit: sliderPopup.unit
            inputBox.boxColor: "#222"
            inputBoxWidth: 100
            textColor: "white"
            onUserSet: sliderPopup.userSet(value)
            live: false
            toolTipBackground.color: "#222"
            showInputBox: false
        }
    }
}