import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control
    width: strip.width
    height: strip.height

    property alias model: repeater.model
    readonly property alias count: repeater.count
    property bool exclusive: true
    property int orientation: Qt.Horizontal

    /* Holds indexes of checked buttons in power of 2 format:
       for example:
       0       - no button checked
       1 = 2^0 - first button checked
       2 = 2^1 - second button checked
       4 = 2^2 - third button checked
       5 = 2^0 + 2^2 - first and third buttons checked
       6 = 2^1 + 2^2 - second and third buttons checked
       7 = 2^0 + 2^1 + 2^2 - first, second and third buttons checked
       8 = 2^3 - fourth button checked

       To check particular button, use isChecked(buttonIndex)
    */
    property int checkedIndices: 0

    signal clicked(int index)

    /* The easiest way to check particular button */
    function isChecked(index) {
        return checkedIndices & (1 << index)
    }

    Grid {
        id: strip

        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        spacing: 1

        Repeater {
            id: repeater

            delegate: SGWidgets.SGButton {
                id: buttonDelegate

                text: modelData
                checkable: true
                checked: checkedIndices & powIndex
                roundedLeft: orientation == Qt.Horizontal ? index === 0 : true
                roundedRight: orientation == Qt.Horizontal ? index === repeater.count - 1 : true
                roundedTop: orientation == Qt.Vertical ? index === 0 : true
                roundedBottom: orientation == Qt.Vertical ? index === repeater.count - 1 : true

                property int powIndex: 1 << index

                onClicked: {
                    control.clicked(index)

                    if (control.exclusive) {
                        checkedIndices = 0
                        checkedIndices = powIndex
                    } else {
                        checkedIndices ^= powIndex
                    }
                }
            }
        }
    }
}
