import QtQuick 2.12
import QtQuick.Controls 2.12

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: root
    implicitHeight: Math.max(sgSlider.height, inputContainer.height)
    implicitWidth: 200

    signal moved()
    signal userSet()
    signal programmaticallySet()

    property alias from: sgSlider.from
    property alias to: sgSlider.to
    property alias position: sgSlider.position
    property alias live: sgSlider.live
    property alias pressed: sgSlider.pressed
    property alias snapMode: sgSlider.snapMode
    property alias stepSize: sgSlider.stepSize
    property alias orientation: sgSlider.orientation
    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text

    property bool inputBox: true
    property bool showToolTip: true
    property color grooveColor: "#D9D9D9"
    property color grooveFillColor: "#808080"
    property color textColor: "black"
    property int toolTipDecimalPlaces: decimalPlacesFromStepSize
    property real fontSizeMultiplier: 1.0
    property real inputBoxWidth: 50

    property int decimalPlacesFromStepSize: {
        return (Math.floor(root.stepSize) === root.stepSize) ?
                    0 : root.stepSize.toString().split(".")[1].length || 0
    }

    property real value: (to - from) / 2
    onValueChanged: {
        sgSlider.value = value
    }
    function setValue(value) {
        value = parseFloat(value).toFixed(root.decimalPlacesFromStepSize)
        if (root.value != value) { //@disable-check M126
            root.value = value
            programmaticallySet()
        }
    }
    function userInput(value) {
        value = parseFloat(value).toFixed(root.decimalPlacesFromStepSize)
        if (root.value != value) { //@disable-check M126
            root.value = value
            userSet()
        }
    }

    Slider {
        id: sgSlider
        value: root.value
        from: 0
        to: 100
        live: false
        implicitWidth: root.width - inputContainer.width - inputContainer.anchors.leftMargin
        implicitHeight: startLabel.text === "" && endLabel.text === "" ? handleImg.height : handleImg.height + Math.max(startLabel.height, endLabel.height)
        padding: 0
        anchors {
            verticalCenter: root.verticalCenter
        }
        enabled: root.enabled
        opacity: root.enabled ? 1 : .5
        layer.enabled: root.enabled ? false : true
        onMoved: root.moved()
        onPressedChanged: {
            if (!pressed) {
                if (value.toFixed(decimalPlacesFromStepSize) != root.value) {
                    root.userInput(value.toFixed(decimalPlacesFromStepSize))
                }
            }
        }
        onValueChanged: {
            root.userInput(value.toFixed(decimalPlacesFromStepSize))
        }
        snapMode: Slider.SnapOnRelease

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
                width: sgSlider.visualPosition * groove.width
                height: groove.height
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

        SGText {
            id: startLabel
            anchors.bottom : sgSlider.bottom
            text: sgSlider.from
            color: root.textColor
            fontSizeMultiplier: root.fontSizeMultiplier
        }

        SGText {
            id: endLabel
            anchors.right : sgSlider.right
            anchors.bottom : sgSlider.bottom
            text: sgSlider.to
            color: root.textColor
            fontSizeMultiplier: root.fontSizeMultiplier
        }
    }

    Rectangle {
        id: inputContainer
        anchors {
            left: sgSlider.right
            verticalCenter: root.verticalCenter
            leftMargin: 5
        }
        height: root.inputBox ? infoText.height : 0
        width: root.inputBox ? root.inputBoxWidth : 0
        visible: root.inputBox
        color: "white"
        border {
            width: 1
            color: "#D9D9D9"
        }
        clip: true

        TextInput {
            id: infoText
            padding: 5
            anchors {
                left: inputContainer.left
                right: inputContainer.right
            }
            text: root.value
            selectByMouse: true
            readOnly: false
            font {
                family: Fonts.inconsolata // inconsolata is monospaced and has clear chars for O/0 etc
                pixelSize: SGSettings.fontPixelSize * root.fontSizeMultiplier
            }
            horizontalAlignment: TextInput.AlignRight
            validator: realNumberValidator
            enabled: root.enabled
            color: root.textColor
            opacity: root.enabled ? 1 : 0.5
            onEditingFinished: {
                root.userInput(parseFloat(this.text))
            }
            onAccepted: {
                root.userInput(parseFloat(this.text))
            }

            DoubleValidator {
                id: realNumberValidator
            }

            MouseArea {
                visible: !infoText.readOnly
                anchors {
                    fill: infoText
                }
                cursorShape: Qt.IBeamCursor
                acceptedButtons: Qt.NoButton
            }
        }
    }
}
