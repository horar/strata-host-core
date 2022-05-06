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

FocusScope {
    id: delegate
    height: Math.max(icon.height, loader.height) + 2*delegate.padding

    focus: true
    visible: false

    property bool isSet: false
    property bool isBusy: false
    property alias content: loader.sourceComponent
    readonly property int horizontalSpace: 10
    readonly property int verticalSpace: 6
    readonly property int padding: 10

    signal aboutToShow()
    signal showed()
    signal hidden()

    function show() {
        delegate.aboutToShow()

        visible = true
        forceActiveFocus()

        delegate.showed()
    }

    function hide() {
        visible = false

        delegate.hidden()
    }

    Rectangle {
        anchors.fill: parent

        color: "#07000000"
        border.width: 1
        border.color: "#22000000"
        radius: 2
    }

    Item {
        id: iconWrapper
        width: icon.width
        height: parent.height
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            margins: delegate.padding
        }

        opacity: isSet ? 1 : 0

        SGWidgets.SGIcon {
            id: icon
            width: 40
            height: width
            anchors {
               centerIn: parent
            }

            iconColor: TangoTheme.palette.chameleon2
            source: "qrc:/sgimages/check.svg"
        }
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: iconWrapper
        height: icon.height + 8
        width: height

        running: isBusy
    }

    Loader {
        id: loader
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: delegate.padding
            left: iconWrapper.right
            leftMargin: horizontalSpace
        }

        focus: true
    }
}
