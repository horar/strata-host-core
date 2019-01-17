import QtQuick 2.9
import QtQuick.Controls 2.2
import "component_source.js" as ComponentSource

Item {
    id: root

    Row {
        id: header
        anchors {
            horizontalCenter: root.horizontalCenter
        }

        Rectangle {
            id: col1
            color: "#ddd"
            height: 30
            width: col1Text.width + 40
            Text {
                id: col1Text
                text: '<b>MOSFET</b>'
                anchors {
                    verticalCenter: col1.verticalCenter
                    horizontalCenter: col1.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col2
            color: "#ddd"
            height: 30
            width: col2Text.width + 40
            Text {
                id: col2Text
                text: '<b>RDSon</b>'
                anchors {
                    verticalCenter: col2.verticalCenter
                    horizontalCenter: col2.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col3
            color: "#ddd"
            height: 30
            width: col3Text.width + 40
            Text {
                id: col3Text
                text: '<b>Coss</b>'
                anchors {
                    verticalCenter: col3.verticalCenter
                    horizontalCenter: col3.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col4
            color: "#ddd"
            height: 30
            width: col4Text.width + 40
            Text {
                id: col4Text
                text: '<b>Qgd</b>'
                anchors {
                    verticalCenter: col4.verticalCenter
                    horizontalCenter: col4.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col5
            color: "#ddd"
            height: 30
            width: col5Text.width + 40
            Text {
                id: col5Text
                text: '<b>Qgs</b>'
                anchors {
                    verticalCenter: col5.verticalCenter
                    horizontalCenter: col5.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col6
            color: "#ddd"
            height: 30
            width: col6Text.width + 40
            Text {
                id: col6Text
                text: '<b>Vth</b>'
                anchors {
                    verticalCenter: col6.verticalCenter
                    horizontalCenter: col6.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col7
            color: "#ddd"
            height: 30
            width: col7Text.width + 40
            Text {
                id: col7Text
                text: '<b>SD Diode Forward Voltage</b>'
                anchors {
                    verticalCenter: col7.verticalCenter
                    horizontalCenter: col7.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col8
            color: "#ddd"
            height: 30
            width: col8Text.width + 40
            Text {
                id: col8Text
                text: '<b>Transconductance</b>'
                anchors {
                    verticalCenter: col8.verticalCenter
                    horizontalCenter: col8.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col9
            color: "#ddd"
            height: 30
            width: col9Text.width + 40
            Text {
                id: col9Text
                text: '<b>Internal Rgin</b>'
                anchors {
                    verticalCenter: col9.verticalCenter
                    horizontalCenter: col9.horizontalCenter
                }
            }
        }

        Rectangle {
            id: col10
            color: "#ddd"
            height: 30
            width: col10Text.width + 40
            Text {
                id: col10Text
                text: '<b>Thermal Resistance</b>'
                anchors {
                    verticalCenter: col10.verticalCenter
                    horizontalCenter: col10.horizontalCenter
                }
            }
        }

//        Rectangle {
//            id: col11
//            color: "#ddd"
//            height: 30
//            width: col11Text.width + 40
//            Text {
//                id: col11Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col11.verticalCenter
//                    horizontalCenter: col11.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col12
//            color: "#ddd"
//            height: 30
//            width: col12Text.width + 40
//            Text {
//                id: col12Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col12.verticalCenter
//                    horizontalCenter: col12.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col13
//            color: "#ddd"
//            height: 30
//            width: col13Text.width + 40
//            Text {
//                id: col13Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col13.verticalCenter
//                    horizontalCenter: col13.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col14
//            color: "#ddd"
//            height: 30
//            width: col14Text.width + 40
//            Text {
//                id: col14Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col14.verticalCenter
//                    horizontalCenter: col14.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col15
//            color: "#ddd"
//            height: 30
//            width: col15Text.width + 40
//            Text {
//                id: col15Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col15.verticalCenter
//                    horizontalCenter: col15.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col16
//            color: "#ddd"
//            height: 30
//            width: col16Text.width + 40
//            Text {
//                id: col16Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col16.verticalCenter
//                    horizontalCenter: col16.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col17
//            color: "#ddd"
//            height: 30
//            width: col17Text.width + 40
//            Text {
//                id: col17Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col17.verticalCenter
//                    horizontalCenter: col17.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col18
//            color: "#ddd"
//            height: 30
//            width: col18Text.width + 40
//            Text {
//                id: col18Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col18.verticalCenter
//                    horizontalCenter: col18.horizontalCenter
//                }
//            }
//        }

//        Rectangle {
//            id: col19
//            color: "#ddd"
//            height: 30
//            width: col19Text.width + 40
//            Text {
//                id: col19Text
//                text: '<b>SD Diode Forward Voltage</b>'
//                anchors {
//                    verticalCenter: col19.verticalCenter
//                    horizontalCenter: col19.horizontalCenter
//                }
//            }
//        }
    }

    ListView {
        id: mosfetView
        anchors {
            left: header.left
            right: header.right
            bottom: root.bottom
            top: header.bottom
        }
        model: mosfetModel
        clip: true
        delegate: Rectangle {
            id: infoRowContainer
            width: infoRow.width
            height: 20
            color: index %2 === 0 ? "#eee" : "white"
            Row {
                id: infoRow
                anchors {
                    verticalCenter: infoRowContainer.verticalCenter
                }
                Text {
                    text: "  " + component_id
                    width: col1.width
                }
                Text {
                    text: RDSon45
                    width: col2.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: Coss
                    width: col3.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: Qgd
                    width: col4.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: Qgs
                    width: col5.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: Vth
                    width: col6.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: SDDiodeForwardVoltage
                    width: col7.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: Transconductance
                    width: col8.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: InternalRgin
                    width: col9.width
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    text: ThermalResistance
                    width: col10.width
                    horizontalAlignment: Text.AlignHCenter
                }
//                Text {
//                    text: RDSonTemperatureCoefficient
//                    width: col11.width
//                    horizontalAlignment: Text.AlignHCenter
//                }
//                Text {
//                    text: RDSon10
//                    width: col12.width
//                    horizontalAlignment: Text.AlignHCenter
//                }
//                Text {
//                    text: measuredQrr
//                    width: col13.width
//                    horizontalAlignment: Text.AlignHCenter
//                }
            }
        }
    }

    ListModel {
        id: mosfetModel
        Component.onCompleted: {
            ComponentSource.loadComponentsIntoModel("MOSFET", this)
        }
    }
}
