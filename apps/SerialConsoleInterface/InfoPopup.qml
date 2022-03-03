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
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Popup {
    id: popup
    x: parent ? Math.round((parent.width - width) / 2) : 0
    y: parent ? Math.round((parent.height - height) / 2) : 0

    padding: 16

    property int closeDelay: 1500
    property alias text: textItem.text
    property alias icon: statusIcon.source
    property url succeedIcon: "qrc:/sgimages/check.svg"
    property url failedIcon: "qrc:/sgimages/times.svg"
    property alias color: dot.color
    property color succeedColor: Theme.palette.green
    property color failedColor: TangoTheme.palette.error

    function showSuccess(text) {
        popup.text = text
        popup.color = popup.succeedColor
        popup.icon = popup.succeedIcon
        popup.open()
    }

    function showFailed(text) {
        popup.text = text
        popup.color = popup.failedColor
        popup.icon = popup.failedIcon
        popup.open()
    }

    function show(text, color, icon) {
        popup.text = text
        popup.color = color
        popup.icon = icon
        popup.open()
    }

    onAboutToShow: {
        popup.opacity = 1
        autoDestructionTimer.start()
    }

    Timer {
        id: autoDestructionTimer
        interval: popup.closeDelay
        onTriggered: {
            closeAnimation.start()
        }
    }

    SequentialAnimation {
        id: closeAnimation

        NumberAnimation {
            target: popup
            property: "opacity"
            duration: 200
            to: 0
        }

        ScriptAction {
            script: {
                popup.close()
            }
        }
    }

    Column {
        spacing: 10

        Item {
            id: iconItem
            width: 100
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: dot
                anchors.fill: parent
                radius: Math.round(width/2)
                color: Theme.palette.green
            }
            SGWidgets.SGIcon {
                id: statusIcon
                anchors.centerIn: parent
                width: Math.round(parent.width*0.6)
                height: width
                iconColor:"white"
                source: succeedIcon
            }
        }

        SGWidgets.SGText {
            id: textItem
            anchors.horizontalCenter: parent.horizontalCenter
            alternativeColorEnabled: true
            fontSizeMultiplier: 1.5
            font.bold: true
        }
    }

    background: RectangularGlow {
        id: effect
        spread: 0.5
        glowRadius: 4
        cornerRadius: 10
        color: "black"
        opacity: 0.7
    }
}
