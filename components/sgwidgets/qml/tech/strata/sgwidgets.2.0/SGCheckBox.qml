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
import QtQuick.Controls.Styles 1.4
import tech.strata.sgwidgets 2.0
import tech.strata.theme 1.0

CheckBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    padding: 0
    spacing: 6

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20

        x: text ? (control.mirrored ? control.width - width - control.rightPadding : control.leftPadding) : control.leftPadding + (control.availableWidth - width) / 2
        y: control.topPadding + (control.availableHeight - height) / 2

        border.width: control.visualFocus ? 2 : 1
        border.color: control.visualFocus ? Theme.palette.onsemiOrange : Theme.palette.gray
        color: control.enabled ? Theme.palette.white : Theme.palette.lightGray

        SGIcon {
            width: control.checkState === Qt.PartiallyChecked ? Math.floor(parent.width * 0.6) : Math.floor(parent.width * 0.7)
            height: width
            anchors.centerIn: parent
            visible: control.checkState === Qt.Checked || control.checkState === Qt.PartiallyChecked
            source: control.checkState === Qt.PartiallyChecked ? "qrc:/sgimages/minus.svg" : "qrc:/sgimages/check.svg"
            opacity: control.enabled ? 1 : 0.5
        }
    }

    contentItem: SGText {
        id: contentItem
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        verticalAlignment: Text.AlignVCenter

        text: control.text
        opacity: control.enabled ? 1 : 0.5
    }
}
