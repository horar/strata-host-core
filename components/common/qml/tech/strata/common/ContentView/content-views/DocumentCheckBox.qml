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

CheckBox {
    id: control

    property bool fakeEnabled: false

    opacity: enabled || fakeEnabled ? 1 : 0.5

    indicator: Rectangle {
        id: outerRadio
        implicitWidth: 20
        implicitHeight: 20


        x: text ? control.leftPadding : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        radius: width / 2
        color: "transparent"
        border.width: 1
        border.color: Theme.palette.darkGray

        Rectangle {
            id: innerRadio
            implicitWidth: parent.width - 8
            implicitHeight: implicitWidth
            anchors.centerIn: parent

            radius: width / 2
            opacity: enabled || fakeEnabled ? 1.0 : 0.3
            color: Theme.palette.onsemiOrange
            visible: control.checked
        }
    }

    contentItem: SGWidgets.SGText {
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        text: control.text
        verticalAlignment: Text.AlignVCenter
    }
}
