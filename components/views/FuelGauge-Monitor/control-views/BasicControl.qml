import QtQuick 2.6
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.sgwidgets 1.0 as Widget01
import tech.strata.fonts 1.0
import QtGraphicalEffects 1.0
import "qrc:/js/help_layout_manager.js" as Help
import QtQuick.Dialogs 1.2
import tech.strata.logger 1.0
import QtCharts 2.0

ColumnLayout {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    property alias virtualtextarea: virtualtextarea
    property alias logSwitch: logSwitch
    property var x_Axis_Timer_:0
    property var x_Axis_Timer_1:0
    property  int clear:0 ///
    property var dataArray_temp_graph: []
    property var dataArray_voltage_graph: []
    property var one_time_clear_all_data: 0
    property var temp_validator:0
    property var voltage_validator:0

    property var cell__voltage: +platformInterface.telemetry.cell_voltage
    onCell__voltageChanged:{
        voltage_validator++
        if((cell__voltage>1500) && (platformInterface.telemetry.log_indicator !=="black")){
            if(voltage_validator>0){
                dataArray_voltage_graph.push({"x":x_Axis_Timer_1,"y":cell__voltage})
                x_Axis_Timer_1=x_Axis_Timer_1+(+virtualtextarea.realtimelog)
                basicGraph.xMax = x_Axis_Timer_1
            }
        }
    }

    property var cell__temp: +platformInterface.telemetry.cell_temp
    onCell__tempChanged:{
        temp_validator++
        if((cell__voltage>1500) && (platformInterface.telemetry.log_indicator !=="black")){
            if(temp_validator>0){
                dataArray_temp_graph.push({"x":x_Axis_Timer_,"y":cell__temp})
                x_Axis_Timer_=x_Axis_Timer_+(+virtualtextarea.realtimelog)
                basicGraph1.xMax = x_Axis_Timer_
            }
        }
    }

    property var estd_test_time_N_log_interval: +virtualtextarea.estd_tst_time
    onEstd_test_time_N_log_intervalChanged:{
        platformInterface.set_est_test_time.update(+virtualtextarea.estd_tst_time)
        platformInterface.set_log_interval.update(+virtualtextarea.realtimelog)
        //		console.log("charge estd time="+virtualtextarea.estd_tst_time)
        //		console.log("charge log time="+virtualtextarea.realtimelog)
    }

    //inturrupts recv from MCU:
    property var double_estd_time: platformInterface.int_os_alert.double_time
    onDouble_estd_timeChanged: {
        if(double_estd_time==="red"){sgStatusLight18.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=0
        } else if(double_estd_time==="black"){sgStatusLight18.status="black"}
    }

    property var cut_off_voltage: platformInterface.int_os_alert.cut_off_volt
    onCut_off_voltageChanged: {
        if(cut_off_voltage==="red"){sgStatusLight1.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=0
        } else if(cut_off_voltage==="black"){sgStatusLight1.status="black"}
    }

    // inturrupts
    property var no_battery: platformInterface.int_os_alert.no_battery
    onNo_batteryChanged: {
        if(no_battery==="red"){sgStatusLight17.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=0
        } else if(no_battery==="black"){sgStatusLight17.status="black"}
    }

    property var over_volt: platformInterface.int_os_alert.over_volt
    onOver_voltChanged: {
        if(over_volt==="red"){sgStatusLight_overvoltage.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=0
        } else if(over_volt==="black"){sgStatusLight_overvoltage.status="black"}
    }

    property var over_current: platformInterface.int_os_alert.over_current
    onOver_currentChanged: {
        if(over_current==="red"){sgStatusLight_overcurrent.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=07
        } else if(over_current==="black"){sgStatusLight_overcurrent.status="black"}
    }

    property var over_temp: platformInterface.int_os_alert.over_temp
    onOver_tempChanged: {
        if(over_temp==="red"){sgStatusLight_overtemp.status="red"
            logSwitch.checked = false
            switch_checked_false()
            virtualtextarea.start_check=0
        } else if(over_temp==="black"){sgStatusLight_overtemp.status="black"}
    }

    function clearGraphsData() {
        if (clear==1){
            dataArray_temp_graph=[]
            dataArray_voltage_graph=[]
            if(basicGraph.count > 0) {
                basicGraph.removeCurve(0)
            }
            //basicGraph1.removeCurve(0)
            if(basicGraph1.count > 0) {
                basicGraph1.removeCurve(0)
            }
            temp_validator=0
            voltage_validator=0
            x_Axis_Timer_=0
            x_Axis_Timer_1=0
            basicGraph1.xMax=+virtualtextarea.realtimelog
            basicGraph.xMax=+virtualtextarea.realtimelog
            clear=0;
        }
        return 0
    }
    //Handles oprtn When start measure switch is ON
    function switch_checked_true() {
        if(set_load_current.enabled==true){
            set_load_current.enabled=false
            manufacturer_name.readOnly=true
            modal_name.readOnly=true
            set_b_constant.enabled=false
            set_capacitance.enabled=false
            set_cut_off_volt.enabled=false
            set_charge_volt.enabled=false
        }

        if((qsTr(sgcomboBS.currentText)==="Charge")){
            if (sgsliderCC.enabled==true){
                sgsliderCC.enabled=false
                sgcomboBS.enabled=false
            }
        }

        if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Enable"){
            if (sgsliderOBLC.enabled==true){
                sgsliderOBLC.enabled=false
                sgcomboBS.enabled=false
                set_onboard_load_en.enabled=false
            }
        }

        if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Disable"){
            if (sgsliderELC.enabled==true){
                sgsliderELC.enabled=false
                sgcomboBS.enabled=false
                set_onboard_load_en.enabled=false
            }
        }
    }

    function switch_checked_false() {
        if(set_load_current.enabled==false){
            set_load_current.enabled=true
            manufacturer_name.readOnly=false
            modal_name.readOnly=false
            set_b_constant.enabled=true
            set_capacitance.enabled=true
            set_cut_off_volt.enabled=true
            set_charge_volt.enabled=true
        }

        if((qsTr(sgcomboBS.currentText)==="Charge")){
            if (sgsliderCC.enabled==false){
                sgsliderCC.enabled=true
                sgcomboBS.enabled=true
            }
        }

        if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Enable"){
            if (sgsliderOBLC.enabled==false){
                sgsliderOBLC.enabled=true
                sgcomboBS.enabled=true
                set_onboard_load_en.enabled=true
            }
        }

        if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Disable"){
            if (sgsliderELC.enabled==false){
                sgsliderELC.enabled=true
                sgcomboBS.enabled=true
                set_onboard_load_en.enabled=true
            }
        }
    }

    Component.onCompleted: {
        graphTimerPoints.start()
        graphTimerPoints1.start()
        dataArray_temp_graph=[]
        dataArray_voltage_graph=[]
        if(basicGraph.count > 0) {
            basicGraph.removeCurve(0)
        }
        if(basicGraph1.count > 0) {
            basicGraph1.removeCurve(0)
        }
        platformInterface.set_measurement.update("stop")
        platformInterface.set_onboard_load_en.update("Enable")
        platformInterface.set_load_current.update(4)
        platformInterface.set_charge_volt.update(4.2)
        platformInterface.set_cut_off_volt.update(2510)
        platformInterface.set_b_constant.update(3380)
        platformInterface.set_apt.update(30)
        platformInterface.set_est_test_time.update(15000)
        platformInterface.set_log_interval.update(180)
        platformInterface.set_fg_initialize.update("")	//Send this at LAST
    }

    spacing: 1
    anchors {
        fill: parent
        bottom: parent.bottom
        bottomMargin: 1
        topMargin: 1
    }

    RowLayout {
        id: rowLayout
        width: root.width
        height: root.height

        Item {
            id: main_item
            width: root.width
            height: root.height

            Rectangle {
                id: mainrect
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                color: "transparent"
                Layout.fillHeight: true
                Layout.fillWidth: true
                border.width: 0
                border.color: "transparent"

                Grid {
                    id: maingrid
                    anchors.fill: parent
                    columns: 2
                    spacing:1
                    Rectangle {
                        id: rect1
                        color: "transparent"; width: parent.width*0.5; height: parent.height*0.5
                        Rectangle {
                            id: rect111
                            color: "transparent"; radius: 5; width: parent.width; height: parent.height
                            border.width: 2
                            border.color: "lightgrey"
                            anchors.centerIn: parent

                            Grid {
                                id: grid1
                                anchors.fill:parent
                                columns: 2
                                spacing: 1.6
                                Rectangle {
                                    id: rect11
                                    color: "transparent"; width: parent.width*0.5; height: parent.height*0.25
                                    Rectangle {
                                        id: rect12ab
                                        color: "#f9f9f9"; width: parent.width; height: parent.height*0.98
                                        anchors.bottom: parent.bottom

                                        Text {
                                            id: name1
                                            text: "Battery Spec:"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.05
                                            font.pixelSize: 16
                                            color: "black"
                                        }
                                        Image {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: parent.height*0.14
                                            id: image12w
                                            source: "battery12.png"
                                            fillMode: Image.PreserveAspectFit
                                        }
                                    }
                                }

                                Rectangle {
                                    id: rect12
                                    color: "transparent"; width: parent.width*0.495; height: parent.height*0.25
                                    Rectangle {
                                        id: rect12a
                                        color: "#f9f9f9"; width: parent.width*0.995; height: parent.height*0.98
                                        anchors.bottom: parent.bottom

                                        Text {
                                            id: name3155
                                            text: "Charging Voltage (v)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.2
                                            font {
                                                pixelSize: 16
                                            }
                                            color:"black"
                                        }


                                        Widget09.SGComboBox {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.bottom: parent.bottom
                                            anchors.bottomMargin: parent.height*0.11
                                            id: set_charge_volt
                                            model: ["4.2", "4.35", "4.4"]
                                            //label: "<b>Charging Voltage:</b>"	// Default: "" (if not entered, label will not appear)
                                            labelLeft: false					// Default: true
                                            comboBoxWidth: 130					// Default: 120 (set depending on model info length)
                                            textColor: "black"					// Default: "black"
                                            indicatorColor: "#aaa"				// Default: "#aaa"
                                            borderColor: "#aaa"					// Default: "#aaa"
                                            boxColor: "#f9f9f9"					// Default: "white"
                                            dividers: true						// Default: false
                                            onCurrentTextChanged: {
                                                platformInterface.set_charge_volt.update(+set_charge_volt.currentText)
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    id: rect13
                                    color: "#f9f9f9"; width: parent.width*0.5; height: parent.height*0.22

                                    Text {
                                        id: name2
                                        text: "Manufacturer"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                        anchors.topMargin: parent.height*0.03
                                        font {
                                            pixelSize: 14
                                        }
                                        color:"black"
                                    }

                                    TextField {
                                        id: manufacturer_name
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width*0.6
                                        anchors.centerIn: parent
                                        height: 33
                                        text: ""
                                    }
                                }

                                Rectangle {
                                    id: rect14
                                    color: "#f9f9f9"; width: parent.width*0.492; height: parent.height*0.22

                                    Text {
                                        id: name6
                                        text: "Typical Capacity (mAh)"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                        anchors.topMargin: 3
                                        font {
                                            pixelSize: 14
                                        }
                                        color:"black"
                                    }

                                    Widget09.SGSlider {
                                        id: set_load_current
                                        anchors.centerIn: parent
                                        label: ""
                                        textColor: "black"				// Default: "black"
                                        labelLeft: false				// Default: true
                                        width: parent.width*0.9			// Default: 200
                                        stepSize: 1.0					// Default: 1.0
                                        value: 1000.0					// Default: average of from and to
                                        from: 20.0						// Default: 0.0
                                        to: 6000.0						// Default: 100.0
                                        startLabel: "20mAh"				// Default: from
                                        endLabel: "6000mAh"				// Default: to
                                        showToolTip: true				// Default: true
                                        toolTipDecimalPlaces: 0			// Default: 0
                                        grooveColor: "#ddd"				// Default: "#dddddd"
                                        grooveFillColor: "lightgreen"	// Default: "#888888"
                                        live: false						// Default: false (will only send valueChanged signal when slider is released)
                                        labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                        inputBox: true					// Default: true
                                        onUserSet: {
                                            //platformInterface.set_load_current.update(value)
                                        }
                                    }
                                }
                                Rectangle {
                                    id: rect15
                                    color: "transparent"; width: parent.width*0.5; height: parent.height*0.25
                                    Rectangle {
                                        id: rect15a
                                        color: "#f9f9f9"; width: parent.width; height: parent.height*0.9
                                        anchors.top: parent.top; radius:3

                                        Text {
                                            id: modal_name_container
                                            text: "Model Name"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.03
                                            font {
                                                pixelSize: 14
                                            }
                                            color:"black"
                                        }

                                        TextField {
                                            id: modal_name
                                            anchors.verticalCenter: parent.verticalCenter
                                            width: parent.width*0.6
                                            anchors.centerIn: parent
                                            height: 33
                                            text: ""	//"ICR18650"
                                        }
                                    }
                                }
                                Rectangle {
                                    id: rect16
                                    color: "transparent"; width: parent.width*0.495; height: parent.height*0.25
                                    Rectangle {
                                        id: rect16a
                                        color: "#f9f9f9"; width: parent.width*0.995; height: parent.height*0.9
                                        anchors.top: parent.top; radius: 3

                                        Text {
                                            id: name8
                                            text: "Discharge Cut-off Voltage (mV)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.03
                                            font {
                                                pixelSize: 14
                                            }
                                            color:"black"
                                        }
                                        Widget09.SGSlider {
                                            id: set_cut_off_volt
                                            anchors.centerIn: parent
                                            label: ""
                                            textColor: "black"				// Default: "black"
                                            labelLeft: false				// Default: true
                                            width: parent.width*0.9			// Default: 200
                                            stepSize: 1.0					// Default: 1.0
                                            value: 2800.0					// Default: average of from and to
                                            from: 2510.0					// Default: 0.0
                                            to: 3500.0						// Default: 100.0
                                            startLabel: "2510mV"			// Default: from
                                            endLabel: "3500mV"				// Default: to
                                            showToolTip: true				// Default: true
                                            toolTipDecimalPlaces: 0			// Default: 0
                                            grooveColor: "#ddd"				// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"	// Default: "#888888"
                                            live: false						// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true					// Default: true
                                            onUserSet: {
                                                platformInterface.set_cut_off_volt.update(value)
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    id: rect17
                                    color: "transparent"; width: parent.width*0.5; height: parent.height*0.27
                                    radius: 0;	//border.width: 0.5; border.color: "lightgrey";
                                    Image {
                                        anchors.right: parent.right
                                        anchors.topMargin: 0
                                        id: image12we
                                        source: "thermistor.png"
                                        fillMode: Image.PreserveAspectFit
                                    }
                                    Rectangle {
                                        id: rect17a
                                        color: "#f7f7fe"; width: parent.width+1; height: parent.height*0.78
                                        radius: 3;anchors.bottom: parent.bottom; anchors.bottomMargin: 4

                                        Text {
                                            id: name41
                                            text: "B Constant (K)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.03
                                            font {
                                                pixelSize: 12
                                            }
                                            color:"black"
                                        }

                                        Widget09.SGSlider {
                                            id: set_b_constant
                                            anchors.centerIn: parent
                                            label: ""
                                            textColor: "black"					// Default: "black"
                                            labelLeft: false					// Default: true
                                            width: parent.width*0.9				// Default: 200
                                            //var xcv= sgSlider1.setValue(500)
                                            stepSize: 1.0						// Default: 1.0
                                            value: 3380.0						// Default: average of from and to
                                            from: 2000.0						// Default: 0.0
                                            to: 5000.0							// Default: 100.0
                                            startLabel: "2000K"					// Default: from
                                            endLabel: "5000K"					// Default: to
                                            showToolTip: true					// Default: true
                                            toolTipDecimalPlaces: 0				// Default: 0
                                            grooveColor: "#ddd"					// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"		// Default: "#888888"
                                            live: false							// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false				// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true						// Default: true
                                            onUserSet: {
                                                platformInterface.set_b_constant.update(value)
                                            }
                                        }
                                    }
                                }
                                Rectangle {
                                    id: rect18
                                    color: "transparent"; width: parent.width*0.495; height: parent.height*0.27
                                    radius: 0;
                                    Text {
                                        id: name42
                                        text: " NTC Thermistor (10.0 KΩ):"
                                        anchors.left: parent.left
                                        anchors.topMargin: parent.height*0.03
                                        font {
                                            pixelSize: 12
                                        }
                                        color:"black"
                                    }
                                    Rectangle {
                                        id: rect18a
                                        color: "#f7f7fe"; width: parent.width*0.996; height: parent.height*0.78
                                        radius: 3;anchors.bottom: parent.bottom; anchors.bottomMargin: 4
                                        Widget09.SGLabelledInfoBox {
                                            id: set_apt
                                            infoBoxWidth: 45
                                            anchors.right: parent.right
                                            anchors.rightMargin: parent.width*0.018
                                            y:parent.height*0.77
                                            infoBoxHeight:16
                                            labelPixelSize: 10
                                            label: "APT =<b>></b>"
                                            info: +(Math.round((set_capacitance.value*1000*0.325)+30))	///Math.round
                                            labelLeft: true												// Default: true (if false, label will be on top)
                                            infoBoxColor: "#f7f7fe"										// Default: "#eeeeee" (light gray)
                                            infoBoxBorderColor: "white"									// Default: "#cccccc" (light gray)
                                            infoBoxBorderWidth: 1										// Default: 1 (assign 0 for no border)
                                            textColor: "green"											// Default: "black" (colors label as well as text in box
                                            onInfoChanged: {
                                                platformInterface.set_apt.update(+info)
                                            }
                                        }

                                        Text {
                                            id: name9
                                            text: "Capacitance (nF)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.03
                                            font {
                                                pixelSize: 12
                                            }
                                            color:"black"
                                        }

                                        Widget09.SGSlider {
                                            id: set_capacitance
                                            anchors.centerIn: parent
                                            label: ""
                                            textColor: "black"				// Default: "black"
                                            labelLeft: false				// Default: true
                                            width: parent.width*0.9			// Default: 200
                                            stepSize: 0.01					// Default: 1.0
                                            value: 0.0						// Default: average of from and to
                                            from: 0.0						// Default: 0.0
                                            to: 200.0						// Default: 100.0
                                            startLabel: "0.00nF"			// Default: from
                                            endLabel: "200.00nF"			// Default: to
                                            showToolTip: true				// Default: true
                                            toolTipDecimalPlaces: 2			// Default: 0
                                            grooveColor: "#ddd"				// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"	// Default: "#888888"
                                            live: false						// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true					// Default: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Rectangle {
                        id: rect2
                        color: "#00000000"; width: parent.width*0.5; height: parent.height*0.5
                        border.width: 0
                        border.color: "lightgrey"
                        Text {
                            id: heading1
                            text: qsTr("Smart LiB Gauge Automatic Support Tool")
                            font.bold: true
                            anchors.top:parent.top
                            anchors.topMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            font.pixelSize: 16
                        }

                        TextArea{
                            id:virtualtextarea
                            visible: false
                            font.pixelSize: 5
                            property var over_temperature: foo8()
                            function foo8(){
                                var lighton="on"
                                var lightoff="off"
                                if(sgStatusLight_overtemp.status==="red"){return lighton}
                                else if(sgStatusLight_overtemp.status==="black"){return lightoff}
                            }
                            property var over_currnt: foo7()
                            function foo7(){
                                var lighton="on"
                                var lightoff="off"
                                if(sgStatusLight_overcurrent.status==="red"){return lighton}
                                else if(sgStatusLight_overcurrent.status==="black"){return lightoff}
                            }
                            property var over_volatage: foo6()
                            function foo6(){
                                var lighton="on"
                                var lightoff="off"
                                if(sgStatusLight_overvoltage.status==="red"){return lighton}
                                else if(sgStatusLight_overvoltage.status==="black"){return lightoff}
                            }

                            property var double_time: foo4()
                            function foo4(){
                                var lighton="on"
                                var lightoff="off"
                                if(sgStatusLight18.status==="red"){return lighton}
                                else if(sgStatusLight18.status==="black"){return lightoff}
                            }
                            property var cut_off_volt: foo5()
                            function foo5(){
                                var lightonn="on"
                                var lightofff="off"
                                if(sgStatusLight1.status==="red"){return lightonn}	//cut_off_voltage
                                else if(sgStatusLight1.status==="black"){return lightofff}
                            }
                            property var on_board_load_:foo33()//
                            function foo33(){
                                var disable="Disable"
                                if((set_onboard_load_en.currentText===" ")){
                                    return disable
                                }
                                else return(set_onboard_load_en.currentText)
                            }

                            property int realtimelog:foo1() //
                            function foo1(){
                                if((qsTr(sgcomboBS.currentText)==="Charge")) {return set_log_interval3.info}
                                if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Enable"){return set_log_interval1.info}
                                if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Disable"){return set_log_interval2.info}
                            }

                            property var estd_tst_time:foo2() //set_est_test_time3
                            function foo2(){
                                if((qsTr(sgcomboBS.currentText)==="Charge")) {return set_est_test_time3.info}
                                if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Enable"){return set_est_test_time1.info}
                                if((qsTr(sgcomboBS.currentText)==="Discharge") && qsTr(set_onboard_load_en.currentText)==="Disable"){return set_est_test_time2.info}
                            }
                            //time capture start
                            property var start_stop_time: +platformInterface.telemetry.cell_voltage//+logSwitch.clear_log_data
                            property var start_time: 0
                            property var start_check:0
                            onStart_stop_timeChanged:{
                                if((start_check===0)&&(platformInterface.telemetry.log_indicator==="green")){
                                    start_time= (new Date().toLocaleString(Qt.locale(),"yyyy/MM/dd h:mm:ss"))
                                    start_check=1
                                }
                            }

                            text: "[SystemSpec]\n"+"AppVersion = 1.0.0\n"+"LsiName = LC709204\n"+"[BatterySpec]\n"+"Manufacturer = "+manufacturer_name.text+"\nModelName = "+modal_name.text+
                                  "\nTypicalCapacity = "+set_load_current.value+"\nChargingVoltage = "+set_charge_volt.currentText+"\nDischargeCut-offVoltage = "+set_cut_off_volt.value +
                                  "\n[ThermistorSpec]"+"\nBConstant = "+set_b_constant.value+"\nCapacitance = "+set_capacitance.value*1000+"\nAPT = "+set_apt.info+"\n[MeasurementCondition]"+
                                  "\nBatteryStatus = "+ sgcomboBS.currentText+
                                  "\nOn-boardLoad = "+ on_board_load_+
                                  "\nLogInterval = "+realtimelog+
                                  "\nOn-boardLoadCurrent = "+sgsliderOBLC.value+
                                  "\nExternalLoadCurrent = "+sgsliderELC.value+
                                  "\nChargingCurrent = "+sgsliderCC.value+
                                  "\n[StopCondition]"+
                                  "\nCut-offVoltage = "+ cut_off_volt+
                                  "\nOverVoltage = "+ over_volatage+
                                  "\nOverCurrent = "+ over_currnt+
                                  "\nOver/UnderTemp = "+ over_temperature+
                                  "\nDoubleEstimatedTime = "+ double_time+
                                  "\n[Data]  \n" + "Start_time= "+start_time+ "\n"
                        }

                        Rectangle {
                            id: rectangle_graphs
                            color: "#00000000"; width: parent.width*0.98; height: parent.height*0.93
                            anchors.bottom: parent.bottom
                            Rectangle {
                                anchors.fill: parent
                                anchors.top: parent.top
                                // spacing: 0
                                Rectangle {
                                    width: parent.width
                                    height: parent.height*0.8
                                    anchors.top: parent.top
                                    Widget01.SGGraph {
                                        id: basicGraph
                                        anchors.fill: parent
                                        anchors.left: parent.left
                                        anchors.leftMargin: 8
                                        title: "Cell Voltage"
                                        xMin: 0
                                        xMax: +virtualtextarea.realtimelog
                                        yMin: 0
                                        yMax: 5000
                                        backgroundColor: "#FDEEF4"
                                        foregroundColor: "steelblue"
                                        xTitle: "							 Time (sec)" + "			 " + "Estd. : "+ basicGraph.xMax.toFixed(0) + "  of  "+ virtualtextarea.estd_tst_time*60
                                        yTitle: "Cell Voltage (mV)"
                                        Button {
                                            id:resetChartButton
                                            anchors {
                                                top:parent.top
                                                right: parent.right
                                                margins: 1
                                            }
                                            text: "set"
                                            visible: true
                                            width: 38
                                            height: 18
                                            onClicked: {
                                                basicGraph.resetChart()
                                            }
                                        }
                                        function resetChart() {
                                            basicGraph.xMin = 0//somevalue
                                            basicGraph.xMax = x_Axis_Timer_1//basicGraph.xMax	//somevalue
                                            basicGraph.yMin = 0//somevalue
                                            basicGraph.yMax = 5000//somevalue
                                        }
                                    }
                                    Timer{
                                        id: graphTimerPoints
                                        interval: +(virtualtextarea.realtimelog*1000+1500)	// chang to seconds *1000 or 3000sec
                                        running: false
                                        repeat: true
                                        onTriggered: {
                                            //platformInterface.get_measurement_value.update("")
                                            if(basicGraph.count > 0) {
                                                basicGraph.removeCurve(0)
                                            }
                                            var curve = basicGraph.createCurve("graphCurve")
                                            curve.color = "green"
                                            curve.appendList(dataArray_voltage_graph)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: rect3
                        color: "transparent"; radius: 5; width: parent.width*0.5; height: parent.height*0.5
                        border.width: 0
                        border.color: "lightgrey"

                        Grid {
                            id: grid3
                            anchors.fill: parent
                            rows: 4
                            spacing: 1

                            Rectangle {
                                id: rect31
                                color: "transparent"; width: parent.width; height: parent.height*0.3
                                Text {
                                    id: name111
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: parent.height*0.02
                                    text: "Measurement Condition:"
                                    font {
                                        pixelSize: 13
                                    }
                                    color:"black"
                                }
                                Rectangle {
                                    id: rect313d
                                    color: "transparent"; width: parent.width; height: parent.height*0.65
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 15
                                    Grid {
                                        id: grid31
                                        anchors.fill: parent
                                        columns: 5
                                        spacing: 1.5
                                        Rectangle {
                                            id: rect313a
                                            color: "transparent"; width: parent.width*0.08; height: parent.height
                                        }
                                        Rectangle {
                                            id: rect311
                                            color: "#f9f9f9"; radius: 5; border.width: 2; border.color: "lightgrey"; width: parent.width*0.42; height: parent.height

                                            Widget09.SGComboBox {
                                                anchors.centerIn: parent
                                                id: sgcomboBS
                                                model: ["Discharge", "Charge"]
                                                label: "Battery status"				// Default: "" (if not entered, label will not appear)
                                                labelLeft: true						// Default: true
                                                comboBoxWidth: parent.width*0.5
                                                textColor: "black"					// Default: "black"
                                                indicatorColor: "#aaa"				// Default: "#aaa"
                                                borderColor: "#aaa"					// Default: "#aaa"
                                                boxColor: "#f7f7fe"					// Default: "white"
                                                dividers: false //true				// Default: false
                                                //popupHeight: 300					// Default: 300 (sets max height for popup if model is lengthy)
                                                onCurrentTextChanged:  {

                                                    if(qsTr(sgcomboBS.currentText)==="Charge"){
                                                        set_onboard_load_en.currentIndex=1
                                                        sgsliderELC.enabled=false
                                                        sgsliderOBLC.enabled=false
                                                        set_onboard_load_en.enabled=false
                                                        labelledInfoBox11.visible=false
                                                        sgsliderCC.enabled=true
                                                        labelledInfoBox11w.visible=false
                                                        rect32a.color="#ffffff"
                                                        rect34a.color="#f7f7fe"
                                                        rect33a.color="#ffffff"
                                                        platformInterface.set_onboard_load_en.update(qsTr(set_onboard_load_en.currentText))
                                                    }

                                                    if(qsTr(sgcomboBS.currentText)==="Discharge") {
                                                        sgsliderELC.enabled=false
                                                        sgsliderOBLC.enabled=true
                                                        set_onboard_load_en.enabled=true
                                                        set_onboard_load_en.currentIndex=0
                                                        labelledInfoBox11.visible=false
                                                        sgsliderCC.enabled=false
                                                        rect32a.color="#f7f7fe"
                                                        rect34a.color="#ffffff"
                                                        labelledInfoBox11w.visible=true
                                                        platformInterface.set_onboard_load_en.update(qsTr(set_onboard_load_en.currentText))
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect313h
                                            color: "transparent"; width: parent.width*0.005; height: parent.height
                                        }

                                        Rectangle {
                                            id: rect312
                                            color: "#f9f9f9"; radius: 5; border.width: 2; border.color: "lightgrey"; width: parent.width*0.42; height: parent.height
                                            Text {
                                                id: name313
                                                text: "(Disharge Only)"
                                                anchors.left: parent.left
                                                anchors.leftMargin: parent.width*0.58
                                                anchors.top: parent.top
                                                anchors.topMargin: parent.height*0.07
                                                font.pixelSize: 9
                                                color: "black"
                                            }
                                            Widget09.SGComboBox {
                                                anchors.centerIn: parent
                                                id: set_onboard_load_en
                                                model: ["Enable", "Disable"]
                                                label: "On-board Load"				// Default: "" (if not entered, label will not appear)
                                                labelLeft: true						// Default: true
                                                comboBoxWidth: parent.width*0.5
                                                textColor: "black"					// Default: "black"
                                                indicatorColor: "#aaa"				// Default: "#aaa"
                                                borderColor: "#aaa"					// Default: "#aaa"
                                                boxColor: "#f7f7fe"					// Default: "white"
                                                dividers: true						// Default: false
                                                //popupHeight: 300					// Default: 300 (sets max height for popup if model is lengthy)
                                                onCurrentTextChanged:  {
                                                    if((qsTr(sgcomboBS.currentText)==="Discharge")&&(qsTr(set_onboard_load_en.currentText)==="Disable")) {
                                                        sgsliderELC.enabled=true
                                                        sgsliderOBLC.enabled=false
                                                        labelledInfoBox11.visible=true
                                                        sgsliderCC.enabled=false
                                                        labelledInfoBox11w.visible=false
                                                        rect32a.color = "#ffffff"
                                                        rect33a.color="#f7f7fe"
                                                        platformInterface.set_onboard_load_en.update(qsTr(set_onboard_load_en.currentText))
                                                    }
                                                    if((qsTr(sgcomboBS.currentText)==="Discharge")&&(qsTr(set_onboard_load_en.currentText)==="Enable")) {
                                                        sgsliderELC.enabled=false
                                                        sgsliderOBLC.enabled=true
                                                        set_onboard_load_en.enabled=true
                                                        labelledInfoBox11.visible=false
                                                        sgsliderCC.enabled=false
                                                        labelledInfoBox11w.visible=true
                                                        rect32a.color = "#f7f7fe"
                                                        rect33a.color="#ffffff"
                                                        platformInterface.set_onboard_load_en.update(qsTr(set_onboard_load_en.currentText))
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect313
                                            color: "transparent"; width: parent.width*0.06; height: parent.height
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: rect32
                                color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width; height: parent.height*0.23
                                Rectangle {
                                    id: rect32a
                                    color: "#ffffff"; radius: 5; border.width: 2; border.color: "lightgrey"; width: parent.width; height: parent.height*0.96
                                    anchors.bottom: parent.bottom; anchors.left: parent.left
                                    Rectangle {
                                        id: rect32aa
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.65; height: parent.height; anchors.left: parent.left

                                        Text {
                                            id: name315
                                            text: "On-board Load Current"
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width*0.23
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.08
                                            font.pixelSize: 14
                                            color: "black"
                                        }
                                        Widget09.SGLabelledInfoBox {
                                            id: labelledInfoBox11w
                                            infoBoxWidth: 43
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width*0.2
                                            y:parent.height*0.72
                                            infoBoxHeight:18
                                            labelPixelSize: 9
                                            border.color: "transparent"
                                            label: "Recommended current for simulator(mA) =<b>></b>"
                                            info: +(Math.round(set_load_current.value*0.25))
                                            labelLeft: true					// Default: true (if false, label will be on top)
                                            infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                            infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                            infoBoxBorderWidth: 1			// Default: 1 (assign 0 for no border)
                                            textColor: "green"				// Default: "black" (colors label as well as text in box
                                        }

                                        Widget09.SGSlider {
                                            id: sgsliderOBLC
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.33
                                            label: ""
                                            textColor: "black"				// Default: "black"
                                            labelLeft: false				// Default: true
                                            width: parent.width*0.9
                                            stepSize: 0.1					// Default: 1.0
                                            value: 4.0						// Default: average of from and to
                                            from: 4.0						// Default: 0.0
                                            to: 1500.0						// Default: 100.0
                                            startLabel: "4.0mA"				// Default: from
                                            endLabel: "1500.0mA"			// Default: to
                                            showToolTip: true				// Default: true
                                            toolTipDecimalPlaces: 1			// Default: 0
                                            grooveColor: "#ddd"				// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"	// Default: "#888888"
                                            live: false						// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true					// Default: true
                                            onUserSet: platformInterface.set_load_current.update(value)
                                        }
                                    }
                                    Rectangle {
                                        id: rect32aab
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.35; height: parent.height*0.99; anchors.right: parent.right; anchors.rightMargin: 3
                                        Rectangle {
                                            id: rect421113a
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.top: parent.top; anchors.topMargin: 3
                                            Widget09.SGLabelledInfoBox {
                                                id: set_est_test_time1
                                                property var height11: +(Math.ceil((+set_load_current.value)*60/((+sgsliderOBLC.value))))
                                                property int height22: +height11
                                                property int height33:foo()
                                                function foo(){
                                                    if (height22>=65000){return 65000}
                                                    else { return height22 }
                                                }

                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "Estd.Test Time (Min)"
                                                info: +height33
                                                labelLeft: true					// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2			// Default: 1 (assign 0 for no border)
                                                textColor: "black"				// Default: "black" (colors label as well as text in box
                                            }
                                        }

                                        Rectangle {
                                            id: rect42123da
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 2
                                            Widget09.SGLabelledInfoBox {
                                                id: set_log_interval1
                                                property var height11: +(Math.ceil((((+set_load_current.value)/(+sgsliderOBLC.value))*60*60)/5000))
                                                property int height22: +height11
                                                property int height33:foo()
                                                function foo(){
                                                    if (height22>=600){return 600}
                                                    else if (height22<=2){return 2}
                                                    else {return height22}
                                                }
                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "     Log Interval (Sec)"
                                                info: +height33
                                                labelLeft: true					// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2			// Default: 1 (assign 0 for no border)
                                                textColor: "black"				// Default: "black" (colors label as well as text in box
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: rect33
                                color: "transparent"; radius: 0; border.color: "lightgrey"; border.width: 0; width: parent.width; height: parent.height*0.23
                                Rectangle {
                                    id: rect33a
                                    color: "#ffffff"; radius: 5; border.width: 2; border.color: "lightgrey"; width: parent.width; height: parent.height*0.96
                                    anchors.top: parent.top
                                    Rectangle {
                                        id: rect32aa1
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.65; height: parent.height; anchors.left: parent.left

                                        Text {
                                            id: name316
                                            text: "External Load Current"
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width*0.23
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.08
                                            font.pixelSize: 14
                                            color: "black"
                                        }

                                        Widget09.SGLabelledInfoBox {
                                            id: labelledInfoBox11
                                            infoBoxWidth: 43
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width*0.2
                                            y:parent.height*0.72
                                            infoBoxHeight:18
                                            labelPixelSize: 9
                                            border.color: "transparent"
                                            label: "Recommended current for simulator(mA) =<b>></b>"
                                            info: +(Math.round(set_load_current.value*0.25))		////Math.round
                                            labelLeft: true											// Default: true (if false, label will be on top)
                                            infoBoxColor: "transparent"	 							// Default: "#eeeeee" (light gray)
                                            infoBoxBorderColor: "#f3f3fe"							// Default: "#cccccc" (light gray)
                                            infoBoxBorderWidth: 1									// Default: 1 (assign 0 for no border)
                                            textColor: "green"										// Default: "black" (colors label as well as text in box
                                        }
                                        Widget09.SGSlider {
                                            id: sgsliderELC
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.33
                                            label: ""
                                            textColor: "black"				// Default: "black"
                                            labelLeft: false				// Default: true
                                            width: parent.width*0.9
                                            stepSize: 0.1					// Default: 1.0
                                            value: 1.0						// Default: average of from and to
                                            from: 1.0						// Default: 0.0
                                            to: 6000.0						// Default: 100.0
                                            startLabel: "1.0mA"				// Default: from
                                            endLabel: "6000.0mA"			// Default: to
                                            showToolTip: true				// Default: true
                                            toolTipDecimalPlaces: 1			// Default: 0
                                            grooveColor: "#ddd"				// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"	// Default: "#888888"
                                            live: false						// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true					// Default: true
                                        }
                                    }
                                    Rectangle {
                                        id: rect32aab1
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.35; height: parent.height*0.99; anchors.right: parent.right; anchors.rightMargin: 3
                                        Rectangle {
                                            id: rect421113a1
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.top: parent.top; anchors.topMargin: 3
                                            Widget09.SGLabelledInfoBox {
                                                property var height11: +(Math.ceil((set_load_current.value)*60/((+sgsliderELC.value))))
                                                property int height22: +height11
                                                property int height33:foo()
                                                function foo(){
                                                    if (height22>=65000){return 65000}
                                                    else { return height22 }
                                                }
                                                id: set_est_test_time2
                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "Estd.Test Time (Min)"
                                                info: +height33
                                                labelLeft: true					// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2			// Default: 1 (assign 0 for no border)
                                                textColor: "black"				// Default: "black" (colors label as well as text in box
                                            }
                                        }

                                        Rectangle {
                                            id: rect42123da1
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 2

                                            Widget09.SGLabelledInfoBox {
                                                id: set_log_interval2
                                                property var height11: +(Math.ceil((((+set_load_current.value)/(+sgsliderELC.value))*60*60)/5000))
                                                property int height22: +height11
                                                property int height33:foo()
                                                function foo(){
                                                    if (height22>=600){return 600}
                                                    else if (height22<=2){return 2}
                                                    else {return height22}
                                                }
                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "     Log Interval (Sec)"
                                                info: +height33
                                                labelLeft: true						// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"			// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"		// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2				// Default: 1 (assign 0 for no border)
                                                textColor: "black"					// Default: "black" (colors label as well as text in box
                                            }
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                id: rect34
                                color: "transparent"; radius: 0; border.color: "lightgrey"; border.width: 0; width: parent.width; height: parent.height*0.23
                                Rectangle {
                                    id: rect34a
                                    color: "#fbfbfb"; radius: 5; border.width: 2; border.color: "lightgrey"; width: parent.width; height: parent.height*0.96
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0
                                    Rectangle {
                                        id: rect32aa1a
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.65; height: parent.height; anchors.left: parent.left

                                        Text {
                                            id: name317
                                            text: "Charging Current"
                                            anchors.left: parent.left
                                            anchors.leftMargin: parent.width*0.31
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.16
                                            font.pixelSize: 14
                                            color: "black"
                                        }
                                        Widget09.SGSlider {
                                            id: sgsliderCC
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.46
                                            label: ""
                                            textColor: "black"				// Default: "black"
                                            labelLeft: false				// Default: true
                                            width: parent.width*0.9			// Default: 200
                                            stepSize: 0.1					// Default: 1.0
                                            value: 1.0						// Default: average of from and to
                                            from: 1.0						// Default: 0.0
                                            to: 6000.0						// Default: 100.0
                                            startLabel: "1.0mA"				// Default: from
                                            endLabel: "6000.0mA"			// Default: to
                                            showToolTip: true				// Default: true
                                            toolTipDecimalPlaces: 1			// Default: 0
                                            grooveColor: "#ddd"				// Default: "#dddddd"
                                            grooveFillColor: "lightgreen"	// Default: "#888888"
                                            live: false						// Default: false (will only send valueChanged signal when slider is released)
                                            labelTopAligned: false			// Default: false (only applies to label on left of slider, decides vertical centering of label)
                                            inputBox: true					// Default: true
                                        }

                                        Text {
                                            id: crate
                                            width: 35
                                            height: 20
                                            text: +((sgsliderCC.value/set_load_current.value).toFixed(4))
                                            visible: false
                                            onTextChanged:{
                                                if(qsTr(sgcomboBS.currentText)==="Charge"){
                                                    var cv_const=0
                                                    var charging_current=0
                                                    var log_interval=0
                                                    if (((+crate.text)<0.2)){cv_const = 22}
                                                    if (((+crate.text)>=0.2) && ((+crate.text)<0.3)){cv_const = 44}
                                                    if (((+crate.text)>=0.3) && ((+crate.text)<0.4)){cv_const = 56}
                                                    if (((+crate.text)>=0.4) && ((+crate.text)<0.5)){cv_const = 69}
                                                    if (((+crate.text)>=0.5) && ((+crate.text)<0.6)){cv_const = 75}
                                                    if (((+crate.text)>=0.6) && ((+crate.text)<0.7)){cv_const = 79}
                                                    if (((+crate.text)>=0.7) && ((+crate.text)<0.8)){cv_const = 83}
                                                    if (((+crate.text)>=0.8) && ((+crate.text)<0.9)){cv_const = 89}
                                                    if (((+crate.text)>=0.9) && ((+crate.text)<1.0)){cv_const = 92}
                                                    if (((+crate.text)>=1.0) && ((+crate.text)<1.1)){cv_const = 94}
                                                    if (((+crate.text)>=1.1) && ((+crate.text)<1.2)){cv_const = 96}
                                                    if (((+crate.text)>=1.2) && ((+crate.text)<1.3)){cv_const = 98}
                                                    if (((+crate.text)>=1.3) && ((+crate.text)<1.4)){cv_const = 101}
                                                    if (((+crate.text)>=1.4) && ((+crate.text)<1.5)){cv_const = 103}
                                                    if (((+crate.text)>=1.5) && ((+crate.text)<1.6)){cv_const = 105}
                                                    if (((+crate.text)>=1.6) && ((+crate.text)<1.7)){cv_const = 107}
                                                    if (((+crate.text)>=1.7) && ((+crate.text)<1.8)){cv_const = 109}
                                                    if (((+crate.text)>=1.8) && ((+crate.text)<1.9)){cv_const = 111}
                                                    if (((+crate.text)>=1.9) && ((+crate.text)<2.0)){cv_const = 112}
                                                    if (((+crate.text)>=2.0) && ((+crate.text)<2.1)){cv_const = 113}
                                                    if (((+crate.text)>=2.1) && ((+crate.text)<2.2)){cv_const = 115}
                                                    if (((+crate.text)>=2.2) && ((+crate.text)<2.3)){cv_const = 116}
                                                    if (((+crate.text)>=2.3) && ((+crate.text)<2.4)){cv_const = 117}
                                                    if ((+crate.text)>=2.4) {cv_const = 118}
                                                    log_interval=+Math.ceil(((36*(102-((+crate.text)*42.1))/(+crate.text))+((cv_const)*60))/5000)

                                                    set_log_interval3.info= +log_interval
                                                    if(set_log_interval3.info>=600){
                                                        set_log_interval3.info= +600
                                                    }
                                                    else if(set_log_interval3.info<=2){
                                                        set_log_interval3.info= +2
                                                    }

                                                    charging_current=+(Math.ceil(((0.6*(102-((+crate.text)*42.1)))/((+crate.text)))+cv_const))

                                                    set_est_test_time3.info= +charging_current
                                                    if(set_est_test_time3.info >= 65000){
                                                        set_est_test_time3.info= +65000
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    Rectangle {
                                        id: rect32aab1a
                                        color: "transparent"; radius: 0; border.width: 0; border.color: "lightgrey"; width: parent.width*0.35; height: parent.height*0.99; anchors.right: parent.right; anchors.rightMargin: 3
                                        Rectangle {
                                            id: rect421113a1a
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.top: parent.top; anchors.topMargin: 3
                                            Widget09.SGLabelledInfoBox {
                                                id:  set_est_test_time3
                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "Estd.Test Time (Min)"
                                                info: +61197					// 130
                                                labelLeft: true					// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2			// Default: 1 (assign 0 for no border)
                                                textColor: "black"				// Default: "black" (colors label as well as text in box
                                            }
                                        }

                                        Rectangle {
                                            id: rect42123da1a
                                            color: "transparent"; radius: 4; border.width: 1; border.color: "#f7f7fe"; width: parent.width; height: parent.height*0.49
                                            anchors.bottom: parent.bottom; anchors.bottomMargin: 2

                                            Widget09.SGLabelledInfoBox {
                                                id: set_log_interval3
                                                infoBoxWidth: 48
                                                anchors.centerIn: parent
                                                infoBoxHeight:27
                                                label: "     Log Interval (Sec)"
                                                info: +600 //2
                                                labelLeft: true					// Default: true (if false, label will be on top)
                                                infoBoxColor: "transparent"		// Default: "#eeeeee" (light gray)
                                                infoBoxBorderColor: "#f3f3fe"	// Default: "#cccccc" (light gray)
                                                infoBoxBorderWidth: 2			// Default: 1 (assign 0 for no border)
                                                textColor: "black"				// Default: "black" (colors label as well as text in box
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: rect4
                        color: "transparent"; width: parent.width*0.5; height: parent.height*0.5
                        border.width: 0
                        border.color: "lightgrey"
                        Grid {
                            id: grid4
                            anchors.fill: parent
                            rows: 3
                            spacing: 0

                            Rectangle {
                                id: rect41
                                color: "#ffffff"; width: parent.width*0.98; height: parent.height*0.42
                                border.width: 0; border.color: "#fafafa"
                                Rectangle {
                                    id: rect214
                                    color: "#FDEEF4"; width: parent.width; height: parent.height*1.25
                                    anchors.bottom:parent.bottom
                                    anchors.bottomMargin: 19
                                    anchors.right: parent.right
                                    Rectangle {
                                        anchors.fill: parent
                                        // spacing: 0
                                        Widget01.SGGraph {
                                            id: basicGraph1
                                            anchors.fill: parent
                                            anchors.left: parent.left
                                            anchors.leftMargin: 8
                                            title: "Cell Temperature"
                                            xMin: 0
                                            xMax: +virtualtextarea.realtimelog
                                            yMin: 0
                                            yMax: 75
                                            backgroundColor: "#FDEEF4"
                                            foregroundColor: "steelblue"
                                            xTitle: "Time (sec)"
                                            yTitle: "Cell Temp.(° C)"

                                            Button {
                                                id:resetChartButton1
                                                anchors {
                                                    top:parent.top
                                                    right: parent.right
                                                    margins: 1
                                                }
                                                text: "set"
                                                visible: true
                                                width: 38
                                                height: 18
                                                onClicked: {
                                                    basicGraph1.resetChart()
                                                }
                                            }
                                            function resetChart() {
                                                basicGraph1.xMin = 0				//somevalue
                                                basicGraph1.xMax = x_Axis_Timer_
                                                basicGraph1.yMin = 0				//somevalue
                                                basicGraph1.yMax = 75				//somevalue
                                            }
                                        }
                                        Timer{
                                            id: graphTimerPoints1
                                            interval: +(virtualtextarea.realtimelog*1000+1850)
                                            running: false
                                            repeat: true
                                            onTriggered: {
                                                if(basicGraph1.count > 0) {
                                                    basicGraph1.removeCurve(0)
                                                }
                                                var curvex = basicGraph1.createCurve("graphCurve")
                                                curvex.color = "red"
                                                curvex.appendList(dataArray_temp_graph)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    id: name318
                                    text: "Measurement Status"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 2
                                    font.pixelSize: 12
                                    color: "black"
                                }
                            }

                            Rectangle {
                                id: rect42
                                color: "transparent"; width: parent.width*0.99; height: parent.height*0.35
                                Rectangle {
                                    id: rect42a
                                    color: "transparent"; width: parent.width; height: parent.height
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 8
                                    anchors.top: parent.top
                                    border.width: 4
                                    radius: 11
                                    border.color: "black"
                                    Grid {
                                        id: grid41
                                        anchors.fill: parent
                                        columns: 3
                                        spacing: 0

                                        Rectangle {
                                            id: rect421
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.33
                                            Rectangle {
                                                id: rect42111
                                                color: "#00000000"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight1
                                                    anchors.centerIn: parent
                                                    status: "off"				// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                    label: ""
                                                    labelLeft: true				// Default: true
                                                    lightSize: 30				// Default: 50
                                                    textColor: "black"			// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect4212
                                                color: "transparent"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right
                                                Text {
                                                    text: "Cut-off Voltage"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect422
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.33
                                            Rectangle {
                                                id: rect42112
                                                color: "transparent"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight_overcurrent
                                                    anchors.centerIn: parent
                                                    status: "black"				// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                    label: ""
                                                    labelLeft: true				// Default: true
                                                    lightSize: 30				// Default: 50
                                                    textColor: "black"			// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect42122
                                                color: "#00000000"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right
                                                Text {
                                                    text: "Overcurrent"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect423
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.3//0.33; border.width: 0;
                                            Rectangle {
                                                id: rect423ab
                                                color: "#e6e3ff"; width: parent.width*0.93; height: parent.height*.95; anchors.bottom: parent.bottom;anchors.bottomMargin: -3; anchors.right: parent.right;anchors.rightMargin: 2
                                                Rectangle {
                                                    id: rect42113
                                                    color: "transparent"; width: parent.width*0.3; height: parent.height
                                                    anchors.left: parent.left

                                                    Widget09.SGStatusLight {
                                                        id: sgStatusLight13
                                                        anchors.centerIn: parent
                                                        status: "off"					// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                        label: ""
                                                        labelLeft: true					// Default: true
                                                        lightSize: 30					// Default: 50
                                                        textColor: "black"				// Default: "black"
                                                        property var log_indicator: platformInterface.telemetry.log_indicator
                                                        onLog_indicatorChanged:{
                                                            sgStatusLight13.status=log_indicator
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    id: rect42123
                                                    color: "transparent"; width: parent.width*0.7; height: parent.height
                                                    anchors.right: parent.right		//: rect4221.left
                                                    Text {
                                                        text: "Log Enable"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: parent.left
                                                        font.pixelSize: 14
                                                        color: "black"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: rect424
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.32
                                            Rectangle {
                                                id: rect42114
                                                color: "transparent"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight_overvoltage
                                                    anchors.centerIn: parent
                                                    status: "off"				// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                    label: ""
                                                    labelLeft: true				// Default: true
                                                    lightSize: 30				// Default: 50
                                                    textColor: "black"			// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect42124
                                                color: "transparent"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right
                                                Text {
                                                    text: "Overvoltage"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect425
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.33
                                            Rectangle {
                                                id: rect42115
                                                color: "transparent"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight_overtemp
                                                    anchors.centerIn: parent
                                                    status: "off"				// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                    label: ""
                                                    labelLeft: true
                                                    lightSize: 30				// Default: 50
                                                    textColor: "black"	 		// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect42125
                                                color: "transparent"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right		//: rect4221.left
                                                Text {
                                                    text: "Overtemperature"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect426
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.31		//0.33
                                            Rectangle{
                                                id: rect426ab
                                                color: "#e6e3ff"; width: parent.width*0.93; height: parent.height*1.08; anchors.bottom: parent.bottom; anchors.bottomMargin: -2; anchors.right: parent.right;anchors.rightMargin: 2

                                                Rectangle {
                                                    id: rect42116
                                                    color: "transparent"; width: parent.width*0.3; height: parent.height
                                                    anchors.left: parent.left

                                                    Widget09.SGStatusLight {
                                                        id: sgStatusLight16
                                                        anchors.centerIn: parent
                                                        status: "off"				// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                        label: ""
                                                        labelLeft: true				// Default: true
                                                        lightSize: 30				// Default: 50
                                                        textColor: "black"			// Default: "black"
                                                        property var on_board_load_led: platformInterface.telemetry.onboard_indicator
                                                        onOn_board_load_ledChanged:{
                                                            sgStatusLight16.status=on_board_load_led
                                                        }
                                                    }
                                                }

                                                Rectangle {
                                                    id: rect42126
                                                    color: "transparent"; width: parent.width*0.7; height: parent.height
                                                    anchors.right: parent.right
                                                    Text {
                                                        text: "On-board Load"
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        anchors.left: parent.left
                                                        font.pixelSize: 14
                                                        color: "black"
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: rect427
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.33

                                            Rectangle {
                                                id: rect42116a
                                                color: "transparent"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight17
                                                    anchors.centerIn: parent
                                                    status: "off"
                                                    label: ""
                                                    labelLeft: true			// Default: true
                                                    lightSize: 30			// Default: 50
                                                    textColor: "black"		// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect42126a
                                                color: "transparent"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right
                                                Text {
                                                    text: "No Battery"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect428
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.33
                                            Rectangle {
                                                id: rect42117
                                                color: "transparent"; width: parent.width*0.3; height: parent.height
                                                anchors.left: parent.left

                                                Widget09.SGStatusLight {
                                                    id: sgStatusLight18
                                                    anchors.centerIn: parent
                                                    status: "black"			// Default: "off" (other options: "green", "yellow", "orange", "red")
                                                    label: ""
                                                    labelLeft: true			// Default: true
                                                    lightSize: 30			// Default: 50
                                                    textColor: "black"		// Default: "black"
                                                }
                                            }

                                            Rectangle {
                                                id: rect42127
                                                color: "transparent"; width: parent.width*0.7; height: parent.height
                                                anchors.right: parent.right
                                                Text {
                                                    text: "Double Estd. Time"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    font.pixelSize: 14
                                                    color: "black"
                                                }
                                            }
                                        }
                                        Rectangle {
                                            id: rect429
                                            color: "transparent"; width: parent.width*0.33; height: parent.height*0.31
                                            Rectangle{
                                                id: rect429ab
                                                color: "#e6e3ff"; width: parent.width*0.93; height: parent.height; anchors.bottom: parent.bottom; anchors.bottomMargin: 1.5; anchors.right: parent.right;anchors.rightMargin: 2
                                            }
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                id: rect43
                                color: "transparent"; width: parent.width*0.99; height: parent.height*0.22
                                border.width: 0
                                border.color: "lightgray"
                                Grid {
                                    id: grid42
                                    anchors.fill: parent
                                    columns: 3
                                    spacing: 1

                                    Rectangle {
                                        id: rect431
                                        color: "transparent"; width: parent.width*0.5; height: parent.height
                                        Text {
                                            id: name319
                                            text: "Log status (Time,Cell temperature,Cell voltage)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.09
                                            font.pixelSize: 12
                                            color: "black"
                                        }

                                        Widget09.SGLabelledInfoBox {
                                            id: labelledInfoBox1exr
                                            infoBoxWidth: parent.width*0.99//*0.58
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.4
                                            infoBoxHeight:40
                                            label: ""
                                            info: platformInterface.telemetry.total_time + " min," + platformInterface.telemetry.cell_temp + "°C,"+ platformInterface.telemetry.cell_voltage + "mV "
                                            labelLeft: true						// Default: true (if false, label will be on top)
                                            infoBoxColor: "lightgray"			// Default: "#eeeeee" (light gray)
                                            infoBoxBorderColor: "#f3f3fe"		// Default: "#cccccc" (light gray)
                                            infoBoxBorderWidth: 0.5				// Default: 1 (assign 0 for no border)
                                            textColor: "green"					// Default: "black" (colors label as well as text in box
                                        }
                                    }
                                    Rectangle {
                                        id: rect432
                                        color: "#00000000"; width: parent.width*0.25; height: parent.height
                                        Text {
                                            id: name320
                                            //height: 19
                                            text: "Measure (Start/Stop)"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.09
                                            font.pixelSize: 12
                                            color: "black"
                                        }

                                        Widget09.SGSwitch{
                                            id: logSwitch
                                            switchWidth: 105
                                            switchHeight: 46
                                            checkedLabel: "<b>Start</b>"				// Default: "" (if not entered, label will not appear)
                                            uncheckedLabel: "<b>Stop</b>"				// Default: "" (if not entered, label will not appear)
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.4
                                            label: ""									// Default: "" (if nothing entered, label will not appear)
                                            labelLeft: false							// Default: true (controls whether label appears at left side or on top of switch)
                                            labelsInside: true							// Default: true (controls whether checked labels appear inside the control or outside of it	// Default: 26
                                            textColor: "black"							// Default: "black"
                                            handleColor: "#fff9f4"						// Default: "white"
                                            grooveColor: "#00b82c"			//#00b82c	// Default: "#ccc"
                                            grooveFillColor: "#ff471a"					// Default: "#0cf"
                                            property var condition1: "start"
                                            property var condition0: "stop"
                                            property var start_stop_measure: 0
                                            property var clear_log_data:2

                                            onClicked: {
                                                if(logSwitch.checked == true) {
                                                    clear=1
                                                    clearGraphsData()
                                                    platformInterface.set_measurement.update(condition1)
                                                    clear_log_data=1
                                                    switch_checked_true()
                                                    // platformInterface.get_measurement_value.update("")
                                                }
                                                if(logSwitch.checked == false){
                                                    platformInterface.set_measurement.update(condition0)
                                                    // platformInterface.set_measurement.update(condition0)
                                                    clear_log_data=0
                                                    switch_checked_false()
                                                    virtualtextarea.start_check=0
                                                }
                                            }
                                        }
                                    }
                                    Rectangle {
                                        id: rect433
                                        color: "#00000000"; width: parent.width*0.25; height: parent.height
                                        Text {
                                            id: name321
                                            text: "Log File"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.09
                                            font.pixelSize: 12
                                            color: "black"
                                        }

                                        SaveDialogMenu {
                                            id:save_dialog_menu
                                            anchors.left: parent.left
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            anchors.top: parent.top
                                            anchors.topMargin: parent.height*0.38
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
