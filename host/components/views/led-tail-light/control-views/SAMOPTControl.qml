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
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

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
        width: parent.width/1.5
        height: parent.height/1.2
        anchors.centerIn: parent

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true

            RowLayout {
                anchors.fill: parent

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: diagLabel
                        target: diag
                        alignment: SGAlignedLabel.SideTopCenter
                        anchors {
                            top:parent.top
                            topMargin: 10
                            //left: parent.left
                            verticalCenter: parent.verticalCenter
                            //leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "DIAG"
                        font.bold: true

                        SGStatusLight {
                            id: diag
                            //width : 30

                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: enableCRCLabel
                        target: enableCRC
                        text: "Enable\nCRC"
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors {
                            top:parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: enableCRC
                            labelsInside: true
                            checkedLabel: "on"
                            uncheckedLabel: "off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc * 1.2
                            checked: false
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: vDDVoltageDisconnectLabel
                        target: vDDVoltageDisconnect
                        text: "VDD Voltage\nDisconnect"
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors {
                            top:parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: vDDVoltageDisconnect
                            labelsInside: true
                            checkedLabel: "Connect"
                            uncheckedLabel: "Disconnect"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc * 1.2
                            checked: false
                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: i2cStandaloneLabel
                        target: i2cStandalone
                        text: "I2C/Standalone\n(I2CFLAG)"
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors {
                            top:parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: i2cStandalone
                            labelsInside: true
                            checkedLabel: "on"
                            uncheckedLabel: "off"
                            textColor: "black"              // Default: "black"
                            handleColor: "white"            // Default: "white"
                            grooveColor: "#ccc"             // Default: "#ccc"
                            grooveFillColor: "#0cf"         // Default: "#0cf"
                            fontSizeMultiplier: ratioCalc * 1.2
                            checked: false
                        }
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    SGAlignedLabel {
                        id: samOpenLoadLabel
                        target: samOpenLoadDiagnostic
                        text: "SAM Open Load\nDiagnostic"
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors {
                            top:parent.top
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            leftMargin: 20
                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: samOpenLoadDiagnostic
                            fontSizeMultiplier: ratioCalc
                            model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulation Change"]
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
                        text: "<b>" + qsTr("SAM_CONF_1") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        anchors.verticalCenter: parent.verticalCenter
                    }


                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out1
                        width: 30
                        anchors.centerIn: parent
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out2
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out3
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out4
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out5
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out6
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out7
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out8
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out9
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out10
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out11
                        width: 30
                        anchors.centerIn: parent
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: out12
                        width: 30
                        anchors.centerIn: parent
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
                        text: "<b>" + qsTr("SAM_CONF_2") + "</b>"
                        fontSizeMultiplier: ratioCalc * 1.2
                        anchors.verticalCenter: parent.verticalCenter
                    }


                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut1
                        width: 30
                        anchors.centerIn: parent
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut2
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut3
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut4
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut5
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut6
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut7
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut8
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut9
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut10
                        width: 30
                        anchors.centerIn: parent
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut11
                        width: 30
                        anchors.centerIn: parent
                    }
                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight {
                        id: samOut12
                        width: 30
                        anchors.centerIn: parent
                    }
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
                    SGAlignedLabel {
                        id: current7bitLabel
                        text: "Current 7-bit\nI2C Address"
                        target: current7bit
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGInfoBox {
                            id: current7bit
                            height:  35 * ratioCalc
                            width: 140 * ratioCalc
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                            text: "0x60"

                        }
                    }
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    SGAlignedLabel {
                        id: new7bitLabel
                        text: "New 7-bit I2C\nAddress After OTP"
                        target: new7bit
                        alignment: SGAlignedLabel.SideTopLeft
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGSubmitInfoBox {
                            id: new7bit
                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                            height:  35 * ratioCalc
                            width: 140 * ratioCalc
                            validator: IntValidator { }
                            placeholderText: "0x60-0x7F"

                        }
                    }


                }

                //                Rectangle {
                //                    Layout.fillHeight: true
                //                    Layout.preferredWidth: parent.width/6
                //                    RowLayout {
                //                        anchors.fill: parent
                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true

                //                            SGAlignedLabel {
                //                                id: i2cAddressLabel
                //                                text: "I2C\nAddress"
                //                                target: i2cAddress
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true

                //                                SGStatusLight {
                //                                    id: i2cAddress
                //                                    width: 30

                //                                }
                //                            }
                //                        }

                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true
                //                            SGAlignedLabel {
                //                                id: placeholdLabel
                //                                text: "\n"
                //                                target: add2
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true
                //                                SGStatusLight {
                //                                    id: add2
                //                                    width: 30
                //                                    //anchors.centerIn: parent
                //                                }
                //                            }
                //                        }
                //                    }
                //                }

                //                Rectangle {
                //                    Layout.preferredWidth: parent.width/2.6
                //                    Layout.fillHeight: true
                //                    RowLayout {
                //                        anchors.fill: parent
                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true
                //                            SGAlignedLabel {
                //                                id: placehold3Label
                //                                text: "\n"
                //                                target: add3
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true
                //                                SGStatusLight {
                //                                    id: add3
                //                                    width: 30
                //                                    // anchors.centerIn: parent
                //                                }
                //                            }
                //                        }

                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true
                //                            SGAlignedLabel {
                //                                id: placehold4Label
                //                                text: "\n"
                //                                target: add4
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true
                //                                SGStatusLight {
                //                                    id: add4
                //                                    width: 30
                //                                    // anchors.centerIn: parent
                //                                }
                //                            }
                //                        }
                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true
                //                            SGAlignedLabel {
                //                                id: placehold5Label
                //                                text: "\n"
                //                                target: add5
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true
                //                                SGStatusLight {
                //                                    id: add5
                //                                    width: 30
                //                                    //anchors.centerIn: parent
                //                                }
                //                            }
                //                        }

                //                        Rectangle {
                //                            Layout.fillHeight: true
                //                            Layout.fillWidth: true

                //                            SGAlignedLabel {
                //                                id: placehold6Label
                //                                text: "\n"
                //                                target: add6
                //                                alignment: SGAlignedLabel.SideTopLeft
                //                                anchors.centerIn: parent
                //                                fontSizeMultiplier: ratioCalc * 1.2
                //                                font.bold : true
                //                                SGStatusLight {
                //                                    id: add6
                //                                    width: 30
                //                                    // anchors.centerIn: parent
                //                                }
                //                            }
                //                        }
                //                    }
                //                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            RowLayout {
                width:parent.width/2
                height: parent.height
                anchors.left:parent.left
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGButton {
                        id:  zapButton
                        text: qsTr("One Time \n Program (zap)")
                        anchors.verticalCenter: parent.verticalCenter
                        fontSizeMultiplier: ratioCalc
                        color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                        hoverEnabled: true
                        height: parent.height/2
                        width: parent.width/1.5
                        MouseArea {
                            hoverEnabled: true
                            anchors.fill: parent
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: warningPopup.open()

                        }
                    }

                }
            }
        }
    }
}
