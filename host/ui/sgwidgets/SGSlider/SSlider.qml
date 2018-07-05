import QtQuick 2.9
import QtQuick.Controls 2.3

Item {
    id: root

    // ADD start and stop labels
    // finish adding main label
    // add remaining properties, and add signals

    property bool showDial: true
    property color grooveColor: "#dddddd"
    property color grooveFillColor: "#888888"
    property color textColor: "#000000"
    property string label: ""
    property bool labelLeft: true

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
        value: 0.5
        leftPadding: handleImg.width / 2
        rightPadding: handleImg.width / 2
        implicitWidth: background.width + handleImg.width / 2
        implicitHeight: handleImg.height - 6
        enabled: root.enabled
        opacity: root.enabled ? 1 : .5
        layer.enabled: root.enabled ? false : true



        background: Rectangle {
            x: handleImg.width / 4
            y: (handleImg.height - 6) / 2 - height / 2
            //        implicitWidth: 200
            width: 200
            implicitHeight: 4
            height: implicitHeight
            radius: 2
            color: "#bdbebf"

            Rectangle {
                width: sgSlider.visualPosition * parent.width
                height: parent.height
                color: "#21be2b"
                radius: 2
            }
        }

        handle:
            //        Rectangle {
            //        x: sgSlider.leftPadding + sgSlider.visualPosition * (sgSlider.availableWidth - width)
            //        y: sgSlider.topPadding + sgSlider.availableHeight / 2 - height / 2
            //        implicitWidth: 26
            //        implicitHeight: 26
            //        radius: 13
            //        color: sgSlider.pressed ? "#f0f0f0" : "#f6f6f6"
            //        border.color: "#bdbebf"
            //    }
            Image {
            id: handleImg
            x: sgSlider.visualPosition * (sgSlider.background.width - width/2)
            y: -3
            width: 34.3
            height: 18.6
            source: sgSlider.pressed ? "./images/sliderHandleActive.svg" : "./images/sliderHandle.svg"
            mipmap: true
        }
    }
}
