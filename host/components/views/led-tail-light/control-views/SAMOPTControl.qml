import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    function toHex(d) {
        return  ("0"+(Number(d).toString(16))).slice(-2).toUpperCase()
    }

    function setStatesForControls (theId, index){
        if(index !== null && index !== undefined)  {
            if(index === 0) {
                theId.enabled = true
                theId.opacity = 1.0
            }
            else if(index === 1) {
                theId.enabled = false
                theId.opacity = 1.0
            }
            else {
                theId.enabled = false
                theId.opacity = 0.5
            }
        }
    }

    property var soc_sam_conf_1: platformInterface.soc_sam_conf_1
    onSoc_sam_conf_1Changed: {
        samconfi1Text.text = soc_sam_conf_1.caption
        out1.checked = soc_sam_conf_1.values[0]
        out2.checked = soc_sam_conf_1.values[1]
        out3.checked = soc_sam_conf_1.values[2]
        out4.checked = soc_sam_conf_1.values[3]
        out5.checked = soc_sam_conf_1.values[4]
        out6.checked = soc_sam_conf_1.values[5]
        out7.checked = soc_sam_conf_1.values[6]
        out8.checked = soc_sam_conf_1.values[7]
        out9.checked = soc_sam_conf_1.values[8]
        out10.checked = soc_sam_conf_1.values[9]
        out11.checked = soc_sam_conf_1.values[10]
        out12.checked = soc_sam_conf_1.values[11]

        platformInterface.soc_sam_conf_1_out1 = soc_sam_conf_1.values[0]
        platformInterface.soc_sam_conf_1_out2 = soc_sam_conf_1.values[1]
        platformInterface.soc_sam_conf_1_out3 = soc_sam_conf_1.values[2]
        platformInterface.soc_sam_conf_1_out4 = soc_sam_conf_1.values[3]
        platformInterface.soc_sam_conf_1_out5 = soc_sam_conf_1.values[4]
        platformInterface.soc_sam_conf_1_out6 = soc_sam_conf_1.values[5]
        platformInterface.soc_sam_conf_1_out7 = soc_sam_conf_1.values[6]
        platformInterface.soc_sam_conf_1_out8 = soc_sam_conf_1.values[7]
        platformInterface.soc_sam_conf_1_out9 = soc_sam_conf_1.values[8]
        platformInterface.soc_sam_conf_1_out10 = soc_sam_conf_1.values[9]
        platformInterface.soc_sam_conf_1_out11 = soc_sam_conf_1.values[10]
        platformInterface.soc_sam_conf_1_out12 = soc_sam_conf_1.values[11]

        setStatesForControls(out1,soc_sam_conf_1.states[0])
        setStatesForControls(out2,soc_sam_conf_1.states[0])
        setStatesForControls(out3,soc_sam_conf_1.states[0])
        setStatesForControls(out4,soc_sam_conf_1.states[0])
        setStatesForControls(out5,soc_sam_conf_1.states[0])
        setStatesForControls(out6,soc_sam_conf_1.states[0])
        setStatesForControls(out7,soc_sam_conf_1.states[0])
        setStatesForControls(out8,soc_sam_conf_1.states[0])
        setStatesForControls(out9,soc_sam_conf_1.states[0])
        setStatesForControls(out10,soc_sam_conf_1.states[0])
        setStatesForControls(out11,soc_sam_conf_1.states[0])
        setStatesForControls(out12,soc_sam_conf_1.states[0])
    }

    property var soc_sam_conf_1_values: platformInterface.soc_sam_conf_1_values.values
    onSoc_sam_conf_1_valuesChanged: {
        out1.checked = soc_sam_conf_1_values[0]
        out2.checked = soc_sam_conf_1_values[1]
        out3.checked = soc_sam_conf_1_values[2]
        out4.checked = soc_sam_conf_1_values[3]
        out5.checked = soc_sam_conf_1_values[4]
        out6.checked = soc_sam_conf_1_values[5]
        out7.checked = soc_sam_conf_1_values[6]
        out8.checked = soc_sam_conf_1_values[7]
        out9.checked = soc_sam_conf_1_values[8]
        out10.checked = soc_sam_conf_1_values[9]
        out11.checked = soc_sam_conf_1_values[10]
        out12.checked = soc_sam_conf_1_values[11]

        platformInterface.soc_sam_conf_1_out1 = soc_sam_conf_1_values[0]
        platformInterface.soc_sam_conf_1_out2 = soc_sam_conf_1_values[1]
        platformInterface.soc_sam_conf_1_out3 = soc_sam_conf_1_values[2]
        platformInterface.soc_sam_conf_1_out4 = soc_sam_conf_1_values[3]
        platformInterface.soc_sam_conf_1_out5 = soc_sam_conf_1_values[4]
        platformInterface.soc_sam_conf_1_out6 = soc_sam_conf_1_values[5]
        platformInterface.soc_sam_conf_1_out7 = soc_sam_conf_1_values[6]
        platformInterface.soc_sam_conf_1_out8 = soc_sam_conf_1_values[7]
        platformInterface.soc_sam_conf_1_out9 = soc_sam_conf_1_values[8]
        platformInterface.soc_sam_conf_1_out10 = soc_sam_conf_1_values[9]
        platformInterface.soc_sam_conf_1_out11 = soc_sam_conf_1_values[10]
        platformInterface.soc_sam_conf_1_out12 = soc_sam_conf_1_values[11]





    }

    property var soc_sam_conf_1_state: platformInterface.soc_sam_conf_1_states.states
    onSoc_sam_conf_1_stateChanged: {
        setStatesForControls(out1,soc_sam_conf_1_state[0])
        setStatesForControls(out2,soc_sam_conf_1_state[0])
        setStatesForControls(out3,soc_sam_conf_1_state[0])
        setStatesForControls(out4,soc_sam_conf_1_state[0])
        setStatesForControls(out5,soc_sam_conf_1_state[0])
        setStatesForControls(out6,soc_sam_conf_1_state[0])
        setStatesForControls(out7,soc_sam_conf_1_state[0])
        setStatesForControls(out8,soc_sam_conf_1_state[0])
        setStatesForControls(out9,soc_sam_conf_1_state[0])
        setStatesForControls(out10,soc_sam_conf_1_state[0])
        setStatesForControls(out11,soc_sam_conf_1_state[0])
        setStatesForControls(out12,soc_sam_conf_1_state[0])
    }

    property var soc_sam_conf_2: platformInterface.soc_sam_conf_2
    onSoc_sam_conf_2Changed: {
        samConfig2Text.text = soc_sam_conf_2.caption
        samOut1.checked = soc_sam_conf_2.values[0]
        samOut2.checked = soc_sam_conf_2.values[1]
        samOut3.checked = soc_sam_conf_2.values[2]
        samOut4.checked = soc_sam_conf_2.values[3]
        samOut5.checked = soc_sam_conf_2.values[4]
        samOut6.checked = soc_sam_conf_2.values[5]
        samOut7.checked = soc_sam_conf_2.values[6]
        samOut8.checked = soc_sam_conf_2.values[7]
        samOut9.checked = soc_sam_conf_2.values[8]
        samOut10.checked = soc_sam_conf_2.values[9]
        samOut11.checked = soc_sam_conf_2.values[10]
        samOut12.checked = soc_sam_conf_2.values[11]


        platformInterface.soc_sam_conf_2_out1 = soc_sam_conf_2.values[0]
        platformInterface.soc_sam_conf_2_out2 = soc_sam_conf_2.values[1]
        platformInterface.soc_sam_conf_2_out3 = soc_sam_conf_2.values[2]
        platformInterface.soc_sam_conf_2_out4 = soc_sam_conf_2.values[3]
        platformInterface.soc_sam_conf_2_out5 = soc_sam_conf_2.values[4]
        platformInterface.soc_sam_conf_2_out6 = soc_sam_conf_2.values[5]
        platformInterface.soc_sam_conf_2_out7 = soc_sam_conf_2.values[6]
        platformInterface.soc_sam_conf_2_out8 = soc_sam_conf_2.values[7]
        platformInterface.soc_sam_conf_2_out9 = soc_sam_conf_2.values[8]
        platformInterface.soc_sam_conf_2_out10 = soc_sam_conf_2.values[9]
        platformInterface.soc_sam_conf_2_out11 = soc_sam_conf_2.values[10]
        platformInterface.soc_sam_conf_2_out12 = soc_sam_conf_2.values[11]

        setStatesForControls(samOut1,soc_sam_conf_2.states[0])
        setStatesForControls(samOut2,soc_sam_conf_2.states[0])
        setStatesForControls(samOut3,soc_sam_conf_2.states[0])
        setStatesForControls(samOut4,soc_sam_conf_2.states[0])
        setStatesForControls(samOut5,soc_sam_conf_2.states[0])
        setStatesForControls(samOut6,soc_sam_conf_2.states[0])
        setStatesForControls(samOut7,soc_sam_conf_2.states[0])
        setStatesForControls(samOut8,soc_sam_conf_2.states[0])
        setStatesForControls(samOut9,soc_sam_conf_2.states[0])
        setStatesForControls(samOut10,soc_sam_conf_2.states[0])
        setStatesForControls(samOut11,soc_sam_conf_2.states[0])
        setStatesForControls(samOut12,soc_sam_conf_2.states[0])


        //        if(soc_sam_conf_2.state === "enabled") {
        //            samOut1.enabled = true
        //            samOut1.opacity = 1.0
        //            samOut2.enabled = true
        //            samOut2.opacity = 1.0
        //            samOut3.enabled = true
        //            samOut3.opacity = 1.0
        //            samOut4.enabled = true
        //            samOut4.opacity = 1.0
        //            samOut5.enabled = true
        //            samOut5.opacity = 1.0
        //            samOut6.enabled = true
        //            samOut6.opacity = 1.0
        //            samOut7.enabled = true
        //            samOut7.opacity = 1.0
        //            samOut8.enabled = true
        //            samOut8.opacity = 1.0
        //            samOut9.enabled = true
        //            samOut9.opacity = 1.0
        //            samOut10.enabled = true
        //            samOut10.opacity = 1.0
        //            samOut11.enabled = true
        //            samOut11.opacity = 1.0
        //            samOut12.enabled = true
        //            samOut12.opacity = 1.0

        //        }
        //        else if (soc_sam_conf_2.state === "disabled") {
        //            samOut1.enabled = false
        //            samOut1.opacity = 1.0
        //            samOut2.enabled = false
        //            samOut2.opacity = 1.0
        //            samOut3.enabled = false
        //            samOut3.opacity = 1.0
        //            samOut4.enabled = false
        //            samOut4.opacity = 1.0
        //            samOut5.enabled = false
        //            samOut5.opacity = 1.0
        //            samOut6.enabled = false
        //            samOut6.opacity = 1.0
        //            samOut7.enabled = false
        //            samOut7.opacity = 1.0
        //            samOut8.enabled = false
        //            samOut8.opacity = 1.0
        //            samOut9.enabled = false
        //            samOut9.opacity = 1.0
        //            samOut10.enabled = false
        //            samOut10.opacity = 1.0
        //            samOut11.enabled = false
        //            samOut11.opacity = 1.0
        //            samOut12.enabled = false
        //            samOut12.opacity = 1.0

        //        }
        //        else {
        //            samOut1.enabled = false
        //            samOut1.opacity = 0.5
        //            samOut2.enabled = false
        //            samOut2.opacity = 0.5
        //            samOut3.enabled = false
        //            samOut3.opacity = 0.5
        //            samOut4.enabled = false
        //            samOut4.opacity = 0.5
        //            samOut5.enabled = false
        //            samOut5.opacity = 0.5
        //            samOut6.enabled = false
        //            samOut6.opacity = 0.5
        //            samOut7.enabled = false
        //            samOut7.opacity = 0.5
        //            samOut8.enabled = false
        //            samOut8.opacity = 0.5
        //            samOut9.enabled = false
        //            samOut9.opacity = 0.5
        //            samOut10.enabled = false
        //            samOut10.opacity = 0.5
        //            samOut11.enabled = false
        //            samOut11.opacity = 0.5
        //            samOut12.enabled = false
        //            samOut12.opacity = 0.5
        //        }
    }

    property var soc_sam_conf_2_values: platformInterface.soc_sam_conf_2_values.values
    onSoc_sam_conf_2_valuesChanged: {
        samOut1.checked = soc_sam_conf_2_values[0]
        samOut2.checked = soc_sam_conf_2_values[1]
        samOut3.checked = soc_sam_conf_2_values[2]
        samOut4.checked = soc_sam_conf_2_values[3]
        samOut5.checked = soc_sam_conf_2_values[4]
        samOut6.checked = soc_sam_conf_2_values[5]
        samOut7.checked = soc_sam_conf_2_values[6]
        samOut8.checked = soc_sam_conf_2_values[7]
        samOut9.checked = soc_sam_conf_2_values[8]
        samOut10.checked = soc_sam_conf_2_values[9]
        samOut11.checked = soc_sam_conf_2_values[10]
        samOut12.checked = soc_sam_conf_2_values[11]


        platformInterface.soc_sam_conf_2_out1 = soc_sam_conf_2_values[0]
        platformInterface.soc_sam_conf_2_out2 = soc_sam_conf_2_values[1]
        platformInterface.soc_sam_conf_2_out3 = soc_sam_conf_2_values[2]
        platformInterface.soc_sam_conf_2_out4 = soc_sam_conf_2_values[3]
        platformInterface.soc_sam_conf_2_out5 = soc_sam_conf_2_values[4]
        platformInterface.soc_sam_conf_2_out6 = soc_sam_conf_2_values[5]
        platformInterface.soc_sam_conf_2_out7 = soc_sam_conf_2_values[6]
        platformInterface.soc_sam_conf_2_out8 = soc_sam_conf_2_values[7]
        platformInterface.soc_sam_conf_2_out9 = soc_sam_conf_2_values[8]
        platformInterface.soc_sam_conf_2_out10 = soc_sam_conf_2_values[9]
        platformInterface.soc_sam_conf_2_out11 = soc_sam_conf_2_values[10]
        platformInterface.soc_sam_conf_2_out12 = soc_sam_conf_2_values[11]


    }

    property var soc_sam_conf_2_state: platformInterface.soc_sam_conf_2_states.states
    onSoc_sam_conf_2_stateChanged: {
        setStatesForControls(samOut1,soc_sam_conf_2_state[0])
        setStatesForControls(samOut2,soc_sam_conf_2_state[0])
        setStatesForControls(samOut3,soc_sam_conf_2_state[0])
        setStatesForControls(samOut4,soc_sam_conf_2_state[0])
        setStatesForControls(samOut5,soc_sam_conf_2_state[0])
        setStatesForControls(samOut6,soc_sam_conf_2_state[0])
        setStatesForControls(samOut7,soc_sam_conf_2_state[0])
        setStatesForControls(samOut8,soc_sam_conf_2_state[0])
        setStatesForControls(samOut9,soc_sam_conf_2_state[0])
        setStatesForControls(samOut10,soc_sam_conf_2_state[0])
        setStatesForControls(samOut11,soc_sam_conf_2_state[0])
        setStatesForControls(samOut12,soc_sam_conf_2_state[0])
    }

    Popup{
        id: warningPopup
        width: parent.width/2
        height: parent.height/4
        anchors.centerIn: parent
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        background: Rectangle{
            id: warningPopupContainer
            width: warningPopup.width
            height: warningPopup.height
            color: "#dcdcdc"
            border.color: "grey"
            border.width: 2
            radius: 10
            Rectangle {
                id:topBorder
                width: parent.width
                height: parent.height/7
                anchors{
                    top: parent.top
                    topMargin: 2
                    right: parent.right
                    rightMargin: 2
                    left: parent.left
                    leftMargin: 2
                }
                radius: 5
                color: "#c0c0c0"
                border.color: "#c0c0c0"
                border.width: 2
            }
        }

        Rectangle {
            id: warningPopupBox
            color: "transparent"
            anchors {
                top: parent.top
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            width: warningPopupContainer.width - 50
            height: warningPopupContainer.height - 50

            Rectangle {
                id: messageContainerForPopup
                anchors {
                    top: parent.top
                    topMargin: 10
                    centerIn:  parent.Center
                }
                color: "transparent"
                width: parent.width
                height:  parent.height - selectionContainerForPopup.height
                Text {
                    id: warningTextForPopup
                    anchors.fill:parent
                    text: "The part will be permanently OTP’ed. The registers on this page will become read-only. Do you want to continue?”"
                    verticalAlignment:  Text.AlignVCenter
                    wrapMode: Text.WordWrap
                    fontSizeMode: Text.Fit
                    width: parent.width
                    font.family: "Helvetica Neue"
                    font.pixelSize: ratioCalc * 15
                }
            }

            Rectangle {
                id: selectionContainerForPopup
                width: parent.width/2
                height: parent.height/4.5
                anchors{
                    top: messageContainerForPopup.bottom
                    topMargin: 10
                    right: parent.right
                }
                color: "transparent"

                SGButton {
                    id: continueButton
                    width: parent.width/3
                    height:parent.height
                    anchors.left: parent.left
                    //anchors.leftMargin: 20
                    //anchors.centerIn: parent
                    text: "Continue"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        warningPopup.close()
                       // platformInterface.soc_otpValue = true
                        platformInterface.set_soc_write.update(
                                    true,
                                    [platformInterface.soc_sam_conf_1_out1,
                                     platformInterface.soc_sam_conf_1_out2,
                                     platformInterface.soc_sam_conf_1_out3,
                                     platformInterface.soc_sam_conf_1_out4,
                                     platformInterface.soc_sam_conf_1_out5,
                                     platformInterface.soc_sam_conf_1_out6,
                                     platformInterface.soc_sam_conf_1_out7,
                                     platformInterface.soc_sam_conf_1_out8,
                                     platformInterface.soc_sam_conf_1_out9,
                                     platformInterface.soc_sam_conf_1_out10,
                                     platformInterface.soc_sam_conf_1_out11,
                                     platformInterface.soc_sam_conf_1_out12

                                    ],
                                    [platformInterface.soc_sam_conf_2_out1,
                                     platformInterface.soc_sam_conf_2_out2,
                                     platformInterface.soc_sam_conf_2_out3,
                                     platformInterface.soc_sam_conf_2_out4,
                                     platformInterface.soc_sam_conf_2_out5,
                                     platformInterface.soc_sam_conf_2_out6,
                                     platformInterface.soc_sam_conf_2_out7,
                                     platformInterface.soc_sam_conf_2_out8,
                                     platformInterface.soc_sam_conf_2_out9,
                                     platformInterface.soc_sam_conf_2_out10,
                                     platformInterface.soc_sam_conf_2_out11,
                                     platformInterface.soc_sam_conf_2_out12
                                    ],
                                    samOpenLoadDiagnostic.currentText,
                                    platformInterface.soc_crcValue,
                                    platformInterface.addr_curr_apply)
                    }
                }

                SGButton {
                    id: cancelButton
                    width: parent.width/3
                    height:parent.height
                    anchors.left: continueButton.right
                    anchors.leftMargin: 20
                    //anchors.centerIn: parent
                    text: "Cancel"
                    color: checked ? "white" : pressed ? "#cfcfcf": hovered ? "#eee" : "white"
                    roundedLeft: true
                    roundedRight: true

                    onClicked: {
                        warningPopup.close()

                    }
                }

            }
        }
    }


    ColumnLayout {
        width: parent.width/1.1
        height: parent.height/1.2
        anchors.centerIn: parent

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                id: i2cConfigHeading
                text: "I2C Configuration"
                font.bold: true
                font.pixelSize: ratioCalc * 20
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line
                height: 1.5
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: i2cConfigHeading.bottom
                    topMargin: 7
                }
            }

            RowLayout {
                width: parent.width
                height: parent.height - i2cConfigHeading.contentHeight - line.height
                anchors {
                    top: line.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true


                    SGAlignedLabel {
                        id: enableCRCLabel
                        target: enableCRC
                        //text: "Enable\nCRC"
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.verticalCenter: parent.verticalCenter


                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: enableCRC
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc * 1.2
                            //checked: false
                            onToggled: {
                                platformInterface.soc_crcValue = checked
                                platformInterface.set_soc_write.update(
                                            false,
                                            [platformInterface.soc_sam_conf_1_out1,
                                             platformInterface.soc_sam_conf_1_out2,
                                             platformInterface.soc_sam_conf_1_out3,
                                             platformInterface.soc_sam_conf_1_out4,
                                             platformInterface.soc_sam_conf_1_out5,
                                             platformInterface.soc_sam_conf_1_out6,
                                             platformInterface.soc_sam_conf_1_out7,
                                             platformInterface.soc_sam_conf_1_out8,
                                             platformInterface.soc_sam_conf_1_out9,
                                             platformInterface.soc_sam_conf_1_out10,
                                             platformInterface.soc_sam_conf_1_out11,
                                             platformInterface.soc_sam_conf_1_out12

                                            ],
                                            [platformInterface.soc_sam_conf_2_out1,
                                             platformInterface.soc_sam_conf_2_out2,
                                             platformInterface.soc_sam_conf_2_out3,
                                             platformInterface.soc_sam_conf_2_out4,
                                             platformInterface.soc_sam_conf_2_out5,
                                             platformInterface.soc_sam_conf_2_out6,
                                             platformInterface.soc_sam_conf_2_out7,
                                             platformInterface.soc_sam_conf_2_out8,
                                             platformInterface.soc_sam_conf_2_out9,
                                             platformInterface.soc_sam_conf_2_out10,
                                             platformInterface.soc_sam_conf_2_out11,
                                             platformInterface.soc_sam_conf_2_out12
                                            ],
                                            samOpenLoadDiagnostic.currentText,
                                            platformInterface.soc_crcValue,
                                            platformInterface.addr_curr)

                            }
                        }

                        property var soc_crc: platformInterface.soc_crc
                        onSoc_crcChanged: {
                            enableCRCLabel.text = soc_crc.caption
                            setStatesForControls(enableCRC,soc_crc.states[0])
                            //                            if(soc_crc.state === "enabled"){
                            //                                enableCRC.enabled = true
                            //                                enableCRC.opacity = 1.0
                            //                            }
                            //                            else if (soc_crc.state === "disabled") {
                            //                                enableCRC.enabled = false
                            //                                enableCRC.opacity = 1.0
                            //                            }
                            //                            else {
                            //                                enableCRC.enabled = false
                            //                                enableCRC.opacity = 0.5
                            //                            }
                            enableCRC.checked = soc_crc.value
                        }

                        property var soc_crc_caption: platformInterface.soc_crc_caption.caption
                        onSoc_crc_captionChanged: {
                            enableCRCLabel.text = soc_crc_caption
                        }

                        property var soc_crc_state: platformInterface.soc_crc_states.states
                        onSoc_crc_stateChanged: {
                            setStatesForControls(enableCRC,soc_crc_state[0])
                        }

                        property var soc_crc_value: platformInterface.soc_crc_value.value
                        onSoc_crc_valueChanged: {
                            enableCRC.checked = soc_crc_value
                        }

                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: current7bitLabel
                        target: current7bit
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGInfoBox {
                            id: current7bit
                            height:  35 * ratioCalc
                            width: 50 * ratioCalc
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                        }
                        SGText{
                            id: current7bitText
                            text: "0x"
                            anchors.right: current7bit.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: current7bit.verticalCenter
                            font.bold: true
                        }


                        property var soc_addr_curr: platformInterface.soc_addr_curr
                        onSoc_addr_currChanged: {
                            text = soc_addr_curr.caption
                            setStatesForControls(current7bit,soc_addr_curr.states[0])
                            //                            if(soc_addr_curr.state === "enabled") {
                            //                                current7bit.enabled = true
                            //                                current7bit.opacity = 1.0
                            //                            }
                            //                            else if (soc_addr_curr.state === "disabled") {
                            //                                current7bit.enabled = false
                            //                                current7bit.opacity = 1.0
                            //                            }
                            //                            else {
                            //                                current7bit.enabled = false
                            //                                current7bit.opacity = 0.5
                            //                            }
                            current7bit.text = toHex(soc_addr_curr.value)
                            platformInterface.addr_curr = soc_addr_curr.value

                        }

                        property var soc_addr_curr_caption: platformInterface.soc_addr_curr_caption.caption
                        onSoc_addr_curr_captionChanged: {
                            text = soc_addr_curr_caption
                        }

                        property var soc_addr_curr_state: platformInterface.soc_addr_curr_states.states
                        onSoc_addr_curr_stateChanged: {
                            setStatesForControls(current7bit,soc_addr_curr_state[0])
                        }

                        property var soc_addr_curr_value: platformInterface.soc_addr_curr_value.value
                        onSoc_addr_curr_valueChanged: {
                            console.log("curr_value",soc_addr_curr_value)
                            current7bit.text = toHex(soc_addr_curr_value)
                            platformInterface.addr_curr = soc_addr_curr_value

                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: new7bitLabel
                        target: new7bit
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGSubmitInfoBox {
                            id: new7bit
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                            height:  35 * ratioCalc
                            width: 50 * ratioCalc
                            onAccepted: {
                                var hexTodecimal = parseInt(text, 16)
                                console.log(text)
                                console.log(hexTodecimal)
                                if(hexTodecimal > platformInterface.soc_addr_new.scales[0]) {
                                    console.log(text.toString(16))
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[0])
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }

                                else if(hexTodecimal < platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = toHex(platformInterface.soc_addr_new.scales[1])
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                                else if(hexTodecimal <= platformInterface.soc_addr_new.scales[0] && hexTodecimal >= platformInterface.soc_addr_new.scales[1]){
                                    new7bit.text = text
                                    platformInterface.addr_curr_apply = parseInt(new7bit.text, 16)
                                }
                            }
                        }

                        SGText{
                            id: nw7bitText
                            text: "0x"
                            anchors.right: new7bit.left
                            anchors.rightMargin: 10
                            anchors.verticalCenter: new7bit.verticalCenter
                            font.bold: true
                        }


                        property var soc_addr_new: platformInterface.soc_addr_new
                        onSoc_addr_newChanged: {
                            new7bitLabel.text = soc_addr_new.caption
                            setStatesForControls(new7bit,soc_addr_new.states[0])
                            //                            if(soc_addr_new.state === "enabled") {
                            //                                new7bit.enabled = true
                            //                                new7bit.opacity = 1.0
                            //                            }
                            //                            else if (soc_addr_new.state === "disabled") {
                            //                                new7bit.enabled = false
                            //                                new7bit.opacity = 1.0
                            //                            }
                            //                            else {
                            //                                new7bit.enabled = false
                            //                                new7bit.opacity = 0.5
                            //                            }
                            new7bit.text =  toHex(soc_addr_new.value)
                            platformInterface.addr_curr_apply = parseInt(new7bit.text , 16)
                        }

                        property var soc_addr_new_caption: platformInterface.soc_addr_new_caption.caption
                        onSoc_addr_new_captionChanged: {
                            new7bitLabel.text = soc_addr_new_caption
                        }

                        property var soc_addr_new_state: platformInterface.soc_addr_new_states.states
                        onSoc_addr_new_stateChanged: {
                            setStatesForControls(new7bit,soc_addr_new_state[0])

                        }

                        property var soc_addr_new_value: platformInterface.soc_addr_new_value.value
                        onSoc_addr_new_valueChanged: {
                            new7bit.text =  toHex(soc_addr_new_value)
                            platformInterface.addr_curr_apply = parseInt(new7bit.text , 16)
                            console.log(platformInterface.addr_curr_apply)
                        }

                    }


                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGButton {
                        id:  i2cAddressButton
                        text: qsTr("Apply \n I2C Address")
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc
                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                        hoverEnabled: true
                        height: parent.height/2
                        width: parent.width/2
                        MouseArea {
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                platformInterface.set_soc_write.update(
                                            false,
                                            [platformInterface.soc_sam_conf_1_out1,
                                             platformInterface.soc_sam_conf_1_out2,
                                             platformInterface.soc_sam_conf_1_out3,
                                             platformInterface.soc_sam_conf_1_out4,
                                             platformInterface.soc_sam_conf_1_out5,
                                             platformInterface.soc_sam_conf_1_out6,
                                             platformInterface.soc_sam_conf_1_out7,
                                             platformInterface.soc_sam_conf_1_out8,
                                             platformInterface.soc_sam_conf_1_out9,
                                             platformInterface.soc_sam_conf_1_out10,
                                             platformInterface.soc_sam_conf_1_out11
                                            ],
                                            [platformInterface.soc_sam_conf_2_out1,
                                             platformInterface.soc_sam_conf_2_out2,
                                             platformInterface.soc_sam_conf_2_out3,
                                             platformInterface.soc_sam_conf_2_out4,
                                             platformInterface.soc_sam_conf_2_out5,
                                             platformInterface.soc_sam_conf_2_out6,
                                             platformInterface.soc_sam_conf_2_out7,
                                             platformInterface.soc_sam_conf_2_out8,
                                             platformInterface.soc_sam_conf_2_out9,
                                             platformInterface.soc_sam_conf_2_out10,
                                             platformInterface.soc_sam_conf_2_out11
                                            ],
                                            samOpenLoadDiagnostic.currentText,
                                            platformInterface.soc_otpValue,
                                            platformInterface.addr_curr_apply)

                            }

                        }
                    }
                }
            }
        }


        Rectangle {
            Layout.preferredHeight: parent.height/2
            Layout.fillWidth: true
            ColumnLayout{
                anchors.fill: parent
                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/9
                    color: "transparent"
                    Text {
                        id: standAloneModeHeading
                        text: "Stand Alone Mode (SAM) Configuration"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line2
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: standAloneModeHeading.bottom
                            topMargin: 7
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: i2cStandaloneLabel
                                target: i2cStandalone
                                // text: "I2C/Standalone\n(I2CFLAG)"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: i2cStandalone
                                    labelsInside: true
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_soc_mode.update("I2C")
                                        else platformInterface.set_soc_mode.update("SAM")
                                    }
                                }

                                property var soc_mode: platformInterface.soc_mode
                                onSoc_modeChanged: {
                                    i2cStandaloneLabel.text = soc_mode.caption
                                    setStatesForControls(i2cStandalone,soc_mode.states[0])
                                    //                                    if(soc_mode.state === "enabled"){
                                    //                                        i2cStandalone.enabled = true
                                    //                                        i2cStandalone.opacity = 1.0
                                    //                                    }
                                    //                                    else if (soc_mode.state === "disabled") {
                                    //                                        i2cStandalone.enabled = false
                                    //                                        i2cStandalone.opacity = 1.0
                                    //                                    }
                                    //                                    else {
                                    //                                        i2cStandalone.enabled = false
                                    //                                        i2cStandalone.opacity = 0.5
                                    //                                    }
                                    i2cStandalone.checkedLabel = soc_mode.values[0]
                                    i2cStandalone.uncheckedLabel = soc_mode.values[1]
                                    if(soc_mode.value === "I2C")
                                        i2cStandalone.checked = true
                                    else  i2cStandalone.checked = false
                                }

                                property var soc_mode_caption: platformInterface.soc_mode_caption.caption
                                onSoc_mode_captionChanged: {
                                    i2cStandaloneLabel.text = soc_mode_caption
                                }

                                property var soc_mode_state: platformInterface.soc_mode_states.states
                                onSoc_mode_stateChanged: {
                                    setStatesForControls(i2cStandalone,soc_mode_state[0])
                                }

                                property var soc_mode_values: platformInterface.soc_mode_values.values
                                onSoc_mode_valuesChanged: {
                                    i2cStandalone.checkedLabel = soc_mode_values[0]
                                    i2cStandalone.uncheckedLabel = soc_mode_values[1]
                                }

                                property var soc_mode_value: platformInterface.soc_mode_value.value
                                onSoc_mode_valueChanged:{
                                    if(soc_mode_value === "I2C")
                                        i2cStandalone.checked = true
                                    else  i2cStandalone.checked = false
                                }


                            }
                        }

                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: samConfigLabel
                                target: samConfig
                                // text: "SAM\n(Configuration)"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    //top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: samConfig
                                    labelsInside: true
                                    //checkedLabel: "SAM1"
                                    //uncheckedLabel: "SAM2"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_soc_conf.update("SAM1")
                                        else
                                            platformInterface.set_soc_conf.update("SAM2")

                                    }

                                    property var soc_conf: platformInterface.soc_conf
                                    onSoc_confChanged: {
                                        samConfigLabel.text = soc_conf.caption
                                        setStatesForControls(samConfig,soc_conf.states[0])
                                        //                                        if(soc_conf.state === "enabled"){
                                        //                                            samConfig.enabled = true
                                        //                                            samConfig.opacity = 1.0
                                        //                                        }
                                        //                                        else if (soc_conf.state === "disabled") {
                                        //                                            samConfig.enabled = false
                                        //                                            samConfig.opacity = 1.0
                                        //                                        }
                                        //                                        else {
                                        //                                            samConfig.enabled = false
                                        //                                            samConfig.opacity = 0.5
                                        //                                        }

                                        samConfig.checkedLabel = soc_conf.values[0]
                                        samConfig.uncheckedLabel = soc_conf.values[1]
                                        if(soc_conf.value === "SAM1")
                                            samConfig.checked = true
                                        else  samConfig.checked = false

                                    }

                                    property var soc_conf_caption: platformInterface.soc_conf_caption.caption
                                    onSoc_conf_captionChanged: {
                                        samConfigLabel.text = soc_conf_caption
                                    }

                                    property var soc_conf_state: platformInterface.soc_conf_states.states
                                    onSoc_conf_stateChanged: {
                                        setStatesForControls(samConfig,soc_conf_state[0])
                                    }

                                    property var soc_conf_values: platformInterface.soc_conf_values.values
                                    onSoc_conf_valuesChanged: {
                                        samConfig.checkedLabel = soc_conf_values[0]
                                        samConfig.uncheckedLabel = soc_conf_values[1]
                                    }

                                    property var soc_conf_value: platformInterface.soc_conf_value.value
                                    onSoc_conf_valueChanged:{
                                        if(soc_conf_value === "SAM1"){
                                            samConfig.checked = true
                                        }
                                        else  samConfig.checked = false
                                    }



                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: vDDVoltageDisconnectLabel
                                target: vDDVoltageDisconnect
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors {
                                    //top:parent.top
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 20
                                }

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: vDDVoltageDisconnect
                                    labelsInside: true
                                    // checkedLabel: "Connect"
                                    // uncheckedLabel: "Disconnect"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_soc_vdd_disconnect.update("Connect")
                                        else  platformInterface.set_soc_vdd_disconnect.update("Disconnect")
                                    }
                                }

                                property var soc_vdd_disconnect: platformInterface.soc_vdd_disconnect
                                onSoc_vdd_disconnectChanged: {
                                    vDDVoltageDisconnectLabel.text = soc_vdd_disconnect.caption
                                    setStatesForControls(vDDVoltageDisconnect,soc_vdd_disconnect.states[0])
                                    //                                    if(soc_vdd_disconnect.state === "enabled"){
                                    //                                        vDDVoltageDisconnect.enabled = true
                                    //                                        vDDVoltageDisconnect.opacity = 1.0
                                    //                                    }
                                    //                                    else if (soc_vdd_disconnect.state === "disabled") {
                                    //                                        vDDVoltageDisconnect.enabled = false
                                    //                                        vDDVoltageDisconnect.opacity = 1.0
                                    //                                    }
                                    //                                    else {
                                    //                                        vDDVoltageDisconnect.enabled = false
                                    //                                        vDDVoltageDisconnect.opacity = 0.5
                                    //                                    }
                                    vDDVoltageDisconnect.checkedLabel = soc_vdd_disconnect.values[0]
                                    vDDVoltageDisconnect.uncheckedLabel = soc_vdd_disconnect.values[1]

                                    if(soc_vdd_disconnect.value === "Connect")
                                        vDDVoltageDisconnect.checked = true

                                    else  vDDVoltageDisconnect.checked = false

                                }


                                property var soc_vdd_disconnect_caption: platformInterface.soc_vdd_disconnect_caption.caption
                                onSoc_vdd_disconnect_captionChanged: {
                                    vDDVoltageDisconnectLabel.text = soc_vdd_disconnect_caption
                                }

                                property var soc_vdd_disconnect_state: platformInterface.soc_vdd_disconnect_states.states
                                onSoc_vdd_disconnect_stateChanged: {
                                    setStatesForControls(vDDVoltageDisconnect,soc_vdd_disconnect_state[0])
                                }

                                property var soc_vdd_disconnect_values: platformInterface.soc_vdd_disconnect_values.values
                                onSoc_vdd_disconnect_valuesChanged: {
                                    vDDVoltageDisconnect.checkedLabel = soc_vdd_disconnect_values[0]
                                    vDDVoltageDisconnect.uncheckedLabel = soc_vdd_disconnect_values[1]
                                }

                                property var soc_vdd_disconnect_value: platformInterface.soc_vdd_disconnect_value.value
                                onSoc_vdd_disconnect_valueChanged:{
                                    if(soc_vdd_disconnect_value === "Connect")
                                        vDDVoltageDisconnect.checked = true

                                    else  vDDVoltageDisconnect.checked = false
                                }


                            }
                        }




                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    // color: "green"
                    RowLayout{
                        anchors.fill: parent

                        Rectangle {
                            Layout.preferredWidth: parent.width/4
                            Layout.fillHeight: true

                            SGText {
                                id:samconfi1Text
                                //text: "<b>" + qsTr("SAM_CONF_1") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                                property var soc_sam_conf_1_caption: platformInterface.soc_sam_conf_1_caption.caption
                                onSoc_sam_conf_1_captionChanged: {
                                    text = soc_sam_conf_1_caption
                                }
                            }


                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: out1Label
                                target: out1
                                text: "OUT 0"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out1
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false


                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out1 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: out2Label
                                target: out2
                                text: "OUT 1"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out2
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false

                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out2 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out3Label
                                target: out3
                                text: "OUT 2"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out3
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false

                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out3 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out4Label
                                target: out4
                                text: "OUT 3"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out4
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out4 = checked
                                        platformInterface.set_soc_write.update(
                                                   false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out5Label
                                target: out5
                                text: "OUT 4"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out5
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out5 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out6Label
                                target: out6
                                text: "OUT 5"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out6
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out6 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out7Label
                                target: out7
                                text: "OUT 6"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out7
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out7 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out8Label
                                target: out8
                                text: "OUT 7"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out8
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out8 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out9Label
                                target: out9
                                text: "OUT 8"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out9
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out9 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out10Label
                                target: out10
                                text: "OUT 9"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out10
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out10 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out11Label
                                target: out11
                                text: "OUT 10"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out11
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out11 = checked
                                        platformInterface.set_soc_write.update(
                                                   false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: out12Label
                                target: out12
                                text: "OUT 11"
                                alignment: SGAlignedLabel.SideTopCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGSwitch {
                                    id: out12
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc
                                    checked: false
                                    anchors.verticalCenter: parent.verticalCenter
                                    onToggled: {
                                        platformInterface.soc_sam_conf_1_out12 = checked
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12

                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11,
                                                     platformInterface.soc_sam_conf_2_out12
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    RowLayout{
                        anchors.fill: parent

                        Rectangle {
                            Layout.preferredWidth: parent.width/4
                            Layout.fillHeight: true

                            SGText {
                                id: samConfig2Text
                                // text: "<b>" + qsTr("SAM_CONF_2") + "</b>"
                                fontSizeMultiplier: ratioCalc * 1.2
                                anchors.verticalCenter: parent.verticalCenter
                                font.bold: true

                                property var soc_sam_conf_2_caption: platformInterface.soc_sam_conf_2_caption.caption
                                onSoc_sam_conf_2_captionChanged: {
                                    text = soc_sam_conf_2_caption
                                }
                            }


                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGSwitch {
                                id: samOut1
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out1 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut2
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out2 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut3
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out3 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut4
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out4 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut5
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out5 = checked
                                    platformInterface.set_soc_write.update(
                                               false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut6
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out6 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut7
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out7 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut8
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out8 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut9
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out9 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut10
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out10 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut11
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out11 = checked
                                    platformInterface.set_soc_write.update(
                                               false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGSwitch {
                                id: samOut12
                                labelsInside: true
                                checkedLabel: "On"
                                uncheckedLabel: "Off"
                                fontSizeMultiplier: ratioCalc
                                checked: false
                                anchors.verticalCenter: parent.verticalCenter
                                onToggled: {
                                    platformInterface.soc_sam_conf_2_out12 = checked
                                    platformInterface.set_soc_write.update(
                                                false,
                                                [platformInterface.soc_sam_conf_1_out1,
                                                 platformInterface.soc_sam_conf_1_out2,
                                                 platformInterface.soc_sam_conf_1_out3,
                                                 platformInterface.soc_sam_conf_1_out4,
                                                 platformInterface.soc_sam_conf_1_out5,
                                                 platformInterface.soc_sam_conf_1_out6,
                                                 platformInterface.soc_sam_conf_1_out7,
                                                 platformInterface.soc_sam_conf_1_out8,
                                                 platformInterface.soc_sam_conf_1_out9,
                                                 platformInterface.soc_sam_conf_1_out10,
                                                 platformInterface.soc_sam_conf_1_out11,
                                                 platformInterface.soc_sam_conf_1_out12

                                                ],
                                                [platformInterface.soc_sam_conf_2_out1,
                                                 platformInterface.soc_sam_conf_2_out2,
                                                 platformInterface.soc_sam_conf_2_out3,
                                                 platformInterface.soc_sam_conf_2_out4,
                                                 platformInterface.soc_sam_conf_2_out5,
                                                 platformInterface.soc_sam_conf_2_out6,
                                                 platformInterface.soc_sam_conf_2_out7,
                                                 platformInterface.soc_sam_conf_2_out8,
                                                 platformInterface.soc_sam_conf_2_out9,
                                                 platformInterface.soc_sam_conf_2_out10,
                                                 platformInterface.soc_sam_conf_2_out11,
                                                 platformInterface.soc_sam_conf_2_out12
                                                ],
                                                samOpenLoadDiagnostic.currentText,
                                                platformInterface.soc_crcValue,
                                                platformInterface.addr_curr)
                                }
                            }
                        }
                    } // end of RowLayout

                }
            }
        }


        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true


            RowLayout {
                anchors.fill: parent
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true


                    Text {
                        id: oneTimeProgramHeading
                        text: "One Time Program"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line3
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: oneTimeProgramHeading.bottom
                            topMargin: 7
                        }
                    }


                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        anchors {
                            top: line3.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        SGButton {
                            id:  zapButton

                            anchors.verticalCenter: parent.verticalCenter
                            fontSizeMultiplier: ratioCalc
                            color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                            hoverEnabled: true
                            height: parent.height/2
                            width: parent.width/2
                            MouseArea {
                                hoverEnabled: true
                                anchors.fill: parent
                                cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: warningPopup.open()

                            }

                            property var soc_otp: platformInterface.soc_otp
                            onSoc_otpChanged:{
                                text = soc_otp.caption
                                setStatesForControls(zapButton,soc_otp.states[0])
                            }

                            property var soc_otp_caption: platformInterface.soc_otp_caption.caption
                            onSoc_otp_captionChanged: {
                                text = soc_otp_caption
                            }

                            property var soc_otp_state: platformInterface.soc_otp_states.states
                            onSoc_otp_stateChanged: {
                                setStatesForControls(zapButton,soc_otp_state[0])
                            }
                        }
                    }


                }

                Rectangle{
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width/1.5


                    Text {
                        id: diagnosticHeading
                        text: "Diagnostic"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line4
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: diagnosticHeading.bottom
                            topMargin: 7
                        }
                    }

                    RowLayout{
                        width: parent.width
                        height: parent.height - diagnosticHeading.contentHeight - line4.height
                        anchors {
                            top: line4.bottom
                            left: parent.left
                            right: parent.right
                            bottom: parent.bottom
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: diagLabel
                                target: diag
                                alignment: SGAlignedLabel.SideTopCenter
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 1.2
                                // text: "DIAG"
                                font.bold: true

                                SGStatusLight {
                                    id: diag
                                    width : 40

                                }


                                property var soc_diag: platformInterface.soc_diag
                                onSoc_diagChanged: {
                                    diagLabel.text = soc_diag.caption
                                    setStatesForControls(diag,soc_diag.states[0])

                                    //                                    if(soc_diag.state === "enabled"){
                                    //                                        diag.enabled = true
                                    //                                        diag.opacity = 1.0
                                    //                                    }
                                    //                                    else if (soc_diag.state === "disabled") {
                                    //                                        diag.enabled = false
                                    //                                        diag.opacity = 1.0
                                    //                                    }
                                    //                                    else {
                                    //                                        diag.enabled = false
                                    //                                        diag.opacity = 0.5
                                    //                                    }

                                    if(soc_diag.value === true)
                                        diag.status = SGStatusLight.Red
                                    else  diag.status = SGStatusLight.Off

                                }

                                property var soc_diag_caption: platformInterface.soc_diag_caption.caption
                                onSoc_diag_captionChanged: {
                                    diagLabel.text = soc_diag_caption
                                }

                                property var soc_diag_state: platformInterface.soc_diag_states.states
                                onSoc_diag_stateChanged: {
                                    setStatesForControls(diag,soc_diag_state[0])
                                }

                                property var soc_diag_value: platformInterface.soc_diag_value.value
                                onSoc_diag_valueChanged: {
                                    if(soc_diag_value === true)
                                        diag.status = SGStatusLight.Red
                                    else  diag.status = SGStatusLight.Off
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                            SGAlignedLabel {
                                id: samOpenLoadLabel
                                target: samOpenLoadDiagnostic
                                //text: "SAM Open Load\nDiagnostic"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: samOpenLoadDiagnostic
                                    fontSizeMultiplier: ratioCalc
                                    //model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulation Change"]
                                    onActivated: {
                                        platformInterface.set_soc_write.update(
                                                    false,
                                                    [platformInterface.soc_sam_conf_1_out1,
                                                     platformInterface.soc_sam_conf_1_out2,
                                                     platformInterface.soc_sam_conf_1_out3,
                                                     platformInterface.soc_sam_conf_1_out4,
                                                     platformInterface.soc_sam_conf_1_out5,
                                                     platformInterface.soc_sam_conf_1_out6,
                                                     platformInterface.soc_sam_conf_1_out7,
                                                     platformInterface.soc_sam_conf_1_out8,
                                                     platformInterface.soc_sam_conf_1_out9,
                                                     platformInterface.soc_sam_conf_1_out10,
                                                     platformInterface.soc_sam_conf_1_out11,
                                                     platformInterface.soc_sam_conf_1_out12
                                                    ],
                                                    [platformInterface.soc_sam_conf_2_out1,
                                                     platformInterface.soc_sam_conf_2_out2,
                                                     platformInterface.soc_sam_conf_2_out3,
                                                     platformInterface.soc_sam_conf_2_out4,
                                                     platformInterface.soc_sam_conf_2_out5,
                                                     platformInterface.soc_sam_conf_2_out6,
                                                     platformInterface.soc_sam_conf_2_out7,
                                                     platformInterface.soc_sam_conf_2_out8,
                                                     platformInterface.soc_sam_conf_2_out9,
                                                     platformInterface.soc_sam_conf_2_out10,
                                                     platformInterface.soc_sam_conf_2_out11
                                                    ],
                                                    samOpenLoadDiagnostic.currentText,
                                                    platformInterface.soc_crcValue,
                                                    platformInterface.addr_curr)
                                    }
                                }

                                property var soc_sam_open_load_diagnostic: platformInterface.soc_sam_open_load_diagnostic
                                onSoc_sam_open_load_diagnosticChanged: {
                                    samOpenLoadLabel.text = soc_sam_open_load_diagnostic.caption
                                    setStatesForControls(samOpenLoadDiagnostic,soc_sam_open_load_diagnostic.states[0])
                                    samOpenLoadDiagnostic.model = soc_sam_open_load_diagnostic.values
                                    for(var a = 0; a < samOpenLoadDiagnostic.model.length; ++a) {
                                        if(soc_sam_open_load_diagnostic.value === samOpenLoadDiagnostic.model[a].toString()){
                                            samOpenLoadDiagnostic.currentIndex = a
                                        }
                                    }

                                }

                                property var soc_sam_open_load_diagnostic_caption: platformInterface.soc_sam_open_load_diagnostic_caption.caption
                                onSoc_sam_open_load_diagnostic_captionChanged: {
                                    samOpenLoadLabel.text = soc_sam_open_load_diagnostic_caption
                                }

                                property var soc_sam_open_load_diagnostic_state: platformInterface.soc_sam_open_load_diagnostic_states.states
                                onSoc_sam_open_load_diagnostic_stateChanged: {
                                    setStatesForControls(samOpenLoadDiagnostic,soc_sam_open_load_diagnostic_state[0])
                                }

                                property var soc_sam_open_load_diagnostic_values: platformInterface.soc_sam_open_load_diagnostic_values.values
                                onSoc_sam_open_load_diagnostic_valuesChanged: {
                                    samOpenLoadDiagnostic.model = soc_sam_open_load_diagnostic_values
                                }

                                property var soc_sam_open_load_diagnostic_value: platformInterface.soc_sam_open_load_diagnostic_values.value
                                onSoc_sam_open_load_diagnostic_valueChanged: {
                                    for(var a = 0; a < samOpenLoadDiagnostic.model.length; ++a) {
                                        if(soc_sam_open_load_diagnostic_values === samOpenLoadDiagnostic.model[a].toString()){
                                            samOpenLoadDiagnostic.currentIndex = a
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
}
