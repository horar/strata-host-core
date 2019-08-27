import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0

Slider {
    id: hueSlider
    padding: 0
    value: 128
    height: 28
    width: 300
    live: false
    from: 0
    to: 255
    opacity: enabled ? 1 : 0.5

    property string color1: "red"
    property string color2: "green"
    property int color_value1: 0
    property int color_value2: 0
    property var rgbArray: [0,0,0]
    property bool powerSave: false

    background: Rectangle {
        y: 4
        width: hueSlider.width
        height: hueSlider.height-8
        radius: 5
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.hsva(0.0,1,1,1) }
            GradientStop { position: 0.1667; color: Qt.hsva(0.1667,1,1,1) }
            GradientStop { position: 0.3333; color: Qt.hsva(0.3333,1,1,1) }
            GradientStop { position: 0.5; color: Qt.hsva(0.5,1,1,1) }
            GradientStop { position: 0.6667; color: Qt.hsva(0.6667,1,1,1) }
            GradientStop { position: 0.8333; color: Qt.hsva(0.8333,1,1,1) }
            GradientStop { position: 1.0; color: Qt.hsva(1.0,1,1,1) }
        }
    }

    handle: Item {
        id: handle
        x: hueSlider.leftPadding + hueSlider.visualPosition * (hueSlider.availableWidth - width)
        y: 0
        width: 12
        height: hueSlider.height

        Canvas {
            z:50
            visible: true
            implicitWidth: handle.width
            implicitHeight: handle.height
            contextType: "2d"

            onPaint: {
                var context = getContext("2d")
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


    onValueChanged: {
        if (powerSave) {
            rgbArray = hueToRgbPowerSave(value/255)
        } else {
            rgbArray = hsvToRgb(value/255, 1, 1)
        }

        if (rgbArray[0] === '0') {
            color1 = "green"
            color_value1 = rgbArray[1]
            color2 = "blue"
            color_value2 = rgbArray[2]
        } else if (rgbArray[1] === '0') {
            color1 = "blue"
            color_value1 = rgbArray[2]
            color2 = "red"
            color_value2 = rgbArray[0]
        } else {
            color1 = "red"
            color_value1 = rgbArray[0]
            color2 = "green"
            color_value2 = rgbArray[1]
        }
    }

    function hueToRgbPowerSave (h) {  // PowerSave mode for mixing 2 colors (max 255 value between 2 colors)
        var r, g, b;

        var i = Math.floor(h * 3);
        var f = h * 3 - i;

        switch(i % 3){
        case 0: r = 1-f; g = f; b = 0; break;
        case 1: r = 0; g = 1-f; b = f; break;
        case 2: r = f; g = 0; b = 1-f; break;
        }

        return [(r * 255).toFixed(0), (g * 255).toFixed(0), (b * 255).toFixed(0)];
    }

    function hsvToRgb(h, s, v){  // Regular RGB color mixing mode
        var r, g, b;

        var i = Math.floor(h * 6);
        var f = h * 6 - i;
        var p = v * (1 - s);
        var q = v * (1 - f * s);
        var t = v * (1 - (1 - f) * s);

        switch(i % 6){
        case 0: r = v; g = t; b = p; break;
        case 1: r = q; g = v; b = p; break;
        case 2: r = p; g = v; b = t; break;
        case 3: r = p; g = q; b = v; break;
        case 4: r = t; g = p; b = v; break;
        case 5: r = v; g = p; b = q; break;
        }

        return [(r * 255).toFixed(0), (g * 255).toFixed(0), (b * 255).toFixed(0)];
    }
}
