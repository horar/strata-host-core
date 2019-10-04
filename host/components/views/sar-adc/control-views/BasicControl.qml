import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import tech.strata.fonts 1.0
import QtQuick.Controls.Styles 1.4
import "qrc:/js/help_layout_manager.js" as Help
import "SAR-ADC-Analysis.js" as SarAdcFunction

Rectangle {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    color: "#a9a9a9"

    property var dataArray: []
    property var data_value: platformInterface.get_data.data

    //hardcorded for now
    property int clock: 250
    //The first one is  "" so we have to go from -1
    property int number_of_notification: -1
    property int packet_number: 80

    onData_valueChanged: {
        if(data_value !== "") {
            var b = Array.from(data_value.split(','),Number);
            for (var i=0; i<b.length; i++)
            {
                dataArray.push(b[i])
                //  graph.series1.append(i,b[i])
            }
        }
        number_of_notification += 1
        if(number_of_notification === packet_number) {
            adc_data_to_plot()
            number_of_notification = 0
            dataArray = [""]
        }

    }

    function adc_data_to_plot() {
        var processed_data = SarAdcFunction.adcPostProcess(dataArray,clock,4096)
        var fdata = processed_data[0]
        var tdata = processed_data[1]
        var hdata = processed_data[2]
        var max_length = Math.max(fdata.length/* ,tdata.length*/, hdata.length)
        var fdata_length = fdata.length ///4
        var tdata_length = tdata.length/8
        var hdata_length = hdata.length ///9

        console.log("fdata_length", fdata_length)
        console.log(" fdata.length/2", fdata.length)

        for(var i = 0; i <fdata_length; i+=2){
            var frequencyData =fdata[i]
            graph2.series1.append(frequencyData[0], frequencyData[1])
        }

//        for(var x = fdata_length; x<(fdata_length*2); x++){
//            var frequencyData2 =fdata[x]
//            graph2.series1.append(frequencyData2[0], frequencyData2[1])
//        }

//        for(var w = (fdata_length*2); w <(fdata_length*3); w++) {
//            var frequencyData3 =fdata[w]
//            graph2.series1.append(frequencyData3[0], frequencyData3[1])
//        }

//        for(var k = (fdata_length*3); k < (fdata_length*4); k++) {
//            var frequencyData4 =fdata[k]
//            graph2.series1.append(frequencyData4[0], frequencyData4[1])
//        }

        console.log("tdata_length", tdata_length)
        console.log("tdata.length/4", tdata.length)

        for(var y = 0; y<tdata_length; y++){
            var  timeData = tdata[y]
            graph.series1.append(timeData[0],timeData[1])
        }

        for(var t = tdata_length; t <(tdata_length*2);t++){
            var  timeData2 = tdata[t]
            graph.series1.append(timeData2[0],timeData2[1])
        }

        for(var z = tdata_length*2; z <(tdata_length*3);z++){
            var  timeData3 = tdata[z]
            graph.series1.append(timeData3[0],timeData3[1])
        }

        for(var q = tdata_length*3; q <(tdata_length*4);q++){
            var  timeData4 = tdata[q]
            graph.series1.append(timeData4[0],timeData4[1])
        }

        for(var q1 = tdata_length*4; q1 <(tdata_length*5);q1++){
            var  timeData5 = tdata[q1]
            graph.series1.append(timeData5[0],timeData5[1])
        }

        for(var q2 = tdata_length*5; q2 <(tdata_length*6);q2++){
            var  timeData6 = tdata[q2]
            graph.series1.append(timeData6[0],timeData6[1])
        }

        for(var q3 = tdata_length*6; q3 <(tdata_length*7);q3++){
            var  timeData7 = tdata[q3]
            graph.series1.append(timeData7[0],timeData7[1])
        }
        for(var q4 = tdata_length*7; q4 <(tdata_length*8);q4++){
            var  timeData8 = tdata[q4]
            graph.series1.append(timeData8[0],timeData8[1])
        }



        console.log("hdata_length", hdata_length)
        console.log(" hdata.length/2", hdata.length)

        for(var y1 = 0; y1 <hdata_length; y1+=2){
            graph.series1.append(y1,hdata[y1])
        }

//        for(var t1 = hdata_length; t1<(hdata_length+hdata_length); t1++){
//            graph.series1.append(t1,hdata[t1])
//        }

//        for(var z1 = hdata_length*2; z1<(hdata_length*3); z1++){
//            graph.series1.append(z1,hdata[z1])
//        }

//        for(var q_t = hdata_length*3; q_t <hdata_length*4 ;q_t++){
//            graph.series1.append(q_t,hdata[q_t])

//        }
//        for(var r = hdata_length*4; r<hdata_length*5 ;r++){
//            graph.series1.append(r,hdata[r])

//        }
//        for(var r2 = hdata_length*5; r2<hdata_length*6 ;r2++){
//            graph.series1.append(r2,hdata[r2])

//        }
//        for(var r3 = hdata_length*6; r3<hdata_length*7 ;r3++){
//            graph.series1.append(r3,hdata[r3])

//        }

//        for(var r4 = hdata_length*7; r4<hdata_length*8 ;r4++){
//            graph.series1.append(r4,hdata[r4])

//        }

//        for(var r5 = hdata_length*8; r5<hdata_length*9 ;r5++){
//            graph.series1.append(r5,hdata[r5])

//        }
        //        for(var r6 = hdata_length*9; r6<hdata_length*10 ;r6++){
        //            graph.series1.append(r6,hdata[r6])

        //        }
        //        for(var r7 = hdata_length*10; r7<hdata_length*11 ;r7++){
        //            graph.series1.append(r7,hdata[r7])

        //        }
        //        for(var r8 = hdata_length*9; r8<hdata_length*10 ;r8++){
        //            graph.series1.append(r8,hdata[r8])

        //        }
        //        for(var r9 = hdata_length*10; r9<hdata_length*11 ;r9++){
        //            graph.series1.append(r6,hdata[r6])

        //        }
        //        for(var r7 = hdata_length*10; r7<hdata_length*11 ;r7++){
        //            graph.series1.append(r7,hdata[r7])

        //        }

        //        for(var y = 0; y <hdata_length; y++){
        //            var  timeData = tdata[y]
        //            graph.series1.append(timeData[0],timeData[1])

        //        }


        //        for(var i = 0; i <max_length; i+=2){
        //            if(i < fdata.length) {
        //                var frequencyData =fdata[i]
        //                graph2.series1.append(frequencyData[0], frequencyData[1])

        //            }
        ////            if(i < tdata.length) {
        ////                var timeData = tdata[i]
        ////                graph.series1.append(timeData[0],timeData[1])

        ////                if(i === (tdata.length -1)){
        ////                    var maxX = tdata[i]
        ////                    // 1000000 = clock
        ////                    graph.maxXValue =  maxX[0]
        ////                    graph.xyvalueArray = [maxX[0],4096,0,0]
        ////                }
        ////            }
        //            if( i < 4096) {
        //                graph3.series1.append(i,hdata[i])

        //            }
        //        }



        //        var sndr =  processed_data[3]
        //        var sfdr =  processed_data[4]
        //        var snr =   processed_data[5]
        //        var thd =   processed_data[6]
        //        var enob =  processed_data[7]
        //        snr_info.info = snr.toFixed(3)
        //        sndr_info.info = sndr.toFixed(3)
        //        thd_info.info = thd.toFixed(3)
        //        enob_info.info = enob.toFixed(3)
        warningPopup.close()
    }

    Popup{
        id: warningPopup
        width: parent.width/3
        height: parent.height/5
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        modal: true
        focus: true
        closePolicy:Popup.NoAutoClose
        background: Rectangle{
            anchors.fill:parent
            color: "black"
            anchors.centerIn: parent

        }

        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                top: parent.top
                topMargin: 20
            }
            width: (parent.width)
            height: parent.height/6
            Text {
                id: warningText
                anchors.centerIn: parent
                text: "<b>Data Acquisition In Progress</b>"
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
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: (parent.width)
            height: parent.height/6
        }
    }


    function setAvgPowerMeter(a,b) {
        var holder = a+b
        return holder
    }

    property var get_power_avdd: platformInterface.set_clk.avdd_power_uW
    onGet_power_avddChanged: {
        analogPowerConsumption.info = get_power_avdd
    }

    property var get_power_dvdd: platformInterface.set_clk.dvdd_power_uW
    onGet_power_dvddChanged: {
        digitalPowerConsumption.info = get_power_dvdd

    }

    property var get_power_total: platformInterface.set_clk.total_power_uW
    onGet_power_totalChanged: {
        lightGauge.value = get_power_total

    }

    property var get_adc_avdd: platformInterface.adc_supply_set.avdd_power_uW
    onGet_adc_avddChanged: {
        analogPowerConsumption.info = get_adc_avdd
    }

    property var get_adc_dvdd: platformInterface.adc_supply_set.dvdd_power_uW
    onGet_adc_dvddChanged: {
        digitalPowerConsumption.info = get_adc_dvdd

    }

    property var get_adc_total: platformInterface.adc_supply_set.total_power_uW
    onGet_adc_totalChanged: {
        lightGauge.value = get_adc_total

    }
    property var clk_data: platformInterface.get_clk_freqs.freqs
    onClk_dataChanged: {
        var clock_frequency_values = []
        var clk_freqs = clk_data
        var b = Array.from(clk_freqs.split(','),Number);
        for (var i=0; i<b.length; i++)
        {
            clock_frequency_values.push(b[i] + "kHz"
                                        )
        }

        clockFrequencyModel.model = clock_frequency_values
    }

    Component.onCompleted: {
        platformInterface.get_clk_freqs_values.update()

    }


    Rectangle{
        width: parent.width
        height: (parent.height/1.8) - 50
        color: "#a9a9a9"
        //color: "red"
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
            xAxisTitle: "Time (s)"            // Default: empty
            yAxisTitle: "ADC Code"          // Default: empty
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "green"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0                   // Default: 0
            maxYValue: 4096              // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue: 10                   // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            xyvalueArray: [10,4096,0,0]


        }


        SGGraphStatic{
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
            minYValue: -160                  // Default: 0
            maxYValue: 1                  // Default: 10
            minXValue: 0                    // Default: 0
            //maxXValue: 31250               // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            //xyvalueArray: [31250,1,0,-160]

        }

        SGGraphStatic{
            id: graph3
            anchors {
                left: graph.right
                leftMargin: 10
                right: parent.right
                rightMargin: 10
                top: partNumber.bottom
                topMargin: 10
            }
            visible: false

            width: parent.width/2
            height: parent.height - 130
            textSize: 15
            title: "Histogram"                  // Default: empty
            yAxisTitle: "Hit Count"
            xAxisTitle: "Codes"
            textColor: "#ffffff"            // Default: #000000 (black) - Must use hex colors for this property
            dataLine1Color: "white"         // Default: #000000 (black)
            dataLine2Color: "blue"          // Default: #000000 (black)
            axesColor: "#cccccc"            // Default: Qt.rgba(.2, .2, .2, 1) (dark gray)
            gridLineColor: "#666666"        // Default: Qt.rgba(.8, .8, .8, 1) (light gray)
            backgroundColor: "black"        // Default: #ffffff (white)
            minYValue: 0              // Default: 0
            maxYValue: 40                  // Default: 10
            minXValue: 0                    // Default: 0
            maxXValue:  4096                  // Default: 10
            showXGrids: false               // Default: false
            showYGrids: true                // Default: false
            xyvalueArray: [4096,40,0,0]

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
                    font.pixelSize:  (parent.height)/2.5
                    opacity: enabled ? 1.0 : 0.3
                    color: plotSetting1.down ? "#17a81a" : "white"//"#21be2b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    width: parent.width
                }



                onClicked: {
                    backgroundContainer1.color  = "#d3d3d3"
                    backgroundContainer2.color = "#33b13b"
                    graph3.yAxisTitle = "Hit Count"
                    graph3.xAxisTitle = "Codes"

                    //                    graph3.minXValue = 0
                    //                    graph3.maxXValue = 4096
                    //                    graph3.minYValue = 0
                    //                    graph3.maxYValue = 40
                    graph3.visible = true
                    graph2.visible = false


                }
            }
            Button {
                id: plotSetting2
                width: ratioCalc * 130
                height : ratioCalc * 50
                text: qsTr("FFT")
                checked: true
                checkable: true

                background: Rectangle {
                    id: backgroundContainer2
                    implicitWidth: 100
                    implicitHeight: 40
                    opacity: enabled ? 1 : 0.3
                    border.color: plotSetting2.down ? "#17a81a" : "black"//"#21be2b"
                    border.width: 1
                    color: {
                        if(plotSetting1.checked) {
                            color = "lightgrey"
                        }
                        else {
                            color =  "#33b13b"
                        }

                    }
                    radius: 10
                }
                Layout.alignment: Qt.AlignHCenter
                contentItem: Text {
                    text: plotSetting2.text
                    font.pixelSize: (parent.height)/2.5
                    opacity: enabled ? 1.0 : 0.3
                    color: plotSetting2.down ? "#17a81a" : "white"//"#21be2b"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    width: parent.width
                }

                onClicked: {
                    graph2.yAxisTitle = "Power (dB)"
                    graph2.xAxisTitle = "Frequency (KHz)"
                    backgroundContainer1.color = "#33b13b"
                    backgroundContainer2.color  = "#d3d3d3"
                    //                    graph2.minXValue = 0
                    //                    graph2.maxXValue = 31250
                    //                    graph2.minYValue = -160
                    //                    graph2.maxYValue = 0
                    graph3.visible = false
                    graph2.visible = true

                }
            }
        }
    }
    Rectangle{
        width: parent.width
        height: parent.height/2
        color: "#696969"
        anchors{
            top: graphContainer.bottom
            topMargin: 20

        }
        Row{
            anchors.fill: parent
            Rectangle {
                width:parent.width/2.8
                height : parent.height
                anchors{
                    top: parent.top
                    topMargin: 10

                }
                color: "transparent"


                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height/2
                    color: "transparent"

                    Rectangle{
                        id: adcSetting
                        width: parent.width
                        height: parent.height/2
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
                                Layout.bottomMargin: 20
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            SGRadioButtonContainer {
                                id: dvsButtonContainer
                                // Optional configuration:
                                //fontSize: (parent.width+parent.height)/32
                                label: "<b> ADC Digital Supply \n DVDD: <\b>" // Default: "" (will not appear if not entered)
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
                                            //  platformInterface.get_power_value.update()
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
                                label: "<b> ADC Analog Supply \n AVDD: <\b>" // Default: "" (will not appear if not entered)
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


                                            //platformInterface.get_power_value.update()

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
                        id: clockFrequencySetting
                        width:  parent.width
                        height : parent.height/2
                        color: "transparent"
                        anchors{
                            top:adcSetting.bottom
                            topMargin: 20
                        }

                        SGComboBox {
                            id: clockFrequencyModel
                            label: "<b> Clock Frequency <\b> "   // Default: "" (if not entered, label will not appear)
                            labelLeft: true           // Default: true
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/3// Default: 120 (set depending on model info length)
                            textColor: "white"          // Default: "black"
                            indicatorColor: "#aaa"      // Default: "#aaa"
                            borderColor: "white"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            anchors.centerIn: parent
                            fontSize: 15
                            onActivated: {
                                var clock_data =  parseInt(currentText.substring(0,(currentText.length)-3))
                                clock = clock_data
                                platformInterface.set_clk_data.update(clock_data)
                            }
                        }
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
                    height: parent.height/4.5
                    Button {
                        id: acquireDataButton
                        width: parent.width/3
                        height: parent.height/1.5

                        text: qsTr("Acquire \n Data")
                        onClicked: {
                            graph.series1.clear()
                            graph2.series1.clear()
                            graph3.series1.clear()

                            warningPopup.open()
                            progressBar.start_restart += 1
                            graph2.maxXValue = (clock/32)
                            graph2.xyvalueArray = [(clock/32),1,0,-160]
                            platformInterface.get_data_value.update(packet_number)
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
                            font.pixelSize: (parent.height)/3.5
                            opacity: enabled ? 1.0 : 0.3
                            color: acquireDataButton.down ? "#17a81a" : "white"//"#21be2b"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            width: parent.width
                            //                            height: parent.height


                        }
                    }
                }
                Rectangle {
                    id: gaugeContainer
                    anchors{
                        top: acquireButtonContainer.bottom
                        horizontalCenter: parent.horizontalCenter
                    }

                    width: parent.width
                    height: parent.height/2.8
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

                        // value: platformInterface.get_power.total_power_uW//setAvgPowerMeter(parseInt(digitalPowerConsumption.info) ,parseInt(analogPowerConsumption.info))
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
                width: parent.width/4
                height : parent.height
                color: "transparent"
                //Layout.leftMargin: 20

                Rectangle {
                    width : parent.width
                    height: parent.height
                    anchors {

                        centerIn: parent
                    }
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
                            topMargin: 10
                        }
                        spacing: 10

                        Rectangle{
                            width: parent.width
                            height: parent.height/5
                            color: "transparent"

                            SGLabelledInfoBox {
                                id: snr_info
                                label: "SNR"
                                info: "0.00"
                                unit: "dB"
                                infoBoxWidth: parent.width/2.5
                                infoBoxHeight : parent.height/2
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
                            height: parent.height/5
                            color: "transparent"

                            SGLabelledInfoBox {
                                id: sndr_info
                                label: "SNDR"
                                info: "0.00"
                                unit: "dB"
                                infoBoxWidth: parent.width/2.5
                                infoBoxHeight : parent.height/2
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
                            height: parent.height/5
                            SGLabelledInfoBox {
                                id: thd_info
                                label: "THD"
                                info: "0.00"
                                unit: "dB"
                                infoBoxWidth: parent.width/2.5
                                infoBoxHeight : parent.height/2
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
                            height: parent.height/5
                            color: "transparent"
                            SGLabelledInfoBox {
                                id: enob_info
                                label: "ENOB"
                                info: "0.00"
                                unit: "bits"
                                infoBoxWidth: parent.width/2.5
                                infoBoxHeight : parent.height/2
                                fontSize: 15
                                unitSize: 10
                                anchors{
                                    centerIn: parent
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
}
