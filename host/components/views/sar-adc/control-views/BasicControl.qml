import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import tech.strata.fonts 1.0
import QtQuick.Controls.Styles 1.4
import "qrc:/js/help_layout_manager.js" as Help
import "SAR-ADC-Analysis.js" as SarAdcFunction
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Dialogs 1.3

Rectangle {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    color: "#a9a9a9"
    property real graphPlottedCount: 0
    
    property var dataArray: []
    property int time_maxValue: 10
    property var packet_number_data:  platformInterface.get_data.packet
    
    //Initial clock = 250
    property int clock: 250
    //NOTE: By default the first pack is empty "". To start counting the packets we need to start with -1
    property int number_of_notification: -1
    
    property int packet_number: 80 // Total number of packets are hardcoded to 80
    property int total_iteration: 0
    
    //progress bar iteration varible
    property real completed: completed_iterations/total_iteration
    property int completed_iterations: 0
    
    //Notification to acquire from the evaluation board by using the "get_data" command.
    property var data_value: platformInterface.get_data.data

    property var dataToSave: []

    property var clock_data: 0
    onData_valueChanged: {
        if(number_of_notification == 1) {
            warningPopup.open()
        }
        if(number_of_notification === 0){
            completed_iterations = Qt.binding(function(){ return number_of_notification})
            total_iteration = packet_number
        }
        
        // progress bar need to stop before it hits 80.
        if(completed_iterations === 78) {
            barContainer.visible = false
            warningBox.visible = false
            progressBar.visible = false
            graphTitle.visible = true
        }
        
        if(data_value !== "") {
            var b = Array.from(data_value.split(','),Number);
            for (var i=0; i<b.length; i++)
            {
                dataArray.push(b[i])
            }
        }
        
        number_of_notification += 1 //increment the notification variable
        
        //if the packet number equals number_of_notification variable proceed to do data evaluation
        if(number_of_notification === packet_number) {
            adc_data_to_plot()
            number_of_notification = 0
            dataArray = []
        }
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    function toCSV(json) {
        json = Object.values(json);
        var csv = "";
        var keys = (json[0] && Object.keys(json[0])) || [];
        csv += keys.join(',') + '\n';
        for (var line of json) {
            csv += keys.map(key => line[key]).join(',') + '\n';
        }
        return csv;
    }


    FileDialog {
        id: saveFileDialog
        selectExisting: false
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted:  {
            saveFile(saveFileDialog.fileUrl,  toCSV(dataToSave))
        }
    }
    
    function adc_data_to_plot() {
        var processed_data = SarAdcFunction.adcPostProcess(dataArray,clock,4096)
        var fdata = processed_data[0]
        var tdata = processed_data[1]
        var hdata = processed_data[2]
        var fdata_length = fdata.length
        var total_time_length = tdata.length
        var tdata_length = total_time_length
        var hdata_length = hdata.length // length of histogram data
        var maxXvaule // variable to hold the max x value data for time domain graph

        //DEBUG
        //console.log("start Plotting........................................")

        //frequency plot
        var curve2 = graph2.createCurve("graph2")
        curve2.color = "White"
        var dataArray1 = []
        for(var i = 0; i <fdata_length; i++){
            var frequencyData = fdata[i]
            dataArray1.push({"x":frequencyData[0], "y":frequencyData[1]})
        }
        curve2.appendList(dataArray1)

        //Time plot
        var curve1 = graph.createCurve("graph")
        curve1.color = "Green"
        var dataArray3 = []
        for(var y = 0; y <tdata_length; y++){
            var  timeData = tdata[y]
            dataArray3.push({"x":timeData[0], "y":timeData[1]})
            maxXvaule = Math.round(timeData[0])
            dataToSave.push({"Time x": timeData[0], "Time y": timeData[1]})
        }


        graph.xMax = maxXvaule
        time_maxValue = maxXvaule
        curve1.appendList(dataArray3)
        //Histogram Plot
        var curve3 = graph3.createCurve("graph3")
        curve3.color = "Green"
        var dataArray2 = []
        for(var y1 = 0; y1 < hdata_length; y1++){
            dataArray2.push({"x":y1, "y":hdata[y1]})
        }
        curve3.appendList(dataArray2)
        warningPopup.close()
        acquireButtonContainer.enabled = true
        graphPlottedCount++;
        
        //DEBUG
        console.log("Done Plotting........................................")

        var sndr =  processed_data[3]
        var sfdr =  processed_data[4]
        var snr =   processed_data[5]
        var thd =   processed_data[6]
        var enob =  processed_data[7]
        snr_info.info = snr.toFixed(3)
        sndr_info.info = sndr.toFixed(3)
        thd_info.info = thd.toFixed(3)
        enob_info.info = enob.toFixed(3)
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
            id: graphTitle
            anchors.centerIn: parent
            width: (parent.width)
            height: parent.height/3
            visible: false
            color: "red"
            Text {
                id:graphWarning
                text: "Plotting Data. \n One Moment Please"
                font.bold: true
                font.family: "Helvetica"
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: (parent.width + parent.height)/ 35
                color: "white"
                z:2
            }
            
            Text {
                id: warningIcon1
                anchors {
                    right: graphWarning.left
                    verticalCenter: graphWarning.verticalCenter
                    rightMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/ 20
                color: "white"
            }
            
            Text {
                id: warningIcon2
                anchors {
                    left: graphWarning.right
                    verticalCenter: graphWarning.verticalCenter
                    leftMargin: 10
                }
                text: "\ue80e"
                font.family: Fonts.sgicons
                font.pixelSize: (parent.width + parent.height)/20
                color: "white"
            }
            
        }
        
        Rectangle {
            id: warningBox
            color: "red"
            anchors {
                top: parent.top
                topMargin: 20
            }
            anchors.horizontalCenter: parent.horizontalCenter
            width: (parent.width) - 50
            height: parent.height/6
            Text {
                id: warningText
                anchors.centerIn: parent
                text: "<b>Data Acquisition In Progress</b>"
                font.pixelSize: (parent.width + parent.height)/ 32
                color: "white"
            }
            
            Text {
                id: warningIcon3
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
                id: warningIcon4
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
        Rectangle {
            id:barContainer
            anchors.top: warningBox.bottom
            anchors.topMargin: 30
            anchors.horizontalCenter: parent.horizontalCenter
            width: (parent.width)
            height: parent.height/6
            z:2
            visible: true
            color: "transparent"
            SGProgressBar{
                id: progressBar
                anchors.fill: parent
                percent_complete: completed
                z:3
            }
        }
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

    // Read initial notification
    property var initial_data: platformInterface.read_initial
    onInitial_dataChanged: {
        var clk_data =  initial_data.clk + "kHz"
        for(var i=0; i< clockFrequencyModel.model.length; i++) {
            if(clk_data === clockFrequencyModel.model[i]) {
                clockFrequencyModel.currentIndex = i
                
            }
        }
        var dvdd_data_initial = initial_data.dvdd
        if(dvdd_data_initial !== 0) {
            if(dvdd_data_initial === 3.3) {
                dvsButtonContainer.radioButtons.dvdd1.checked = true
            }
            else dvsButtonContainer.radioButtons.dvdd2.checked = true
        }
        var avdd_data_initial = initial_data.avdd
        if(avdd_data_initial !== 0) {
            if(avdd_data_initial === 3.3) {
                avddButtonContainer.radioButtons.avdd1.checked = true
            }
            else avddButtonContainer.radioButtons.avdd2.checked = true
        }
        
        var total_power_data = initial_data.total_power_uW
        lightGauge.value = total_power_data
        
        var avdd_power_data = initial_data.avdd_power_uW
        analogPowerConsumption.info = avdd_power_data.toFixed(2)
        
        var dvdd_power_data = initial_data.dvdd_power_uW
        digitalPowerConsumption.info = dvdd_power_data
        
    }
    
    Component.onCompleted: {
        //Debug
        //platformInterface.get_inital_state.update()
        clock_data = 1000
        clock = clock_data
        platformInterface.set_clk_data.update(clock_data)
        platformInterface.set_adc_supply.update("1.8", "3.3")
        plotSetting2.checked = true
        plotSetting1.checked = false
    }

    Rectangle{
        id: graphContainer
        width: parent.width
        height: (parent.height/1.8) - 50
        color: "#a9a9a9"
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
        
        SGWidgets.SGGraph {
            id: graph
            property real startXMin
            property real startXMax
            property real startYMin
            property real startYMax
            anchors {
                top: partNumber.bottom
                topMargin: 10
            }
            width: parent.width/2
            height: parent.height - 130
            title: "Time Domain"
            xTitle: "Time (ms)"
            yTitle: "ADC Code"
            backgroundColor: "black"
            foregroundColor: "white"
            yMin: 0
            yMax: 4096
            xMin: 0                    // Default: 0
            xMax: 10                   // Default: 10

            Component.onCompleted: {
                startXMin = graph.xMin
                startXMax = graph.xMax
                startYMin = graph.yMin
                startYMax = graph.yMax
            }

            function resetChart() {
                graph.xMin = startXMin
                graph.xMax = time_maxValue
                graph.yMin = startYMin
                graph.yMax = startYMax
                resetChartButton.visible = false
            }

            MouseArea {
                anchors{
                    fill: graph
                }
                property point mousePosition: "0,0"
                preventStealing: true

                onWheel: {
                    if(graph.zoomXEnabled) {
                        var scale = Math.pow(1.5, wheel.angleDelta.y * 0.001)
                        var scaledChartWidth = (graph.xMax - graph.xMin) / scale
                        var chartCenter = Qt.point((graph.xMin + graph.xMax) / 2, (graph.yMin + graph.yMax) / 2)
                        var chartWheelPosition = graph.mapToValue(Qt.point(wheel.x, wheel.y))
                        var chartOffset = Qt.point((chartCenter.x - chartWheelPosition.x) * (1 - scale), (chartCenter.y - chartWheelPosition.y) * (1 - scale))

                        if (graph.zoomXEnabled) {
                            graph.xMin = (chartCenter.x - (scaledChartWidth / 2)) + chartOffset.x
                            graph.xMax = (chartCenter.x + (scaledChartWidth / 2)) + chartOffset.x
                        }

                        resetChartButton.visible = true
                    }
                }


                onPressed: {
                    if (graph.panXEnabled) {
                        mousePosition = Qt.point(mouse.x, mouse.y)
                    }
                }

                onPositionChanged: {
                    if (graph.panXEnabled) {
                        let originToPosition = graph.mapToPosition(Qt.point(0,0))
                        originToPosition.x += (mouse.x - mousePosition.x)
                        let deltaLocation = graph.mapToValue(originToPosition)
                        graph.autoUpdate = false
                        if (graph.panXEnabled) {
                            graph.shiftXAxis(-deltaLocation.x)
                        }
                        graph.autoUpdate = true
                        graph.update()
                        mousePosition = Qt.point(mouse.x, mouse.y)
                        resetChartButton.visible = true

                    }
                }
            }

            Button {
                id:resetChartButton
                anchors {
                    top:parent.top
                    right: parent.right
                    margins: 12
                }
                text: "Reset Chart"
                visible: false
                width: 90
                height: 20
                onClicked: {
                    graph.resetChart()
                }
            }
        }
        
        
        SGWidgets.SGGraph{
            id: graph2
            property real startXMin
            property real startXMax
            property real startYMin
            property real startYMax
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
            title: "Frequency Domain"
            xTitle: "Frequency (KHz)"
            yTitle: "Power Relative to Fundamental (dB)"
            backgroundColor: "black"
            foregroundColor: "white"
            zoomXEnabled: true
            panXEnabled: true
            yMin: -160
            yMax: 1
            xMin: 0
            xMax: 10

            Component.onCompleted: {
                startXMin = graph2.xMin
                startXMax = graph2.xMax
                startYMin = graph2.yMin
                startYMax = graph2.yMax
            }

            function resetChart() {
                graph2.xMin = startXMin
                graph2.xMax = (clock/32)
                graph2.yMin = startYMin
                graph2.yMax = startYMax
                resetChart2Button.visible = false
            }


            MouseArea {
                anchors{
                    fill: graph2
                }
                property point mousePosition: "0,0"
                preventStealing: true

                onWheel: {
                    if(graph2.zoomXEnabled) {
                        var scale = Math.pow(1.5, wheel.angleDelta.y * 0.001)
                        var scaledChartWidth = (graph2.xMax - graph2.xMin) / scale
                        var chartCenter = Qt.point((graph2.xMin + graph2.xMax) / 2, (graph2.yMin + graph2.yMax) / 2)
                        var chartWheelPosition = graph2.mapToValue(Qt.point(wheel.x, wheel.y))
                        var chartOffset = Qt.point((chartCenter.x - chartWheelPosition.x) * (1 - scale), (chartCenter.y - chartWheelPosition.y) * (1 - scale))

                        if (graph2.zoomXEnabled) {
                            graph2.xMin = (chartCenter.x - (scaledChartWidth / 2)) + chartOffset.x
                            graph2.xMax = (chartCenter.x + (scaledChartWidth / 2)) + chartOffset.x
                        }

                        resetChart2Button.visible = true
                    }
                }

                onPressed: {
                    if (graph2.panXEnabled) {
                        mousePosition = Qt.point(mouse.x, mouse.y)
                    }
                }

                onPositionChanged: {
                    if (graph2.panXEnabled) {
                        let originToPosition = graph2.mapToPosition(Qt.point(0,0))
                        originToPosition.x += (mouse.x - mousePosition.x)
                        let deltaLocation = graph2.mapToValue(originToPosition)
                        graph2.autoUpdate = false
                        if (graph2.panXEnabled) {
                            graph2.shiftXAxis(-deltaLocation.x)
                        }
                        graph2.autoUpdate = true
                        graph2.update()
                        mousePosition = Qt.point(mouse.x, mouse.y)
                        resetChart2Button.visible = true

                    }
                }
            }

            Button {
                id:resetChart2Button
                anchors {
                    top:parent.top
                    right: parent.right
                    margins: 12
                }
                text: "Reset Chart"
                visible: false
                width: 90
                height: 20
                onClicked: {
                    graph2.resetChart()

                }
            }
        }
        
        SGWidgets.SGGraph{
            id: graph3
            property real startXMin
            property real startXMax
            property real startYMin
            property var startYMax
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
            title: "Histogram"
            yTitle: "Hit Count"
            xTitle: "Codes"
            foregroundColor: "white"
            backgroundColor: "black"
            zoomXEnabled: true
            panXEnabled: true
            yMin: 0
            yMax: 40
            xMin: 0
            xMax:  4096
            Component.onCompleted: {
                startXMin = graph3.xMin
                startXMax = graph3.xMax
                startYMin = graph3.yMin
                startYMax = graph3.yMax
            }

            function resetChart() {
                graph3.xMin = startXMin
                graph3.xMax = startXMax
                graph3.yMin = startYMin
                graph3.yMax = startYMax
                resetChart3Button.visible = false
            }

            MouseArea {
                anchors{
                    fill: graph3
                }
                property point mousePosition: "0,0"
                preventStealing: true

                onWheel: {
                    if(graph3.zoomXEnabled) {
                        var scale = Math.pow(1.5, wheel.angleDelta.y * 0.001)
                        var scaledChartWidth = (graph3.xMax - graph3.xMin) / scale
                        var chartCenter = Qt.point((graph3.xMin + graph3.xMax) / 2, (graph3.yMin + graph3.yMax) / 2)
                        var chartWheelPosition = graph3.mapToValue(Qt.point(wheel.x, wheel.y))
                        var chartOffset = Qt.point((chartCenter.x - chartWheelPosition.x) * (1 - scale), (chartCenter.y - chartWheelPosition.y) * (1 - scale))

                        if (graph3.zoomXEnabled) {
                            graph3.xMin = (chartCenter.x - (scaledChartWidth / 2)) + chartOffset.x
                            graph3.xMax = (chartCenter.x + (scaledChartWidth / 2)) + chartOffset.x
                        }

                        resetChart3Button.visible = true
                    }
                }

                onPressed: {
                    if (graph3.panXEnabled) {
                        mousePosition = Qt.point(mouse.x, mouse.y)
                    }
                }

                onPositionChanged: {
                    if (graph3.panXEnabled) {
                        let originToPosition = graph3.mapToPosition(Qt.point(0,0))
                        originToPosition.x += (mouse.x - mousePosition.x)
                        // originToPosition.y += (mouse.y - mousePosition.y)
                        let deltaLocation = graph3.mapToValue(originToPosition)
                        graph3.autoUpdate = false
                        if (graph3.panXEnabled) {
                            graph3.shiftXAxis(-deltaLocation.x)
                        }
                        graph3.autoUpdate = true
                        graph3.update()

                        mousePosition = Qt.point(mouse.x, mouse.y)
                        resetChart3Button.visible = true

                    }
                }
            }

            Button {
                id:resetChart3Button
                anchors {
                    top:parent.top
                    right: parent.right
                    margins: 12
                }
                text: "Reset Chart"
                visible: false
                width: 90
                height: 20

                onClicked: {
                    graph3.resetChart()
                }
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
                checked: false
                checkable: true
                background: Rectangle {
                    id: backgroundContainer1
                    implicitWidth: 100
                    implicitHeight: 40
                    opacity: enabled ? 1 : 0.3
                    color: {
                        if(plotSetting1.checked) {
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
                    color: plotSetting1.down ? "#17a81a" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    width: parent.width
                }
                
                onClicked: {
                    backgroundContainer1.color  = "#d3d3d3"
                    backgroundContainer2.color = "#33b13b"
                    graph3.yTitle = "Hit Count"
                    graph3.xTitle = "Codes"
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
                    border.color: plotSetting2.down ? "#17a81a" : "black"
                    border.width: 1
                    color: plotSetting2.checked ? "lightgrey" :  "#33b13b"
                    radius: 10
                }
                Layout.alignment: Qt.AlignHCenter
                contentItem: Text {
                    text: plotSetting2.text
                    font.pixelSize: (parent.height)/2.5
                    opacity: enabled ? 1.0 : 0.3
                    color: plotSetting2.down ? "#17a81a" : "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    wrapMode: Text.Wrap
                    width: parent.width
                }
                
                onClicked: {
                    graph2.yTitle = "Power (dB)"
                    graph2.xTitle = "Frequency (KHz)"
                    backgroundContainer1.color = "#33b13b"
                    backgroundContainer2.color  = "#d3d3d3"
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
                    height: parent.height/1.5
                    color: "transparent"
                    
                    Rectangle{
                        id: adcSetting
                        width: parent.width
                        height: parent.height/2.5
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
                                Layout.bottomMargin: 10
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            SGRadioButtonContainer {
                                id: dvsButtonContainer
                                label: "<b> ADC Digital Supply \n DVDD: <\b>" // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "white"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true
                                Layout.alignment: Qt.AlignCenter
                                
                                radioGroup: GridLayout {
                                    // columnSpacing: 10
                                    rowSpacing: 10
                                    property alias dvdd1: dvdd1
                                    property alias dvdd2 : dvdd2
                                    
                                    property int fontSize: (parent.width+parent.height)/8
                                    SGRadioButton {
                                        id: dvdd1
                                        text: "3.3V"

                                        onCheckedChanged: {
                                            if(checked){
                                                if(avddButtonContainer.radioButtons.avdd1.checked) {
                                                    platformInterface.set_adc_supply.update("3.3","3.3")
                                                }
                                                else {
                                                    platformInterface.set_adc_supply.update("3.3","1.8")
                                                }
                                            }
                                            else  {
                                                if(avddButtonContainer.radioButtons.avdd1.checked) {
                                                    platformInterface.set_adc_supply.update("1.8","3.3")
                                                }
                                                else {
                                                    platformInterface.set_adc_supply.update("1.8","1.8")
                                                }
                                            }
                                        }
                                    }
                                    
                                    SGRadioButton {
                                        id: dvdd2
                                        checked: true
                                        text: "1.8V"
                                    }
                                }
                            }
                            SGRadioButtonContainer {
                                id: avddButtonContainer
                                label: "<b> ADC Analog Supply \n AVDD: <\b>" // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "white"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true
                                Layout.alignment: Qt.AlignCenter
                                
                                radioGroup: GridLayout {
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
                                                if(dvsButtonContainer.radioButtons.dvdd1.checked) {
                                                    platformInterface.set_adc_supply.update("3.3","3.3")
                                                }
                                                else {
                                                    platformInterface.set_adc_supply.update("1.8","3.3")
                                                }
                                            }
                                            else  {
                                                if(dvsButtonContainer.radioButtons.dvdd1.checked) {
                                                    platformInterface.set_adc_supply.update("3.3","1.8")
                                                }
                                                else {
                                                    platformInterface.set_adc_supply.update("1.8","1.8")

                                                }
                                            }
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
                    Rectangle {
                        id: noteMessage
                        width: parent.width - 50
                        height: parent.height/4
                        color:"transparent"
                        anchors{
                            top:clockFrequencySetting.bottom
                            topMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            id: noteMessageText
                            text: "Note: Connecting INN / INP to an active signal will influence \n the power measurements. \n  For true power readings, disconnect INN and INP."
                            anchors.top:parent.top
                            font.pixelSize: (parent.width + parent.height)/35
                            color: "white"
                            font.bold: true
                            font.family: "Helvetica"
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    
                    Rectangle{
                        id: clockFrequencySetting
                        width:  parent.width
                        height : parent.height/4
                        color: "transparent"
                        anchors{
                            top:adcSetting.bottom
                            topMargin:10
                            
                        }
                        
                        SGComboBox {
                            id: clockFrequencyModel
                            label: "<b> Clock Frequency <\b> "   // Default: "" (if not entered, label will not appear)
                            labelLeft: true
                            comboBoxWidth: parent.width/3
                            comboBoxHeight: parent.height/2// Default: 120 (set depending on model info length)
                            textColor: "white"          // Default: "black"
                            indicatorColor: "#aaa"      // Default: "#aaa"
                            borderColor: "white"         // Default: "#aaa"
                            boxColor: "black"           // Default: "white"
                            dividers: true              // Default: false
                            anchors.centerIn: parent
                            fontSize: 15
                            model : ["250kHz","500kHz","1000kHz","2000kHz","4000kHz","8000kHz","16000kHz","32000kHz"]
                            onActivated: {
                                clock_data =  parseInt(currentText.substring(0,(currentText.length)-3))
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
                    height: parent.height/5.5

                    RowLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            Button {
                                id: acquireDataButton
                                width: parent.width/1.5
                                height: parent.height/1.5
                                text: qsTr("Acquire \n Data")
                                onClicked: {
                                    progressBar.visible = true
                                    warningBox.visible = true
                                    barContainer.visible = true
                                    graphTitle.visible = false
                                    //Clear the graph if the graph is plotted before (!=0)
                                    if(graphPlottedCount != 0) {
                                        graph.removeCurve(0)
                                        graph2.removeCurve(0)
                                        graph3.removeCurve(0)
                                    }
                                    //set back all the graph initial x & y axises
                                    graph2.xMax = (clock/32)
                                    graph2.yMax = 1
                                    graph2.xMin = 0
                                    graph2.yMin = -160
                                    graph2.resetChart()
                                    graph3.xMax = 4096
                                    graph3.yMax = 40
                                    graph3.xMin = 0
                                    graph3.yMin = 0
                                    graph3.resetChart()
                                    time_maxValue = 10
                                    graph.xMax = 10
                                    graph.yMax = 4096
                                    graph.xMin = 0
                                    graph.yMin = 0
                                    graph.resetChart()
                                    acquireButtonContainer.enabled = false
                                    platformInterface.get_data_value.update(packet_number)
                                    saveDataButton.opacity = 1.0
                                    saveDataButton.enabled = true
                                    dataToSave =  []
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
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            Button {
                                id: saveDataButton
                                width: parent.width/1.5
                                height: parent.height/1.5
                                text: qsTr("Save \n Data")
                                opacity: 0.5
                                enabled: false
                                anchors.centerIn: parent
                                onClicked: {
                                    saveFileDialog.open()
                                }

                                background: Rectangle {
                                    implicitWidth: 100
                                    implicitHeight: 60
                                    opacity: enabled ? 1 : 0.3
                                    border.color: saveDataButton.down ? "#17a81a" : "black"//"#21be2b"
                                    border.width: 1
                                    color: "#33b13b"
                                    radius: 10
                                }
                                contentItem: Text {
                                    text: saveDataButton.text
                                    font.pixelSize: (parent.height)/3.5
                                    opacity: enabled ? 1.0 : 0.3
                                    color: saveDataButton.down ? "#17a81a" : "white"//"#21be2b"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    wrapMode: Text.Wrap
                                    width: parent.width
                                }
                            }
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
