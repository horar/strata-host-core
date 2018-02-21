import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4
import QtPositioning 5.2
import QtQuick.Layouts 1.2

import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtPositioning 5.2
import QtQuick.Layouts 1.2

Slider {
    id: sgSlider

    maximumValue: 0
    minimumValue: 20
    value: 0.00
    stepSize: 10

    anchors.centerIn: parent

    property alias startLabel: startLabel.text
    property alias endLabel: endLabel.text
    property real hoverOpacity: 0

    style: SliderStyle {
        id: sliderStyle

        property bool hoverVisible: false

        groove: Rectangle {
            y: sgSlider.topPadding + sgSlider.availableHeight / 2 - height / 2
            implicitWidth: 200; implicitHeight: 4
            width: sgSlider.availableWidth; height: implicitHeight
            radius: 2
            color: "#bdbebf"

            Rectangle {
                width: sgSlider.visualPosition * parent.width; height: parent.height
                color: "yellow"
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
                anchors.bottom: valueIMG.top
                opacity: sgSlider.hoverOpacity

                Label {
                    id: check
                    text: sgSlider.value
                    font.pointSize: 6
                    font.bold: true
                    anchors.centerIn:  handler
                    anchors.verticalCenterOffset: -4

                }
            }
        }
    }

    PropertyAnimation {
        id: hoverShowAnimation
        target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 1; duration: 1000
    }

    PropertyAnimation {
        id: hoverHideAnimation
        target: sgSlider; properties: "hoverOpacity"; from: sgSlider.hoverOpacity; to: 0; duration: 1000
    }


    // monitor slider pressed
    onPressedChanged: {
        // show slider Hover when pressed, hide otherwise
        if( pressed ) {
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
        anchors.topMargin: 0.5
        font.pointSize: 12
        text: qsTr("0V")
    }

    Label {
        id: endLabel
        anchors.right:parent.right
        anchors.top : parent.bottom
        anchors.topMargin: 0.5
        font.pointSize: 12
        text: qsTr("20V")
    }
}
