import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import tech.strata.fonts 1.0
import QtQuick.Controls.Styles 1.4
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height



    Popup{
        id: warningPopup
        width: parent.width/2
        height: parent.height/2
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        focus: true
        closePolicy:Popup.CloseOnPressOutside
        background: Rectangle{
            anchors.fill:parent
            color: "transparent"
        }

        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                centerIn: parent
            }
            width: (parent.width/2) + 40
            height: parent.height/12
            Text {
                id: warningText
                anchors {
                    centerIn: warningBox
                }
                text: "<b>Acquire Data In progress</b>"
                font.pixelSize: (parent.width + parent.height)/ 32
                color: "white"
            }

            Text {
                id: warningIcon1
                anchors {
                    right: warningText.left
                    verticalCenter: warningText.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }

            Text {
                id: warningIcon2
                anchors {
                    left: warningText.right
                    verticalCenter: warningText.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "white"
            }
        }
        SGProgressBar{
            id: progressBar
            anchors.top: warningBox.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }


    function setAvgPowerMeter(a,b) {
        var holder = a+b
        return holder
    }

    property var get_power_avdd: platformInterface.get_power.AVDD
    onGet_power_avddChanged: {
        analogPowerConsumption.info = get_power_avdd
    }

    property var get_power_dvdd: platformInterface.get_power.DVDD
    onGet_power_dvddChanged: {
        digitalPowerConsumption.info = get_power_dvdd

    }




    Component.onCompleted: {
        platformInterface.set_adc_supply.update("3.3","3.3")
        platformInterface.get_clk_freqs_values.update()
        clockFrequencyModel.model = populate_clock_frequency()
        platformInterface.get_power_value.update()

    }

    function populate_clock_frequency(){
        var clock_frequency_values = []
        var clk_freqs = platformInterface.get_clk_freqs.clk

        for(var i = 0 ; i < clk_freqs.length; i++) {
            console.log(clk_freqs[i])
            if(i >= 4) {
                clock_frequency_values[i] = clk_freqs[i]/1000 + "MHz"
            }

            else clock_frequency_values[i] = clk_freqs[i] + "kHz"

        }
        return clock_frequency_values
    }

    Rectangle{
        width: parent.width
        height: parent.height/1.8
        color: "#a9a9a9"
        // color: "transparent"
        id: graphContainer

        Text {
            id: partNumber
            text: "STR-NCD98010-GEVK"
            font.bold: true
            color: "white"
            anchors{
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }

            font.pixelSize: 20
            horizontalAlignment: Text.AlignHCenter
        }

        SGGraphStatic {
            id: graph
            anchors {
                top: partNumber.bottom
                topMargin: 10

            }
            width: parent.width/2
            height: parent.height - 130
            title: "Time Domain"                  // Default: empty
            xAxisTitle: "Seconds"            // Default: empty
            yAxisTitle: "Voltage"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "green"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 20                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 20                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false

            Component.onCompleted: {
                for (var i = 0; i < 100; i=(i+.1)){
                    series1.append(i, Math.sin(i)+10)
                }
            }
        }


        SGGraphStatic {
            id: graph2
            anchors {
                left: graph.right
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: partNumber.bottom
                topMargin: 10
            }
            width: parent.width/2
            height: parent.height - 130
            textSize: 15
            title: "Frequency Domain"                  // Default: empty
            xAxisTitle: "Frequency (KHz)"            // Default: empty
            yAxisTitle: "Power (dB)"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "white"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                    // Default: 0
            maxYValue: 20                   // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 20                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false

            Component.onCompleted: {
                for (var i = 0; i < 100; i=(i+.1)){
                    series1.append(i, Math.sin(i)+10)
                }
            }
            GridLayout{
                width: ratioCalc * 250
                height: ratioCalc * 75
                anchors{
                    top: graph2.bottom
                    horizontalCenter: graph2.horizontalCenter
                }
                Button {
                    id: plotSetting1
                    width: ratioCalc * 130
                    height : ratioCalc * 50
                    text: qsTr(" Histogram")
                    checkable: true
                    background: Rectangle {
                        id: backgroundContainer1
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        color: {
                            if(plotSetting2.checked) {
                                color = "lightgrey"
                            }
                            else {
                                color =  "#33b13b"
                            }

                        }
                        border.width: 1
                        radius: 10

                    }
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Text {
                        text: plotSetting1.text
                        font: plotSetting1.font
                        opacity: enabled ? 1.0 : 0.3
                        color: plotSetting1.down ? "#17a81a" : "white"//"#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }



                    onCheckedChanged: {
                        console.log("check2", checked)
                        if(backgroundContainer1.color == "#d3d3d3") {
                            backgroundContainer1.color = "#33b13b"
                            graph2.yAxisTitle = "Power (dB)"
                            graph2.xAxisTitle = "Frequency (KHz)"
                            backgroundContainer2.color = "#d3d3d3"
                        }
                        else {
                            backgroundContainer2.color = "#33b13b"
                            graph2.yAxisTitle = "Hit Count"
                            graph2.xAxisTitle = "Codes"
                            backgroundContainer1.color  = "#d3d3d3"
                        }
                    }
                }
                Button {
                    id: plotSetting2
                    width: ratioCalc * 130
                    height : ratioCalc * 50
                    text: qsTr("FFT")
                    checkable: true
                    background: Rectangle {
                        id: backgroundContainer2
                        implicitWidth: 100
                        implicitHeight: 40
                        opacity: enabled ? 1 : 0.3
                        border.color: plotSetting2.down ? "#17a81a" : "black"//"#21be2b"
                        border.width: 1
                        color: "lightgrey"
                        radius: 10
                    }
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Text {
                        text: plotSetting2.text
                        font: plotSetting2.font
                        opacity: enabled ? 1.0 : 0.3
                        color: plotSetting2.down ? "#17a81a" : "white"//"#21be2b"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    onCheckedChanged: {
                        console.log("check2", checked)
                        if(backgroundContainer2.color == "#d3d3d3") {
                            backgroundContainer2.color = "#33b13b"
                            graph2.yAxisTitle = "Hit Count"
                            graph2.xAxisTitle = "Codes"
                            backgroundContainer1.color = "#d3d3d3"
                        }
                        else {
                            graph2.yAxisTitle = "Power (dB)"
                            graph2.xAxisTitle = "Frequency (KHz)"
                            backgroundContainer1.color = "#33b13b"
                            backgroundContainer2.color  = "#d3d3d3"
                        }
                    }
                }
            }
        }
    }
    Rectangle{
        width: parent.width
        height: parent.height/2
        color: "#696969"
        anchors.top: graphContainer.bottom

        Row{
            anchors.fill: parent
            Rectangle {
                width:parent.width/2.7
                height : parent.height
                anchors{
                    top: parent.top
                    topMargin: 10

                }
                color: "transparent"


                Rectangle{
                    id: adcSetting
                    width: parent.width
                    height: parent.height/4
                    color: "transparent"
                    ColumnLayout {
                        anchors.fill: parent

                        Text {
                            width: ratioCalc * 50
                            height : ratioCalc * 50
                            id: containerTitle
                            text: "ADC Stimuli"
                            font.bold: true
                            font.pixelSize: 20
                            color: "white"
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        SGRadioButtonContainer {
                            id: dvsButtonContainer
                            // Optional configuration:
                            //fontSize: (parent.width+parent.height)/32
                            label: "<b> ADC Digital Supply DVDD: <\b>" // Default: "" (will not appear if not entered)
                            labelLeft: true         // Default: true
                            textColor: "white"      // Default: "#000000"  (black)
                            radioColor: "black"     // Default: "#000000"  (black)
                            exclusive: true         // Default: true
                            Layout.alignment: Qt.AlignCenter


                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10
                                property alias dvdd1: dvdd1
                                property alias dvdd2 : dvdd2


                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: dvdd1
                                    text: "3.3V"
                                    checked: true
                                    onCheckedChanged: {
                                        if(checked){
                                            if(avddButtonContainer.radioButtons.avdd1.checked)
                                                platformInterface.set_adc_supply.update("3.3","3.3")
                                            else platformInterface.set_adc_supply.update("3.3","1.8")
                                        }
                                        else  {
                                            if(avddButtonContainer.radioButtons.avdd1.checked)
                                                platformInterface.set_adc_supply.update("1.8","3.3")
                                            else platformInterface.set_adc_supply.update("1.8","1.8")
                                        }
                                        platformInterface.get_power_value.update()
                                    }
                                }

                                SGRadioButton {
                                    id: dvdd2
                                    text: "1.8V"
                                }
                            }
                        }
                        SGRadioButtonContainer {
                            id: avddButtonContainer
                            // Optional configuration:
                            //fontSize: (parent.width+parent.height)/32
                            label: "<b> ADC Analog Supply AVDD: <\b>" // Default: "" (will not appear if not entered)
                            labelLeft: true         // Default: true
                            textColor: "white"      // Default: "#000000"  (black)
                            radioColor: "black"     // Default: "#000000"  (black)
                            exclusive: true         // Default: true
                            Layout.alignment: Qt.AlignCenter

                            radioGroup: GridLayout {
                                columnSpacing: 10
                                rowSpacing: 10
                                property alias avdd1: avdd1
                                property alias avdd2 : avdd2

                                property int fontSize: (parent.width+parent.height)/8
                                SGRadioButton {
                                    id: avdd1
                                    text: "3.3V"
                                    checked: true
                                    onCheckedChanged: {
                                        if(checked){
                                            if(dvsButtonContainer.radioButtons.dvdd1.checked)
                                                platformInterface.set_adc_supply.update("3.3","3.3")
                                            else platformInterface.set_adc_supply.update("1.8","3.3")
                                        }
                                        else  {
                                            if(dvsButtonContainer.radioButtons.dvdd1.checked)
                                                platformInterface.set_adc_supply.update("3.3","1.8")
                                            else platformInterface.set_adc_supply.update("1.8","1.8")
                                        }
                                        platformInterface.get_power_value.update()

                                    }
                                }
                                SGRadioButton {
                                    id: avdd2
                                    text: "1.8V"
                                }
                            }
                        }
                    }
                }
                Rectangle{
                    id: frequencySetting
                    width:  parent.width
                    height : parent.height/6
                    color: "transparent"
                    anchors{
                        top: adcSetting.bottom
                    }

                    SGSubmitInfoBox{
                        label: "Input Frequency"
                        // placeholderText: "1000.5"
                        value: "1000.5"
                        infoBoxWidth: parent.width/3
                        infoBoxHeight: parent.height/2
                        infoBoxColor: "black"
                        textColor: "white"
                        showButton: false
                        anchors.centerIn: parent
                        unit: "kHz"
                        fontSize: 15
                        validator: DoubleValidator { }
                    }
                }
                Rectangle{
                    id: clockFrequencySetting
                    width:  parent.width
                    height : parent.height/6
                    color: "transparent"
                    anchors{
                        top:frequencySetting.bottom
                    }

                    SGComboBox {
                        id: clockFrequencyModel
                        label: "Clock Frequency"   // Default: "" (if not entered, label will not appear)
                        labelLeft: true           // Default: true
                        comboBoxWidth: parent.width/3          // Default: 120 (set depending on model info length)
                        textColor: "white"          // Default: "black"
                        indicatorColor: "#aaa"      // Default: "#aaa"
                        borderColor: "white"         // Default: "#aaa"
                        boxColor: "black"           // Default: "white"
                        dividers: true              // Default: false
                        comboBoxHeight: parent.height/2
                        anchors.centerIn: parent
                        fontSize: 15
                        onActivated: {
                            platformInterface.set_clk.update(currentText.substring(0,currentText.length - 3))
                            platformInterface.get_power_value.update()
                        }



                        //model: ["10 kHz", "50 kHz", "100 kHz", "500 kHz", "1 MHz", "32 MHz"]

                    }
                }

                Rectangle{
                    id: dataModel
                    width:  parent.width/0.9
                    height : parent.height/4.5
                    color: "transparent"

                    anchors{
                        top:clockFrequencySetting.bottom
                        topMargin: 10
                    }

                    SGStatusListBox {
                        id: statusMessages
                        implicitWidth: parent.width/1.5
                        implicitHeight : parent.height
                        title: "Status:"
                        titleBoxColor: "black"
                        titleTextColor: "white"
                        statusBoxColor: " black"
                        statusTextColor: "#eeeeee"
                        model: faultModel
                        anchors.centerIn: parent
                    }

                    property var statusString: platformInterface.status.status
                    onStatusStringChanged:{
                        console.log(statusString)
                        faultModel.insert(0, {status : statusString})
                    }

                    ListModel {
                        id: faultModel
                    }
                }

            }


            Rectangle {
                width:parent.width/3
                height : parent.height
                color: "transparent"

                Rectangle{
                    id: acquireButtonContainer
                    color: "transparent"
                    width: parent.width
                    height: parent.height/5
                    Button {
                        id: acquireDataButton
                        width: parent.width/3
                        height: parent.height/1.5

                        text: qsTr("Acquire \n Data")
                        onClicked: {
                            warningPopup.open()
                            progressBar.start_restart =+ 1
                        }

                        anchors.centerIn: parent
                        background: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 60
                            opacity: enabled ? 1 : 0.3
                            border.color: acquireDataButton.down ? "#17a81a" : "black"//"#21be2b"
                            border.width: 1
                            color: "#33b13b"
                            radius: 10
                        }

                        contentItem: Text {
                            text: acquireDataButton.text
                            font: acquireDataButton.font
                            opacity: enabled ? 1.0 : 0.3
                            color: acquireDataButton.down ? "#17a81a" : "white"//"#21be2b"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight

                        }
                    }
                }
                Rectangle {
                    id: gaugeContainer
                    anchors{
                        top: acquireButtonContainer.bottom
                    }

                    width: parent.width
                    height: parent.height/2.7
                    color: "transparent"
                    SGCircularGauge{
                        id:lightGauge
                        anchors {
                            fill: parent
                            horizontalCenter: parent.horizontalCenter
                        }
                        gaugeFrontColor1: Qt.rgba(0,1,0,1)
                        gaugeFrontColor2: Qt.rgba(1,1,1,1)
                        minimumValue: 0
                        maximumValue: 400
                        tickmarkStepSize: 40
                        outerColor: "white"
                        unitLabel: "µW"
                        gaugeTitle : "Average" + "\n"+ "Power"

                        value: setAvgPowerMeter(parseInt(digitalPowerConsumption.info) ,parseInt(analogPowerConsumption.info))
                        function lerpColor (color1, color2, x){
                            if (Qt.colorEqual(color1, color2)){
                                return color1;
                            } else {
                                return Qt.rgba(
                                            color1.r * (1 - x) + color2.r * x,
                                            color1.g * (1 - x) + color2.g * x,
                                            color1.b * (1 - x) + color2.b * x, 1
                                            );
                            }
                        }
                    }
                }
                Rectangle {
                    id: digitalPowerContainer
                    width:  parent.width
                    height : parent.height/7
                    color: "transparent"
                    anchors.top: gaugeContainer.bottom
                    anchors.topMargin: 5
                    SGLabelledInfoBox {
                        id: digitalPowerConsumption
                        label: "Digital Power \n Consumption"
                        info: "92"
                        unit: "µW"
                        anchors.centerIn: parent
                        infoBoxWidth: parent.width/3
                        infoBoxHeight: parent.height/1.6
                        fontSize: 15
                        unitSize: 10
                        infoBoxColor: "black"
                        labelColor: "white"

                    }
                }
                Rectangle {
                    width:  parent.width
                    height : parent.height/7
                    color: "transparent"
                    anchors.top: digitalPowerContainer.bottom
                    SGLabelledInfoBox {
                        id: analogPowerConsumption
                        label: "Analog Power \n Consumption"
                        info: "100"
                        unit: "µW"
                        anchors.centerIn: parent
                        infoBoxWidth: parent.width/3
                        infoBoxHeight: parent.height/1.6
                        fontSize: 15
                        unitSize: 10
                        infoBoxColor: "black"
                        labelColor: "white"

                    }
                }
            }


            Rectangle {
                width: parent.width/3.5
                height : parent.height
                color: "transparent"
                Rectangle {
                    id: titleContainer
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    Text {
                        id: title
                        text: " ADC Performance \n Metrics"
                        color: "white"
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 20
                        font.bold: true
                    }
                }
                Column{
                    width: parent.width
                    height: parent.height - titleContainer.height
                    anchors{
                        top: titleContainer.bottom
                        topMargin: 5
                    }
                    spacing: 10

                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "SNR"
                            info: "68.9"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "SNDR"
                            info: "67.8"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                                horizontalCenterOffset: -5
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                    Rectangle{

                        color: "transparent"
                        width: parent.width
                        height: parent.height/7
                        SGLabelledInfoBox {
                            label: "THD"
                            info: "70"
                            unit: "dB"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"

                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"
                        SGLabelledInfoBox {
                            label: "ENOB"
                            info: "11.5"
                            unit: "bits"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                            }
                            infoBoxColor: "black"
                            labelColor: "white"

                        }
                    }
                    Rectangle{
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        SGLabelledInfoBox {
                            label: "Offset"
                            info: "2.5"
                            unit: "bits"
                            infoBoxWidth: parent.width/3
                            infoBoxHeight : parent.height/1.6
                            fontSize: 15
                            unitSize: 10
                            anchors{
                                centerIn: parent
                                horizontalCenterOffset: -2
                            }
                            infoBoxColor: "black"
                            labelColor: "white"
                        }
                    }
                }
            }
        }
    }
}
