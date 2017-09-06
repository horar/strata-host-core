import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtCharts 2.2

Item {
    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"
    }
    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "onsemi_logo.png"
    }

    // Control Section
    Rectangle {
        id: controlSection
        anchors {top: headerLogo.bottom}
        width: mainWindow.width; height: mainWindow.height * 0.5
        //border.width: 1; border.color: "black"  // DEBUG
        //color: "#cbd9ef"

        Switch {
            anchors { horizontalCenter: controlSection.horizontalCenter; verticalCenter: controlSection.verticalCenter; verticalCenterOffset: 0 }
        }
        Label {
            id: directionLabel
            anchors { horizontalCenter: controlSection.horizontalCenter; verticalCenter: controlSection.verticalCenter; verticalCenterOffset: 20 }
            text: "Direction"
            font.pixelSize: 14
            font.bold: true
            color: "darkblue"
        }

        ColumnLayout {
            id: layoutId
            spacing: 5
            anchors { top: controlSection.top; topMargin: 50; centerIn: controlSection }

            CircularGauge {
                id: tachMeterGauge

                minimumValue: 0; maximumValue: 100

                Behavior on value { NumberAnimation { duration: 1500 } }

                style: CircularGaugeStyle {
                    minimumValueAngle: -90; maximumValueAngle: 90

                    needle: Rectangle {
                        y: outerRadius * 0.15
                        implicitWidth: outerRadius * 0.03
                        implicitHeight: outerRadius * 0.9
                        antialiasing: true
                        color: Qt.rgba(0.66, 0.3, 0, 1)
                    }

                    foreground: Item {
                        Rectangle {
                            width: outerRadius * 0.2
                            height: width
                            radius: width / 2
                            color: "black"
                            anchors.centerIn: parent
                        }
                    }
                    tickmarkLabel:  Text {
                        font.pixelSize: Math.max(6, outerRadius * 0.1)
                        text: styleData.value
                        color: styleData.value >= 80 ? "#e34c22" : "black"
                        antialiasing: true
                    }
                }
            } // end CircularGauge

            Label {
                id: tachMeterLabel
                anchors { top: tachMeterGauge.top; topMargin: 80; horizontalCenter: layoutId.horizontalCenter  }

                text: "RPM"
                font.pixelSize: 14
                font.bold: true
                color: "darkblue"
            }

            Slider {
                id: motorSpeedControl

                anchors { horizontalCenter: layoutId.horizontalCenter}
                from: 0; to: 100
                value: 0

                onPositionChanged: {
                    console.debug("value:" + position * 100)
                    tachMeterGauge.value = position * 100
                    gauge1.value = position * 200
                    gauge2.value = position * 200
                    gauge3.value = position * 200
                }

                ToolTip {
                    parent: motorSpeedControl.handle
                    visible: motorSpeedControl.pressed
                    text: motorSpeedControl.valueAt(motorSpeedControl.position).toFixed(1)
                }
            }

            Label {
                id: motorSpeedControlLabel
                anchors { horizontalCenter: layoutId.horizontalCenter  }

                text: "Motor Speed"
                font.pixelSize: 14
                font.bold: true
                color: "darkblue"
            }
        } // end Column Layout
    } // end Control Section Rectangle

    // Performance Section
    Rectangle {
        id: performanceSection
        anchors {top: controlSection.bottom; left: mainWindow.left; right: environmentSection.left; bottom: parent.bottom}
        width: mainWindow.width * 0.5; height: parent.height
        //border.width: 1; border.color: "black"  // DEBUG
        //color: "#dae2ef"

        Image {
            anchors.fill: performanceSection
            width: performanceSection.width; height: performanceSection.height
            fillMode: Image.PreserveAspectFit
            source: "graph1.png"
        }
    }

    // Environment Section
    Rectangle {
        id: environmentSection
        anchors {top: controlSection.bottom; left: performanceSection.right; right: mainWindow.right ; bottom: parent.bottom}
        width: parent.width * 0.5; height: parent.height * 0.5
        //border.width: 1; border.color: "black"  // DEBUG
        //color: "#dae2ef"

        // Phase U temperature
        RowLayout {
            spacing: 180

            ColumnLayout {
                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge1
                    width: parent.width; height: parent.height * 0.9
                    anchors.fill: parent
                    anchors.margins: 10
                    minimumValue: -40
                    maximumValue: 200

                    value: 20

                    Behavior on value { NumberAnimation {duration: 6000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge1.value / gauge1.maximumValue, 0, 1 - gauge1.value / gauge1.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }

                }
                Label {
                    id: gaugeLabel1
                    anchors {top: gauge1.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase U"
                }
            }

            // Phase U temperature
            ColumnLayout {
                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge2
                    width: parent.width; height: parent.height * 0.9
                    anchors.fill: parent
                    anchors.margins: 10
                    minimumValue: -40
                    maximumValue: 200

                    value: 20

                    Behavior on value { NumberAnimation {duration: 2000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge2.value / gauge2.maximumValue, 0, 1 - gauge2.value / gauge2.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }

                }
                Label {
                    id: gaugeLabel2
                    anchors {top: gauge2.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase V"
                }
            }

            // Phase W temperature
            ColumnLayout {
                width: environmentSection.width / 3;  height: environmentSection.height - 30
                Gauge {
                    id: gauge3
                    width: parent.width; height: parent.height * 0.9
                    anchors.fill: parent
                    anchors.margins: 10
                    minimumValue: -40
                    maximumValue: 200

                    value: 20

                    Behavior on value { NumberAnimation {duration: 4000 } }

                    style: GaugeStyle {
                        valueBar: Rectangle {
                            implicitWidth: 16
                            color: Qt.rgba(gauge3.value / gauge3.maximumValue, 0, 1 - gauge3.value / gauge3.maximumValue, 1)
                        }

                        tickmark: Item {
                            implicitWidth: 18
                            implicitHeight: 1

                            Rectangle {
                                color: "black"
                                anchors.fill: parent
                                anchors.leftMargin: 3
                                anchors.rightMargin: 3
                            }
                        }

                        minorTickmark: Item {
                            implicitWidth: 8
                            implicitHeight: 1

                            Rectangle {
                                color: "#cccccc"
                                anchors.fill: parent
                                anchors.leftMargin: 2
                                anchors.rightMargin: 4
                            }
                        }
                    }

                }
                Label {
                    id: gaugeLabel3
                    anchors {top: gauge3.bottom; left: parent.left; leftMargin: 5 }
                    width: parent.width; height: parent.height * 0.1
                    text: "Phase W"
                }
            }
        }

    }



}













