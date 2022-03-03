/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

RowLayout {
    property alias message: messageBar.text
    property alias messageBackgroundColor: messageBackground.color
    property alias activityLevel: activityLevelBar.text
    property alias activityLevelColor: activityLevelBackground.color
    property bool displayActivityLevel: false

    spacing: 0

    TextField {
        id: messageBar
        Layout.fillHeight: true
        Layout.fillWidth: true

        horizontalAlignment: TextInput.AlignHCenter
        color: "#eee"
        text: ""
        readOnly: true
        background: Rectangle {
            id: messageBackground
            anchors.fill: parent
            color: "#b55400"
        }
    }

    Rectangle {
        Layout.fillHeight: true
        Layout.preferredWidth: 1

        color: "black"
        visible: displayActivityLevel
    }

    TextField {
        id: activityLevelBar
        Layout.fillHeight: true
        Layout.preferredWidth: 100

        visible: displayActivityLevel
        color: "#eee"
        text: ""
        readOnly: true
        horizontalAlignment: TextInput.AlignHCenter
        background: Rectangle {
            id: activityLevelBackground
            anchors.fill: parent
            color: "green"
        }
    }
}
