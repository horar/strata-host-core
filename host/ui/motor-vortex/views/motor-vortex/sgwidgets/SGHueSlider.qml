import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0

Item {
    id: root

    property real value: 128

    property string label: ""
    property bool labelLeft: true
    property color textColor : "black"
    property real sliderHeight: 28

    implicitHeight: labelLeft ? Math.max(labelText.height, sliderHeight) : labelText.height + sliderHeight + hueSlider.anchors.topMargin
    implicitWidth: 300

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? hueSlider.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (hueSlider.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Slider {
        id: hueSlider
        padding: 0
        value: root.value/255
        height: root.sliderHeight
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
            right: root.right
        }

        onPressedChanged: {
            if (!hueSlider.pressed) {
                root.value = Math.floor(value * 255)
            }
        }

        background: Rectangle {
            y: 4
            width: hueSlider.width
            height: hueSlider.height-8
            radius: 5
            layer.enabled: true
            layer.effect: LinearGradient {
                start: Qt.point(0, 0)
                end: Qt.point(width, 0)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.hsva(0.0,1,1,1) }
                    GradientStop { position: 0.1667; color: Qt.hsva(0.1667,1,1,1) }
                    GradientStop { position: 0.3333; color: Qt.hsva(0.3333,1,1,1) }
                    GradientStop { position: 0.5; color: Qt.hsva(0.5,1,1,1) }
                    GradientStop { position: 0.6667; color: Qt.hsva(0.6667,1,1,1) }
                    GradientStop { position: 0.8333; color: Qt.hsva(0.8333,1,1,1) }
                    GradientStop { position: 1.0; color: Qt.hsva(1.0,1,1,1) }
                }
            }
        }

        handle: Item {
            x: hueSlider.leftPadding + hueSlider.visualPosition * (hueSlider.availableWidth - width)
            y: 0
            width: 12
            height: sliderHeight

            Canvas {
                z:50
                visible: true
                implicitWidth: parent.width
                implicitHeight: parent.height
                contextType: "2d"

                onPaint: {
                    context.reset();
                    context.lineWidth = 1
                    context.strokeStyle = "#888"
                    context.fillStyle = "#eee";

                    context.beginPath();
                    context.moveTo(0, 0);
                    context.lineTo(width, 0);
                    context.lineTo(width, 7);
                    context.lineTo(width/2, 12);
                    context.lineTo(0, 7);
                    context.lineTo(0, 0);

                    context.moveTo(0, height);
                    context.lineTo(width, height);
                    context.lineTo(width, height-7);
                    context.lineTo(width/2, height-12);
                    context.lineTo(0, height-7);
                    context.closePath();
                    context.fill();
                    context.stroke();
                }
            }
        }
    }

    function lerpColor (color1, color2, x){
        if (Qt.colorEqual(color1, color2)){
            return color1;
        } else {
            return Qt.hsva(
                color1.hsvHue * (1 - x) + color2.hsvHue * x,
                color1.hsvSaturation * (1 - x) + color2.hsvSaturation * x,
                color1.hsvValue * (1 - x) + color2.hsvValue * x, 1
                );
        }
    }

}
