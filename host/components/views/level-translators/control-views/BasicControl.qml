import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height

    Component.onCompleted: {
        Help.registerTarget(enableI2c, "Enable or disable the I2C FXMA2102 level shifter. The IO pins will be high impedance when disabled.", 0, "levelTranslatorsHelp")
        Help.registerTarget(vcca_vccbI2c, "Monitors VCCA and VCCB voltages of the I2C FXMA2102 level shifter circuit. Apply voltage using the headers at the left and right side of the board.", 1, "levelTranslatorsHelp")
        Help.registerTarget(enableSpi, "Enable or disable the SPI FXLA104 level shifter. The IO pins will be high impedance when disabled.", 2, "levelTranslatorsHelp")
        Help.registerTarget(vcca_vccbSpi, "Monitors VCCA and VCCB voltages of the SPI FXLA104 level shifter circuit. Apply voltage using the headers at the left and right side of the board.", 3, "levelTranslatorsHelp")
        Help.registerTarget(enableUni, "Enable or disable UB (Uni/Bi Directional) FXL4TD245 level shifter. The IO pins will be high impedance when disabled.", 4, "levelTranslatorsHelp")
        Help.registerTarget(vcca_vccbUni, "Monitors VCCA and VCCB voltages of the UB (Uni/Bi Directional) FXL4TD245 level shifter circuit. Apply voltage using the headers at the left and right side of the board.", 5, "levelTranslatorsHelp")
        Help.registerTarget(trSwitchContainerForHelp,"Transmit and receive inputs. Transmit will send data from A to B (left to right on the PCB) and receive will send data from B to A (right to left on PCB).", 6, "levelTranslatorsHelp")
    }

    Item {
        id: vcca_vccbI2c
        property point topLeft
        property point bottomRight
        width:  (vcca3.width) * 3
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = vcca3.mapToItem(root, 0,  0)
            bottomRight = vccb3.mapToItem(root, vccb3.width, vccb3.height)
        }
    }
    Item {
        id: vcca_vccbSpi
        property point topLeft
        property point bottomRight
        width:  (vcca2.width) * 3
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = vcca2.mapToItem(root, 0,  0)
            bottomRight = vccb2.mapToItem(root, vccb2.width, vccb2.height)
        }
    }
    Item {
        id: vcca_vccbUni
        property point topLeft
        property point bottomRight
        width:  (vcca.width) * 3
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = vcca.mapToItem(root, 0,  0)
            bottomRight = vccb.mapToItem(root, vccb.width, vccb.height)
        }
    }

    onWidthChanged: {
        vcca_vccbI2c.update()
        vcca_vccbSpi.update()
        vcca_vccbUni.update()
    }
    onHeightChanged: {
        vcca_vccbI2c.update()
        vcca_vccbSpi.update()
        vcca_vccbUni.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            vcca_vccbI2c.update()
            vcca_vccbSpi.update()
            vcca_vccbUni.update()
        }
    }

    property var startup: platformInterface.startup
    onStartupChanged: {
        enableI2c.checked = startup.oe_i2c
        enableSpi.checked = startup.oe_spi
        enableUni.checked = startup.oe_ub
        tr0.checked = startup.tr_0
        tr1.checked = startup.tr_1
        tr2.checked = startup.tr_2
        tr3.checked = startup.tr_3
    }

    property var adc: platformInterface.adc
    onAdcChanged: {
        vcca3.text = adc.vcca_i2c.toFixed(2)
        vccb3.text  = adc.vccb_i2c.toFixed(2)

        vcca2.text = adc.vcca_spi.toFixed(2)
        vccb2.text  = adc.vccb_spi.toFixed(2)

        vcca.text = adc.vcca_ub.toFixed(2)
        vccb.text  = adc.vccb_ub.toFixed(2)
    }

    MouseArea {
        id: containMouseArea
        anchors.fill: parent
        onClicked: {
            forceActiveFocus()
        }
    }
    ColumnLayout {
        width: parent.width
        height: parent.height/1.2
        spacing: 5
        anchors.centerIn: parent
        Text {
            id: platformName
            Layout.alignment: Qt.AlignHCenter
            text: "Level Shifters"
            font.bold: true
            font.pixelSize: ratioCalc * 30
            topPadding: 7
        }
        Rectangle {
            Layout.preferredWidth: parent.width/1.5
            Layout.preferredHeight: parent.height - platformName.contentHeight - 40
            Layout.alignment: Qt.AlignCenter
            ColumnLayout {
                anchors.fill:parent
                Rectangle{
                    Layout.preferredHeight: parent.height/5
                    Layout.fillWidth: true
                    color: "red"
                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                id: thirdHeading
                                text: "I2C FXMA2102"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }

                            Rectangle {
                                id: line3
                                height: 1.5
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 1.5
                                anchors {
                                    top: thirdHeading.bottom
                                    topMargin: 7
                                }
                            }
                            RowLayout {
                                anchors {
                                    top: line3.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id:  enableI2cLabel
                                        target: enableI2c
                                        text: "Enable"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent

                                        SGSwitch {
                                            id: enableI2c
                                            checkedLabel: "On"
                                            uncheckedLabel: "Off"
                                            onToggled: {
                                                platformInterface.oe_i2c_command.update(checked)
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vcca3Label
                                        target: vcca3
                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        text: "VCCA"
                                        anchors.centerIn: parent
                                        SGInfoBox {
                                            id: vcca3
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            boxColor: "lightgrey"
                                            boxFont.family: Fonts.digitalseven
                                            height:  35 * ratioCalc
                                            width: 125 * ratioCalc
                                            unit: "<b>V</b>"
                                            text: "1.50"



                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vccb3Label
                                        target: vccb3
                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        text: "VCCB"
                                        anchors.centerIn: parent
                                        SGInfoBox {
                                            id: vccb3
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            boxColor: "lightgrey"
                                            boxFont.family: Fonts.digitalseven
                                            height:  35 * ratioCalc
                                            width: 125 * ratioCalc
                                            unit: "<b>V</b>"
                                            text: "1.26"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.preferredHeight: parent.height/5
                    Layout.fillWidth: true
                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                id: secondHeading
                                text: "SPI FXLA104"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }
                            Rectangle {
                                id: line2
                                height: 1.5
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 1.5
                                anchors {
                                    top: secondHeading.bottom
                                    topMargin: 7
                                }
                            }
                            RowLayout{
                                anchors {
                                    top: line2.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id:  enableSpiLabel
                                        target: enableSpi
                                        text: "Enable"
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        font.bold : true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        anchors.centerIn: parent

                                        SGSwitch {
                                            id: enableSpi
                                            checkedLabel: "On"
                                            uncheckedLabel: "Off"
                                            onToggled: {
                                                platformInterface.oe_spi_command.update(checked)
                                            }
                                        }
                                    }
                                }
                                Rectangle{
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vcca2Label
                                        target: vcca2
                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        text: "VCCA"
                                        anchors.centerIn: parent
                                        SGInfoBox {
                                            id: vcca2
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            boxColor: "lightgrey"
                                            boxFont.family: Fonts.digitalseven
                                            height:  35 * ratioCalc
                                            width: 125 * ratioCalc
                                            unit: "<b>V</b>"
                                            text: "1.20"


                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    SGAlignedLabel {
                                        id: vccb2Label
                                        target: vccb2
                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopLeft
                                        fontSizeMultiplier: ratioCalc * 1.2
                                        text: "VCCB"
                                        anchors.centerIn: parent
                                        SGInfoBox {
                                            id: vccb2
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                            boxColor: "lightgrey"
                                            boxFont.family: Fonts.digitalseven
                                            height:  35 * ratioCalc
                                            width: 125 * ratioCalc
                                            unit: "<b>V</b>"
                                            text: "3.00"


                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Item {
                        id: trSwitchContainerForHelp
                        width: parent.width/1.2
                        height: parent.height/12
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 45
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Text {
                                id: firstHeading
                                text: "Uni/Bi FXL4TD245"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    left: parent.left
                                    leftMargin: 10
                                    top: parent.top
                                }
                            }

                            Rectangle {
                                id: line1
                                height: 1.5
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 1.5
                                anchors {
                                    top: firstHeading.bottom
                                    topMargin: 7
                                }
                            }

                            ColumnLayout{
                                width: parent.width
                                height: parent.height - line1.height - firstHeading.contentHeight
                                anchors {
                                    top: line1.bottom
                                    topMargin: 10
                                    left: parent.left
                                    right: parent.right
                                    bottom: parent.bottom
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"
                                    RowLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  enableUniLabel
                                                target: enableUni
                                                text: "Enable"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent
                                                SGSwitch {
                                                    id: enableUni
                                                    checkedLabel: "On"
                                                    uncheckedLabel: "Off"
                                                    onToggled: {
                                                        platformInterface.oe_ub_command.update(checked)
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: vccaLabel
                                                target: vcca
                                                font.bold: true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "VCCA"
                                                anchors.centerIn: parent
                                                SGInfoBox {
                                                    id: vcca
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    height:  35 * ratioCalc
                                                    width: 125 * ratioCalc
                                                    unit: "<b>V</b>"
                                                    text: "1.50"
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id: vccbLabel
                                                target: vccb
                                                font.bold: true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                text: "VCCB"
                                                anchors.centerIn: parent
                                                SGInfoBox {
                                                    id: vccb
                                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                    boxColor: "lightgrey"
                                                    boxFont.family: Fonts.digitalseven
                                                    height:  35 * ratioCalc
                                                    width: 125 * ratioCalc
                                                    unit: "<b>V</b>"
                                                    text: "2.50"
                                                }
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"
                                    GridLayout{
                                        anchors.fill: parent
                                        columns: 4
                                        columnSpacing: -30
                                        Rectangle {
                                            id: trContainer
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  tr0Label
                                                target: tr0
                                                text: "T/R#0"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent
                                                SGSwitch {
                                                    id: tr0
                                                    checkedLabel: "Transmit"
                                                    uncheckedLabel: "Recieve"
                                                    onToggled: {
                                                        platformInterface.tr_0_command.update(checked)
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  tr1Label
                                                target: tr1
                                                text: "T/R#1"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent
                                                SGSwitch {
                                                    id: tr1
                                                    checkedLabel: "Transmit"
                                                    uncheckedLabel: "Recieve"
                                                    onToggled: {
                                                        platformInterface.tr_1_command.update(checked)
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true

                                            SGAlignedLabel {
                                                id:  tr2Label
                                                target: tr2
                                                text: "T/R#2"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent
                                                SGSwitch {
                                                    id: tr2
                                                    checkedLabel: "Transmit"
                                                    uncheckedLabel: "Recieve"
                                                    onToggled: {
                                                        platformInterface.tr_2_command.update(checked)
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillHeight: true
                                            Layout.fillWidth: true
                                            SGAlignedLabel {
                                                id:  tr3Label
                                                target: tr3
                                                text: "T/R#3"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                font.bold : true
                                                alignment: SGAlignedLabel.SideTopLeft
                                                anchors.centerIn: parent
                                                SGSwitch {
                                                    id: tr3
                                                    checkedLabel: "Transmit"
                                                    uncheckedLabel: "Recieve"
                                                    onToggled: {
                                                        platformInterface.tr_3_command.update(checked)
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
        }
    }
}

