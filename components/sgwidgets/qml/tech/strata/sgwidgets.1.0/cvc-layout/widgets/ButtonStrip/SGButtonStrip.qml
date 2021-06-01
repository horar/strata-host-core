import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    id: control
    anchors.fill: parent

    property alias model: repeater.model
    readonly property alias count: repeater.count
    property bool exclusive: true
    property int orientation: Qt.Horizontal
//    property color textColor: "red"
//    property color color: "green"

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

    property color textColor: {
        if (repeater.children.checked) {
            if (repeater.children.enabled) {
                return "#ffffff"
            } else {
                return "#4dffffff"
            }
        } else {
            if (repeater.children.enabled) {
                return "#26282a"
            } else {
                return "#4d26282a"
            }
        }
    }

    property color color: {
        if (repeater.children.checked) {
            if (repeater.children.down) {
                return "#79797a"
            } else {
                return "#353637"
            }
        } else {
            if (repeater.children.down) {
                return "#cfcfcf"
            } else {
                return "#e0e0e0"
            }
        }
    }


    GridLayout {
        id: strip
        anchors.fill: parent

        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        columnSpacing: 1
        rowSpacing: 1

        Repeater {
            id: repeater

            delegate: Button {
                id: buttonDelegate
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: modelData
                checkable: true
                checked: checkedIndices & powIndex

                Component.onCompleted: {
                    background.color = Qt.binding(() => {return control.color})
                    contentItem.color = Qt.binding(() => {return control.textColor})
                }

                // roundedLeft: orientation == Qt.Horizontal ? index === 0 : true
                // roundedRight: orientation == Qt.Horizontal ? index === repeater.count - 1 : true
                // roundedTop: orientation == Qt.Vertical ? index === 0 : true
                // roundedBottom: orientation == Qt.Vertical ? index === repeater.count - 1 : true

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


