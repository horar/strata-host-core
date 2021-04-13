import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets


Item {
    id: control
    anchors.fill: parent

    property alias model: repeater.model
    readonly property alias count: repeater.count
    property bool exclusive: true
    property int orientation: Qt.Vertical

    Grid {
        id: strip

        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        spacing: 1

        Repeater {
            id: repeater

            delegate: SGWidgets.SGRadioButton {
                id: buttonDelegate
                objectName : modelData
                checkable: true
                spacing: 10

            }
        }
    }


}
