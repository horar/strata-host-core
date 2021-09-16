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

RowLayout {
    anchors {
        bottom: parent.bottom
        left: parent.left
        bottomMargin: 20
        leftMargin: controlViewCreatorLoader.active ? 80 : 20
    }
    spacing: 1

    property alias text: button.text
    property alias checked: button.checked

    RoundButton {
        id: button
        font {
            bold: true
        }
        checkable: true
    }

    RoundButton {
        id: cleanup
        icon.source: "qrc:/sgimages/broom.svg"
        onClicked: qmlErrorModel.clear()
    }

    NumberAnimation on opacity {
        id: qmlErrorButtonAnimation
        from: 0.6
        to: 1.0
        duration: 1500
        easing.type: Easing.OutQuart
        loops: Animation.Infinite
        running: button.checked === false
    }
}