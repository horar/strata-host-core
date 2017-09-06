import QtQuick 2.7
import QtQuick.Controls 2.0

Popup {
    id: container

    modal: true
    focus: false
    dim: true

    transformOrigin : Popup.Center

    background: Rectangle {
        opacity: 0.0
    }

    enter: Transition {
        // grow_fade_in
        NumberAnimation { property: "scale"; from: 0.1; to: 1.0; easing.type: Easing.OutQuint; duration: 500 }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; easing.type: Easing.OutCubic; duration: 150 }
    }

    exit: Transition {
        // shrink_fade_out
        NumberAnimation { property: "scale"; from: 1.0; to: 0.1; easing.type: Easing.OutQuint; duration: 500 }
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; easing.type: Easing.OutCubic; duration: 150 }
    }
}
