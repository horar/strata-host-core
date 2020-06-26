import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color boxBackground: "#91ABE1"
    property color accentColor:"#86724C"
    property int    boxHeight:75
    property int    statBoxUnitSize:18
    property int    statBoxValueSize:36


    Text{
        id:telemetryLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"Telemetry"
    }
    Rectangle{
        id:underlineRect
        anchors.left:telemetryLabel.left
        anchors.top:telemetryLabel.bottom
        anchors.topMargin: -5
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:1
        color:"grey"
    }



    Column{
        id:leftColumn
        anchors.top:telemetryLabel.bottom
        anchors.topMargin: 10
        anchors.bottomMargin: 20
        spacing:10

        Row{
            id:topRow
            spacing: 10

            property bool isConnected: platformInterface.usb_pd_port_connect.connection_state === "connected"

            Text{
                id:usbLabel
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                text:"USB"
                width:70
                horizontalAlignment: Text.AlignRight
            }

            PortStatBox{
                id:usbSpacerBox1
                width:boxHeight
                height:boxHeight
                color:"transparent"
                label: ""
                value:""
                unitColor: "transparent"
                visible:topRow.isConnected
            }

            PortStatBox{
                id:usbVBUSBox
                width:boxHeight
                height:boxHeight
                label: "VBUS"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                visible:topRow.isConnected
                value: platformInterface.request_usb_power_notification.output_voltage
            }

            PortStatBox{
                id:usbSpacerBox2
                width:boxHeight
                height:boxHeight
                color:"transparent"
                label: ""
                value:""
                unitColor: "transparent"
                visible: topRow.isConnected
            }

            Rectangle{
                id:notConnectedScrim
                //width:topRow.width
                width:boxHeight * 3 + (topRow.spacing *2)
                height:boxHeight
                visible:!topRow.isConnected
                color:"transparent"
                Text{
                    anchors.centerIn: parent
                    text:"not connected"
                    color:hightlightColor
                    font.pixelSize: 36
                    opacity:.75
                }
            }

        }
        Row{
            id:middleRow
            spacing: 10
            Text{
                id:batteryLabel
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                text:"Battery"
                width:70
                horizontalAlignment: Text.AlignRight
            }
            PortStatBox{
                id:batteryCurrentBox
                width:boxHeight
                height:boxHeight
                label: "CURRENT"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                unit:"A"
                value:platformInterface.battery_status.battery_current
            }
            PortStatBox{
                id:batteryVoltageBox
                width:boxHeight
                height:boxHeight
                label: "VOLTAGE"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                value: platformInterface.battery_status.battery_voltage
            }
            PortStatBox{
                id:batteryPowerBox
                width:boxHeight
                height:boxHeight
                label: "POWER"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                unit:"W"
                value:platformInterface.battery_status.battery_power
            }
        }
        Row{
            id:bottomRow
            spacing: 10
            Text{
                id:audioRailLabel
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
                text:"Audio\nrail"
                width:70
                horizontalAlignment: Text.AlignRight
            }
            PortStatBox{
                id:audioCurrentBox
                width:boxHeight
                height:boxHeight
                label: "CURRENT"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                unit:"A"
            }
            PortStatBox{
                id:audioVoltageBox
                width:boxHeight
                height:boxHeight
                label: "VOLTAGE"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
            }
            PortStatBox{
                id:audioPowerBox
                width:boxHeight
                height:boxHeight
                label: "POWER"
                labelColor: "white"
                color:boxBackground
                valueSize:statBoxValueSize
                unitSize:statBoxUnitSize
                unitColor: "grey"
                textColor: "black"
                bottomMargin:10
                unit:"W"
                value:platformInterface.audio_power.audio_power
            }
        }
    }
}
