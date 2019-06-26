import QtQuick 2.12
import QtQuick.Controls 2.12
import "qrc:/js/navigation_control.js" as NavigationControl

Button {
    text: "entice_rgb"
    onClicked: {
        var data = { class_id: "entice_rgb"}
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
    }
}



