import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root

    implicitWidth: 200
    implicitHeight: root.labelLeft ? sgSlider.height : sgSlider.height + labelText.height + sgSlider.anchors.topMargin

    signal moved()

    property alias from: sgSlider.from
    property alias to: sgSlider.to
    property alias value: sgSlider.value
    property alias position: sgSlider.position
    property alias live: sgSlider.live
    property alias pressed: sgSlider.pressed
    property alias snapMode: sgSlider.snapMode
    property alias stepSize: sgSlider.stepSize
    property alias orientation: sgSlider.orientation
    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text

    property bool showToolTip: true
    property color grooveColor: "#dddddd"
    property color grooveFillColor: "#888888"
    property color textColor: "#000000"
    property string label: ""
    property bool labelLeft: true
    property int toolTipDecimalPlaces: 0

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? sgSlider.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (sgSlider.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Slider {
        id: sgSlider
        value: 50
        from: 0
        to: 100
        live: false
        implicitWidth: root.labelLeft ? root.width - labelText.width - sgSlider.anchors.leftMargin : root.width
        implicitHeight: startLabel.text === "" && endLabel.text === "" ? handleImg.height : handleImg.height + Math.max(startLabel.height, endLabel.height)
        padding: 0
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        enabled: root.enabled
        opacity: root.enabled ? 1 : .5
        layer.enabled: root.enabled ? false : true

        background: Rectangle {
            id: groove
            y: handleImg.height / 2 - height / 2
            width: sgSlider.width
            implicitHeight: 4
            height: implicitHeight
            radius: 2
            color: root.grooveColor

            Rectangle {
                id: grooveFill
                width: sgSlider.visualPosition * parent.width
                height: parent.height
                color: root.grooveFillColor
                radius: 2
            }

            // TODO: Faller - fix up the following repeater to make tickmarks at user specified intervals
//            Repeater {
//                id: tickRepeater
//                model: 9

//                Rectangle {
//                    id: tickMarks
//                    color: "#ddd"
//                    height: 6
//                    width: 1
//                    anchors {
//                        top: groove.bottom
//                        topMargin: 2
//                    }
//                    z: -1
//                    x: (index + 1) * (sgSlider.width - sgSlider.handle.width) / 10 + sgSlider.handle.width/2
//                }
//            }
        }

        handle: Image {
            id: handleImg
            x: sgSlider.visualPosition * (sgSlider.width - width + 4) - 2
            width: 32
            height: 16
            source: sgSlider.pressed ? "./images/sliderHandleActive.svg" : "./images/sliderHandle.svg"
            mipmap: true
        }

        ToolTip {
            id: toolTip
            parent: sgSlider.handle
            visible: root.showToolTip ? sgSlider.pressed : false
            text: (sgSlider.valueAt(sgSlider.position)).toFixed(root.toolTipDecimalPlaces)

            contentItem: Text {
                color: root.textColor
                text: toolTip.text
            }

            background: Rectangle {
                id: toolTipBackground
                color: "#eee"
                radius: 2
            }
        }

        Label {
            id: startLabel
            anchors.bottom : parent.bottom
            font.pixelSize : 12
            text: sgSlider.from
            color: root.textColor
        }

        Label {
            id: endLabel
            anchors.right : parent.right
            anchors.bottom : parent.bottom
            font.pixelSize: 12
            text: sgSlider.to
            color: root.textColor
        }
    }
}
