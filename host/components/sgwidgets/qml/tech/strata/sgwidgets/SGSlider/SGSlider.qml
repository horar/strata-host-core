import QtQuick 2.12
import QtQuick.Controls 2.12

import tech.strata.theme 1.0

Item {
    id: root
    implicitWidth: 200
    implicitHeight: root.labelLeft ? controlContainer.height : controlContainer.height + labelText.height + controlContainer.anchors.topMargin

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
    property alias overrideLabelWidth: labelText.width
    property alias endLabel: endLabel.text

    property bool inputBox: true
    property bool labelTopAligned: false
    property bool showToolTip: true
    property color grooveColor: "#dddddd"
    property color grooveFillColor: "#888888"
    property color textColor: "#000000"
    property string label: ""
    property bool labelLeft: true
    property int toolTipDecimalPlaces: 0

    property real value: (to - from) / 2
    onValueChanged: {
        sgSlider.value = value
        if (inputBox) {
            infoText.text = value
        }
    }
    function setValue(value) {
        if (root.value !== value) {
            root.value = value
            programmaticallySet()
        }
    }
    function userInput(value) {
        if (root.value !== value) {
            root.value = value
            userSet()
        }
    }

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? controlContainer.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? labelTopAligned ? 0 : (controlContainer.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Item {
        id: controlContainer
        implicitHeight: Math.max(sgSlider.height, inputContainer.height)
        implicitWidth: root.labelLeft ? root.width - labelText.width - this.anchors.leftMargin : root.width
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }

        Slider {
            id: sgSlider
            value: root.value
            from: 0
            to: 100
            live: false
            implicitWidth: controlContainer.width - inputContainer.width
            implicitHeight: startLabel.text === "" && endLabel.text === "" ? handleImg.height : handleImg.height + Math.max(startLabel.height, endLabel.height)
            padding: 0
            anchors {
                verticalCenter: controlContainer.verticalCenter
            }
            enabled: root.enabled
            opacity: root.enabled ? 1 : .5
            layer.enabled: root.enabled ? false : true
            onMoved: root.moved()
            onPressedChanged: {
                if (!pressed) {
                    root.userInput(value)
                }
            }
            onValueChanged: {
                root.userInput(value)
            }

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

            Label {
                id: startLabel
                anchors.bottom : sgSlider.bottom
                font.pixelSize : 12
                text: sgSlider.from
                color: root.textColor
            }

            Label {
                id: endLabel
                anchors.right : sgSlider.right
                anchors.bottom : sgSlider.bottom
                font.pixelSize: 12
                text: sgSlider.to
                color: root.textColor
            }
        }

        Item {
            id: inputContainer
            anchors {
                left: sgSlider.right
                verticalCenter: controlContainer.verticalCenter
            }
            height: root.inputBox ? infoText.height : 0
            width: root.inputBox ? 50 : 0
            visible: root.inputBox

            TextInput {
                id: infoText
                padding: 5
                anchors {
                    left: inputContainer.left
                    right: inputContainer.right
                    leftMargin: 5
                }
                text: root.value
                selectByMouse: true
                readOnly: false
                font {
//                    family: inconsolata.name // inconsolata is monospaced and has clear chars for O/0 etc
                    pixelSize: Theme.basePixelSize
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
                clip: true

                RegExpValidator {
                    id: realNumberValidator
                    regExp: /[-+]?([0-9]*\.[0-9]+|[0-9]+)/
                }

                MouseArea {
                    visible: !infoText.readOnly
                    anchors {
                        fill: infoText
                    }
                    cursorShape: Qt.IBeamCursor
                    acceptedButtons: Qt.NoButton
                }

                Rectangle {
                    color: "transparent"
                    border {
                        width: 1
                        color: "lightgrey"
                    }
                    anchors {
                        fill: infoText
                    }
                }
            }
        }
    }
}
