import QtQuick 2.9
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: root

    property real input: 50

    // Optional Configurations:
    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"

    property real thresholdValue: 80
    property real minimumValue: 0
    property real maximumValue: 100
    property real threshold: 0

    property alias gaugeElements : gaugeElements.sourceComponent



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
        id: capacityBar
        anchors {
            left: root.labelLeft ? labelText.right : parent.left
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            top: root.labelLeft ? labelText.top : labelText.bottom
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }
        color: "lightgreen"
        width: 200
        height: 32


//        Rectangle {
//            id: threshold
//            anchors {
//                top: capacityBar.top
//                bottom: capacityBar.bottom
//                right: capacityBar.right
//            }
//        }

        Gauge {
            id: gauge
            value: root.input
            tickmarkStepSize: 20
            minorTickmarkCount: 1
            font.pixelSize: 15
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -4
            orientation: Qt.Horizontal

            style: GaugeStyle {
                valueBar: Rectangle {
                    id: gaugeValueBar
                    implicitWidth: 28
                    color: "yellow"

                    Loader {
                        id: gaugeElements
                        anchors {
                            fill: parent
                        }
                    }


                }

                background: Rectangle {
                    id: gaugeBackground
                    anchors {
                        fill: parent
                    }
                    color: "lightgray"
                    border {
                        width: 1
                        color: colorMod(capacityBar.color, -0.5)
                    }

                    Rectangle {
                        id: gaugeThreshold
                        color: "red"
                        anchors {
                            top: gaugeBackground.top
                            topMargin: 1
                            right: gaugeBackground.right
                            rightMargin: 1
                            left: gaugeBackground.left
                            leftMargin: 1
                        }
                        height: root.maximumValue - root.thresholdValue
                    }
                }

                foreground: null

                tickmark: Item {
                    implicitWidth: 8
                    implicitHeight: 2

                    Rectangle {
                        x: control.tickmarkAlignment === Qt.AlignLeft
                           || control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
                        width: 28
                        height: parent.height
                        color: "#ffffff"
                    }
                }

                minorTickmark: Item {
                    implicitWidth: 8
                    implicitHeight: 1

                    Rectangle {
                        x: control.tickmarkAlignment === Qt.AlignLeft
                           || control.tickmarkAlignment === Qt.AlignTop ? parent.implicitWidth : -28
                        width: 28
                        height: parent.height
                        color: "#ffffff"
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
