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
    property real radioSize: 12
    property color radioColor: "black"
    property int checkedIndices: 1

    signal clicked(int index)

    GridLayout {
        id: strip
        rows: orientation === Qt.Horizontal ? 1 : -1
        columns: orientation === Qt.Vertical ? 1 : -1
        anchors.fill: parent
        columnSpacing: 1
        rowSpacing: 1

        Repeater {
            id: repeater

            delegate: RadioButton {
                id: buttonDelegate
                checkable: true
                checked: checkedIndices
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true

                indicator :  Rectangle {
                    id: outerRadio
                    implicitWidth: control.radioSize
                    implicitHeight: implicitWidth
                    radius: width/2
                    color: "transparent"
                    border.width: 1
                    border.color: control.radioColor

                    Rectangle {
                        id: innerRadio
                        implicitWidth: outerRadio.width * 0.6
                        implicitHeight: implicitWidth
                        anchors {
                            horizontalCenter: outerRadio.horizontalCenter
                            verticalCenter: outerRadio.verticalCenter
                        }
                        radius: width / 2
                        color: control.radioColor
                        visible: buttonDelegate.checked
                    }
                }

//                property int powIndex: 1 << index

                onClicked: {
                    control.clicked(index)
                }

            }
        }
    }


}
