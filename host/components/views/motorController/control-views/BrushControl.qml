import QtQuick 2.9
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 0.9
import QtQuick.Controls 2.1
import QtGraphicalEffects 1.12
import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        color: motorControllerGrey

        property int leftMargin: 100
        property int statBoxHeight:100
        property int motorColumnTopMargin: 50

        SGSlider{
            id:pwmSlider
            height:50
            anchors.top:parent.top
            anchors.topMargin: 100
            anchors.left:parent.left
            anchors.leftMargin:container.leftMargin*3
            anchors.right:parent.right
            anchors.rightMargin: container.leftMargin * 3

            from: .01
            to: .99
            label: "PWM Fequency:"
            toolTipDecimalPlaces:2
            grooveFillColor: motorControllerTeal

        }

        LinearGradient{
            id:column1background
            anchors.top:pwmSlider.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:parent.left
            //anchors.leftMargin: container.leftMargin
            anchors.bottom:parent.bottom
            width: parent.width/2
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            opacity:.2
            gradient: Gradient {
                GradientStop { position: 0.0; color: motorControllerGrey }
                GradientStop { position: .75; color: motorControllerBlue }
            }
        }

        LinearGradient{
            id:column2background
            anchors.top:pwmSlider.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:column1background.right
            anchors.bottom:parent.bottom
            width: parent.width/2
            start: Qt.point(0, 0)
            end: Qt.point(0, height)
            opacity:.2
            gradient: Gradient {
                GradientStop { position: 0.0; color: motorControllerGrey }
                GradientStop { position: .75; color: motorControllerTeal }
            }
        }

        Column{
            id:motor1Column

            anchors.top:pwmSlider.bottom
            anchors.topMargin: container.motorColumnTopMargin
            anchors.left:parent.left
            anchors.leftMargin: container.leftMargin
            anchors.bottom:parent.bottom
            width: parent.width/3
            spacing: 20




            Row{
                id:motor1SNameRow
                height:container.statBoxHeight
                width: parent.width
                spacing: 20

                Image {
                    id: motor1icon
                    height:container.statBoxHeight
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-motor.svg"
                }

                Text{
                    id:motor1Name
                    text: "Motor 1"
                    font {
                        pixelSize: 72
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        //horizontalCenter: parent.horizontalCenter
                    }
                }
            }


            PortStatBox{
                id:motor1InputVoltage

                height:container.statBoxHeight
                width:parent.width/2
                anchors.horizontalCenter: parent.horizontalCenter
                label: "INPUT VOLTAGE"
                unit:"V"
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .5
                bottomMargin: 10
            }
            PortStatBox{
                id:motor1InputCurrent

                height:container.statBoxHeight
                width:parent.width/2
                anchors.horizontalCenter: parent.horizontalCenter
                label: "INPUT CURRENT"
                unit:"A"
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .5
                bottomMargin: 10
            }

            SGSwitch{
                id:directionSwitch
                label:"Direction:"
                anchors.left:parent.left
                anchors.leftMargin: 5
                grooveFillColor: motorControllerTeal
            }
            SGSlider{
                id:dutyRatioSlider
                anchors.left:parent.left
                width:parent.width

                from: 0
                to: 100
                label: "Duty ratio:"
                grooveFillColor: motorControllerTeal

            }

            Row{
                spacing: 10
                id:motor1ButtonRow
                anchors.horizontalCenter: parent.horizontalCenter

                Button{
                    id:motor1startButton
                    text:"start"

                    contentItem: Text {
                            text: motor1startButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1startButton.down ? "grey" : "dimgrey"
                            color:motor1startButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }


                }
                Button{
                    id:motor1stopButton
                    text:"stop"
                    contentItem: Text {
                            text: motor1stopButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1stopButton.down ? "grey" : "dimgrey"
                            color:motor1stopButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }
                }
                Button{
                    id:motor1standbyButton
                    text:"standby"
                    contentItem: Text {
                            text: motor1standbyButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                            color:motor1standbyButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }
                }

            }
        }

//-------------------------------------------------------------------------------------------------
//
//      spacer column
//
//-------------------------------------------------------------------------------------------------
        Column{
            id:spacerColumn
            anchors.top:pwmSlider.bottom
            anchors.topMargin: container.motorColumnTopMargin/2
            anchors.left:motor1Column.right
            anchors.bottom:parent.bottom
            //anchors.leftMargin: leftMargin
            width: container.leftMargin*2
            //height:400

            Rectangle{
                height:parent.height
                width: 1
                anchors.horizontalCenter: parent.horizontalCenter
                color: "dimgrey"
            }
        }

//-------------------------------------------------------------------------------------------------
//
//      MOTOR 2
//
//-------------------------------------------------------------------------------------------------

        Column{
            id:motor2Column
            anchors.top:pwmSlider.bottom
            anchors.topMargin: container.motorColumnTopMargin
            anchors.left:spacerColumn.right
            width: parent.width/3
            spacing: 20

            Row{
                id:motor2NameRow
                height:container.statBoxHeight
                width: parent.width
                spacing: 20

                Image {
                    id: motor2icon
                    height:container.statBoxHeight
                    fillMode: Image.PreserveAspectFit
                    mipmap:true

                    source:"../images/icon-motor.svg"
                }

                Text{
                    id:motor2Name
                    text: "Motor 2"
                    font {
                        pixelSize: 72
                    }
                    color:"black"
                    opacity:.8
                    anchors {
                        //horizontalCenter: parent.horizontalCenter
                    }
                }
            }



            PortStatBox{
                id:motor2InputVoltage

                height:container.statBoxHeight
                width:parent.width/2
                anchors.horizontalCenter: parent.horizontalCenter
                label: "INPUT VOLTAGE"
                unit:"V"
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .65
                bottomMargin: 10
            }
            PortStatBox{
                id:motor2InputCurrent

                height:container.statBoxHeight
                width:parent.width/2
                anchors.horizontalCenter: parent.horizontalCenter
                label: "INPUT CURRENT"
                unit:"A"
                color:"transparent"
                valueSize: 64
                unitSize:20
                textColor: "black"
                portColor: "#2eb457"
                labelColor:"black"
                //underlineWidth: 0
                imageHeightPercentage: .65
                bottomMargin: 10
            }

            SGSwitch{
                id:directionSwitch2
                label:"Direction:"
                anchors.left:parent.left
                anchors.leftMargin: 5
                grooveFillColor: motorControllerTeal
            }
            SGSlider{
                id:dutyRatioSlider2
                anchors.left:parent.left
                width:parent.width
                from: 0
                to: 100
                label: "Duty ratio:"
                grooveFillColor: motorControllerTeal

            }
            Row{

                id:motor2ButtonRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                SGButton{
                    id:motor2startButton
                    text:"start"
                    contentItem: Text {
                            text: motor2startButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                            color:motor2startButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }
                }
                SGButton{
                    id:motor2stopButton
                    text:"stop"
                    contentItem: Text {
                            text: motor2stopButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                            color:motor2stopButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }
                }
                SGButton{
                    id:motor2standbyButton
                    text:"standby"
                    contentItem: Text {
                            text: motor2standbyButton.text
                            font.pixelSize: 32
                            color:"black"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }

                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 40
                            opacity: enabled ? 1 : 0.3
                            //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                            color:motor2standbyButton.down ? "dimgrey" : "lightgrey"
                            border.width: 1
                            radius: 10
                        }
                }

            }
        }


    }
}



