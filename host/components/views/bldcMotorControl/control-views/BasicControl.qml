import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    property int leftMargin: 75
    property int labelFontSize: 36
    property int labelUnitFontSize: 24
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



        Rectangle{
            height:100
            width:parent.width
            Text {
                id: targetSpeedLabel
                text: "Target speed:"
                width:parent.width/2
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -10
                font {
                    pixelSize: labelFontSize
                }
            }


            SGSlider {
                id: targetSpeedSlider
                width: parent.width * .95
                from: 100
                to: 2000
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: targetSpeedLabel.right
                anchors.leftMargin: 10
                inputBox.unit:"rpm"
                //I wish I could change the color of this text
                //inputBox.unit.implicitColor: "lightgrey" CS-250
                inputBox.fontSizeMultiplier: 2.5
                inputBoxWidth: 150
                handleSize: 20
                inputBox.boxFont.family: "helvetica"
                stepSize: 1

                value: platformInterface.target_speed.rpm

                onMoved:{
                    platformInterface.set_target_speed.update(value)
                }
            }
        }

        SGAlignedLabel {
            id: actualspeedLabel
            target: actualSpeedRow
            text: "Actual speed:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            Row{
                id:actualSpeedRow
                Text {
                    id: actualSpeedText
                    width: 90
                    text:platformInterface.speed.rpm
                    font.pixelSize: labelFontSize
                }

                Text {
                    id: actualSpeedUnitText
                    width: 150
                    text:" rpm"
                    color:"lightgrey"
                    horizontalAlignment: Text.AlignLeft
                    anchors.bottom:parent.bottom
                    font.pixelSize: labelUnitFontSize
                }
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
                text:platformInterface.state.M_state
                font.pixelSize: labelFontSize
            }


        }

        SGAlignedLabel {
            id: dcLinkLabel
            target: dcLinkRow
            text: "DC Link:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            Row{
                id:dcLinkRow

                Text {
                    id: dcLinkText
                    width: 65
                    text:platformInterface.link_voltage.link_v
                    font.pixelSize: labelFontSize

                }
                Text {
                    id: dcLinkUnitText
                    width: 100
                    text:" V"
                    color:"lightgrey"
                    horizontalAlignment: Text.AlignLeft
                    anchors.bottom:parent.bottom
                    font.pixelSize: labelUnitFontSize
                }
            }
        }

        SGAlignedLabel {
            id: phaseCurrentLabel
            target: phaseCurrentRow
            text: "Phase current:"
            overrideLabelWidth:leftTextWidth
            horizontalAlignment: Text.AlignRight
            font {
                pixelSize: labelFontSize
            }

            alignment: SGAlignedLabel.SideLeftCenter

            Row{
                id:phaseCurrentRow
                Text {
                    id: phaseCurrentText
                    width: 50
                    text:platformInterface.phase_current.p_current
                    font.pixelSize: labelFontSize
                }
                Text {
                    id: phaseCurrentUnitText
                    width: 100
                    text:" A"
                    color:"lightgrey"
                    horizontalAlignment: Text.AlignLeft
                    anchors.bottom:parent.bottom
                    font.pixelSize: labelUnitFontSize
                }
            }
        }

        Rectangle{
            height:100
            width:parent.width
            Text {
                id: poleLabel
                text: "Number of poles:"
                width:parent.width/2
                horizontalAlignment: Text.AlignRight
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -10
                font {
                    pixelSize: labelFontSize
                }
            }


            SGSlider {
                id: poleSlider
                width: parent.width*.95
                from: 4
                to: 48
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: poleLabel.right
                anchors.leftMargin: 10
                inputBox.unit:""
                inputBox.fontSizeMultiplier: 2.5
                inputBoxWidth: 60
                handleSize: 20
                inputBox.boxFont.family: "helvetica"
                stepSize: 2

                value: platformInterface.poles.poles

                onMoved:{
                    platformInterface.set_poles.update(value)
                }
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


                MCSegmentedButton{
                    text: qsTr("Graph")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "white"
                    textActiveColor: "black"
                    textSize:labelFontSize
                    checked: true
                    hoverEnabled: false
                    onClicked: {
                        graphTachometerContainerRect.showGraph();
                    }
                }

                MCSegmentedButton{
                    text: qsTr("Tachometer")
                    activeColor: "dimgrey"
                    inactiveColor: "gainsboro"
                    textColor: "white"
                    textActiveColor: "black"
                    textSize:labelFontSize
                    hoverEnabled: false
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
                title: "Graph"                  // Default: empty
                xAxisTitle: "Seconds"           // Default: empty
                yAxisTitle: "rpm"          // Default: empty
                showYGrids: true                // Default: false
                // showXGrids: false               // Default: false
                reverseDirection: true          // Default: false - Reverses the direction of graph motion
                autoAdjustMaxMin: true          // Default: false - If inputData is greater than maxYValue or less than minYValue, these limits are adjusted to encompass that point.
                maxYValue: 2000                  // Default: 10
                maxXValue: 10

                opacity:1
                anchors.centerIn: parent

                inputData: platformInterface.speed.rpm

            }

            SGCircularGauge {
                id: speedGauge
                anchors.centerIn: parent
                height: 300
                width: 300
                opacity:0

                value: platformInterface.speed.rpm
            }
        }


    }   //right Column

    Row{
        id:buttonRow
        anchors.bottom:root.bottom
        anchors.bottomMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        spacing:50

        SGButton{
            property bool isRunning: false

            id:startButton
            text:isRunning ? "stop" : "start"
            fontSizeMultiplier:2.4


            background: Rectangle {
                implicitWidth: 150
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                //border.color: motor1standbyButton.down ? "grey" : "dimgrey"
                color: startButton.isRunning ? "red" :"green"
                border.width: 1
                radius: 10
            }

            onClicked: {
                //send something to the platform
                startButton.isRunning = !startButton.isRunning
            }


        }


        SGButton{
            id:pauseButton
            text:"pause"
            checkable: true

            fontSizeMultiplier:2.4

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
