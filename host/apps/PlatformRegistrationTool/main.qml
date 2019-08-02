import QtQuick 2.12
import tech.strata.prt 1.0 as PrtCommon
import tech.strata.common 1.0 as Common
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGWindow {
    id: window
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("ON Semiconductor: Platform Registration Tool")

    PrtCommon.PrtModel {
        id: prtModel
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    Common.ProgramDeviceWizard {
        anchors {
            fill: parent
            margins: 4
        }
        boardController: prtModel.boardController
    }
}
