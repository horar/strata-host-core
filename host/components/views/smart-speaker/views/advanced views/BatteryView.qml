import QtQuick 2.10
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"

    property int theStateOfHealth: 50
    property int theRunTime: 27
    property int theAmbientTemperature: 40
    property int theBatteryTemperature: 22
    property int theFloatVoltage: 12
    property string theChargeMode: "fast charge"
    property string thePowerMode: "battery"
    property bool isInOverCurrentProtection: false
    property int telemetryTextWidth:175
    property int theTimeToEmpty:10
    property int theTimeToFull:60
    property int theBatteryPercentage:52


    Text{
        id:telemetryLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"Battery"
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

    Rectangle{
        id:noBatteryScrim
        anchors.top:underlineRect.bottom
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.right:parent.right
        anchors.bottom:parent.bottom
        color:backgroundColor
        z: 10
        visible:false

        Text{
            id:noBatteryText
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top:parent.top
            anchors.topMargin: parent.height/4
            text:"no \nbattery"
            horizontalAlignment: Text.AlignHCenter
            color:hightlightColor
            font.pixelSize: 72
            opacity:.75
        }
    }

    Column{
        id:batteryColumn
        anchors.top: underlineRect.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.right:parent.right
        Row{
            id:timeToFullRow
            spacing:10
            width:parent.width

            Text{
                id:timeToFullLabel
                font.pixelSize: 13
                width:telemetryTextWidth-45
                text:"Time to full:"
                horizontalAlignment: Text.AlignRight
                color: "black"
            }
            Text{
                id:timeToFullValue
                font.pixelSize: 13
                text:theTimeToFull
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:timeToFullUnit
                font.pixelSize: 13
                text:"min."
                color: "grey"
            }
        }
        Row{
            id:batteryRow
            spacing:10
            width:parent.width
            height: 140
            Rectangle{
                height: 150
                width:parent.width
                color:"transparent"
                Text{
                    id:batteryPercentage
                    font.pixelSize: 36
                    text:theBatteryPercentage
                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right:batteryRectangle.left
                    anchors.rightMargin: 25
                    color: "black"
                    width:50
                }
                Text{
                    id:batteryPercentageUnit
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 5
                    anchors.left: batteryPercentage.right
                    anchors.leftMargin: 5
                    font.pixelSize: 15
                    text:"%"

                    color: "grey"
                }
                Rectangle{
                    id:batteryRectangle
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    height:125
                    width:75
                    radius:15
                    border.color:"black"
                    border.width: 2
                    color:"transparent"

                    Rectangle{
                        id:batteryTip
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom:parent.top
                        anchors.bottomMargin: -2
                        height:batteryRectangle.height/12
                        width:batteryRectangle.width/2
                        border.color:"black"
                        color:"transparent"
                    }

                    Column{
                        anchors.top: parent.top
                        anchors.topMargin: 10
                        anchors.left:parent.left
                        anchors.leftMargin: 10
                        anchors.right:parent.right
                        anchors.rightMargin: 10
                        spacing:batteryRectangle.height/12

                        Rectangle{
                            id:rectangle1
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color: theBatteryPercentage > 80?"green":"transparent"
                        }
                        Rectangle{
                            id:rectangle2
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color: theBatteryPercentage > 60?"green":"transparent"
                        }
                        Rectangle{
                            id:rectangle3
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color: theBatteryPercentage > 40?"green":"transparent"
                        }
                        Rectangle{
                            id:rectangle4
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color: theBatteryPercentage > 20?"green":"transparent"
                        }
                        Rectangle{
                            id:rectangle5
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color: theBatteryPercentage > 0?"green":"transparent"
                        }
                    }
                }
            }
        }

        Row{
            id:timeToEmptyRow
            spacing:5
            width:parent.width

            Text{
                id:timeToEmptyLabel
                font.pixelSize: 13
                width:telemetryTextWidth-45
                text:"Time to empty:"
                horizontalAlignment: Text.AlignRight
                color: "black"
            }
            Text{
                id:timeToEmptyValue
                font.pixelSize: 13
                text:theTimeToEmpty
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:timeToEmptyUnit
                font.pixelSize: 13
                text:"min."
                color: "grey"
            }
        }
    }

    Column{
        id:telemetryColumn
        anchors.top: underlineRect.bottom
        anchors.topMargin: 200
        anchors.left:parent.left
        anchors.right:parent.right
        Row{
            id:stateOfHealthRow
            spacing:10
            width:parent.width

            Text{
                id:stateOfHealthLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"State of health:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:stateOfHealthValue
                font.pixelSize: 18
                text:theStateOfHealth
                horizontalAlignment: Text.Text.AlignLeft
                color: "black"
            }
            Text{
                id:stateOfHealthUnit
                font.pixelSize: 15
                text:"%"
                color: "grey"
            }
        }
        Row{
            id:runTimeRow
            spacing:10

            Text{
                id:runTimeLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"RunTime:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:runTimeValue
                font.pixelSize: 18
                text:theRunTime
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:runTimeUnit
                font.pixelSize: 15
                text:"minutes"
                color: "grey"
            }
        }
        Row{
            id:ambientTemperatureRow
            spacing:10

            Text{
                id:ambientTemperatureLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Ambient temperature:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:ambientTemperatureValue
                font.pixelSize: 18
                text:theAmbientTemperature
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:ambientTemperatureUnit
                font.pixelSize: 15
                text:"°C"
                color: "grey"
            }
        }
        Row{
            id:batteryTemperatureRow
            spacing:10

            Text{
                id:batteryTemperatureLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Battery temperature:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:batteryTemperatureValue
                font.pixelSize: 18
                text:theBatteryTemperature
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:batteryTemperatureUnit
                font.pixelSize: 15
                text:"°C"
                color: "grey"
            }
        }
        Row{
            id:floatVoltageRow
            spacing:10

            Text{
                id:floatVoltageLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Float voltage:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:floatVoltageValue
                font.pixelSize: 18
                text:theFloatVoltage
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }
            Text{
                id:floatVoltageUnit
                font.pixelSize: 15
                text:"V"
                color: "grey"
            }
        }
        Row{
            id:chargeModeRow
            spacing:10

            Text{
                id:chargeModeLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Charge mode:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            Text{
                id:chargeModeValue
                font.pixelSize: 18
                text:theChargeMode
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }

        }
        Row{
            id:powerModeRow
            spacing:10

            Text{
                id:powerModeLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Power mode:"
                horizontalAlignment: Text.AlignRight
                color: "black"
            }
            Text{
                id:powerModeValue
                font.pixelSize: 18
                text:thePowerMode
                horizontalAlignment: Text.AlighLeft
                color: "black"
            }

        }

    }
}
