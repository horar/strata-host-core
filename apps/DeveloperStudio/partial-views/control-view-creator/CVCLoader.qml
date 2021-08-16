import QtQuick 2.12
import QtQuick.Layouts 1.3

import "qrc:/partial-views/control-view-creator"
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.signals 1.0

Loader {
    id: cvcLoader
    Layout.fillHeight: true
    Layout.fillWidth: true
    active: false

    sourceComponent: ControlViewCreator {
        id: controlViewCreator
    }

    onStatusChanged: {
        if (status === Loader.Ready) {
            Help.control_view_creator = item
        } else if (status === Loader.Null) {
            Help.control_view_creator = null
        }
    }

    Connections {
        target: Signals

        onLoadCVC: {
            cvcLoader.active = true
            let data = {"index": NavigationControl.stack_container_.count-1}
            NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
        }
    }
}
