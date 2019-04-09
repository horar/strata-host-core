import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import tech.strata.prt 1.0 as PrtCommon
import "./common" as Common

Window {
    id: window
    width: 800
    height: 900
    minimumWidth: 800
    minimumHeight: 900

    visible: true
    title: qsTr("ON Semiconductor: Platform Registration Tool")

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#eeeeee"
    }

    Component.onCompleted: {
        stackView.pushPage("MainPage.qml")
    }

    PrtCommon.PrtModel {
        id: prtModel
    }

    StackView {
        id: stackView
        anchors {
            fill:parent
        }

        function pushPage(item, properties, operation) {
            if (properties === undefined) {
                properties = {}
            }

            properties["prtModel"] = prtModel

            push(item, properties, operation)
        }
    }
}
