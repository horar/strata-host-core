import QtQuick 2.7
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4

// TODO - Faller 5/30/18: encapsulate slider in a container to spec height so hover bubble/labels don't get cut off (?)

// Note - Faller 5/30/18: there was some Controls 2.3 code (updated slider) in groove that was conflicting and doing nothing.
//                        If this ever is converted to QC 2.3+, go find an old version that has this code to start from.

Item{
    id: container
    width: 200
    height: 28

    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text
    property int decimalPlaces: 0
    property alias maximumValue: sgSlider.maximumValue
    property alias minimumValue: sgSlider.minimumValue
    property alias value: sgSlider.value
    property alias stepSize: sgSlider.stepSize
    property bool showDial: true

    Slider {
        id: sgSlider

        property real hoverOpacity: 0

        minimumValue: 0.0
        maximumValue: 100.0
        value: 0.0
        stepSize: 1.0
        anchors {
            centerIn: parent
        }

        style: SliderStyle {
            id: sliderStyle

            groove: Rectangle {
                implicitWidth: container.width
                implicitHeight: 4
                width: container.width
                height: implicitHeight
                radius: 2
                z:1
                color: "#dddddd"

                Rectangle {
                    id: grooveShadow
                    width: parent.width
                    height: 1
                    z:2
                    color: "#bbbbbb"
                    anchors {
                        top: parent.top
                    }
                }

                Rectangle {
                    id: grooveFill
                    width: styleData.handlePosition
                    height: parent.height
                    z:3
                    color: "#888888"
                    radius: 2

                    Rectangle {
                        id: fillShadow
                        width: parent.width
                        height: 1
                        color: "#666666"
                        z:4
                        anchors {
                            top: parent.top
                        }
                    }
                }
            }

            handle: Image {
                id: valueIMG
                anchors { centerIn: parent }
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
                    anchors.verticalCenterOffset: -19
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

        PropertyAnimation {
            id: hoverShowAnimation
            target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 1; duration: 100
        }

        PropertyAnimation {
            id: hoverHideAnimation
            target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 0; duration: 100
        }


        // monitor slider pressed
        onPressedChanged: {
            // show slider dial when pressed, hide otherwise
            if (showDial){
                if ( pressed ) {
                    console.log("slider pressed. show dial.")
                    hoverShowAnimation.start()
                }
                else {
                    console.log("slider released. hide dial.")
                    hoverHideAnimation.start()
                }
            }
        }

        Label {
            id: startLabel
            anchors.top : parent.bottom
            anchors.topMargin: -4.0
            font.pointSize: 12
            text: qsTr("0")
        }

        Label {
            id: endLabel
            anchors.right:parent.right
            anchors.top : parent.bottom
            anchors.topMargin: -4.0
            font.pointSize: 12
            text: qsTr("100")
        }
    }
}
