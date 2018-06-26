import QtQuick 2.9
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: root

    // Optional Configurations:
    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"

    property bool showThreshold: false
    property real thresholdValue: 0
    property real minimumValue: 0
    property real maximumValue: 100

    property alias gaugeElements : gaugeElements.sourceComponent

    implicitWidth: 300
    implicitHeight: 10

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
        color: "mintcream"
        width: gauge.width
        height: gauge.height + capacityBar.height

        Rectangle {
            id: capacityBar
            height: 32
            anchors {
                top: capacityBarContainer.top
                right: capacityBarContainer.right
                rightMargin: 12
                left: capacityBarContainer.left
                leftMargin: 12
            }
            color: "#252838"
            border {
                width: 1
                color: colorMod(capacityBar.color, -0.1)
            }


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
        }

        Loader {
            id: gaugeElements

            property real masterMinimumValue: root.minimumValue
            property real masterMaximumValue: root.maximumValue
            property real masterWidth: capacityBar.width

            anchors {
                top: capacityBar.top
                topMargin: 1
                bottom: capacityBar.bottom
                bottomMargin: 1
                left: capacityBar.left
                leftMargin: 1
//                right: capacityBar.right
//                rightMargin: 1
            }
            width: childrenRect.width
            Component.onCompleted: console.log(childrenRect.width)
        }

        Gauge {
            id: gauge
            tickmarkStepSize: 20
            minorTickmarkCount: 1
            font.pixelSize: 15
            anchors {
                top: capacityBar.bottom
                topMargin: 1
                left: capacityBarContainer.left
            }
            orientation: Qt.Horizontal
            width: root.width

            Rectangle {   // TODO Faller - Remove debug layer
                color: "tomato"
                opacity: .1
                anchors {
                    fill: parent
                }
                z:20
            }

            style: GaugeStyle {
                valueBar: Rectangle {
                    implicitWidth: 0
                }

                background: null
                foreground: null

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
                        width: 8
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
