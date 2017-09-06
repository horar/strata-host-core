
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
    id: portVoltageSlider

    maximumValue: 0
    minimumValue: 20
    value: 0.00
    stepSize: 10

    anchors.centerIn: parent

    property alias label5: label5
    property alias label4: label4
    property real hoverOpacity: 0
    PropertyAnimation {
        id: hoverShowAnimation
        target: portVoltageSlider; properties: "hoverOpacity"; from: portVoltageSlider.hoverOpacity; to: 1; duration: 1000
    }

    PropertyAnimation {
        id: hoverHideAnimation
        target: portVoltageSlider; properties: "hoverOpacity"; from: portVoltageSlider.hoverOpacity; to: 0; duration: 1000
    }

   style: SliderStyle {
        id: sliderStyle

        property bool hoverVisible: false

        groove: Rectangle {
            y: portVoltageSlider.topPadding + portVoltageSlider.availableHeight / 2 - height / 2
            implicitWidth: 200; implicitHeight: 4
            width: portVoltageSlider.availableWidth; height: implicitHeight
            radius: 2
            color: "#bdbebf"

            Rectangle {
                width: portVoltageSlider.visualPosition * parent.width; height: parent.height
                color: "yellow"
                radius: 2
            }
        }

        handle: Image {

            // ID first
            id: valueIMG

            // anchoring 2nd
            anchors { centerIn: parent }

            // dimensions 3rd
            width: 22; height: 24

            // content last
            source: "./images/sliderThumb.svg"

            Image {
                id: handler
                width: 22
                height: 24
                source: "./images/sliderValue.svg"
                anchors.bottom: valueIMG.top
                opacity: portVoltageSlider.hoverOpacity

                Label {
                    id: check
                    text: portVoltageSlider.value
                    font.pointSize: 6
                    font.bold: true
                    anchors.centerIn:  handler
                    anchors.verticalCenterOffset: -4

               }
            }
        }
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
        id: label4
        anchors.top : parent.bottom
        anchors.topMargin: 0.5
        font.pointSize: parent.height/2 * 3
        text: qsTr("0V")
    }

    Label {
        id: label5
        anchors.right:parent.right
        anchors.top : parent.bottom
        anchors.topMargin: 0.5
        font.pointSize: parent.height/2 * 3
        text: qsTr("20V")
    }
}
