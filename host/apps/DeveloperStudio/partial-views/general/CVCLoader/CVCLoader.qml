import QtQuick 2.12
import QtQuick.Layouts 1.3

import "qrc:/partial-views/control-view-creator"
import "qrc:/js/navigation_control.js" as NavigationControl
import tech.strata.signals 1.0
Loader {
    id: cvcLoader
    Layout.fillHeight: true
    Layout.fillWidth: true
    active: false

    property bool cvcCloseRequested: false

    sourceComponent: ControlViewCreator {
        id: controlViewCreator
        cvcCloseRequested: cvcLoader.cvcCloseRequested
    }

    Connections {
        target: Signals

        onLoadCVC:{
            cvcLoader.active = true
            let data = {"index": NavigationControl.stack_container_.count-2}
            NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
        }

        onRequestCVCClose:{
            cvcLoader.cvcCloseRequested = true
            cvcLoader.item.confirmClosePopup.unsavedFileCount = cvcLoader.item.openFilesModel.getUnsavedCount()
            if(cvcLoader.item.confirmClosePopup.unsavedFileCount > 0){
                cvcLoader.item.confirmClosePopup.open()
            } else {
                cvcLoader.cvcCloseRequested = false
                Signals.closeCVC()
            }
        }

        onCloseCVC:{
            cvcLoader.active = false
            let data = {"index": NavigationControl.stack_container_.count-3}
            NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
        }
    }
}
