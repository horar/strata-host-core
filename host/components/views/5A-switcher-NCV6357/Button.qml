import QtQuick 2.12
import QtQuick.Controls 2.12
import "qrc:/js/navigation_control.js" as NavigationControl

Button {
    text: "5A-switcher-6357"
    onClicked: {
        var data = { class_id: "216"}
        NavigationControl.updateState(NavigationControl.events.NEW_PLATFORM_CONNECTED_EVENT, data)
    }
}
