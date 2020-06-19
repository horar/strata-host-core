import QtQuick 2.10
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9

Rectangle {
    id: front
    color:backgroundColor
    opacity:1
    radius: 10

    property color backgroundColor: "#D1DFFB"
    property color accentColor:"#86724C"
    property int telemetryTextWidth:250
    property color buttonSelectedColor:"#91ABE1"

    Text{
        id:chargerLabel
        anchors.top:parent.top
        anchors.topMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        font.pixelSize: 24
        text:"Charger"
    }
    Rectangle{
        id:underlineRect
        anchors.left:chargerLabel.left
        anchors.top:chargerLabel.bottom
        anchors.topMargin: -5
        anchors.right:parent.right
        anchors.rightMargin: 10
        height:1
        color:"grey"
    }

    Column{
        id:telemetryColumn
        anchors.top: underlineRect.bottom
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.right:parent.right
        spacing: 10
        Row{
            spacing:10
            width:parent.width

            Text{
                id:ocpLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"VBUS over voltage protection:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSegmentedButtonStrip {
                id: ocpSegmentedButton
                labelLeft: false
                anchors.left: sinkCapLabel.right
                anchors.leftMargin: 10
                anchors.verticalCenter: sinkCapLabel.verticalCenter
                textColor: "#444"
                activeTextColor: "white"
                radius: buttonHeight/2
                buttonHeight: 20
                exclusive: true
                buttonImplicitWidth: 40
                hoverEnabled:false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("6.5V")
                        activeColor: buttonSelectedColor
                        inactiveColor: "white"
                        checked: true
                        //height:40
                        onClicked: {}
                    }

                    SGSegmentedButton{
                        text: qsTr("10.5V")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {}
                    }
                    SGSegmentedButton{
                        text: qsTr("13.7V")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {}
                    }

                }
            }

        }
        Row{
            spacing:10

            Text{
                id:ibusCurrentLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"IBUS current limit:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSlider{
                id:ibusCurrentLimitSlider
                anchors.verticalCenter: ibusCurrentLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                from:100
                to:3000
                inputBox: true
                grooveColor: "grey"
                grooveFillColor: hightlightColor
            }
            Text{
                id:busCurrentLimitUnit
                font.pixelSize: 15
                text:"mA"
                color: "grey"
            }

        }
        Row{
            spacing:10

            Text{
                id:fastChargeLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Fast charge current label:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSlider{
                id:fastChargeSlider
                anchors.verticalCenter: fastChargeLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                from:200
                to:3000
                inputBox: true
                grooveColor: "grey"
                grooveFillColor: hightlightColor
            }
            Text{
                id:fastChargeUnit
                font.pixelSize: 15
                text:"mA"
                color: "grey"
            }

        }
        Row{
            spacing:10

            Text{
                id:prechargeCurrentLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Precharge current limit:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSlider{
                id:preChargeCurrentSlider
                anchors.verticalCenter: prechargeCurrentLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                from:200
                to:800
                inputBox: true
                grooveColor: "grey"
                grooveFillColor: hightlightColor
            }

            Text{
                id:prechargeCurrentLimitUnit
                font.pixelSize: 15
                text:"mA"
                color: "grey"
            }
        }
        Row{
            spacing:10

            Text{
                id:terminationCurrentLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Termination curent limit:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSlider{
                id:terminationCurrentLimitSlider
                anchors.verticalCenter: terminationCurrentLabel.verticalCenter
                anchors.verticalCenterOffset: 5
                height:25
                from:100
                to:600
                inputBox: true
                grooveColor: "grey"
                grooveFillColor: hightlightColor
            }

            Text{
                id:terminationCurrentLimitUnit
                font.pixelSize: 15
                text:"mA"
                color: "grey"
            }
        }
        Row{
            spacing:10

            Text{
                id:temperatureThresholdLabel
                font.pixelSize: 18
                width:telemetryTextWidth
                text:"Charge mode:"
                horizontalAlignment: Text.Text.AlignRight
                color: "black"
            }
            SGSegmentedButtonStrip {
                id: tempThresholdSegmentedButton
                labelLeft: false
                anchors.left: sinkCapLabel.right
                anchors.leftMargin: 10
                anchors.verticalCenter: sinkCapLabel.verticalCenter
                textColor: "#444"
                activeTextColor: "white"
                radius: buttonHeight/2
                buttonHeight: 20
                exclusive: true
                buttonImplicitWidth: 40
                hoverEnabled:false

                segmentedButtons: GridLayout {
                    columnSpacing: 2
                    rowSpacing: 2

                    SGSegmentedButton{
                        text: qsTr("70°C")
                        activeColor: buttonSelectedColor
                        inactiveColor: "white"
                        checked: true
                        //height:40
                        onClicked: {}
                    }

                    SGSegmentedButton{
                        text: qsTr("85°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {}
                    }
                    SGSegmentedButton{
                        text: qsTr("100°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {}
                    }
                    SGSegmentedButton{
                        text: qsTr("120°C")
                        activeColor:buttonSelectedColor
                        inactiveColor: "white"
                        //height:40
                        onClicked: {}
                    }

                }
            }


        }


    }
}
