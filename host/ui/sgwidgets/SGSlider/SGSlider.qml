import QtQuick 2.9
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4

// Note - Faller 5/30/18: there was some Controls 2.3 code (updated slider) in groove that was conflicting and doing nothing.
//                        If this ever is converted to QC 2.3+, go find an old version that has this code to start from.

Item{
    id: root
    implicitWidth: 200
    implicitHeight: root.labelLeft ? sgSlider.height : sgSlider.height + labelText.height

    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text
    property alias maximumValue: sgSlider.maximumValue
    property alias minimumValue: sgSlider.minimumValue
    property alias value: sgSlider.value
    property alias stepSize: sgSlider.stepSize

    property string label: ""
    property bool labelLeft: true
    property int decimalPlaces: 0
    property bool showDial: true
    property color grooveColor: "#dddddd"
    property color grooveFillColor: "#888888"

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? sgSlider.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (sgSlider.height-contentHeight)/2 : 0
        bottomPadding: topPadding
    }

    Slider {
        id: sgSlider

        property real hoverOpacity: 0

        height: 30
        minimumValue: 0.0
        maximumValue: 100.0
        value: 0.0
        stepSize: 1.0
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }

        style: SliderStyle {
            id: sliderStyle
            property real offset: -8

            groove: Rectangle {
                id: groove
                implicitWidth: root.labelLeft ? root.width - labelText.width - sgSlider.anchors.leftMargin : root.width
                implicitHeight: 4
                radius: height/2
                y: sliderStyle.offset
                z: 1
                color: root.grooveColor

                Rectangle {
                    id: grooveShadow
                    width: parent.width-parent.radius*2
                    height: 1
                    z: 2
                    color: Qt.rgba(groove.color.r/1.3, groove.color.g/1.3, groove.color.b/1.3, 1)
                    anchors {
                        top: parent.top
                        horizontalCenter: parent.horizontalCenter
                    }
                }

                Rectangle {
                    id: grooveFill
                    width: styleData.handlePosition
                    height: parent.height
                    anchors {
                        left: parent.left
                        top: parent.top
                    }
                    z:3
                    color: grooveFillColor
                    radius: height/2

                    Rectangle {
                        id: fillShadow
                        width: parent.width-parent.radius*2
                        height: 1
                        color: Qt.rgba(grooveFill.color.r/1.3, grooveFill.color.g/1.3, grooveFill.color.b/1.3, 1)
                        y: groove.y
                        z:4
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }

            handle: Image {
                id: valueIMG
                y: sliderStyle.offset
                width: 34.3
                height: 18.6
                source: sgSlider.pressed ? "./images/sliderHandleActive.svg" : "./images/sliderHandle.svg"
                mipmap: true

                Image {
                    id: handler
                    width: 2
                    height: 24
                    source: "./images/sliderValue.svg"
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: sliderStyle.offset-8
                    opacity: sgSlider.hoverOpacity

                    Label {
                        id: check
                        color: "white"
                        text: sgSlider.value.toFixed(decimalPlaces)
                        font.pointSize: 8
                        anchors.centerIn:  handler
                        anchors.verticalCenterOffset: -3
                        onTextChanged: {
                            handler.width = check.width + 12;
                        }
                    }
                }
            }
        }

        Label {
            id: startLabel
            anchors.bottom : parent.bottom
            font.pointSize : 12
            text: sgSlider.minimumValue
        }

        Label {
            id: endLabel
            anchors.right : parent.right
            anchors.bottom : parent.bottom
            font.pointSize: 12
            text: sgSlider.maximumValue
        }

        PropertyAnimation {
            id: hoverShowAnimation
            target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 1; duration: 100
        }

        PropertyAnimation {
            id: hoverHideAnimation
            target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 0; duration: 100
        }

        // Monitor slider pressed
        onPressedChanged: {
            // Show slider dial when pressed, hide otherwise
            if (showDial){
                if ( pressed ) {
                    hoverShowAnimation.start()
                }
                else {
                    hoverHideAnimation.start()
                }
            }
        }
    }
}
