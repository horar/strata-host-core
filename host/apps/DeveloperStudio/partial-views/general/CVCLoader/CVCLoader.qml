import QtQuick 2.12
import QtQuick.Layouts 1.3

import "qrc:/partial-views/control-view-creator"
import tech.strata.signals 1.0
Item {
    Layout.fillHeight: true
    Layout.fillWidth: true

    Loader {
        id: cvcLoader
        anchors.fill: parent
        active: false

        sourceComponent: ControlViewCreator {
            id: controlViewCreator
        }

        Connections {
            target: Signals

            onExecuteCVCSignal: {
                if(!loaded){
                    cvcLoader.active = true
                } else if(loaded && !changes){
                    cvcLoader.active = false
                }
            }
        }
    }
}
