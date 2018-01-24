import QtQuick 2.6
import QtQuick.Window 2.2
import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.0
import QtQuick 2.7

import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Private 1.0
import QtQuick.Extras 1.4
import QtQuick.Extras.Private 1.0
import QtQuick.Extras.Private.CppUtils 1.0
import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 2.1

import QtQml 2.2
import QtQuick 2.0


Dial {
    id: control
    live : true
    from : 0
    to : 100
    background: Rectangle {
        x: control.width / 2 - width / 2
        y: control.height / 2 - height / 2
        width: Math.max(64, Math.min(control.width, control.height))
        height: width
        color: "transparent"
        radius: width / 2
        border.color: control.pressed ? "#17a81a" : "#21be2b"
        opacity: control.enabled ? 1 : 0.3
    }



    handle: Rectangle {
        id: handleItem
        x: control.background.x + control.background.width / 2 - width / 2
        y: control.background.y + control.background.height / 2 - height / 2
        width: 16
        height: 16
        color: control.pressed ? "#17a81a" : "#21be2b"
        radius: 8
        antialiasing: true
        opacity: control.enabled ? 1 : 0.3
        transform: [
            Translate {
                y: -Math.min(control.background.width, control.background.height) * 0.4 + handleItem.height / 2
            },
            Rotation {
                angle: control.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]

    }
    Label {
        id: test
        x: 51
        width: 42
        height: 30

        text: Math.round(control.value)
        anchors.topMargin: 77
        anchors.top: parent.top
        anchors.centerIn: control
    }
}

