import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: leftSetting
            Layout.fillHeight: true
            Layout.preferredWidth: root.width/3
            // color: "red"

            ColumnLayout {
                anchors.fill: parent
                spacing: 20

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //color: "red"
                    SGAlignedLabel {
                        id: enableOutputLabel
                        target: enableOutput
                        text: "Output Enable (OEN)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: enableOutput
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: lockPWMDutyLabel
                        target: lockPWMDuty
                        text: "Lock PWM Duty Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: lockPWMDuty
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: lockPWMDutyENLabel
                        target: lockPWMDutyEN
                        text: "Lock PWM EN Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGSwitch {
                            id: lockPWMDutyEN
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmLinearLogLabel
                        target: pwmLinearLog
                        text: "PWM Linear/Log"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        //horizontalAlignment: Text.AlignHCenter

                        SGSwitch {
                            id: pwmLinearLog
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //color: "red"

                    SGAlignedLabel {
                        id: autoFaultRecoveryLabel
                        target: autoFaultRecovery
                        text: "Auto Fault Recovery"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: autoFaultRecovery
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: label
                        target: labelSwitch
                        text: "?"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: labelSwitch
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmFrequencyLabel
                        target: pwmFrequency
                        text: "PWM Frequency (Hz)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: pwmFrequency
                            fontSizeMultiplier: ratioCalc
                            model: ["150", "250", "300"]
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: openLoadLabel
                        target: openLoadDiagnostic
                        text: "I2C Open Load Diagnostic"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: openLoadDiagnostic
                            fontSizeMultiplier: ratioCalc

                            model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulations\nChange"]
                        }
                    }
                }
            }
        }

        Rectangle {
            id: rightSetting
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"

            ColumnLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.preferredHeight: parent.height/1.5
                    Layout.fillWidth: true
                    color: "green"
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "red"
                }


            }
        }
    }
}



