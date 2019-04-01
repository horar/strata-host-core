import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/5A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help
import Fonts 1.0

Item {
    id: root
    height: 350
    width: parent.width
    anchors.left: parent.left

    property var sense_register: platformInterface.status_sense_register.sense_reg_value
    property string register_Binary
    onSense_registerChanged: {
        register_Binary = ("00000000"+sense_register.toString(2)).substr(-8)
    }

    property var read_sense_register_status: platformInterface.initial_status_1.read_int_sen
    onRead_sense_register_statusChanged: {
        register_Binary = ("00000000"+read_sense_register_status.toString(2)).substr(-8)
    }


    property var read_mask_register_status: platformInterface.initial_status_1.read_int_msk
    property string register_mask_binary
    onRead_mask_register_statusChanged: {
        register_mask_binary = ("00000000"+read_mask_register_status.toString(2)).substr(-8)
    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(diagnoticsContainer, "Clicking the blank circles under each interrupt will fill the circle in signaling that the interrupt has been masked. By clicking read, the LEDs will light up to give the user the current status of the interrupt sense register (INTSEN).", 0, "advance5Asetting3Help")
    }

    Text {
        id: helpIcon
        anchors {
            right: parent.right
            rightMargin: 15
            top: parent.top
            topMargin: 10

        }
        text: "\ue808"
        color: helpMouse.containsMouse ? "lightgrey" : "grey"
        font {
            family: Fonts.sgicons
            pixelSize: 40
        }
        visible: true

        MouseArea {
            id: helpMouse
            anchors {
                fill: helpIcon
            }
            onClicked: {
                Help.startHelpTour("advance5Asetting3Help")
            }
            hoverEnabled: true
        }
    }

    Rectangle {
        id: diagnoticsContainer
        width : parent.width/1.5
        height: parent.height/2
        color: "transparent"
        border.color: "black"
        border.width: 3
        radius: 10

        anchors {
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }

        RowLayout {
            width: parent.width
            height: parent.height
            spacing: 20

            Rectangle {

                id: container
                width: parent.width/14
                height: parent.height
                color: "red"

                Text {
                    id: titleColumn
                    width: parent.width
                    height: parent.height/4
                    anchors{
                        top:parent.top

                    }
                    text: " "
                }

                Text {
                    id: maskTitle
                    text: "Write Mask\nregister"
                    horizontalAlignment: Text.AlignHCenter


                    font.bold: true
                    width: parent.width
                    height: parent.height/6
                    anchors {
                        top:titleColumn.bottom
                        topMargin: 13
                        left: parent.left
                        leftMargin: 50
                    }
                }

                Button {
                    id: readTitle
                    text: "Read Sense\nRegister"

                    width: 100
                    height: 50
                    anchors {
                        top:maskTitle.bottom
                        topMargin: 20
                        left: parent.left
                        leftMargin: 10
                    }

                    onClicked: {
                        platformInterface.read_sense_register.update()
                    }
                }
            }

            Rectangle {
                width: parent.width/15
                height: parent.height


                ColumnLayout {
                    spacing: 20
                    anchors{
                        left: parent.left
                        leftMargin: 20
                    }

                    Text {
                        id: tsd
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: "TSD"
                        font.bold: true
                    }

                    DiagnoticRadioButton {
                        id: tsd1

                        anchors {
                            top: tsd.bottom
                            topMargin: 39
                            horizontalCenter: tsd.horizontalCenter
                        }

                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[0])
                        }

                        onClicked:{
                            if (checked) {
                                platformInterface.mask_thermal_shutdown_interrupt.update("masked")
                            }
                            else {
                                platformInterface.mask_thermal_shutdown_interrupt.update("unmasked")
                            }
                        }
                    }

                    SGStatusLight {
                        id: tsd2
                        anchors {
                            top: tsd1.bottom
                            topMargin: 20
                            horizontalCenter: tsd.horizontalCenter
                        }
                        lightSize: 25

                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[6] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width/15
                height: parent.height

                ColumnLayout {
                    spacing: 20
                    Text {
                        id: twarn
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        text: "TWARN"
                        font.bold: true
                    }


                    DiagnoticRadioButton{
                        id: twarn1
                        anchors {
                            top: twarn.bottom
                            horizontalCenter: twarn.horizontalCenter
                            topMargin: 39
                        }

                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[1])
                        }

                        onClicked: {
                            if (checked) {
                                platformInterface.mask_thermal_warn_interrupt.update("masked")
                                platformInterface.mask_thermal_warn_interrupt.show()
                            }
                            else {
                                platformInterface.mask_thermal_warn_interrupt.update("unmasked")
                                platformInterface.mask_thermal_warn_interrupt.show()
                            }

                        }

                    }

                    SGStatusLight {
                        id: twarn2
                        anchors {
                            top: twarn1.bottom
                            topMargin: 20
                            horizontalCenter: twarn.horizontalCenter
                        }
                        lightSize: 25

                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[5] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }

                    }

                }

            }

            Rectangle {
                width: parent.width/15
                height: parent.height
                ColumnLayout {
                    spacing: 20
                    Text {
                        id: tprew
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15
                        }
                        text: "TPREW"
                        font.bold: true
                    }
                    DiagnoticRadioButton{
                        id: tprew1
                        anchors {
                            top: tprew.bottom
                            topMargin: 39
                            horizontalCenter: tprew.horizontalCenter
                        }

                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[2])
                        }

                        onClicked: {
                            if (checked) {
                                platformInterface.mask_thermal_prewarn_interrupt.update("masked")
                                platformInterface.mask_thermal_prewarn_interrupt.show()
                            }
                            else {
                                platformInterface.mask_thermal_prewarn_interrupt.update("unmasked")
                                platformInterface.mask_thermal_prewarn_interrupt.show()
                            }
                        }

                    }
                    SGStatusLight {
                        id: tprew2
                        anchors {
                            top: tprew1.bottom
                            topMargin: 20
                            horizontalCenter: tprew.horizontalCenter

                        }
                        lightSize: 25

                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[4] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width/15
                height: parent.height
                ColumnLayout {
                    spacing: 20

                    Text {
                        id: ishort
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15

                        }
                        text: "ISHORT"
                        font.bold: true
                    }
                    DiagnoticRadioButton{
                        id: ishort1
                        anchors {
                            top: ishort.bottom
                            topMargin: 39
                            horizontalCenter: ishort.horizontalCenter
                        }

                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[4])
                        }

                        onClicked: {
                            if (checked) {
                                platformInterface.mask_short_circuit_interrupt.update("masked")
                                platformInterface.mask_short_circuit_interrupt.show()
                            }
                            else {
                                platformInterface.mask_short_circuit_interrupt.update("unmasked")
                                platformInterface.mask_short_circuit_interrupt.show()
                            }
                        }
                    }

                    SGStatusLight {
                        id: ishort2
                        anchors {
                            top: ishort1.bottom
                            topMargin: 20
                            horizontalCenter: ishort.horizontalCenter
                        }
                        lightSize: 25
                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[4] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }

                    }

                }

            }

            Rectangle {
                width: parent.width/15
                height: parent.height

                ColumnLayout {
                    spacing: 20

                    Text {
                        id: uvlo
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter

                        }
                        text: "UVLO"
                        font.bold: true
                    }
                    DiagnoticRadioButton{
                        id: uvlo1
                        anchors {
                            top: uvlo.bottom
                            topMargin: 39
                            horizontalCenter: uvlo.horizontalCenter
                        }

                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[5])
                        }

                        onClicked: {
                            if (checked) {
                                platformInterface.mask_uvlo_interrupt.update("masked")
                                platformInterface.mask_uvlo_interrupt.show()
                            }
                            else {
                                platformInterface.mask_uvlo_interrupt.update("unmasked")
                                platformInterface.mask_uvlo_interrupt.show()
                            }
                        }
                    }
                    SGStatusLight {
                        id: uvlo2
                        anchors {
                            top: uvlo1.bottom
                            topMargin: 20
                            horizontalCenter: uvlo.horizontalCenter
                        }
                        lightSize: 25

                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[5] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }
                    }
                }
            }
            Rectangle {
                width: parent.width/15
                height: parent.height
                color: "yellow"

                ColumnLayout {
                    spacing: 20

                    Text {
                        id: idcdc
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15

                        }
                        text: "IDCDC"
                        font.bold: true
                    }
                    DiagnoticRadioButton{
                        id: idcdc1
                        anchors {
                            top: idcdc.bottom
                            topMargin: 39
                            horizontalCenter:idcdc.horizontalCenter
                        }
                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[6])
                        }
                        onClicked: {
                            if (checked) {
                                platformInterface.mask_ocp_interrupt.update("masked")
                                platformInterface.mask_ocp_interrupt.show()
                            }
                            else {
                                platformInterface.mask_ocp_interrupt.update("unmasked")
                                platformInterface.mask_ocp_interrupt.show()
                            }
                        }
                    }

                    SGStatusLight {
                        id: idcdc2

                        anchors {
                            top: idcdc1.bottom
                            topMargin: 20
                            horizontalCenter: idcdc.horizontalCenter
                        }
                        lightSize: 25

                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[6] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width/2
                height: parent.height

                ColumnLayout {
                    spacing: 20
                    ExclusiveGroup { id: tabPositionGroup6 }
                    Text {
                        id: pg
                        width: parent.width
                        height: parent.height/4
                        anchors{
                            top:parent.top
                            topMargin: 15
                        }
                        text: "PG"
                        font.bold: true
                    }
                    DiagnoticRadioButton{
                        id: pg1
                        anchors {
                            top: pg.bottom
                            topMargin: 39
                        }
                        property string register_value: register_mask_binary
                        onRegister_valueChanged: {
                            checked = parseInt(register_value[7])
                        }

                        onClicked: {
                            if (checked) {
                                platformInterface.mask_pgood_interrupt.update("masked")
                                platformInterface.mask_pgood_interrupt.show()
                            }
                            else {
                                platformInterface.mask_pgood_interrupt.update("unmasked")
                                platformInterface.mask_pgood_interrupt.show()
                            }
                        }
                    }
                    SGStatusLight {
                        id: pg2
                        anchors {
                            top: pg1.bottom
                            topMargin: 20
                        }
                        lightSize: 25
                        property string register_value: register_Binary

                        onRegister_valueChanged: {
                            if(register_value[7] === "1"){
                                status = "green"
                            }
                            else status = "red"
                        }

                    }

                }
            }
        }
    }
}

