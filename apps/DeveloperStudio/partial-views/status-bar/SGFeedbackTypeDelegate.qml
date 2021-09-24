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
import tech.strata.fonts 1.0

Component {
    Rectangle {
        id: label
        color: containsMouse ? hoverColor : baseColor
        implicitWidth: content.width + 15
        implicitHeight: 30
        radius: 5
        border.width: feedbackTypeListView.currentIndex === index ? 2 : 0
        border.color: "black"
        Accessible.role: Accessible.Button
        Accessible.name: content.text
        Accessible.onPressAction: onClick()

        property alias containsMouse: buttonMouseArea.containsMouse
        property string typeValue: type

        function onClick() {
            feedbackTypeListView.currentIndex = index
        }

        Text {
            id: content
            anchors.centerIn: parent
            text: qsTr(type)
            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: label.onClick()
        }
    }
}
