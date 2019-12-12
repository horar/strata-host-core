import QtQuick 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.0
import tech.strata.sgwidgets 1.0

Item {
    id: capacityBarContainer
    implicitWidth: 300
    height: gauge.height + capacityBar.height

    signal overThreshold()

    // Optional Configurations:
    property color textColor: "black"
    property bool showThreshold: false
    property real thresholdValue: maximumValue
    property bool thresholdExceeded: false
    property real fontSizeMultiplier: 1.0

    property alias minimumValue: gauge.minimumValue
    property alias maximumValue: gauge.maximumValue

    Rectangle {
        id: capacityBar
        height: 32
        anchors {
            top: capacityBarContainer.top
            right: capacityBarContainer.right
            rightMargin: 10
            left: capacityBarContainer.left
            leftMargin: anchors.rightMargin + 1
        }
        color: "#252838"
        border {
            width: 1
            color: capacityBar.color
        }
        clip: true

        property var elementsList: []

        Rectangle {
            id: threshold
            visible: capacityBarContainer.showThreshold
            anchors {
                top: capacityBar.top
                topMargin: 1
                bottom: capacityBar.bottom
                bottomMargin: 1
                right: capacityBar.right
                rightMargin: 1
            }
            color: "#961b1e"
            width: (1 - (capacityBarContainer.thresholdValue / capacityBarContainer.maximumValue)) * capacityBar.width
        }

        Row {
            id: gaugeElements
            spacing: 1
            anchors {
                top: capacityBar.top
                topMargin: 1
                bottom: capacityBar.bottom
                bottomMargin: 1
                left: capacityBar.left
                leftMargin: 1
            }

            property real minimumValue: gauge.minimumValue
            property real maximumValue: gauge.maximumValue
            property real masterWidth: capacityBar.width
            property real totalValue: childrenRect.width

            onTotalValueChanged: {
                if (totalValue > capacityBar.width - threshold.width && !capacityBarContainer.thresholdExceeded) {
                    capacityBarContainer.overThreshold()
                    capacityBarContainer.thresholdExceeded = true
                } else if (totalValue < capacityBar.width - threshold.width && capacityBarContainer.thresholdExceeded) {
                    capacityBarContainer.thresholdExceeded = false
                }
            }
        }

        Component.onCompleted: {
            reparentChildren()
        }

        function reparentChildren () {
            for (var i = 0; i < capacityBarContainer.children.length; i++){
                if (capacityBarContainer.children[i].objectName === "capacityBarElement") {
                    elementsList.push(capacityBarContainer.children[i])
                }
            }

            for (i = 0; i < elementsList.length; i++){
                elementsList[i].parent = gaugeElements
                elementsList[i].capacityBar = gaugeElements
            }
        }
    }

    Gauge {
        id: gauge
        width: capacityBarContainer.width
        anchors {
            top: capacityBar.bottom
            topMargin: 0
            left: capacityBarContainer.left
        }
        orientation: Qt.Horizontal

        tickmarkStepSize: (maximumValue-minimumValue)/5
        minorTickmarkCount: 1
        maximumValue: 100
        minimumValue: 0

        style: GaugeStyle {
            background: null
            foreground: null
            valueBar: Rectangle {
                implicitWidth: 0
            }

            tickmarkLabel: SGText {
                text: styleData.value.toFixed(0)
                implicitColor: capacityBarContainer.textColor
                fontSizeMultiplier: capacityBarContainer.fontSizeMultiplier
            }

            tickmark: Item {
                id: majorTickmark
                implicitWidth: 8
                implicitHeight: 2

                Rectangle {
                    x: control.tickmarkAlignment === Qt.AlignLeft
                       || control.tickmarkAlignment === Qt.AlignTop ? majorTickmark.implicitWidth : 0
                    width: 8
                    height: majorTickmark.height
                    color: "#999"
                }
            }

            minorTickmark: Item {
                id: minorTickmarks
                implicitWidth: 8
                implicitHeight: 1

                Rectangle {
                    x: control.tickmarkAlignment === Qt.AlignLeft
                       || control.tickmarkAlignment === Qt.AlignTop ? minorTickmarks.implicitWidth : 0
                    width: 4
                    height: minorTickmarks.height
                    color: "#999"
                }
            }
        }
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
