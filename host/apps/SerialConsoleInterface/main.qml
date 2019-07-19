import QtQuick 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGWindow {
    id: window

    visible: true
    height: 600
    width: 800
    minimumHeight: 600
    minimumWidth: 800

    title: qsTr("Serial Console Interface")

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SciMain {
        anchors.fill: parent
    }
}
