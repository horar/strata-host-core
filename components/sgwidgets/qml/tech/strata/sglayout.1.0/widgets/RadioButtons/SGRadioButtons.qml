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
    property int radioSize: 25
    property color radioColor: "black"
    property color textColor: radioColor
    property int checkedIndex: 1
    property real fontSizeMultiplier: 1.0
    property real pixelSize: SGWidgets.SGSettings.fontPixelSize * fontSizeMultiplier

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
                checked: checkedIndex & powIndex
                spacing: 10
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: modelData
                padding: 0

                Component.onCompleted:  {
                    indicator.color = Qt.binding(function(){ return "transparent"} )
                    indicator.implicitWidth = Qt.binding(function(){ return control.radioSize } )
                    indicator.implicitHeight = Qt.binding(function(){ return indicator.implicitWidth } )
                    indicator.border.color = Qt.binding(function(){ return control.radioColor} )
                    indicator.children[0].color = Qt.binding(function(){ return control.radioColor} )
                    indicator.children[0].width = Qt.binding(function(){ return (control.radioSize * 0.6)} )
                    indicator.children[0].height = Qt.binding(function(){ return (indicator.children[0].width)} )
                    contentItem.font.pixelSize = Qt.binding(function(){ return control.pixelSize} )
                    contentItem.color = Qt.binding(function(){ return control.textColor} )
                }

                property int powIndex: 1 << index

                onClicked: {
                    control.clicked(index)
                }
            }
        }
    }
}
