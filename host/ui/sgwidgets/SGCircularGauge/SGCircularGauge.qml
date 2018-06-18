import QtQuick 2.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import "qrc:/fonts"

Rectangle {
    id: root

    property real value: 0
    property real maximumValue: 100
    property real minimumValue: 0
    property color gaugeRearColor: "#eeeeee"
    property color gaugeFrontColor1: Qt.rgba(0,.75,1,1)
    property color gaugeFrontColor2: gaugeFrontColor1
    property real tickmarkStepSize : 10
    property string unitLabel: "RPM"

    implicitWidth: 256
    implicitHeight: 256

    CircularGauge {
        id: gauge
        value: (root.value-root.minimumValue)/(root.maximumValue-root.minimumValue)*200 // Normalize incoming values against 200 tickmarks
        width: root.width > root.height ? root.height *.7 : root.width *.7
        height: root.height > root.width ? root.width *.7 : root.height *.7
        anchors {
            centerIn: parent
        }

        maximumValue: 200
        minimumValue: 0

        style : CircularGaugeStyle {
            id: gaugeStyle
            needle: null
            foreground: null
            tickmarkLabel: null
            tickmarkStepSize: 1
            minorTickmark: null
            tickmark: Rectangle {
                id: tickmarks
//                color: styleData.value > gauge.value ? root.gaugeRearColor : (styleData.value > gauge.value-1 ? "red" : "root.gaugeFrontColor")
                color: styleData.value > gauge.value ? root.gaugeRearColor : lerpColor(root.gaugeFrontColor1, root.gaugeFrontColor2, styleData.value/gauge.maximumValue)
                width: gauge.width / 68.26
                height: gauge.width / 4.26
                antialiasing: true
            }
        }

        Text {
            id: gaugeValue
            text: root.value.toFixed(0)
            anchors { centerIn: parent }
            font.family: digital.name
            font.pixelSize: Math.min(gauge.width / 3, gauge.width/Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length)) // Scale the gauge font based on what the largest or smallest number that might be displayed
            renderType: Text.NativeRendering
        }
        Text {
            id: gaugeLabel
            text: unitLabel
            anchors {
                top: gaugeValue.bottom
                topMargin: - gauge.width / 25.6
                horizontalCenter: gaugeValue.horizontalCenter

            }
            font.pixelSize: gauge.width / 21.3
            font.italic: true
        }

        CircularGauge {
            id: ticksBackground
            z: -1
            width: parent.width
            height: parent.height
            anchors.centerIn: parent

            minimumValue: root.minimumValue
            maximumValue: root.maximumValue
            style : CircularGaugeStyle {
                tickmarkStepSize: root.tickmarkStepSize
                id: gaugeStyle2
                needle: null
                foreground: null
                minorTickmark: null

                tickmarkInset: -ticksBackground.width / 34
                labelInset: -ticksBackground.width / (15 - 1.2 * Math.max((root.maximumValue+ "").length, (root.minimumValue + "").length))  // Base label distance from gauge center on max/minValue
                Component.onCompleted: console.log(labelInset)
                minimumValueAngle: -145.25
                maximumValueAngle: 145.25
            }
        }
    }

    FontLoader {
        id: digital
        source: "fonts/digitalseven.ttf"
    }

    function lerpColor (color1, color2, x){
        if (Qt.colorEqual(color1, color2)){
            return color1;
        } else {
            return Qt.rgba(
                        color1.r * (1 - x) + color2.r * x,
                        color1.g * (1 - x) + color2.g * x,
                        color1.b * (1 - x) + color2.b * x, 1
                        );
        }
    }
}
