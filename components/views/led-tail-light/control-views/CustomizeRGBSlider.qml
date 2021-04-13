import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Slider {
    id: root
    padding: 0
    value: 0
    height: 28
    width: 300
    live: false
    stepSize: 1
    property var rgbArray: hToRgb(value)
    property string color: "yellow"
    property int color_value: 0
    property real slider_start_color: 0
    property real slider_start_color2 : 1
    property real grooveHandleRatio: .2
    property color textColor: "black"
    property real fontSizeMultiplier: 1.0
    property bool showToolTip: true
    property color sliderColor: "White"

    signal userSet(real value)
    signal moved()
    orientation: Qt.Vertical
    onUserSet: {
        console.log("user set:", value)

    }
    function increase () {
        root.increase()
    }
    function decrease () {
        root.decrease()
    }

    property real lastValue
    onPressedChanged: {
        if (!live && !pressed && value.toFixed(0) != lastValue) {
            userSet(value.toFixed(0))
        } else {
            lastValue = value.toFixed(0)
        }
    }
    onMoved: {
        if (live && value !== lastValue){
            // QML Slider press/release while live results in onMoved calls (despite no movement and no value change)
            // this check filters out those calls and ensure userSet() only called when value changes
            userSet(value.toFixed(0))
            lastValue = value.toFixed(0)
        }
        root.moved()
    }

    property real roundedValue: parseFloat(value.toFixed(decimals))

    property int decimals: {
        if (stepSize === 0.0) {
            // stepSize of 0 logically means infinite decimals; 15 is max of double precision IEEE 754
            return 15
        } else if (Math.floor(root.stepSize) === root.stepSize) {
            return 0
        } else {
            return root.stepSize.toString().split(".")[1].length || 0
        }
    }


    background: Rectangle {
        id: groove
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
    handle: Rectangle {
        y: root.topPadding + root.visualPosition * (root.availableHeight - height)
        x: root.leftPadding + root.availableWidth / 2 - width / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: sliderColor
        border.color: sliderColor

        ToolTip {
            id: toolTip
            visible: root.showToolTip && root.pressed
            text: (root.valueAt(root.position))

            contentItem: SGText {
                id: toolTipText
                color: root.textColor
                text: toolTip.text
                font.family: Fonts.inconsolata
                fontSizeMultiplier: root.fontSizeMultiplier
            }

            background: Rectangle {
                id: toolTipBackground
                color: "#eee"
                radius: 2
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
