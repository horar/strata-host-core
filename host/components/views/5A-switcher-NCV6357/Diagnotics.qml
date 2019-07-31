import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    height: 350
    width: parent.width
    anchors.left: parent.left

    property var sense_register: platformInterface.status_sense_register.sense_reg_value
    property string register_Binary
    onSense_registerChanged: {
        register_Binary = ("00000000"+sense_register.toString(2)).substr(-8)
        console.log("asdasdada: ",register_Binary)
    }

    property var read_sense_register_status: platformInterface.initial_status_1.read_int_sen
    onRead_sense_register_statusChanged: {
        register_Binary = ("00000000"+read_sense_register_status.toString(2)).substr(-8)
    }

    Component.onCompleted: {
        helpIcon.visible = true
        Help.registerTarget(diagnoticsContainer, "Clicking the blank circles under each interrupt will fill the circle in signaling that the interrupt has been masked. By clicking read, the LEDs will light up to give the user the current status of the interrupt sense register (INTSEN).", 0, "advance5Asetting3Help")
    }

    SGIcon {
        id: helpIcon
        anchors {
            right: parent.right
            rightMargin: 15
            top: parent.top
            topMargin: 10
        }
        source: "question-circle-solid.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        sourceSize.height: 40
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
        width : parent.width/1.1
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
            anchors.fill:parent
            spacing: 20

            ColumnLayout {
                id: container
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100

                Layout.preferredHeight: 50
                Layout.leftMargin: 20
                spacing: 20

                Text {
                    id: titleColumn
                    width: parent.width
                    height: parent.height/2
                    text: " "
                    Layout.alignment: Qt.AlignCenter
                }

                Button {
                    id: readTitle
                    Text {
                        text: "Read Sense\n Register"
                        font.bold: true
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                    }
                    background: Rectangle {
                        color: "light gray"
                        border.width: 1
                        border.color: "gray"
                        radius: 10
                    }

                    Layout.minimumWidth: 40
                    Layout.preferredWidth: 110
                    Layout.maximumWidth: 90
                    Layout.minimumHeight:60
                    Layout.alignment: Qt.AlignCenter

                    onClicked: {
                        platformInterface.read_sense_register.update()
                    }
                }
            }


            ColumnLayout {
                //spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100

                Text {
                    id: tsd
                    width: parent.width
                    height: parent.height/4
                    text: "TSD"
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter
                }


                SGStatusLight {
                    id: tsd2
                    lightSize: 30
                    Layout.alignment: Qt.AlignCenter
                    property string register_value: register_Binary

                    onRegister_valueChanged: {
                        if(register_value[0] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }
                }
            }

            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Text {
                    id: twarn
                    width: parent.width
                    height: parent.height/4
                    text: "TWARN"
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter
                }



                SGStatusLight {
                    id: twarn2
                    lightSize: 30
                    Layout.alignment: Qt.AlignCenter
                    property string register_value: register_Binary
                    onRegister_valueChanged: {
                        if(register_value[1] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }
                }
            }

            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Text {
                    id: tprew
                    width: parent.width
                    height: parent.height/4
                    text: "TPREW"
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight {
                    id: tprew2
                    lightSize: 30
                    Layout.alignment: Qt.AlignCenter
                    property string register_value: register_Binary
                    onRegister_valueChanged: {
                        if(register_value[2] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }
                }
            }

            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100

                Text {
                    id: ishort
                    width: parent.width
                    height: parent.height/4
                    text: "ISHORT"
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight {
                    id: ishort2
                    lightSize: 30
                    Layout.alignment: Qt.AlignCenter
                    property string register_value: register_Binary

                    onRegister_valueChanged: {
                        if(register_value[4] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }

                }

            }

            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100

                Text {
                    id: uvlo
                    width: parent.width
                    height: parent.height/4
                    Layout.alignment: Qt.AlignCenter

                    text: "UVLO"
                    font.bold: true
                }

                SGStatusLight {
                    id: uvlo2
                    lightSize: 30
                    Layout.alignment: Qt.AlignCenter
                    property string register_value: register_Binary

                    onRegister_valueChanged: {
                        if(register_value[5] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }
                }
            }


            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100

                Text {
                    id: idcdc
                    width: parent.width
                    height: parent.height/4
                    Layout.alignment: Qt.AlignCenter
                    text: "IDCDC"
                    font.bold: true
                }

                SGStatusLight {
                    id: idcdc2
                    Layout.alignment: Qt.AlignCenter
                    lightSize: 30

                    property string register_value: register_Binary

                    onRegister_valueChanged: {
                        if(register_value[6] === "1"){
                            status = "green"
                        }
                        else status = "red"
                    }
                }
            }

            ColumnLayout {
                spacing: 20
                Layout.minimumWidth: 50
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.rightMargin: 10
                Text {
                    id: pg
                    width: parent.width
                    text: "PG"
                    font.bold: true
                    Layout.alignment: Qt.AlignCenter
                }

                SGStatusLight {
                    id: pg2
                    Layout.alignment: Qt.AlignCenter
                    lightSize: 30
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
