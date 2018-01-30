import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.spyglass.ImplementationInterfaceBinding 1.0
import "framework"
import "views"

Item {
    id: controlPage
    objectName: "controlLayout"

    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"

        Image {
            anchors { top: parent.top; right: parent.right }
            height: 40
            fillMode: Image.PreserveAspectFit
            source: "images/icons/onLogoGreen.svg"
        }
    }

    // Platform Implementation signals
    Connections {
        target: implementationInterfaceBinding

        onMotorSpeedChanged: {
            tachMeterGauge.value = ((speed - 1500) / 4000) * 100;
            console.log("qml: speed= ", tachMeterGauge.value);
        }
    }

    // Control Section
    Rectangle {
        id: controlSection
        anchors {top: headerLogo.bottom}
        width: mainWindow.width; height: mainWindow.height * 0.5
        //border.width: 1; border.color: "red"; color: "#cbd9ef"  // DEBUG

        ColumnLayout {
            id: layoutId
            anchors { fill: parent }
            Layout.alignment: Qt.AlignVCenter

            CircularGauge {
                id: tachMeterGauge

                minimumValue: 0; maximumValue: 100
                stepSize: 1

                Layout.alignment: Qt.AlignCenter

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

            Slider {
                id: motorSpeedControl
                from: 0; to: 1
                value: 0   // start value
                snapMode: Slider.SnapAlways
                stepSize : 0.05
                live: false

                Layout.alignment: Qt.AlignCenter

                function motorSpeed(value) {
                    // slider range 0 - 1 (%)
                    // motor rage:  1500 -- 5500  (4000 range)
                    return value * 4000 + 1500;
                }

                onMoved: {
                    gauge1.value = position * 200  // TODO [ian] false temp values until hooked up
                    gauge2.value = position * 200
                    gauge3.value = position * 200
                    //console.log("slider: setMotorSpeed(", motorSpeed(position), ")");
                    implementationInterfaceBinding.setMotorSpeed(motorSpeed(position));

                }

                ToolTip {
                    parent: motorSpeedControl.handle
                    visible: motorSpeedControl.pressed
                    text: motorSpeedControl.valueAt(motorSpeedControl.position).toFixed(1) * 5400
                }
            }

            ButtonGroup {
                Layout.alignment: Qt.AlignCenter

                buttons: buttonColumn.children
            }

            GroupBox {
                Layout.alignment: Qt.AlignCenter

                title: "<b><font color='red'>Operation Mode</b></font>"
                Row {
                    id: buttonColumn
                    anchors {fill: parent}

                    RadioButton {
                        checked: true
                        text: "Manual Control"

                        onPressed: {
                            console.log("MANUAL CONTROL")
                            implementationInterfaceBinding.setMotorMode("manual");
                        }
                    }

                    RadioButton {
                        text: "Automatic Test Pattern"

                        onPressed: {
                            console.log("AUTOMATIC")
                            implementationInterfaceBinding.setMotorMode("automatic");
                        }
                    }
                }
            }

        } // end Column Layout
    } // end Control Section Rectangle

    // Environment Section
    Rectangle {
        id: environmentSection
        anchors {
            top: controlSection.bottom;
            verticalCenter: controlPage.verticalCenter
        }

        width: controlPage.width * 0.75; height: controlPage.height * 0.25

        //border.width: 1; border.color: "black"  // DEBUG
        //color: "#dae2ef"

        // Phase U temperature
        RowLayout {
            spacing: 180
            ColumnLayout {
                Layout.alignment: Qt.AlignCenter

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

