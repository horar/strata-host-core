import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help
import Fonts 1.0


Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var pwmArray: []
    // Setting the nct72 LED based on the notification
    property var nct72_get_status_LTHRM_notification: platformInterface.nct72_get_status.LTHRM
    onNct72_get_status_LTHRM_notificationChanged: {
        if(nct72_get_status_LTHRM_notification === 0) {
            lthrm.status = "red"
        }
        else {
            lthrm.status = "green"
        }
    }
    property var nct72_get_status_RTHRM_notification: platformInterface.nct72_get_status.RTHRM
    onNct72_get_status_RTHRM_notificationChanged: {
        if(nct72_get_status_RTHRM_notification === 0) {
            rthrm.status = "red"
        }
        else {
            rthrm.status = "green"
        }
    }
    property var nct72_get_status_OPEN_notification: platformInterface.nct72_get_status.OPEN
    onNct72_get_status_OPEN_notificationChanged: {
        if(nct72_get_status_OPEN_notification === 0) {
            open.status = "red"
        }
        else {
            open.status = "green"
        }
    }
    property var nct72_get_status_RLOW_notification: platformInterface.nct72_get_status.RLOW
    onNct72_get_status_RLOW_notificationChanged: {
        if(nct72_get_status_RLOW_notification === 0) {
            rlow.status = "red"
        }
        else {
            rlow.status = "green"
        }
    }
    property var nct72_get_status_RHIGH_notification: platformInterface.nct72_get_status.RHIGH
    onNct72_get_status_RHIGH_notificationChanged: {
        if(nct72_get_status_RHIGH_notification === 0) {
            rhigh.status = "red"
        }
        else {
            rhigh.status = "green"
        }
    }
    property var nct72_get_status_LLOW_notification: platformInterface.nct72_get_status.LLOW
    onNct72_get_status_LLOW_notificationChanged: {
        if(nct72_get_status_LLOW_notification === 0) {
            llow.status = "red"
        }
        else {
            llow.status = "green"
        }
    }
    property var nct72_get_status_LHIGH_notification: platformInterface.nct72_get_status.LHIGH
    onNct72_get_status_LHIGH_notificationChanged: {
        if(nct72_get_status_LHIGH_notification === 0) {
            lhigh.status = "red"
        }
        else {
            lhigh.status = "green"
        }
    }
    property var nct72_get_status_BUSY_notification: platformInterface.nct72_get_status.BUSY
    onNct72_get_status_BUSY_notificationChanged: {
        if(nct72_get_status_BUSY_notification === 0) {
            busy.status = "red"
        }
        else {
            busy.status = "green"
        }
    }

    property var nct72_int_temp_THERM: platformInterface.nct72_int_temp.THERM
    onNct72_int_temp_THERMChanged: {
        if(nct72_int_temp_THERM === true){
            therm.status = "green"
        }
        else therm.status = "red"
    }
    property var nct72_int_temp_ALERT: platformInterface.nct72_int_temp.ALERT
    onNct72_int_temp_ALERTChanged: {
        if(nct72_int_temp_ALERT === true){
            alert.status = "green"
        }
        else alert.status = "red"
    }
    property var nct72_int_temp_THERM2: platformInterface.nct72_int_temp.THERM2
    onNct72_int_temp_THERM2Changed: {
        if(nct72_int_temp_THERM2 === true){
            alert.status = "green"
        }
        else alert.status = "red"
    }

    //    property var int_temp_alert: platformInterface.nct72_int_temp.ALERT
    //    onInt_temp_alertChanged: {
    //        if(int_temp_alert === true) {
    //            alert.label = "ALERT"
    //        }
    //    }


    //    property var int_temp_THERM: platformInterface.nct72_int_temp.THERM
    //    onInt_temp_THERMChanged: {
    //        if(int_temp_THERM === true) {
    //            alert.label = "THERM"
    //        }
    //    }




    function setPwmDutyCycle()
    {
        for (var i = 0 ; i <= 100 ; i+=10) {
            pwmArray.push(i)
        }
        pwmDutyCycle1.model = pwmArray
        pwmDutyCycle2.model = pwmArray
    }

    Component.onCompleted: {
        setPwmDutyCycle()
        console.log("value", lowlimitSlider.value)
//        lowlimitSlider.from = 0
//        lowlimitSlider.to = 127
//        lowlimitSlider.startLabel = "0°c"
//        lowlimitSlider.endLabel = "127°c"
        highlimitSlider.from = 0
        highlimitSlider.to = 127
        highlimitSlider.startLabel = "0°c"
        highlimitSlider.endLabel = "127°c"
        offsetSlider.from = 0
        offsetSlider.to = 127
        offsetSlider.startLabel = "0°c"
        offsetSlider.endLabel = "127°c"
        locallimitSlider.from = 0
        locallimitSlider.to = 127
        locallimitSlider.startLabel = "0°c"
        locallimitSlider.endLabel = "127°c"
        localhighSlider.from = 0
        localhighSlider.to = 127
        localhighSlider.startLabel = "0°c"
        localhighSlider.endLabel = "127°c"


    }

    Rectangle {
        id: temperatureContainer
        width: parent.width - 60
        height:  parent.height - 20
        color: "transparent"
        border.color: "gray"
        border.width: 2
        radius: 10
        anchors{
            verticalCenter: parent.verticalCenter
            horizontalCenter: parent.horizontalCenter
        }


        Rectangle {
            id: topContainer
            width: parent.width
            height: parent.height/1.7
            color:"transparent"
            anchors {
                top: parent.top
            }
            Rectangle{
                id: leftContainer
                width: parent.width/4
                height:  parent.height - 50
                color: "transparent"
                Rectangle {
                    id: gaugeContainer1
                    width: parent.width
                    height: parent.height/1.7
                    anchors.centerIn: parent
                    color: "transparent"
                    SGCircularGauge{
                        id:remotetempGauge
                        color: "transparent"
                        anchors.fill: parent
                        gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        minimumValue: 0
                        maximumValue: 200
                        tickmarkStepSize: 20
                        outerColor: "#999"
                        unitLabel: "°c"
                        gaugeTitle : "Remote" + "\n"+ "Temp"
                        decimal: 2
                        gaugeTitleSize: 20 * ratioCalc
                        value: platformInterface.nct72_get_temp.external
                    }
                }
                SGComboBox {
                    id: pwmDutyCycle1
                    label: "PWM Positive \n Duty Cycle(%)"
                    comboBoxWidth:ratioCalc * 100
                    comboBoxHeight: ratioCalc * 30
                    fontSize: 15 * ratioCalc
                    anchors{
                        top: gaugeContainer1.bottom
                        topMargin: 20
                        horizontalCenter: gaugeContainer1.horizontalCenter
                    }
                    onActivated: {
                        platformInterface.set_pwm_temp_ext.update(currentText)
                    }

                }

            }
            Rectangle{
                id: middleContainer
                width: parent.width/2
                height:  parent.height
                color: "transparent"
                anchors {
                    left: leftContainer.right
                }
                Column {
                    id: middleSetting
                    anchors.fill: parent

                    Rectangle {
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"
                        RowLayout{
                            anchors.fill: parent

                            Button{
                                id: reset
                                width: 150 * ratioCalc
                                height: 50 * ratioCalc
                                text: qsTr("One-shot")
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    platformInterface.one_shot.update()


                                }
                            }
                            SGStatusLight{
                                id: busy
                                label: "BUSY"
                                fontSize: ratioCalc * 20
                                Layout.alignment: Qt.AlignCenter
                                lightSize: ratioCalc * 30
                            }
                            SGStatusLight{
                                id: therm
                                label: "THERM"
                                fontSize: ratioCalc * 20
                                Layout.alignment: Qt.AlignCenter
                                lightSize: ratioCalc * 30
                            }
                            SGStatusLight{
                                id: alert
                                label: platformInterface.control_properties.nct72_alert_therm2.caption //"ALERT or \n THERM2"
                                fontSize: ratioCalc * 20
                                Layout.alignment: Qt.AlignCenter
                                lightSize: ratioCalc * 30

                            }


                        }


                    }

                    Rectangle {
                        width: parent.width
                        height: parent.height/5
                        color: "transparent"
                        RowLayout{
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            SGRadioButtonContainer {
                                id: mode
                                label: "Mode:" // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "black"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true (sets whether multiple radio buttons can be set or only one at a time)
                                Layout.preferredWidth: parent.width/4
                                Layout.preferredHeight: parent.height/1.7
                                Layout.alignment: Qt.AlignHCenter
                                radioGroup: GridLayout {
                                    columnSpacing: 10
                                    rowSpacing: 10
                                    columns: 1          // Comment this line for horizontal row layout
                                    property alias run : run
                                    property alias standby : standby


                                    property var get_config_range_notification: platformInterface.nct72_get_config.RUN_STOP

                                    onGet_config_range_notificationChanged: {
                                        if(get_config_range_notification === 0){
                                            run.checked = true
                                        }
                                        else {
                                            standby.checked = true
                                        }
                                    }
                                    SGRadioButton {
                                        id: run
                                        text: "Run"
                                        checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.set_config_run_stop.update("Run")
                                                platformInterface.set_config_run_stop.show()
                                            }
                                            else  {
                                                platformInterface.set_config_run_stop.update("Standby")
                                                platformInterface.set_config_run_stop.show()
                                            }
                                        }
                                    }

                                    SGRadioButton {
                                        id: standby
                                        text: "Standby"
                                        checked: !run.checked
                                    }
                                }
                            }
                            SGRadioButtonContainer {
                                id: alertButton
                                label: "ALERT#: " // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "black"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true (sets whether multiple radio buttons can be set or only one at a time)

                                Layout.alignment: Qt.AlignHCenter

                                Layout.preferredWidth: parent.width/3.9
                                Layout.preferredHeight: parent.height/1.7
                                radioGroup: GridLayout {
                                    columnSpacing: 10
                                    rowSpacing: 10
                                    columns: 1          // Comment this line for horizontal row layout

                                    property alias enabled : enabled
                                    property alias masked : masked
                                    property var get_config_mask1_notification: platformInterface.nct72_get_config.MASK1

                                    onGet_config_mask1_notificationChanged: {
                                        if(get_config_mask1_notification === 0){
                                            enabled.checked = true
                                        }
                                        else {
                                            masked.checked = true
                                        }
                                    }

                                    SGRadioButton {
                                        id: enabled
                                        text: "Enabled"
                                        checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.set_config_alert.update("Enabled")
                                                platformInterface.set_config_alert.show()
                                            }
                                            else  {
                                                platformInterface.set_config_alert.update("Masked")
                                                platformInterface.set_config_alert.show()
                                            }
                                        }
                                    }

                                    SGRadioButton {
                                        id: masked
                                        text: "Masked"
                                        checked: !enabled.checked
                                    }
                                }
                            }

                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: parent.height/5
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 20

                            SGRadioButtonContainer {
                                id: pinButton
                                label: "Pin 6" // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "black"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true (sets whether multiple radio buttons can be set or only one at a time)
                                Layout.preferredWidth: parent.width/4
                                Layout.preferredHeight: parent.height/1.7
                                Layout.alignment: Qt.AlignCenter
                                radioGroup: GridLayout {
                                    columnSpacing: 10
                                    rowSpacing: 10
                                    columns: 1
                                    property var get_config_ALERT_THERM2_notification: platformInterface.nct72_get_config.ALERT_THERM2

                                    onGet_config_ALERT_THERM2_notificationChanged: {
                                        if(get_config_ALERT_THERM2_notification === 0){
                                            alertNum.checked = true
                                        }
                                        else {
                                            thermalNum.checked = true
                                        }
                                    }

                                    SGRadioButton {
                                        id: alertNum
                                        text: "ALERT#"
                                        checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.set_config_alert_therm2.update("ALERT")
                                                platformInterface.set_config_alert_therm2.show()
                                            }
                                            else  {
                                                platformInterface.set_config_alert_therm2.update("THERM2")
                                                platformInterface.set_config_alert_therm2.show()
                                            }
                                        }
                                    }

                                    SGRadioButton {
                                        id: thermalNum
                                        text: "THERM2#"
                                        checked: !alertNum.checked


                                    }
                                }
                            }
                            SGRadioButtonContainer {
                                id: rangeButton
                                label: "Range" // Default: "" (will not appear if not entered)
                                labelLeft: true         // Default: true
                                textColor: "black"      // Default: "#000000"  (black)
                                radioColor: "black"     // Default: "#000000"  (black)
                                exclusive: true         // Default: true (sets whether multiple radio buttons can be set or only one at a time)
                                Layout.preferredWidth: parent.width/4
                                Layout.preferredHeight: parent.height/1.7
                                Layout.alignment: Qt.AlignCenter
                                radioGroup: GridLayout {
                                    columnSpacing: 10
                                    rowSpacing: 10
                                    columns: 1          // Comment this line for horizontal row layout

                                    property alias rangeNum1 : rangeNum1
                                    property alias rangeNum2 : rangeNum2
                                    property var get_config_RANGE_notification: platformInterface.nct72_get_config.RANGE

                                    onGet_config_RANGE_notificationChanged: {
                                        if(get_config_RANGE_notification === 0){
                                            rangeNum1.checked = true
                                        }
                                        else {
                                            rangeNum2.checked = true
                                        }
                                    }

                                    SGRadioButton {
                                        id: rangeNum1
                                        text: "0 to 127°c"
                                        checked: true
                                        onCheckedChanged: {
                                            if(checked){
                                                lowlimitSlider.from = 0
                                                lowlimitSlider.to = 127
                                                lowlimitSlider.startLabel = "0°c"
                                                lowlimitSlider.endLabel = "127°c"
                                                highlimitSlider.from = 0
                                                highlimitSlider.to = 127
                                                highlimitSlider.startLabel = "0°c"
                                                highlimitSlider.endLabel = "127°c"
                                                offsetSlider.from = 0
                                                offsetSlider.to = 127
                                                offsetSlider.startLabel = "0°c"
                                                offsetSlider.endLabel = "127°c"
                                                locallimitSlider.from = 0
                                                locallimitSlider.to = 127
                                                locallimitSlider.startLabel = "0°c"
                                                locallimitSlider.endLabel = "127°c"
                                                localhighSlider.from = 0
                                                localhighSlider.to = 127
                                                localhighSlider.startLabel = "0°c"
                                                localhighSlider.endLabel = "127°c"
                                                platformInterface.set_config_range.update("0_127")
                                                platformInterface.set_config_range.show()

                                            }
                                            else {
                                                lowlimitSlider.from = -64
                                                lowlimitSlider.to = 191
                                                lowlimitSlider.startLabel = "-64°c"
                                                lowlimitSlider.endLabel = "191°c"
                                                highlimitSlider.from = -64
                                                highlimitSlider.to = 191
                                                highlimitSlider.startLabel = "-64°c"
                                                highlimitSlider.endLabel = "191°c"
                                                offsetSlider.from = -64
                                                offsetSlider.to = 191
                                                offsetSlider.startLabel = "-64°c"
                                                offsetSlider.endLabel = "191°c"
                                                locallimitSlider.from = -64
                                                locallimitSlider.to = 191
                                                locallimitSlider.startLabel = "-64°c"
                                                locallimitSlider.endLabel = "191°c"
                                                localhighSlider.from = -64
                                                localhighSlider.to = 191
                                                localhighSlider.startLabel = "-64°c"
                                                localhighSlider.endLabel = "191°c"
                                                platformInterface.set_config_range.update("-64_191")
                                                platformInterface.set_config_range.show()

                                            }
                                        }
                                    }

                                    SGRadioButton {
                                        id: rangeNum2
                                        text: "-64 to 191°c"
                                        checked: {
                                            checked =  !rangeNum1.checked

                                        }

                                    }
                                }
                            }

                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            SGComboBox {
                                id: consecutiveAlert
                                Layout.alignment: Qt.AlignCenter
                                comboBoxWidth:ratioCalc * 100
                                comboBoxHeight: ratioCalc * 30
                               // model: platformInterface.control_properties.nct72_cons_alert.values

                                label: platformInterface.control_properties.nct72_cons_alert.caption /*"Consecutive \n ALERTs"*/
                                fontSize: 20 * ratioCalc

                                property var control_state_consecutiveAlert: platformInterface.control_properties.nct72_cons_alert.values
                                onControl_state_consecutiveAlertChanged: {
                                    if (control_state_consecutiveAlert)
                                        model = control_state_consecutiveAlert
                                }

                                property var get_cons_alert_notification:platformInterface.conv_alert_noti //nct72_get_cons_alert.cons_alert
                                onGet_cons_alert_notificationChanged: {
                                    for(var i = 0; i <= model.length; ++i) {
                                        console.log("in the alert noti",get_cons_alert_notification)
                                        if(parseInt(get_cons_alert_notification) === parseInt(model[i])) {
                                            console.log("in the alert noti in if")
                                            consecutiveAlert.currentIndex = i
                                        }
                                    }
                                }

                                property var control_state_value_consecutiveAlerts: platformInterface.control_properties.nct72_cons_alert.value
                                onControl_state_value_consecutiveAlertsChanged: {
                                    currentIndex = control_state_value_consecutiveAlerts - 1
                                }

                                onActivated: {
                                    platformInterface.set_ext_low_lim.update(currentText)
                                    platformInterface.set_ext_low_lim.show()
                                }



                            }

                            SGComboBox {
                                id: conversionInterval
                                Layout.alignment: Qt.AlignCenter
                                comboBoxWidth:ratioCalc * 100
                                comboBoxHeight: ratioCalc * 30

                                model: ["16 s", "8 s", "4 s", "2 s", "1 s", "500 ms", "250 ms", "125 ms", "62.5 ms", "31.25 ms", "15.5 ms"]
                                label: "Conversion \n Interval"
                                fontSize: 20 * ratioCalc
                                onActivated: {
                                    platformInterface.set_conv_rate.update(currentText)
                                    platformInterface.set_conv_rate.show()
                                }
                                property var nct72_get_conv_rate_notification: platformInterface.conv_noti//platformInterface.nct72_get_conv_rate.conv_rate
                                onNct72_get_conv_rate_notificationChanged: {
                                    for(var i = 0; i < model.length; ++i) {
                                        if(nct72_get_conv_rate_notification === model[i]) {
                                            conversionInterval.currentIndex = i
                                        }
                                    }

                                }

                            }
                        }
                    }
                    Rectangle {
                        width: parent.width
                        height: parent.height/7
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            SGSlider {
                                id: sgSlider
                                Layout.alignment: Qt.AlignCenter
                                fontSize: ratioCalc * 20
                                label: "<b>THERM \n Hysteresis:</b>"         // Default: "" (if not entered, label will not appear)
                                textColor: "black"           // Default: "black"
                                labelLeft: false             // Default: true
                                width: 500                   // Default: 200
                                stepSize: 1.0                // Default: 1.0
                                value: 10            // Default: average of from and to
                                from: 0                      // Default: 0.0
                                to: 255                    // Default: 100.0
                                startLabel: "0°c"              // Default: from
                                endLabel: "255°c"            // Default: to
                                showToolTip: true            // Default: true
                                toolTipDecimalPlaces: 0      // Default: 0
                                grooveColor: "#ddd"          // Default: "#dddddd"
                                grooveFillColor: "lightgreen"// Default: "#888888"
                                live: false                  // Default: false (will only send valueChanged signal when slider is released)
                                property var therm_hyst_notification: platformInterface.therm_hyst
                                onTherm_hyst_notificationChanged: {
                                    sgSlider.value = therm_hyst_notification
                                }

                                onMoved: {
                                    platformInterface.set_therm_hyst.update(value)
                                    platformInterface.set_therm_hyst.show()
                                }

                            }
                            SGLabelledInfoBox{
                                id:manufacturerId
                                fontSize: ratioCalc * 18
                                Layout.alignment: Qt.AlignCenter
                                label: "Maufacture ID"
                                unit: ""
                                info: platformInterface.nct72_get_man_id.id
                                infoBoxBorderWidth: ratioCalc * 100
                                infoBoxWidth: ratioCalc * 100
                                infoBoxHeight: ratioCalc * 30
                            }

                        }
                    }
                } // end of cloumn
            }

            Rectangle{
                id: rightContainer
                width: parent.width/4
                height:  parent.height - 50
                color: "transparent"
                anchors {
                    top: parent.top
                    left: middleContainer.right
                }

                Rectangle {
                    id: gaugeContainer2
                    width: parent.width
                    height: parent.height/1.7
                    anchors.centerIn: parent
                    color: "transparent"
                    SGCircularGauge{
                        id:localTempGauge
                        color: "transparent"
                        anchors.fill: parent
                        gaugeFrontColor1: Qt.rgba(0,0.5,1,1)
                        gaugeFrontColor2: Qt.rgba(1,0,0,1)
                        minimumValue: 0
                        maximumValue: 200
                        tickmarkStepSize: 20
                        outerColor: "#999"
                        unitLabel: "°c"
                        gaugeTitle : "Local" + "\n"+ "Temp"
                        gaugeTitleSize: 20 * ratioCalc
                        value: {
                            console.log("value ")
                            platformInterface.nct72_get_temp.internal
                        }
                    }

                }
                SGComboBox {
                    id: pwmDutyCycle2
                    label: "PWM Positive \n Duty Cycle (%)"
                    comboBoxWidth:ratioCalc * 100
                    comboBoxHeight: ratioCalc * 30
                    fontSize: 15 * ratioCalc
                    anchors{
                        top: gaugeContainer2.bottom
                        topMargin: 20
                        horizontalCenter: gaugeContainer2.horizontalCenter
                    }
                    onActivated: {
                        platformInterface.set_pwm_temp_int.update(currentText)
                    }

                }

            }
        }

        Rectangle {
            id: remoteSetting
            width: parent.width/2.5
            height: parent.height/2
            color: "transparent"
            anchors {
                left: parent.left
                top: topContainer.bottom
                leftMargin: 10
            }
            Column {
                id: setting
                anchors.fill: parent
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent
                        SGStatusLight{
                            id: rthrm
                            label: "RTHRM"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }
                        SGStatusLight{
                            id: rlow
                            label: "RLOW"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }
                        SGStatusLight{
                            id: rhigh
                            label: "RHIGH"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }
                        SGStatusLight{
                            id: open
                            label: "OPEN"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }

                    }
                }
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"

                    RowLayout{
                        anchors.fill: parent
                        SGSlider {
                            id: lowlimitSlider
                            Layout.alignment: Qt.AlignCenter
                            fontSize: ratioCalc * 20
                            label: /*platformInterface.control_properties.nct72_remote_low_limit.caption //*/"<b> Remote Low Limit:</b>"         // Default: "" (if not entered, label will not appear)
                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width: parent.width                  // Default: 200
                            stepSize: 1.0
                            //value:
                            showToolTip: true            // Default: true
                            toolTipDecimalPlaces: 0      // Default: 0
                            grooveColor: "#ddd"          // Default: "#dddddd"
                            grooveFillColor: "lightgreen"// Default: "#888888"
                            live: false
                            from: platformInterface.control_properties.nct72_remote_low_limit.scales[0]
                            to: platformInterface.control_properties.nct72_remote_low_limit.scales[1]

                            endLabel: platformInterface.control_properties.nct72_remote_low_limit.scales[1]
                            startLabel: platformInterface.control_properties.nct72_remote_low_limit.scales[0]

                            property var control_state_remote_caption: platformInterface.control_properties.nct72_remote_low_limit.caption
                            onControl_state_remote_captionChanged: {
                                if(control_state_remote_caption)
                                label = control_state_remote_caption
                                else console.log("undefined")
                            }

                            property var control_state_remote_value: parseInt(platformInterface.control_properties.nct72_remote_low_limit.value)

                            onControl_state_remote_valueChanged: {
                                if(control_state_remote_value) {
                                    value = control_state_remote_value
                                }
                            }

                            property var ext_low_lim: platformInterface.nct72_get_ext_low_lim.integer
                            onExt_low_limChanged: {
                                console.log(platformInterface.nct72_get_ext_low_lim.interge)
                                value = ext_low_lim
                            }

                            onMoved: {
                                console.log("stepSize",lowlimitSlider.stepSize )
                                platformInterface.set_ext_low_lim_integer.update(value)
                                platformInterface.set_ext_low_lim_integer.show()
                            }


                        }
                        SGComboBox {
                            id: fractionComboBox1
                            comboBoxWidth:ratioCalc * 70
                            comboBoxHeight: ratioCalc * 30
                            fontSize: 20 * ratioCalc
                            model: ["0.0", "0.25", "0.5", "0.75"]
                            property var get_ext_low_limnotification: platformInterface.nct72_get_ext_low_lim.fraction
                            onGet_ext_low_limnotificationChanged: {
                                for(var i = 0; i < model.length; ++i) {
                                    if(get_ext_low_limnotification === model[i]) {
                                        fractionComboBox1.currentIndex = i
                                    }
                                }
                            }
                            property var get_control_increment: platformInterface.control_properties.nct72_remote_low_limit.scales[2]
                            onGet_control_incrementChanged: {
                                console.log("tanya",get_control_increment)
                                if(get_control_increment === 0.0) {
                                    fractionComboBox1.currentIndex = 0
                                    lowlimitSlider.stepSize = 1.0
                                }
                                else if(get_control_increment === 0.25) {
                                    fractionComboBox1.currentIndex = 1
                                    lowlimitSlider.stepSize = 0.25
                                }
                                else if(get_control_increment === 0.5) {
                                    fractionComboBox1.currentIndex = 2
                                    lowlimitSlider.stepSize = 0.5
                                }
                                else if(get_control_increment === 0.75) {
                                    fractionComboBox1.currentIndex = 2
                                    lowlimitSlider.stepSize = 0.75
                                }
                            }


                            onActivated: {
                                platformInterface.set_ext_low_lim_fraction.update(currentText)
                                if(currentIndex == 0)
                                    lowlimitSlider.stepSize = 1.0
                                else lowlimitSlider.stepSize = currentText

                            }

                        }

                        Rectangle {
                            Layout.preferredWidth:ratioCalc * 50
                            Layout.preferredHeight: ratioCalc * 30
                            Layout.alignment: Qt.AlignCenter
                            color: "light grey"
                            Text{
                                anchors.fill: parent
                                text: lowlimitSlider.value.toFixed(2)
                                anchors.centerIn: parent
                            }
                        }

                    }
                }

                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent
                        SGSlider {
                            id: highlimitSlider
                            Layout.alignment: Qt.AlignCenter
                            fontSize: ratioCalc * 20
                            label: "<b> Remote High Limit:</b>"         // Default: "" (if not entered, label will not appear)
                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width:  parent.width                   // Default: 200
                            stepSize: 1.0                // Default: 1.0
                            value: 50                 // Default: average of from and to
                            endLabel: "127°c"            // Default: to
                            showToolTip: true            // Default: true
                            toolTipDecimalPlaces: 0      // Default: 0
                            grooveColor: "#ddd"          // Default: "#dddddd"
                            grooveFillColor: "lightgreen"// Default: "#888888"
                            live: false
                            onValueChanged: {
                                console.log("stepSize",highlimitSlider.stepSize )
                                platformInterface.set_ext_high_lim_integer.update(value)
                                platformInterface.set_ext_high_lim_integer.show()
                            }

                        }

                        SGComboBox {
                            id: fractionComboBox2
                            comboBoxWidth:ratioCalc * 70
                            comboBoxHeight: ratioCalc * 30
                            fontSize: 20 * ratioCalc

                            model: ["0.0", "0.25", "0.5", "0.75"]
                            property var get_ext_high_limnotification: platformInterface.nct72_get_ext_high_lim.fraction
                            onGet_ext_high_limnotificationChanged: {
                                for(var i = 0; i < model.length; ++i) {
                                    if(get_ext_high_limnotification === model[i]) {
                                        fractionComboBox2.currentIndex = i
                                    }
                                }
                            }
                            onActivated: {
                                platformInterface.set_ext_high_lim_fraction.update(currentText)
                                if(currentIndex == 0)
                                    highlimitSlider.stepSize = 1.0
                                else highlimitSlider.stepSize = currentText
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth:ratioCalc * 50
                            Layout.preferredHeight: ratioCalc * 30
                            Layout.alignment: Qt.AlignCenter
                            color: "light grey"
                            Text{
                                anchors.fill: parent
                                text: highlimitSlider.value.toFixed(2)
                            }
                        }
                    }

                }
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"

                    RowLayout{
                        anchors.fill: parent
                        SGSlider {
                            id: offsetSlider
                            Layout.alignment: Qt.AlignCenter
                            fontSize: ratioCalc * 20
                            label: "<b> Remote Offset:</b>"         // Default: "" (if not entered, label will not appear)
                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width:  parent.width                   // Default: 200
                            stepSize: 1.0                // Default: 1.0
                            value: platformInterface.nct72_get_ext_offset.integer                 // Default: average of from and to
                            endLabel: "127°c"            // Default: to
                            showToolTip: true            // Default: true
                            toolTipDecimalPlaces: 0      // Default: 0
                            grooveColor: "#ddd"          // Default: "#dddddd"
                            grooveFillColor: "lightgreen"// Default: "#888888"
                            live: false

                            onMoved:{
                                platformInterface.set_ext_offset_integer.update(value)
                                platformInterface.set_ext_offset_integer.show()

                            }

                        }
                        SGComboBox {
                            id: fractionComboBox3
                            comboBoxWidth:ratioCalc * 70
                            comboBoxHeight: ratioCalc * 30
                            fontSize: 20 * ratioCalc

                            model: ["0.0", "0.25", "0.5", "0.75"]
                            property var get_ext_offset_notification: platformInterface.nct72_get_ext_offset.fraction
                            onGet_ext_offset_notificationChanged: {
                                for(var i = 0; i < model.length; ++i) {
                                    if(get_ext_offset_notification === model[i]) {
                                        fractionComboBox3.currentIndex = i
                                    }
                                }
                            }

                            onActivated: {
                                platformInterface.set_ext_offset_fraction.update(currentText)
                                if(currentIndex == 0)
                                    offsetSlider.stepSize = 1.0
                                else offsetSlider.stepSize = currentText
                            }
                        }
                        Rectangle {
                            Layout.preferredWidth:ratioCalc * 50
                            Layout.preferredHeight: ratioCalc * 30
                            Layout.alignment: Qt.AlignCenter
                            color: "light grey"
                            Text{
                                anchors.fill: parent
                                text: offsetSlider.value.toFixed(2)

                            }
                        }


                    }
                }
                Rectangle {
                    width: parent.width
                    height: parent.height/7
                    color: "transparent"


                    SGSlider {
                        id: thermSlider
                        fontSize: ratioCalc * 20
                        anchors{
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: -77
                        }
                        label: "<b> Remote THERM Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width: parent.width/2                 // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        value: 20 //platformInterface.nct72_get_therm_limits.external
                        endLabel: "255°c"            // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        property var therm_ext_notification: platformInterface.therm_ext
                        onTherm_ext_notificationChanged: {
                            value = therm_ext_notification
                        }

                        onMoved: {
                            platformInterface.set_ext_therm_limit.update(value)
                            platformInterface.set_ext_therm_limit.show()
                        }

                    }

                }
            }
        }

        Rectangle {
            width: parent.width/3
            height: parent.height/2
            color: "transparent"
            anchors {
                right: parent.right
                rightMargin: 10
                top: topContainer.bottom
                leftMargin: 10
            }

            Column {
                id: settingTwo
                anchors.fill: parent
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"
                    RowLayout{
                        anchors.fill: parent
                        SGStatusLight{
                            id: lthrm
                            label: "LTHRM"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30

                        }
                        SGStatusLight{
                            id: llow
                            label: "LLOW"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }
                        SGStatusLight{
                            id: lhigh
                            label: "LHIGH"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }
                    }
                }
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"

                    SGSlider {
                        id: locallimitSlider
                        anchors.centerIn: parent
                        fontSize: ratioCalc * 20
                        label: "<b> Local Low Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width:  parent.width/1.5                   // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        value: platformInterface.nct72_get_int_low_lim.value               // Default: average of from and to
                        endLabel: "127°c"            // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        onMoved: {
                            platformInterface.set_int_low_lim.update(value)
                        }

                    }

                }
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"

                    SGSlider {
                        id: localhighSlider
                        anchors.centerIn: parent
                        fontSize: ratioCalc * 20
                        label: "<b> Local High Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width:  parent.width/1.5                  // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        value: 10

                        endLabel: "127°c"            // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false

                        property var high_limit_notification: platformInterface.get_int_high_lim.value
                        onHigh_limit_notificationChanged: {
                            value = high_limit_notification
                        }

                        onMoved: {
                            platformInterface.set_int_high_lim.update(value)
                        }


                    }
                }
                Rectangle {
                    width: parent.width
                    height: parent.height/6
                    color: "transparent"

                    SGSlider {
                        id: localthermSlider
                        anchors.centerIn: parent
                        fontSize: ratioCalc * 20
                        label: "<b> Local THERM Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width: parent.width/1.5                 // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        value: 20                 // Default: average of from and to
                        endLabel: "255°c"            // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        property var therm_int_notification: platformInterface.therm_int
                        onTherm_int_notificationChanged: {
                            value = platformInterface.therm_int
                        }

                        onMoved:{
                            platformInterface.set_int_therm_limit.update(value)
                        }

                    }
                }
            }
        }
    }
}

