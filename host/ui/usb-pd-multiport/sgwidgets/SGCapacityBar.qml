import QtQuick 2.9
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: root

    signal overThreshold()

    // Optional Configurations:
    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"
    property bool showThreshold: false
    property real thresholdValue: maximumValue
    property real minimumValue: 0
    property real maximumValue: 100
    property real barWidth: 300

    property alias gaugeElements : gaugeElements.sourceComponent

    property bool thresholdExceeded: false

    implicitWidth: root.labelLeft ? labelText.width + capacityBarContainer.anchors.leftMargin + capacityBarContainer.width : Math.max(labelText.width, capacityBarContainer.width)
    implicitHeight: root.labelLeft ? Math.max(labelText.height, capacityBarContainer.height) :labelText.height + capacityBarContainer.anchors.topMargin + capacityBarContainer.height

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 : root.labelLeft ? capacityBar.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (capacityBar.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    Rectangle {
        id: capacityBarContainer
        anchors {
            left: root.labelLeft ? labelText.right : parent.left
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            top: root.labelLeft ? labelText.top : labelText.bottom
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        implicitWidth: root.barWidth
        height: gauge.height + capacityBar.height

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
                color: colorMod(capacityBar.color, -0.1)
            }
            clip: true

            Rectangle {
                id: threshold
                visible: root.showThreshold
                anchors {
                    top: capacityBar.top
                    topMargin: 1
                    bottom: capacityBar.bottom
                    bottomMargin: 1
                    right: capacityBar.right
                    rightMargin: 1
                }
                color: "#961b1e"
                width: (1 - (root.thresholdValue / root.maximumValue)) * capacityBar.width
                //(root.thresholdValue-root.minimumValue)/(root.maximumValue-root.minimumValue)*300
            }

            Loader {
                id: gaugeElements

                property real masterMinimumValue: root.minimumValue
                property real masterMaximumValue: root.maximumValue
                property real masterWidth: capacityBar.width
                property real totalValue: gaugeElements.item.totalValue

                anchors {
                    top: capacityBar.top
                    topMargin: 1
                    bottom: capacityBar.bottom
                    bottomMargin: 1
                    left: capacityBar.left
                    leftMargin: 1
                }

                onTotalValueChanged: {
                    if (totalValue > capacityBar.width - threshold.width && !root.thresholdExceeded) {
                        root.overThreshold()
                        root.thresholdExceeded = true
                    } else if (totalValue < capacityBar.width - threshold.width && root.thresholdExceeded) {
                        root.thresholdExceeded = false
                    }
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
            maximumValue: root.maximumValue
            minimumValue: root.minimumValue

            style: GaugeStyle {
                background: null
                foreground: null
                valueBar: Rectangle {
                    implicitWidth: 0
                }

                tickmarkLabel: Text {
                    text: styleData.value.toFixed(0)
                    color: root.textColor
                }

                tickmark: Item {
                    implicitWidth: 8
                    implicitHeight: 2

                    Rectangle {
                        x: control.tickmarkAlignment === Qt.AlignLeft
                           || control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : 0
                        width: 8
                        height: parent.height
                        color: "#999"
                    }
                }

                minorTickmark: Item {
                    implicitWidth: 8
                    implicitHeight: 1

                    Rectangle {
                        x: control.tickmarkAlignment === Qt.AlignLeft
                           || control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : 0
                        width: 4
                        height: parent.height
                        color: "#999"
                    }
                }
            }
        }
    }

    // Add increment to color (within range of 0-1) add to lighten, subtract to darken
    function colorMod (color, increment) {
        return Qt.rgba(color.r + increment, color.g + increment, color.b + increment, 1 )
    }
}
