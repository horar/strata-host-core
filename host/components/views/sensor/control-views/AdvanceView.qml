import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item  {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820

    property var sensorArray: []
    property var eachSensor: []

    RowLayout{
        anchors.fill:parent
        anchors.top:parent.top
        anchors.left:parent.Left
        anchors.leftMargin: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill:parent
                spacing: 15
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Enable"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "2nd Gain"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Data"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "Threshold"
                            }
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLightLabel
                                target: ldoTempLight
                                text: "<b>" + qsTr("0") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight
                                    width: 30


                                }
                            }

                        }
                        Rectangle {
                            id:enable0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enable0Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent


                            }

                        }

                        Rectangle {
                            id: sensorList0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorList0
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }


                        }

                        Rectangle {
                            id: sensordata0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata0
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                height: sensordata0Container.height - 10
                                width: sensordata0Container.width/2
                            }

                        }

                        Rectangle {
                            id: threshold0Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: threshold0
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                width: threshold0Container.width/2
                                height: threshold0Container.height - 10

                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN0"

                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: ldoTempLight1Label
                                target:  ldoTempLight1
                                text: "<b>" + qsTr("1") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight1
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enable1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable1Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList1
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata1
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: threshold1
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN1"

                            }
                        }
                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: ldoTempLight2Label
                                target:  ldoTempLight2
                                height: parent.height - 10
                                text: "<b>" + qsTr("2") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight2
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enable2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable2Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorList2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList2
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata2
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: threshold2
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN2"

                            }
                        }
                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: ldoTempLight3Label
                                target:  ldoTempLight3
                                height: parent.height - 10
                                text: "<b>" + qsTr("3") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight3
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enable3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable3Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList3
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata3
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: threshold3
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN3"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: ldoTempLight4Label
                                target:  ldoTempLight4
                                height: parent.height - 10
                                text: "<b>" + qsTr("4") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight4
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enable4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enable4Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList4
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata4
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold4Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: threshold4
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN4"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLight5Label
                                target:  ldoTempLight5
                                height: parent.height - 10
                                text: "<b>" + qsTr("5") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight5
                                    width: 30

                                }
                            }
                        }
                        Rectangle {
                            id:enable5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable5Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorList5
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata5
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold5Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: threshold5
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN5"
                            }
                        }
                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLight6Label
                                target:  ldoTempLight6
                                height: parent.height - 10
                                text: "<b>" + qsTr("6") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight6
                                    width: 30
                                }
                            }
                        }
                        Rectangle {
                            id:enable6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enable6Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList6
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordata6
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold6Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: threshold6
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN6"
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: ldoTempLight7Label
                                target:  ldoTempLight7
                                height: parent.height - 10
                                text: "<b>" + qsTr("7") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLight7
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enable7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true



                            SGSwitch {
                                id: enable7Switch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorList7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorList7
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordata7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordata7
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: threshold7Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: threshold7
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN7"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLightTouchLabel
                                target:  ldoTempLightTouch
                                height: parent.height - 10
                                text: "<b>" + qsTr("Touch") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLightTouch
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enableTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true



                            SGSwitch {
                                id: enableTouchSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorListTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListTouch
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataTouchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordataTouch
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholTouch3Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: thresholdTouch
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN8"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLightProximityLabel
                                target:  ldoTempLightProximity
                                height: parent.height - 10
                                text: "<b>" + qsTr("Proximity") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLightProximity
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enableProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableProximitySwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorListProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListProximity
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataProximity
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholProximityContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdProximity
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN9"
                            }
                        }
                    }


                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            id: ldoLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLightLedLabel
                                target:  ldoTempLightLed
                                height: parent.height - 10
                                text: "<b>" + qsTr("Light") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLightLed
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enableLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGSwitch {
                                id: enableLightSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent

                            }

                        }

                        Rectangle {
                            id: sensorListLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListLight
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: sensordataLight
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true


                            SGInfoBox {
                                id: thresholdLight
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN10"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoTempLedLabel
                                target:  ldoTempLed
                                height: parent.height - 10
                                text: "<b>" + qsTr("Temperature") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoTempLed
                                    width: 30

                                }
                            }

                        }
                        Rectangle {
                            id:enableTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableTemptSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorListTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGComboBox {
                                id: sensorListTemp
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataTemp
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholdTempContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdTemp
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN11"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoALedLabel
                                target:  ldoALed
                                height: parent.height - 10
                                text: "<b>" + qsTr("A") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoALed
                                    width: 30
                                }
                            }
                        }
                        Rectangle {
                            id:enableAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableASwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorListAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListA
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataA
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholdAContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdA
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN12"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoBLedLabel
                                target: ldoBLed
                                height: parent.height - 10
                                text: "<b>" + qsTr("B") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoBLed
                                    width: 30
                                }
                            }
                        }
                        Rectangle {
                            id:enableBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableBSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorListBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListB
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataB
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholdBContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdB
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN12"
                            }
                        }
                    }

                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoCLedLabel
                                target: ldoCLed
                                height: parent.height - 10
                                text: "<b>" + qsTr("C") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoCLed
                                    width: 30
                                }
                            }
                        }
                        Rectangle {
                            id:enableCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableCSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorListCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListC
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataC
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholdCContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdC
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN13"
                            }
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: ldoDLedLabel
                                target: ldoDLed
                                height: parent.height - 10
                                text: "<b>" + qsTr("D") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: ldoDLed
                                    width: 30
                                }
                            }
                        }
                        Rectangle {
                            id:enableDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGSwitch {
                                id: enableDSwitch
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                textColor: "black"              // Default: "black"
                                handleColor: "white"            // Default: "white"
                                grooveColor: "#ccc"             // Default: "#ccc"
                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.centerIn: parent
                            }
                        }

                        Rectangle {
                            id: sensorListDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGComboBox {
                                id: sensorListD
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                            }
                        }

                        Rectangle {
                            id: sensordataDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: sensordataD
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }

                        Rectangle {
                            id: thresholdDContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGInfoBox {
                                id: thresholdD
                                fontSizeMultiplier: ratioCalc * 0.9
                                anchors.centerIn: parent
                                width: parent.width/2
                                height: parent.height - 10
                            }
                        }
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGText {
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                text: "CIN14"
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true


        }
    }
}


