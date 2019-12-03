import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    property int leftMargin: 50
    property int labelFontSize: 36
    property int leftTextWidth: 200


    Text {
        id: title
        text: "motor controller"
        font {
            pixelSize: 72
        }
        color:"black"
        anchors {
            horizontalCenter: root.horizontalCenter
            top: parent.top
            topMargin: 50
        }
    }

    Column{
        id:leftColumn

        anchors.top:title.bottom
        anchors.topMargin: 50
        anchors.left:parent.left
        anchors.leftMargin: root.leftMargin
        anchors.bottom:parent.bottom
        width: parent.width/3
        spacing: 20




        SGAlignedLabel {
            id: targetSpeedLabel
            target: targetSpeedSlider
            text: "Target speed:"
            width:parent.width
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            SGSlider {
                id: targetSpeedSlider
                width: 350
                from: 100
                to: 2000
                anchors.top:parent.top
                anchors.topMargin:20
                inputBox.unit:"rpm"
                //I wish I could change the color of this text
                //inputBox.unit.implicitColor: "lightgrey"
                inputBox.fontSizeMultiplier: 2.5
                handleSize: 20
                inputBox.boxFont.family: "helvetica"
                stepSize: 1
            }
        }

        SGAlignedLabel {
            id: actualspeedLabel
            target: actualSpeedText
            text: "Actual speed:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            SGInfoBox {
                id: actualSpeedText
                width: 150
                text:"1350"
                readOnly: true
                unit: "rpm"
                fontSizeMultiplier: 2.5
                boxColor:"transparent"
                boxBorderColor: "transparent"
                boxFont.family: "helvetica"
                unitFont.family: "helvetica"
                textPadding: 0

            }
        }

        SGAlignedLabel {
            id: stateLabel
            target: stateText
            text: "State:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            Text{
                id: stateText
                width: 150
                text:" ramping"
                font.pixelSize: 36
            }


        }

        SGAlignedLabel {
            id: dcLinkLabel
            target: dcLinkText
            text: "DC Link:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            SGInfoBox {
                id: dcLinkText
                width: 100
                text:"123"
                readOnly: true
                unit: "V"
                fontSizeMultiplier: 2.5
                boxColor:"transparent"
                boxBorderColor: "transparent"
                boxFont.family: "helvetica"
                unitFont.family: "helvetica"

            }
        }

        SGAlignedLabel {
            id: phaseCurrentLabel
            target: phaseCurrentText
            text: "Phase current:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            SGInfoBox {
                id: phaseCurrentText
                width: 100
                text:"3.2"
                readOnly: true
                unit: "A"
                boxFont.family: "helvetica"
                unitFont.family: "helvetica"
                fontSizeMultiplier: 2.5
                boxColor:"transparent"
                boxBorderColor: "transparent"
            }
        }
    }

    Column{
        id:spacerColumn

        anchors.top:title.bottom
        anchors.topMargin: 50
        anchors.bottom:parent.bottom
        anchors.left:leftColumn.right
        width: parent.width/6
    }

    Column{
        id:rightColumn

        anchors.top:title.bottom
        anchors.topMargin: 50
        anchors.left: spacerColumn.right

        width: parent.width/3
        spacing: 20

        Widget09.SGSegmentedButtonStrip {
            id: graphSelector
            labelLeft: false
            anchors.left: parent.left
            anchors.leftMargin: parent.width/4

            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 50
            exclusive: true
            buttonImplicitWidth: 200

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                Widget09.SGSegmentedButton{
                    text: qsTr("Graph")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "black"
                    textActiveColor: "white"
                    checked: true
                    onClicked: {
                        graphTachometerContainerRect.showGraph();
                    }
                }

                Widget09.SGSegmentedButton{
                    text: qsTr("Tachometer")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "black"
                    textActiveColor: "white"
                    onClicked: {
                        graphTachometerContainerRect.showTachometer();
                    }
                }
            }
        }


        Rectangle{
            id:graphTachometerContainerRect
            height:400
            width:500
            //border.color:"red"

            OpacityAnimator{
                id:fadeInGraph
                target: rpmGraph
                from: 0.0
                to: 1
                duration:2000
                running:false
            }

            OpacityAnimator{
                id:fadeInTachometer
                target: speedGauge
                from: 0.0
                to: 1
                duration:2000
                running:false
            }

            OpacityAnimator{
                id:fadeOutGraph
                target: rpmGraph
                from: 1
                to: 0
                duration:1000
                running:false
            }

            OpacityAnimator{
                id:fadeOutTachometer
                target: speedGauge
                from: 1
                to: 0
                duration:1000
                running:false
            }

            function showGraph(){
                fadeInGraph.start()
                if (speedGauge.opacity !== 0)
                    fadeOutTachometer.start()
            }

            function showTachometer(){
                fadeInTachometer.start()
                if (rpmGraph.opacity !== 0)
                    fadeOutGraph.start()
            }

            Widget09.SGGraphTimed{
                id:rpmGraph
                height:400
                width:500
                opacity:1
                anchors.centerIn: parent


            }

            SGCircularGauge {
                id: speedGauge
                anchors.centerIn: parent
                height: 300
                width: 300
                opacity:0

                //value: platformInterface._motor_speed
            }
        }


    }   //right Column

    Row{
        id:buttonRow
        anchors.bottom:root.bottom
        anchors.bottomMargin: root.leftMargin
        anchors.horizontalCenter: parent.horizontalCenter
        spacing:50

        SGButton{
            id:startButton
            text:"start"
            contentItem: Text {
                text: startButton.text
                font.pixelSize: 32
                color:"black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                color:startButton.down ? "dimgrey" : "lightgrey"
                border.width: 1
                radius: 10
            }


        }

        SGButton{
            id:haltButton
            text:"halt"
            contentItem: Text {
                text: haltButton.text
                font.pixelSize: 32
                color:"black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                color:haltButton.down ? "dimgrey" : "lightgrey"
                border.width: 1
                radius: 10
            }

        }
        SGButton{
            id:pauseButton
            text:"pause"
            checkable: true

            contentItem: Text {
                text: pauseButton.text
                font.pixelSize: 32
                color:"black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color:pauseButton.checked ? "dimgrey" : "lightgrey"
                border.width: 1
                radius: 10
            }

        }

    }
}
