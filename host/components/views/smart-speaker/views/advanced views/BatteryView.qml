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
    property int telemetryTextWidth:175

    property int theStateOfHealth: platformInterface.battery_status_inf.state_of_health
    property int theRunTime: platformInterface.battery_status_inf.total_run_time
    property int theAmbientTemperature: platformInterface.battery_status_inf.ambient_temp
    property int theBatteryTemperature: platformInterface.battery_status_inf.battery_temp
    property string theChargeMode: platformInterface.charger_status.charge_mode
    property string thePowerMode: platformInterface.charger_status.audio_power_mode
    property int theTimeToEmpty:platformInterface.battery_status_inf.time_to_empty
    property int theTimeToFull:platformInterface.battery_status_inf.time_to_full
    property int theBatteryPercentage:platformInterface.battery_status_inf.rsoc
    property bool batteryIsMissing: platformInterface.battery_status_fre.no_battery_indicator


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
        visible:batteryIsMissing

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
            spacing:5
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
                horizontalAlignment: Text.AlignLeft
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
                            color:{
                                if (theBatteryPercentage > 40)
                                    return "green"
                                  else if (theBatteryPercentage > 20 && theBatteryPercentage < 40)
                                    return "yellow"
                                  else
                                    return "transparent"
                            }
                        }
                        Rectangle{
                            id:rectangle5
                            height:batteryRectangle.height/12
                            width:parent.width
                            border.color:"grey"
                            color:{
                                if (theBatteryPercentage > 40)
                                    return "green";
                                else if (theBatteryPercentage < 40 && theBatteryPercentage > 20)
                                    return "yellow"
                                else
                                    return "red"
                            }
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
            spacing:5
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
            spacing:5

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
            spacing:5

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
            spacing:5

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
            id:chargeModeRow
            spacing:5

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
            spacing:5

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
