import QtQuick 2.12
import QtQuick.Controls 2.12
import "qrc:/js/navigation_control.js" as NavigationControl

Button {
    text: "USB-PD 4 Ports"
    onClicked: {
        var data = { class_id: "203"}
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
    }
}
