import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.0

Popup {
    padding: 10
    anchors {
        centerIn: Overlay.overlay
    }
    closePolicy: Popup.CloseOnEscape
    modal: true
    background: Rectangle {
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 1
            verticalOffset: 3
            radius: 6.0
            samples: 12
            color: "#99000000"
        }
    }

    onClosed: menuLoader.active = false
}
