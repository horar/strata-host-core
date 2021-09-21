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

Item {
    id: root

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    property alias radioGroup : radioButtons.sourceComponent
    property alias radioButtons: radioButtons.item
    property alias radioButtonSize: radioButtons.radioButtonSize
    property alias overrideLabelWidth: labelText.width

    property color textColor: "#000000"
    property color radioColor: "#000000"
    property bool exclusive: true
    property string label: ""
    property bool labelLeft: true

    Text {
        id: labelText
        text: root.label
        width: implicitWidth
        height: root.label === "" ? 0 : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? 5 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    ButtonGroup {
        buttons: radioButtons.status !== Loader.Ready ? [] : radioButtons.children[0].children
        exclusive: root.exclusive
    }

    Loader {
        id: radioButtons
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }

        property color masterTextColor: textColor
        property color masterRadioColor: radioColor
        property real radioButtonSize: 20
    }
}
