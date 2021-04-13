import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: controlPage
    objectName: "control"
    anchors.fill: parent
    color: "transparent"

    Text {
        id: pageText
        text: "<b> Load Transient PWM configuration for platform <b> "+ multiplePlatform.partNumber +""
        font {
            pixelSize: (parent.width + parent.height)/ 50
        }
        color:"green"
        anchors {
            horizontalCenter: parent.horizontalCenter
            topMargin: 50
            top:parent.top
        }
    }

    Text {
        id: pageText2
        anchors {
            top: pageText.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text:  "<b>Load transient testing is a quick way to check power converter behavior on several aspects:</b>"
        font.pixelSize: (parent.width + parent.height)/ 120
        color: "blue"

    }

    Text {
        id: pageText3
        anchors {
            top: pageText2.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text:  "<b>It will show the converter regulation speed and can highlight loop stability problems.</b>"
        font.pixelSize: (parent.width + parent.height)/ 120
        color: "blue"

    }

    Text {
        id: pageText4
        anchors {
            top: pageText3.bottom
            horizontalCenter: parent.horizontalCenter
        }
        text:  "<b>Other power converter aspects like input voltage stability, slope compensation issues and layout problems can be quickly spotted as well.</b>"
        font.pixelSize: (parent.width + parent.height)/ 120
        color: "blue"

    }

    //property alias warningVisible: warningBox.visible

    Component.onCompleted: {
        Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0, "loadTransientHelp")
        Help.registerTarget(frequencyControl, "The slider will set the PWM Frequency Transient signal going to the Load. PWM Frequency 0 -> 0 Hz, 1 -> 2.5 kHz, 2 -> 4 kHz, 3 -> 5 kHz, 4 -> 8 kHz, 5 -> 10 kHz" , 1 , "loadTransientHelp")
        Help.registerTarget(dutyControl, "The slider will set the PWM Positive Duty Cycle % signal going to the Load." , 2 , "loadTransientHelp")
        Help.registerTarget(basicImageLT, "Load transient testing with high slew rates.", 8, "loadTransientHelp")
        Help.registerTarget(operationModeControl, "These are two modes to control the system. In Load Transient mode, PWM signal will be set by the slider above. In Normal mode, the system will go through a particular PWM signal profile.", 4 , "loadTransientHelp")
        Help.registerTarget(ioutGraph, "Output Current is plotted in real time", 7, "loadTransientHelp")
        Help.registerTarget(voutGraph, "Output Voltage is plotted in real time", 6, "loadTransientHelp")
        Help.registerTarget(powerOutputGauge, "This gauge shows the Output Power.", 3, "loadTransientHelp")
        Help.registerTarget(powerInputGauge, "This gauge shows the Input Power.", 5, "loadTransientHelp")
    }

    // Control Section
    Rectangle {
        id: controlSection1
        width: parent.width
        height:parent.height - pageText4.contentHeight - 10
        anchors {
            top: pageText4.bottom
            bottom: parent.bottom
            bottomMargin: 10
        }
        Rectangle {
            id: rightControl
            anchors {
                fill: parent
            }
            SGSlider {
                id: frequencyControl
                anchors {
                    left: rightControl.left
                    leftMargin: 40
                    right: setFrequency.left
                    rightMargin: 10
                    top: rightControl.top
                }
                stepSize: 1
                from: 0
                to: 5
                grooveColor: "#ddd"
                grooveFillColor: "green"
                showToolTip: true            // Default: true
                startLabel: "0 Hz"              // Default: from
                endLabel: "10 kHz"            // Default: to
                label: if(platformInterface.frequency == 0 ){"<b>Frequency (0): 0 Hz.<b>"}
                       else if(platformInterface.frequency == 1 ){"<b>Frequency (1): 2.5 kHz.<b>"}
                       else if(platformInterface.frequency == 2 ){"<b>Frequency (2): 4 kHz.<b>"}
                       else if(platformInterface.frequency == 3 ){"<b>Frequency (3): 5 kHz.<b>"}
                       else if(platformInterface.frequency == 4 ){"<b>Frequency (4): 8 kHz.<b>"}
                       else if(platformInterface.frequency == 5 ){"<b>Frequency (5): 10 kHz.<b>"}
                labelLeft: false
                value:
                {
                    if(platformInterface.frequency <= 0 ){
                        return 0
                    }
                    if( platformInterface.frequency >= 5 ) {
                        return 5
                    }
                    return platformInterface.frequency
                }

                onValueChanged: {
                    setFrequency.input = value.toFixed(0)
                    var current_slider_value = value.toFixed(0)
                    if(current_slider_value >= 5 && platformInterface.frequency >= 5){
                        console.log("Do nothing")
                    }
                    else if(current_slider_value <= 0 && platformInterface.frequency <= 0){
                        console.log("Do nothing")
                    }
                    else{
                        platformInterface.frequency = current_slider_value
                    }
                }
            }

            SGSubmitInfoBox {
                id: setFrequency
                infoBoxColor: "white"
                buttonVisible: false
                anchors {
                    verticalCenter: frequencyControl.verticalCenter
                    right: rightControl.right
                    rightMargin: 10
                }
                onApplied: {
                    platformInterface.frequency = parseInt(value, 10)
                }
                input: frequencyControl.value
                infoBoxWidth: 80
            }

            SGSlider {
                id: dutyControl
                anchors {
                    left: rightControl.left
                    leftMargin: 40
                    right: setPWM.left
                    rightMargin: 10
                    top: rightControl.top
                    topMargin: 100
                }
                startLabel: "0%"
                endLabel: "Max. 80%"
                showToolTip: true
                grooveColor: "#ddd"
                grooveFillColor: "orange"
                stepSize: 1
                from: 0
                to: 80
                label: "<b>PWM Positive Duty Cycle (%):</b>"
                labelLeft: false
                value:
                {
                    if(platformInterface.duty <= 0 ){
                        return 0
                    }
                    if( platformInterface.duty >= 80 ) {
                        return 80
                    }
                    return platformInterface.duty
                }

                onValueChanged: {
                    setPWM.input = value.toFixed(0)
                    var current_slider_value2 = value.toFixed(0)
                    if(current_slider_value2 >= 80 && platformInterface.duty >= 80){
                        console.log("Do nothing")
                    }
                    else if(current_slider_value2 <= 0 && platformInterface.duty <= 0){
                        console.log("Do nothing")
                    }
                    else{
                        platformInterface.duty = current_slider_value2
                    }
                }
            }

            SGSubmitInfoBox {
                id: setPWM
                infoBoxColor: "white"
                buttonVisible: false
                anchors {
                    verticalCenter: dutyControl.verticalCenter
                    right: rightControl.right
                    rightMargin: 10
                    topMargin: 100
                }
                onApplied: {
                    platformInterface.duty = parseInt(value, 10)
                }
                input: dutyControl.value
                infoBoxWidth: 80
            }

            Rectangle {
                anchors {
                    top : dutyControl.bottom
                    topMargin: 5
                }

                width: parent.width
                height: parent.height/1.3
                RowLayout {
                    anchors.fill: parent
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGRadioButtonContainer {
                            id: operationModeControl
                            anchors {
                                top: parent.top
                                topMargin: 30
                                left: parent.left
                                leftMargin: 5
                            }

                            label: "<b>Operation Mode:</b>"
                            labelLeft: false
                            exclusive: true

                            radioGroup: GridLayout {
                                columnSpacing: 5
                                rowSpacing: 5
                                // Optional properties to access specific buttons cleanly from outside
                                property alias manual : manual
                                property alias automatic: automatic

                                SGRadioButton {
                                    id: manual
                                    text: "Normal Operation"
                                    checked: platformInterface.systemMode
                                    onCheckedChanged: {
                                        if (checked) {
                                            console.log("manual")
                                            platformInterface.systemMode = true
                                            //platformInterface.frequency = 0
                                            //platformInterface.duty = 0
                                            frequencyControl.sliderEnable = false
                                            frequencyControl.opacity = 0.5
                                            dutyControl.sliderEnable = false
                                            dutyControl.opacity = 0.5
                                        }
                                        else {
                                            console.log("automatic")
                                            platformInterface.systemMode = false
                                            platformInterface.frequency = 0
                                            platformInterface.duty = 0
                                            frequencyControl.sliderEnable = true
                                            frequencyControl.opacity = 1.0
                                            dutyControl.sliderEnable = true
                                            dutyControl.opacity = 1.0
                                        }
                                    }
                                }

                                SGRadioButton {
                                    id: automatic
                                    text: "Load Transient"
                                    checked : !manual.checked
                                }
                            }
                        }

                        SGCircularGauge {
                            id: powerInputGauge
                            anchors {
                                centerIn: parent
                            }
                            width: parent.width
                            height: parent.height/2
                            gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            minimumValue: 0
                            maximumValue: multiplePlatform.poutScale
                            tickmarkStepSize: multiplePlatform.poutStep
                            outerColor: "#999"
                            unitLabel: if(multiplePlatform.pdiss === "mW") {"mW"}
                                       else{"W"}
                            gaugeTitle: "Input Power"
                            value: if(multiplePlatform.pdiss === "mW") {((platformInterface.status_voltage_current.vin) * ((platformInterface.status_voltage_current.iin)))/1000}
                                   else{(((platformInterface.status_voltage_current.vin) * ((platformInterface.status_voltage_current.iin)))/1000000).toFixed(3)}
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }

                    }
                    Rectangle{
                        Layout.preferredWidth: parent.width/2.2
                        Layout.fillHeight: true
                        GraphConverter{
                            id: voutGraph
                            width: parent.width/2
                            height: parent.height/2
                            anchors {
                                left: parent.left
                                top: parent.top
                            }
                            showOptions: false
                            autoAdjustMaxMin: false
                            //repeatOldData: visible
                            dataLineColor: "blue"
                            textColor: "black"
                            axesColor: "black"
                            gridLineColor: "lightgrey"
                            underDataColor: "transparent"
                            backgroundColor: "white"
                            xAxisTickCount: 11
                            yAxisTickCount: 6
                            throttlePlotting: true
                            pointCount: 30
                            title: "<b>Output Voltage</b>"
                            xAxisTitle: "<b>50 µs / div<b>"
                            yAxisTitle: "Output Voltage (V)"
                            inputData: {((platformInterface.status_voltage_current.vout)/1000)}
                            maxYValue: multiplePlatform.voutScale
                            showYGrids: true
                            showXGrids: true
                            minXValue: 0
                            maxXValue: 5
                            reverseDirection: true
                        }

                        GraphConverter {
                            id: ioutGraph
                            width: parent.width/2
                            height: parent.height/2
                            anchors {
                                left: parent.left
                                top: voutGraph.bottom
                                topMargin: 2
                                bottom: parent.bottom
                            }
                            showOptions: false
                            autoAdjustMaxMin: false
                            //repeatOldData: visible
                            dataLineColor: "lightgreen"
                            textColor: "black"
                            axesColor: "black"
                            gridLineColor: "lightgrey"
                            underDataColor: "transparent"
                            backgroundColor: "white"
                            xAxisTickCount: 11
                            yAxisTickCount: 6
                            throttlePlotting: true
                            pointCount: 30
                            title: "<b>Output Current</b>"
                            xAxisTitle: "<b>50 µs / div<b>"
                            yAxisTitle: if(multiplePlatform.current === "mA") {"Output Current (mA)"}
                                        else{"Output Current (A)"}
                            inputData: if(multiplePlatform.current === "mA") {((platformInterface.status_voltage_current.iout))}
                                       else{(((platformInterface.status_voltage_current.iout))/1000).toFixed(3)}
                            maxYValue: if(multiplePlatform.current === "mA") {multiplePlatform.ioutScale * 1000}
                                       else{multiplePlatform.ioutScale}
                            showYGrids: true
                            showXGrids: true
                            minXValue: 0
                            maxXValue: 5
                            reverseDirection: true
                        }

                        Image {
                            id:basicImageLT
                            Layout.preferredHeight: parent.height
                            Layout.preferredWidth: parent.width
                            source:"images/transient.gif"
                            width: parent.width/2
                            height: parent.height
                            anchors {
                                left: ioutGraph.right
                                verticalCenter: parent.verticalCenter
                            }
                            // fillMode: Image.PreserveAspectFit
                            mipmap: true
                            opacity: 1
                        }

                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        SGCircularGauge {
                            id: powerOutputGauge
                            anchors {
                                centerIn: parent
                            }
                            width: parent.width
                            height: parent.height/2
                            gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                            gaugeFrontColor2: Qt.rgba(1,0,0,1)
                            minimumValue: 0
                            maximumValue: multiplePlatform.poutScale
                            tickmarkStepSize: multiplePlatform.poutStep
                            outerColor: "#999"
                            unitLabel: if(multiplePlatform.pdiss === "mW") {"mW"}
                                       else{"W"}
                            gaugeTitle: "Output Power"
                            value: if(multiplePlatform.pdiss === "W") {(((platformInterface.status_voltage_current.vout) * ((platformInterface.status_voltage_current.iout)))/1000000).toFixed(0)}
                                   else{(((platformInterface.status_voltage_current.vout) * ((platformInterface.status_voltage_current.iout)))/1000).toFixed(0)}
                            Behavior on value { NumberAnimation { duration: 300 } }
                        }
                    }
                }
            }
        }

    } // end Control Section Rectangle
}
