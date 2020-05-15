import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

Slider {
    id: root
    padding: 0
    value: 0
    height: 28
    width: 300
    live: false
    property var rgbArray: hToRgb(value)
    property string color: "yellow"
    property int color_value: 0
    property real slider_start_color: 0
    property real slider_start_color2 : 1
    signal userSet(real value)
    signal moved()
    onUserSet: console.log("user set:", value)
    function increase () {
        increase()
    }
    function decrease () {
        decrease()
    }
    function valueAt (position) {
        return valueAt(position)
    }
    property real lastValue
    onPressedChanged: {
        if (!live && !pressed) {
            if (value !== lastValue){
                userSet(value)
            }
        } else {
            lastValue = value
        }
    }
    onMoved: {
        if (live && value !== lastValue){
            // QML Slider press/release while live results in onMoved calls (despite no movement and no value change)
            // this check filters out those calls and ensure userSet() only called when value changes
            userSet(value)
            lastValue = value
        }
        root.moved()
    }
    background: Rectangle {
        y: 4
        x: 5
        width: root.width-10
        height: root.height-8
        radius: 5
        layer.enabled: true
        layer.effect: LinearGradient {
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.hsva(root.slider_start_color,root.slider_start_color2,1,1) }
                GradientStop { position: 1.0; color: Qt.hsva(0.0,1,0,1) }
            }
        }
    }
    // Dumbed down version of hsvToRgb function to match simpler RGB gradient slider
    function hToRgb(h){
        var r, g, b;
        var i = Math.floor(h * 3);
        var f = h * 3 - i;
        var q = 1 - f;
        if (i < 3){
            switch(i % 3){
            case 0: r = q; g = 0; b = 0; break;
            case 1: r = 0; g = q; b = 0; break;
            case 2: r = 0; g = 0; b = q; break;
            }
        } else {
            r = 0; g = 0; b = 0;
        }
        return [(r * 255).toFixed(0), (g * 255).toFixed(0), (b * 255).toFixed(0)];
    }
}
