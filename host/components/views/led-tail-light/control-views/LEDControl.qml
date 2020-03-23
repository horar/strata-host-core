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
                spacing: 10

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

            ColumnLayout{
                anchors.fill: parent
                anchors.right: parent.right
                anchors.rightMargin: 15


                Rectangle {
                    Layout.preferredHeight: parent.height/1.2
                    Layout.fillWidth: true
                    //color: "red"
                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //color: "grey"
                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/6
                                    //color: "blue"
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                text: "<b>" + qsTr("OUT EN") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                text: "<b>" + qsTr("Internal/External LED") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                text: "<b>" + qsTr("PWM Enable") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                text: "<b>" + qsTr("Fault Status") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            // color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("PWM Duty (%)") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    //color: "blue"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT0") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            // color: "blue"
                                            SGStatusLight {
                                                id: out0ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10

                                            SGText {
                                                text: "<b>" + qsTr("OUT1") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT2") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            // color: "red"

                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT3") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT4") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT5") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT6") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT7") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT8") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT9") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT10") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10faultStatusLED
                                                width: 30
                                                anchors.left: parent.left
                                                anchors.leftMargin: 5
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT11") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11ENLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11interExterLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11pwmEnableLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                value: 50
                                                anchors.centerIn: parent

                                            }
                                        }

                                    }
                                }



                            }
                        }

                        Rectangle {
                            id: gobalCurrentSetContainer
                            Layout.preferredHeight: parent.height/10
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: gobalCurrentSetLabel
                                target: gobalCurrentSetSlider
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                text: "Gobal Current Set (ISET)"
                                SGSlider {
                                    id: gobalCurrentSetSlider
                                    width: gobalCurrentSetContainer.width/1.5
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    to: 60
                                    from: 0
                                    stepSize: 1
                                    toText.text: "60mA"
                                    fromText.text: "0mA"

                                }

                            }
                        }
                    }
                }


                Rectangle {
                    id: i2cStatusSettingContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //  color: "red"

                    SGText{
                        id: i2cStatusLable
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "I2C Status Registers"
                        font.bold: true
                        anchors.top: parent. top
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Rectangle {
                        id: i2cLEDS
                        anchors.top: i2cStatusLable.bottom
                        anchors.centerIn: parent
                        width: parent.width - 100
                        height: parent.height - i2cStatusLable.contentHeight
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: scIsetLabel
                                    target: scIset
                                    text:  "SC_Iset"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: scIset
                                        width: 30
                                    }
                                }

                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: i2CerrLabel
                                    target: i2Cerr
                                    text:  "I2Cerr"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: i2Cerr
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: uvLabel
                                    target: uv
                                    text:  "UV"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: uv
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: diagRangeLabel
                                    target: diagRange
                                    text:  "diagRange"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagRange
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: twLabel
                                    target: tw
                                    text:  "TW"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tw
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: tsdLabel
                                    target: tsd
                                    text:  "TSD"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tsd
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: diagreeLabel
                                    target: diagree
                                    text:  "DIAGERR"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagree
                                        width: 30
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: olLabel
                                    target: ol
                                    text:  "OL"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: ol
                                        width: 30
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: parent.width/8
                                SGButton {
                                    id:  exportButton
                                    text: qsTr("Export Registers")
                                    anchors.verticalCenter: parent.verticalCenter
                                    fontSizeMultiplier: ratioCalc
                                    color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                    hoverEnabled: true
                                    MouseArea {
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

                                    }
                                }

                            }

                        }

                    }




                }
            }

        }
    }
}



