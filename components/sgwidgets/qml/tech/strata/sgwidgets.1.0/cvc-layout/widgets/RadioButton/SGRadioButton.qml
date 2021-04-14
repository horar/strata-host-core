import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets


Item {
    id: control
    anchors.fill: parent

    property alias model: repeater.model
    readonly property alias count: repeater.count
    property int orientation: Qt.Vertical

    signal checked()

    GridLayout {
        id: strip

        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        anchors.fill: parent
        columnSpacing: 1
        rowSpacing: 1

        Repeater {
            id: repeater


            delegate: SGWidgets.SGRadioButton {
                id: buttonDelegate
                text : modelData
                checkable: true
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                onCheckedChanged: {
                     control.checked()

                }
            }
        }
    }


}
