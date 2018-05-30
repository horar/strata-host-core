import QtQuick 2.7
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls 1.4

// Todo - Faller 5/30/18: encapsulate slider in a container to spec height so hover bubble/labels don't get cut off (?)

// Note - Faller 5/30/18: there was some Controls 2.3 code (updated slider) in groove that was conflicting and doing nothing.
//                        If this ever is converted to QC 2.3+, go find an old version that has this code to start from.

Slider {
    id: sgSlider

    minimumValue: 0.0
    maximumValue: 100.0
    value: 0.0
    stepSize: 1.0

    anchors.centerIn: parent

    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text
    property int decimalPlaces: 0
    property alias maximumValue: sgSlider.maximumValue
    property alias minimumValue: sgSlider.minimumValue
    property alias value: sgSlider.value
    property alias stepSize: sgSlider.stepSize
    property real hoverOpacity: 0

    style: SliderStyle {
        id: sliderStyle

        property bool hoverVisible: false

        groove: Rectangle {
            Component.onCompleted: {console.log(sliderStyle.height)}
            y: -2
            implicitWidth: 200; implicitHeight: 4
            width: sgSlider.width; height: implicitHeight
            radius: 2
            color: "#dddddd"

            Rectangle {
                id: grooveFill
                width: styleData.handlePosition; height: parent.height
                color: "#888888"
                radius: 2
            }
        }

        handle: Image {
            id: valueIMG
            anchors { centerIn: parent }
            width: 22; height: 24
            source: "./images/sliderThumb.svg"

            Image {
                id: handler
                width: 22; height: 24
                source: "./images/sliderValue.svg"
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -19
                opacity: hoverOpacity

                Label {
                    id: check
                    text: sgSlider.value.toFixed(decimalPlaces)
                    font.pointSize: 6
                    font.bold: true
                    anchors.centerIn:  handler
                    anchors.verticalCenterOffset: -2
                }
            }
        }
    }

    PropertyAnimation {
        id: hoverShowAnimation
        target: sgSlider; properties: "hoverOpacity"; from: hoverOpacity; to: 1; duration: 100
    }

    PropertyAnimation {
        id: hoverHideAnimation
        target: sgSlider; properties: "hoverOpacity"; from: hoverOpacity; to: 0; duration: 100
    }


    // monitor slider pressed
    onPressedChanged: {
        // show slider Hover when pressed, hide otherwise
        if ( pressed ) {
            console.log("slider pressed. show hover.")
            hoverShowAnimation.start()
        }
        else {
            console.log("slider released. hide hover.")
            hoverHideAnimation.start()
        }
    }

    Label {
        id: startLabel
        anchors.top : parent.bottom
        anchors.topMargin: -6.0
        font.pointSize: 12
        text: qsTr("0")
    }

    Label {
        id: endLabel
        anchors.right:parent.right
        anchors.top : parent.bottom
        anchors.topMargin: -6.0
        font.pointSize: 12
        text: qsTr("100")
    }
}
