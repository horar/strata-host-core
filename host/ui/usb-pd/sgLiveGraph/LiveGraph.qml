import QtQuick 2.0
import QtQuick.Controls 2.1

Item {
    id: main
    width: 600
    height: 400
    property string chartType: ""
    property int portNumber:0
    ScopeView {
        id: scopeView
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.left: parent.left
        height: main.height
        chartType: main.chartType
        portNumber: main.portNumber

    }
}
