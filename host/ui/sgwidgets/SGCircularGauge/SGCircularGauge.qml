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
    property color gaugeFrontColor: "#aaddff"
    property bool demoColor: false

    CircularGauge {
        id: gauge
        value: (root.value-root.minimumValue)/(root.maximumValue-root.minimumValue)*200 // Normalize incoming values against 200 tickmarks
        anchors.centerIn: parent
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
//                color: styleData.value > gauge.value ? root.gaugeRearColor : (styleData.value > gauge.value-1 ? "red" : "#ff7777")
//                color: styleData.value > gauge.value ? root.gaugeRearColor : root.gaugeFrontColor
                color: styleData.value > gauge.value ? root.gaugeRearColor : lerpColor(Qt.rgba(0,.5,1,0), Qt.rgba(1, 0,0,1), styleData.value/200)
                width: 3.75
                height: 60
                antialiasing: true
            }

            //            tickmark: Canvas {
//                id: canvas
//                width: 8.9
//                height: 60
//                contextType: "2d"

//                Connections {
//                    target: gauge
//                    onValueChanged: canvas.requestPaint()
//                }

//                onPaint: {
//                    context.reset();
//                    context.moveTo(1, 1);
//                    context.lineTo(width, 1);
//                    context.lineTo(width-2, height-1);
//                    context.lineTo(2, height-1);
//                    context.closePath();
//                    context.fillStyle = styleData.value > gauge.value ? "#eeeeee" : ( styleData.value > gauge.value-1 ? "red" : "#ff7777")
//                    context.fill();
//                }
//            }
        }

        Text {
            text: root.value.toFixed(0)
            anchors.centerIn: parent
            font.family: digital.name
            font.pixelSize: 80
        }
    }

    FontLoader {
        id: digital
        source: "fonts/digitalseven.ttf"
    }

    function lerpColor (color1, color2, x){
        return Qt.rgba(
                    color1.r * (1 - x) + color2.r * x,
                    color1.g * (1 - x) + color2.g * x,
                    color1.b * (1 - x) + color2.b * x, 1
                    );
    }
}
