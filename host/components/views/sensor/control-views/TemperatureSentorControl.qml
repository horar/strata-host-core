import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help



Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height
    property var pwmArray: []

    property var remote_low_limit_caption: platformInterface.nct72_remote_low_limit.caption
    onRemote_low_limit_captionChanged: {
        lowlimitSlider.label = remote_low_limit_caption
    }

    property var change_remote_low_limit_caption: platformInterface.nct72_remote_low_limit_caption.caption
    onChange_remote_low_limit_captionChanged: {
        lowlimitSlider.label = change_remote_low_limit_caption
    }

    property var remote_low_limit_value: platformInterface.nct72_remote_low_limit.value
    onRemote_low_limit_valueChanged: {
        lowlimitSlider.value = remote_low_limit_value
    }

    //    property var change_remote_low_limit_value: platformInterface.nct72_remote_low_limit_value.value
    //    onChange_remote_low_limit_valueChanged: {
    //        lowlimitSlider.value = change_remote_low_limit_value
    //    }

    property var remote_low_limit_state: platformInterface.nct72_remote_low_limit.state
    onRemote_low_limit_stateChanged: {
        if(remote_low_limit_state === "enabled"){
            lowlimitSlider.enabled = true
        }
        else if(remote_low_limit_state === "disabled"){
            lowlimitSlider.enabled = false
        }
        else {
            lowlimitSlider.enabled = false
            lowlimitSlider.opacity = 0.5
        }
    }

    property var change_remote_low_limit_state: platformInterface.nct72_remote_low_limit_state.state
    onChange_remote_low_limit_stateChanged: {
        if(change_remote_low_limit_state === "enabled"){
            lowlimitSlider.enabled = true
        }
        else if(change_remote_low_limit_state === "disabled"){
            lowlimitSlider.enabled = false
        }
        else {
            lowlimitSlider.enabled = false
            lowlimitSlider.opacity = 0.5
        }
    }

    property var remote_low_limit_scales: platformInterface.nct72_remote_low_limit.scales
    onRemote_low_limit_scalesChanged: {
        lowlimitSlider.endLabel = remote_low_limit_scales[0]
        lowlimitSlider.startLabel = remote_low_limit_scales[1]
        lowlimitSlider.from = remote_low_limit_scales[1]
        lowlimitSlider.to = remote_low_limit_scales[0]
        lowlimitSlider.stepSize  = remote_low_limit_scales[2]
        for(var i = 0; i < fractionComboBox1.model.length; ++i) {
            if(remote_low_limit_scales[2].toString() === fractionComboBox1.model[i]) {
                console.log("sakjd",parseInt(remote_low_limit_scales[2] ))
                fractionComboBox1.currentIndex = i
            }
        }

    }

    /*Notification:
      {"cmd":"nct72_range_value","payload":{"value":"0_127"}}
    */
    //Notification nct72_remote_high_limit_scales
    property var change_remote_high_limit_scales: platformInterface.nct72_remote_high_limit_scales.scales
    onChange_remote_high_limit_scalesChanged: {
        highlimitSlider.endLabel = change_remote_high_limit_scales[0]
        highlimitSlider.startLabel = change_remote_high_limit_scales[1]
        highlimitSlider.from = change_remote_high_limit_scales[1]
        highlimitSlider.to = change_remote_high_limit_scales[0]
        highlimitSlider.stepSize  = change_remote_high_limit_scales[2]
        for(var i = 0; i < fractionComboBox2.model.length; ++i) {
            if(change_remote_high_limit_scales[2].toString() === fractionComboBox2.model[i]) {
                fractionComboBox2.currentIndex = i
            }
        }

    }

    //Notification nct72_remote_low_limit_scales
    property var change_remote_low_limit_scales: platformInterface.nct72_remote_low_limit_scales.scales
    onChange_remote_low_limit_scalesChanged: {
        lowlimitSlider.endLabel = change_remote_low_limit_scales[0]
        lowlimitSlider.startLabel = change_remote_low_limit_scales[1]
        lowlimitSlider.from = change_remote_low_limit_scales[1]
        lowlimitSlider.to = change_remote_low_limit_scales[0]
        lowlimitSlider.stepSize = change_remote_low_limit_scales[2]
        for(var i = 0; i < fractionComboBox1.model.length; ++i) {
            if(change_remote_low_limit_scales[2].toString() === fractionComboBox1.model[i]) {
                fractionComboBox1.currentIndex = i

            }
        }
    }

    //Notification nct72_local_low_limit_scales
    property var change_local_low_limit_scales: platformInterface.nct72_local_low_limit_scales.scales
    onChange_local_low_limit_scalesChanged: {
        locallimitSlider.endLabel = change_local_low_limit_scales[0]
        locallimitSlider.startLabel = change_local_low_limit_scales[1]
        locallimitSlider.from = change_local_low_limit_scales[1]
        locallimitSlider.to = change_local_low_limit_scales[0]
        locallimitSlider.stepSize = change_local_low_limit_scales[2]
    }

    property var change_local_high_limit_scales: platformInterface.nct72_local_high_limit_scales.scales
    onChange_local_high_limit_scalesChanged: {
        localhighSlider.endLabel = change_local_high_limit_scales[0]
        localhighSlider.startLabel = change_local_high_limit_scales[1]
        localhighSlider.from = change_local_high_limit_scales[1]
        localhighSlider.to = change_local_high_limit_scales[0]
        localhighSlider.stepSize = change_local_high_limit_scales[2]
    }

    //control state alert therm2
    property var alert_therm2_caption: platformInterface.nct72_alert_therm2.caption
    onAlert_therm2_captionChanged: {
        alertAndTherm.label = alert_therm2_caption
    }

    property var change_alert_therm2_caption: platformInterface.nct72_alert_therm2_caption.caption
    onChange_alert_therm2_captionChanged: {
        alertAndTherm.label = change_alert_therm2_caption
    }

    property var alert_therm2_state: platformInterface.nct72_alert_therm2.state
    onAlert_therm2_stateChanged: {
        if(alert_therm2_state === "enabled"){
            alertAndTherm.enabled = true
        }
        else if(alert_therm2_state === "disabled"){
            alertAndTherm.enabled = false
        }
        else {
            alertAndTherm.enabled = false
            alertAndTherm.opacity = 0.5
        }
    }

    property var change_alert_therm2_state: platformInterface.nct72_alert_therm2_state.state
    onChange_alert_therm2_stateChanged: {
        if(change_alert_therm2_state === "enabled"){
            alertAndTherm.enabled = true
        }
        else if(change_alert_therm2_state === "disabled"){
            alertAndTherm.enabled = false
        }
        else {
            alertAndTherm.enabled = false
            alertAndTherm.opacity = 0.5
        }
    }

    property var nct72_cons_alert_caption: platformInterface.nct72_cons_alert.caption
    onNct72_cons_alert_captionChanged: {
        consecutiveAlert.label = nct72_cons_alert_caption
    }

    property var change_nct72_cons_alert_caption: platformInterface.nct72_cons_alert_caption.caption
    onChange_nct72_cons_alert_captionChanged: {
        consecutiveAlert.label = change_nct72_cons_alert_caption
    }

    property var nct72_cons_alert_value: platformInterface.nct72_cons_alert.value
    onNct72_cons_alert_valueChanged: {
        for(var i = 0; i < consecutiveAlert.model.length; ++i) {
            if(nct72_cons_alert_value === consecutiveAlert.model[i]) {
                consecutiveAlert.currentIndex = i
            }
        }
    }

    property var change_nct72_cons_alert_value: platformInterface.nct72_cons_alert_value.value
    onChange_nct72_cons_alert_valueChanged: {
        for(var i = 0; i < consecutiveAlert.model.length; ++i) {
            if(change_nct72_cons_alert_value === consecutiveAlert.model[i]) {
                consecutiveAlert.currentIndex = i
            }
        }
    }

    property var nct72_cons_alert_state: platformInterface.nct72_cons_alert.state
    onNct72_cons_alert_stateChanged: {
        if(nct72_cons_alert_state === "enabled"){
            consecutiveAlert.enabled = true
        }
        else if(nct72_cons_alert_state === "disabled"){
            consecutiveAlert.enabled = false
        }
        else {
            consecutiveAlert.enabled = false
            consecutiveAlert.opacity = 0.5
        }
    }

    property var change_cons_alert_state: platformInterface.nct72_cons_alert_state.state
    onChange_cons_alert_stateChanged: {
        if(change_cons_alert_state === "enabled"){
            consecutiveAlert.enabled = true
        }
        else if(change_cons_alert_state === "disabled"){
            consecutiveAlert.enabled = false
        }
        else {
            consecutiveAlert.enabled = false
            consecutiveAlert.opacity = 0.5
        }
    }

    property var cons_alert_scales : platformInterface.nct72_cons_alert.values
    onCons_alert_scalesChanged: {
        consecutiveAlert.model = cons_alert_scales
    }

    property var change_cons_alert_scales: platformInterface.nct72_cons_alert_values.values
    onChange_cons_alert_scalesChanged: {
        consecutiveAlert.model = change_cons_alert_scales
    }

    property var nct72_therm_value: platformInterface.nct72_therm_value.value
    onNct72_therm_valueChanged: {
        if(nct72_therm_value === 1){
            therm.status = "green"
        }
        else  therm.status = "off"
    }

    property var nct72_alert_therm2_value: platformInterface.nct72_alert_therm2_value.value
    onNct72_alert_therm2_valueChanged: {
        if(nct72_alert_therm2_value === 1){
            alertAndTherm.status = "green"
        }
        else  alertAndTherm.status = "off"
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
                        tickmarkStepSize: 20
                        outerColor: "#999"
                        unitLabel: "°c"
                        decimal: 2
                        gaugeTitleSize: 20 * ratioCalc
                        property var remoteTemp: platformInterface.nct72_remote_temp_value.value
                        onRemoteTempChanged: {
                            value = remoteTemp
                        }

                        property var nct72_remote_temp_caption: platformInterface.nct72_remote_temp.caption
                        onNct72_remote_temp_captionChanged: {
                            remotetempGauge.gaugeTitle = nct72_remote_temp_caption
                        }

                        property var nct72_remote_temp_value: platformInterface.nct72_remote_temp.value
                        onNct72_remote_temp_valueChanged: {
                            remotetempGauge.value = nct72_remote_temp_value
                        }


                        property var nct72_remote_temp_state: platformInterface.nct72_remote_temp.state
                        onNct72_remote_temp_stateChanged: {
                            if(nct72_remote_temp_state === "enabled"){
                                remotetempGauge.enabled = true
                                remotetempGauge.opacity = 1.0
                            }
                            else if (nct72_remote_temp_state === "disabled"){
                                remotetempGauge.enabled = false
                                remotetempGauge.opacity = 1.0

                            }
                            else {
                                remotetempGauge.opacity = 0.5
                                remotetempGauge.enabled = false
                            }
                        }

                        property var nct72_remote_temp_scales: platformInterface.nct72_remote_temp.scales
                        onNct72_remote_temp_scalesChanged: {
                            remotetempGauge.maximumValue = nct72_remote_temp_scales[0]
                            remotetempGauge.minimumValue = nct72_remote_temp_scales[1]
                        }

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
                    model: ["0"]


                    property var nct72_pwm_temp_remote_value: platformInterface.nct72_pwm_temp_remote.value
                    onNct72_pwm_temp_remote_valueChanged: {
                        for(var i = 0; i < pwmDutyCycle1.model.length; ++i ){
                            if( pwmDutyCycle1.model[i].toString() === nct72_pwm_temp_remote_value)
                            {
                                currentIndex = i
                                return;
                            }

                        }
                    }

                    property var nct72_pwm_temp_remote_values: platformInterface.nct72_pwm_temp_remote.values
                    onNct72_pwm_temp_remote_valuesChanged: {
                        pwmDutyCycle1.model = nct72_pwm_temp_remote_values
                    }

                    onActivated: {
                        platformInterface.nct72_pwm_temp_remote_value.update(currentText)

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
                            property var nct72_one_shot_caption: platformInterface.nct72_one_shot.caption
                            onNct72_one_shot_captionChanged: {
                                oneShot.text = nct72_one_shot_caption
                            }

                            property var nct72_one_shot_state: platformInterface.nct72_one_shot.state
                            onNct72_one_shot_stateChanged: {
                                if(nct72_one_shot_state === "enabled"){
                                    oneShot.enabled = true
                                    oneShot.opacity = 1.0
                                }
                                else if (nct72_one_shot_state === "disabled"){
                                    oneShot.enabled = false
                                    oneShot.opacity = 1.0

                                }
                                else {
                                    oneShot.opacity = 0.5
                                    oneShot.enabled = false
                                }
                            }




                            Button{
                                id: oneShot
                                width: 150 * ratioCalc
                                height: 50 * ratioCalc
                                //text: qsTr("One-shot")
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    platformInterface.one_shot.update()
                                }
                            }

                            property var nct72_busy_value: platformInterface.nct72_busy.value
                            onNct72_busy_valueChanged: {
                                if(nct72_busy_value === "0")
                                    busy.status = "off"
                                else busy.status = "red"
                            }

                            property var nct72_busy_caption: platformInterface.nct72_busy.caption
                            onNct72_busy_captionChanged: {
                                busy.label = nct72_busy_caption
                            }

                            property var nct72_busy_state: platformInterface.nct72_busy.state
                            onNct72_busy_stateChanged: {
                                if(nct72_busy_state === "enabled"){
                                    busy.enabled = true
                                    busy.opacity = 1.0
                                }
                                else if (nct72_busy_state === "disabled"){
                                    busy.enabled = false
                                    busy.opacity = 1.0

                                }
                                else {
                                    busy.opacity = 0.5
                                    busy.enabled = false
                                }
                            }

                            SGStatusLight{
                                id: busy
                                fontSize: ratioCalc * 20
                                Layout.alignment: Qt.AlignCenter
                                lightSize: ratioCalc * 30
                            }

                            property var nct72_therm_value: platformInterface.nct72_therm.value
                            onNct72_therm_valueChanged: {
                                if(nct72_therm_value === "0")
                                    therm.status = "off"
                                else therm.status = "red"
                            }

                            property var nct72_therm_caption: platformInterface.nct72_therm.caption
                            onNct72_therm_captionChanged: {
                                therm.label = "THERM"
                            }

                            property var nct72_therm_state: platformInterface.nct72_therm.state
                            onNct72_therm_stateChanged: {
                                if(nct72_therm_state === "enabled"){
                                    therm.enabled = true
                                    therm.opacity = 1.0
                                }
                                else if (nct72_therm_state === "disabled"){
                                    therm.enabled = false
                                    therm.opacity = 1.0

                                }
                                else {
                                    therm.opacity = 0.5
                                    therm.enabled = false
                                }
                            }

                            SGStatusLight{
                                id: therm
                                label: "THERM"
                                fontSize: ratioCalc * 20
                                Layout.alignment: Qt.AlignCenter
                                lightSize: ratioCalc * 30
                            }
                            SGStatusLight{
                                id: alertAndTherm
                                //label: "ALERT or \n THERM2"
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

                            property var nct72_mode_caption: platformInterface.nct72_mode.caption
                            onNct72_mode_captionChanged: {
                                mode.label = nct72_mode_caption
                            }



                            property var nct72_mode_state: platformInterface.nct72_mode.state
                            onNct72_mode_stateChanged: {
                                if(nct72_mode_state === "enabled"){
                                    mode.enabled = true
                                    mode.opacity = 1.0
                                }
                                else if (nct72_mode_state === "disabled"){
                                    mode.enabled = false
                                    mode.opacity = 1.0

                                }
                                else {
                                    mode.opacity = 0.5
                                    mode.enabled = false
                                }
                            }


                            SGRadioButtonContainer {
                                id: mode
                                //label: "Mode:" // Default: "" (will not appear if not entered)
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
                                    property alias run_alias : run
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

                                    property var nct72_mode_value: platformInterface.nct72_mode.value
                                    onNct72_mode_valueChanged: {
                                        if(nct72_mode_value === "Run")
                                            run_alias.checked = true

                                        else  standby.checked = true
                                    }

                                    SGRadioButton {
                                        id: run
                                        text: "Run"
                                        checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.nct72_mode_value.update("Run")
                                            }
                                            else  {
                                                platformInterface.nct72_mode_value.update("Standby")
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

                            property var nct72_alert_caption: platformInterface.nct72_alert.caption
                            onNct72_alert_captionChanged: {
                                alertButton.label = nct72_alert_caption
                            }

                            property var nct72_alert_state: platformInterface.nct72_alert.state
                            onNct72_alert_stateChanged: {
                                if(nct72_alert_state === "enabled"){
                                    alertButton.enabled = true
                                    alertButton.opacity = 1.0
                                }
                                else if (nct72_alert_state === "disabled"){
                                    alertButton.enabled = false
                                    alertButton.opacity = 1.0

                                }
                                else {
                                    alertButton.opacity = 0.5
                                    alertButton.enabled = false
                                }
                            }

                            SGRadioButtonContainer {
                                id: alertButton
                                //label: "ALERT#: " // Default: "" (will not appear if not entered)
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

                                    property var nct72_alert_value: platformInterface.nct72_alert.value
                                    onNct72_alert_valueChanged: {
                                        if(nct72_alert_value === "Enabled")
                                            enabled.checked = true

                                        else  masked.checked = true
                                    }


                                    SGRadioButton {
                                        id: enabled
                                        text: "Enabled"
                                        //checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.nct72_alert_value.update("Enabled")
                                            }
                                            else  {
                                                platformInterface.nct72_alert_value.update("Masked")
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

                        property var nct72_pin6_caption: platformInterface.nct72_pin6.caption
                        onNct72_pin6_captionChanged: {
                            pinButton.label = nct72_pin6_caption
                        }

                        property var nct72_pin6_state: platformInterface.nct72_pin6.state
                        onNct72_pin6_stateChanged: {
                            if(nct72_pin6_state === "enabled"){
                                pinButton.enabled = true
                                pinButton.opacity = 1.0
                            }
                            else if (nct72_pin6_state === "disabled"){
                                pinButton.enabled = false
                                pinButton.opacity = 1.0

                            }
                            else {
                                pinButton.opacity = 0.5
                                pinButton.enabled = false
                            }
                        }

                        RowLayout{
                            anchors.fill: parent
                            anchors.left: parent.left
                            anchors.leftMargin: 20

                            SGRadioButtonContainer {
                                id: pinButton
                                //label: "Pin 6" // Default: "" (will not appear if not entered)
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

                                    property alias alertNum : alertNum
                                    property alias thermalNum : thermalNum

                                    property var get_config_ALERT_THERM2_notification: platformInterface.nct72_get_config.ALERT_THERM2
                                    onGet_config_ALERT_THERM2_notificationChanged: {
                                        if(get_config_ALERT_THERM2_notification === 0){
                                            alertNum.checked = true
                                        }
                                        else {
                                            thermalNum.checked = true
                                        }
                                    }

                                    property var nct72_pin6_value: platformInterface.nct72_pin6.value
                                    onNct72_pin6_valueChanged: {
                                        if(nct72_pin6_value === "ALERT#")
                                           alertNum.checked = true

                                        else  thermalNum.checked = true
                                    }

                                    SGRadioButton {
                                        id: alertNum
                                        text: "ALERT#"
                                        checked: true
                                        onCheckedChanged:  {
                                            if(checked) {
                                                platformInterface.nct72_alert_therm2_ratioButton.update("0")
                                            }
                                            else  {
                                                platformInterface.nct72_alert_therm2_ratioButton.update("1")
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

                            property var nct72_range_caption: platformInterface.nct72_range.caption
                            onNct72_range_captionChanged: {
                                rangeButton.label = nct72_range_caption
                            }



                            SGRadioButtonContainer {
                                id: rangeButton
                                //label: "Range" // Default: "" (will not appear if not entered)
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

                                    property var nct72_range_value: platformInterface.nct72_range.value
                                    onNct72_range_valueChanged: {
                                        if(nct72_range_value === "0_127")
                                            rangeNum1.checked = true
                                        else rangeNum2.checked = true
                                    }


                                    SGRadioButton {
                                        id: rangeNum1
                                        text: "0 to 127°c"
                                        checked: true
                                        onCheckedChanged: {
                                            if(checked){
                                                platformInterface.nct72_range_value.update("0_127")
                                            }
                                            else {
                                                platformInterface.nct72_range_value.update("-64_191")

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
                                fontSize: 20 * ratioCalc

                                onActivated: {
                                    platformInterface.nct72_cons_alert_slider.update(currentText)
                                    platformInterface.nct72_cons_alert_slider.show()
                                }



                            }

                            property var nct72_conv_rate_caption: platformInterface.nct72_conv_rate.caption
                            onNct72_conv_rate_captionChanged:  {
                                conversionInterval.label = nct72_conv_rate_caption
                            }

                            property var nct72_conv_rate_values: platformInterface.nct72_conv_rate.values
                            onNct72_conv_rate_valuesChanged: {
                                conversionInterval.model = nct72_conv_rate_values
                            }
                            property var nct72_conv_rate_value: platformInterface.nct72_conv_rate.value
                            onNct72_conv_rate_valueChanged: {
                                if(conversionInterval.model.length !== "undefined") {
                                    for(var i = 0; i < conversionInterval.model.length; ++i ){
                                        if( conversionInterval.model[i].toString() === nct72_conv_rate_value)
                                        {
                                            conversionInterval.currentIndex = i
                                            return;
                                        }

                                    }
                                }
                            }

                            SGComboBox {
                                id: conversionInterval
                                Layout.alignment: Qt.AlignCenter
                                comboBoxWidth:ratioCalc * 100
                                comboBoxHeight: ratioCalc * 30
                                fontSize: 20 * ratioCalc
                                onActivated: platformInterface.nct72_conv_rate_value.update(currentText)

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
                                //label: "<b>THERM \n Hysteresis:</b>"         // Default: "" (if not entered, label will not appear)
                                textColor: "black"           // Default: "black"
                                labelLeft: false             // Default: true
                                width: 500                   // Default: 200
                                /*     stepSize: 1.0                // Default: 1.0
                                value: 10            // Default: average of from and to
                                from: 0                      // Default: 0.0
                                to: 255  */                  // Default: 100.0
                                startLabel: "0°c"              // Default: from
                                endLabel: "255°c"            // Default: to
                                showToolTip: true            // Default: true
                                toolTipDecimalPlaces: 0      // Default: 0
                                grooveColor: "#ddd"          // Default: "#dddddd"
                                grooveFillColor: "lightgreen"// Default: "#888888"
                                live: false                  // Default: false (will only send valueChanged signal when slider is released)
                                //                                property var therm_hyst_notification: platformInterface.therm_hyst
                                //                                onTherm_hyst_notificationChanged: {
                                //                                    value = therm_hyst_notification
                                //

                                property var nct72_therm_hyst_caption: platformInterface.nct72_therm_hyst.caption
                                onNct72_therm_hyst_captionChanged: {
                                    sgSlider.label = nct72_therm_hyst_caption
                                }
                                property var nct72_therm_hyst_value: platformInterface.nct72_therm_hyst.value
                                onNct72_therm_hyst_valueChanged: {
                                    sgSlider.value = nct72_therm_hyst_value
                                }
                                property var nct72_therm_hyst_scales: platformInterface.nct72_therm_hyst.scales
                                onNct72_therm_hyst_scalesChanged: {
                                    sgSlider.endLabel = nct72_therm_hyst_scales[0]
                                    sgSlider.startLabel = nct72_therm_hyst_scales[1]
                                    sgSlider.from = nct72_therm_hyst_scales[1]
                                    sgSlider.to = nct72_therm_hyst_scales[0]
                                    sgSlider.stepSize = nct72_therm_hyst_scales[2]
                                }


                                onMoved: {
                                    platformInterface.nct72_therm_hyst_value.update(value.toFixed(2))
                                }

                            }
                            SGLabelledInfoBox{
                                id:manufacturerId
                                fontSize: ratioCalc * 18
                                Layout.alignment: Qt.AlignCenter
                                label: "Maufacture ID"
                                unit: ""
                                info: platformInterface.nct72_get_man_id.id
                                //infoBoxBorderWidth: ratioCalc * 100
                                infoBoxWidth: ratioCalc * 100
                                infoBoxHeight: ratioCalc * 30

                                property var nct72_man_id_caption: platformInterface.nct72_man_id.caption
                                onNct72_man_id_captionChanged: {
                                    manufacturerId.label = nct72_man_id_caption
                                }
                                property var nct72_man_id_value: platformInterface.nct72_man_id.value
                                onNct72_man_id_valueChanged: {
                                    manufacturerId.info = nct72_man_id_value
                                }
                                property var nct72_man_id_state: platformInterface.nct72_rthrm.state
                                onNct72_man_id_stateChanged: {
                                    if(nct72_man_id_state === "enabled"){
                                        manufacturerId.enabled = true
                                        manufacturerId.opacity = 1.0
                                    }
                                    else if (nct72_man_id_state === "disabled"){
                                        manufacturerId.enabled = false
                                        manufacturerId.opacity = 1.0

                                    }
                                    else {
                                        manufacturerId.opacity = 0.5
                                        manufacturerId.enabled = false
                                    }
                                }


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
                        property var local_temp: platformInterface.nct72_local_temp_value.value
                        onLocal_tempChanged: {
                            value = local_temp
                        }

                        property var nct72_local_temp_caption: platformInterface.nct72_local_temp.caption
                        onNct72_local_temp_captionChanged: {
                            localTempGauge.gaugeTitle = nct72_local_temp_caption
                        }

                        property var nct72_local_temp_value: platformInterface.nct72_local_temp.value
                        onNct72_local_temp_valueChanged: {
                            localTempGauge.value = nct72_local_temp_value
                        }


                        property var nct72_local_temp_state: platformInterface.nct72_local_temp.state
                        onNct72_local_temp_stateChanged: {
                            if(nct72_local_temp_state === "enabled"){
                                localTempGauge.enabled = true
                                localTempGauge.opacity = 1.0
                            }
                            else if (nct72_local_temp_state === "disabled"){
                                localTempGauge.enabled = false
                                localTempGauge.opacity = 1.0

                            }
                            else {
                                localTempGauge.opacity = 0.5
                                localTempGauge.enabled = false
                            }
                        }

                        property var nct72_local_temp_scales: platformInterface.nct72_local_temp.scales
                        onNct72_local_temp_scalesChanged: {
                            localTempGauge.maximumValue = nct72_local_temp_scales[0]
                            localTempGauge.minimumValue = nct72_local_temp_scales[1]
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
                    model: []

                    property var nct72_pwm_temp_local_value: platformInterface.nct72_pwm_temp_local.value
                    onNct72_pwm_temp_local_valueChanged: {
                        if(pwmDutyCycle2.model.length !== "undefined") {
                            for(var i = 0; i < pwmDutyCycle2.model.length; ++i ){
                                if( pwmDutyCycle2.model[i].toString() === nct72_pwm_temp_local_value)
                                {
                                    currentIndex = i
                                    return;
                                }

                            }
                        }
                    }

                    property var nct72_pwm_temp_local_values: platformInterface.nct72_pwm_temp_local.values
                    onNct72_pwm_temp_local_valuesChanged: {
                        pwmDutyCycle2.model = nct72_pwm_temp_local_values
                    }

                    onActivated: {
                        platformInterface.nct72_pwm_temp_local_value.update(currentText)

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

                        property var nct72_rthrm_caption: platformInterface.nct72_rthrm.caption
                        onNct72_rthrm_captionChanged: {
                            rthrm.label = nct72_rthrm_caption
                        }

                        property var nct72_rthrm_value: platformInterface.nct72_rthrm.value
                        onNct72_rthrm_valueChanged: {
                            if(nct72_rthrm_value === "0") {
                                rthrm.status = "red"
                            }
                            else  rthrm.status = "green"
                        }

                        property var nct72_rthrm_state: platformInterface.nct72_rthrm.state
                        onNct72_rthrm_stateChanged: {
                            if(nct72_rthrm_state === "enabled"){
                                rthrm.enabled = true
                                rthrm.opacity = 1.0
                            }
                            else if (nct72_rthrm_state === "disabled"){
                                rthrm.enabled = false
                                rthrm.opacity = 1.0

                            }
                            else {
                                rthrm.opacity = 0.5
                                rthrm.enabled = false
                            }
                        }

                        SGStatusLight{
                            id: rthrm
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }

                        property var nct72_rlow_caption: platformInterface.nct72_rlow.caption
                        onNct72_rlow_captionChanged: {
                            rlow.label = nct72_rlow_caption
                        }

                        property var nct72_rlow_value: platformInterface.nct72_rlow.value
                        onNct72_rlow_valueChanged: {
                            if(nct72_rlow_value ==="0") {
                                rlow.status = "red"
                            }
                            else  rlow.status = "green"
                        }

                        property var nct72_rlow_state: platformInterface.nct72_rlow.state
                        onNct72_rlow_stateChanged: {
                            if(nct72_rlow_state === "enabled"){
                                rlow.enabled = true
                                rlow.opacity = 1.0
                            }
                            else if (nct72_rlow_state === "disabled"){
                                rlow.enabled = false
                                rlow.opacity = 1.0
                            }
                            else {
                                rlow.opacity = 0.5
                                rlow.enabled = false
                            }
                        }

                        SGStatusLight{
                            id: rlow
                            label: "RLOW"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }

                        property var nct72_rhigh_caption: platformInterface.nct72_rhigh.caption
                        onNct72_rhigh_captionChanged: {
                            rhigh.label = nct72_rhigh_caption
                        }

                        property var nct72_rhigh_value: platformInterface.nct72_rhigh.value
                        onNct72_rhigh_valueChanged: {
                            if(nct72_rhigh_value === "0") {
                                rhigh.status = "red"
                            }
                            else  rhigh.status = "green"
                        }

                        property var nct72_rhigh_state: platformInterface.nct72_rhigh.state
                        onNct72_rhigh_stateChanged: {
                            if(nct72_rhigh_state === "enabled"){
                                rhigh.enabled = true
                                rhigh.opacity = 1.0
                            }
                            else if (nct72_rhigh_state === "disabled"){
                                rhigh.enabled = false
                                rhigh.opacity = 1.0
                            }
                            else {
                                rhigh.opacity = 0.5
                                rhigh.enabled = false
                            }
                        }

                        SGStatusLight{
                            id: rhigh
                            label: "RHIGH"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }

                        property var nct72_open_caption: platformInterface.nct72_open.caption
                        onNct72_open_captionChanged: {
                            open.label = nct72_open_caption
                        }

                        property var nct72_open_value: platformInterface.nct72_open.value
                        onNct72_open_valueChanged: {
                            if(nct72_open_value === "0") {
                                open.status = "red"
                            }
                            else  open.status = "green"
                        }

                        property var nct72_open_state: platformInterface.nct72_open.state
                        onNct72_open_stateChanged: {
                            if(nct72_open_state === "enabled"){
                                open.enabled = true
                                open.opacity = 1.0
                            }
                            else if (nct72_rhigh_state === "disabled"){
                                open.enabled = false
                                open.opacity = 1.0
                            }
                            else {
                                open.opacity = 0.5
                                open.enabled = false
                            }
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
                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width: parent.width                  // Default: 200
                            stepSize: 1.0
                            endLabel: "127°c"            // Default: to
                            showToolTip: true            // Default: true
                            toolTipDecimalPlaces: 0      // Default: 0
                            grooveColor: "#ddd"          // Default: "#dddddd"
                            grooveFillColor: "lightgreen"// Default: "#888888"
                            live: false

                            onMoved: {
                                platformInterface.nct72_remote_low_limit_value.update(value.toString())
                            }


                        }
                        SGComboBox {
                            id: fractionComboBox1
                            comboBoxWidth:ratioCalc * 70
                            comboBoxHeight: ratioCalc * 30
                            fontSize: 20 * ratioCalc
                            //model: ["0.0", "0.25", "0.5", "0.75"]

                            property var nct72_remote_low_limit_frac_values: platformInterface.nct72_remote_low_limit_frac.values
                            onNct72_remote_low_limit_frac_valuesChanged: {
                                fractionComboBox1.model = nct72_remote_low_limit_frac_values
                            }

                            property var nct72_remote_low_limit_frac_value: platformInterface.nct72_remote_low_limit_frac.value
                            onNct72_remote_low_limit_frac_valueChanged: {
                                for(var i = 0; i < fractionComboBox1.model.length; ++i ){
                                    if( fractionComboBox1.model[i] === nct72_remote_low_limit_frac_value)
                                    {
                                        fractionComboBox1.currentIndex = i
                                        return;
                                    }
                                }
                            }

                            onActivated: {
                                platformInterface.nct72_remote_low_limit_frac_value.update(currentText)
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
                            //label: "<b> Remote High Limit:</b>"         // Default: "" (if not entered, label will not appear)
                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width:  parent.width                   // Default: 200
                            stepSize: 1.0                // Default: 1.0
                            //value: 50                 // Default: average of from and to
                            endLabel: "127°c"            // Default: to
                            showToolTip: true            // Default: true
                            toolTipDecimalPlaces: 0      // Default: 0
                            grooveColor: "#ddd"          // Default: "#dddddd"
                            grooveFillColor: "lightgreen"// Default: "#888888"
                            live: false

                            property var nct72_remote_high_limit_caption: platformInterface.nct72_remote_high_limit.caption
                            onNct72_remote_high_limit_captionChanged: {
                                highlimitSlider.label = nct72_remote_high_limit_caption
                            }
                            property var nct72_remote_high_limit_value: platformInterface.nct72_remote_high_limit.value
                            onNct72_remote_high_limit_valueChanged: {
                                console.log("inside",nct72_remote_high_limit_value)
                                highlimitSlider.value = nct72_remote_high_limit_value
                                console.log("inside2",highlimitSlider.value)
                            }



                            onMoved: {
                                platformInterface.nct72_remote_high_limit_value.update(value.toString())
                            }

                        }

                        SGComboBox {
                            id: fractionComboBox2
                            comboBoxWidth:ratioCalc * 70
                            comboBoxHeight: ratioCalc * 30
                            fontSize: 20 * ratioCalc

                            // model: ["0.0", "0.25", "0.5", "0.75"]
                            property var nct72_remote_high_limit_frac_values: platformInterface.nct72_remote_high_limit_frac.values
                            onNct72_remote_high_limit_frac_valuesChanged: {
                                fractionComboBox2.model = nct72_remote_high_limit_frac_values
                            }

                            property var nct72_remote_high_limit_frac_value: platformInterface.nct72_remote_high_limit_frac.value
                            onNct72_remote_high_limit_frac_valueChanged: {
                                for(var i = 0; i < fractionComboBox2.model.length; ++i ){
                                    if( fractionComboBox2.model[i].toString() === nct72_remote_high_limit_frac_value)
                                    {
                                        fractionComboBox2.currentIndex = i
                                        return;
                                    }
                                }
                            }
                            onActivated:  {
                                platformInterface.nct72_remote_high_limit_frac_value.update(currentText)
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
                            property var nct72_remote_offset_caption: platformInterface.nct72_remote_offset.caption
                            onNct72_remote_offset_captionChanged: {
                                offsetSlider.label = nct72_remote_offset_caption
                            }
                            property var nct72_remote_offset_value: platformInterface.nct72_remote_offset.value
                            onNct72_remote_offset_valueChanged: {
                                offsetSlider.value = nct72_remote_offset_value
                            }
                            property var nct72_remote_offset_scales: platformInterface.nct72_remote_offset.scales
                            onNct72_remote_offset_scalesChanged: {
                                offsetSlider.endLabel = nct72_remote_offset_scales[0]
                                offsetSlider.startLabel = nct72_remote_offset_scales[1]
                                offsetSlider.from = nct72_remote_offset_scales[1]
                                offsetSlider.to = nct72_remote_offset_scales[0]
                                offsetSlider.stepSize = nct72_remote_offset_scales[2]
                            }


                            textColor: "black"           // Default: "black"
                            labelLeft: false             // Default: true
                            width:  parent.width                   // Default: 200
                            stepSize: 1.0                // Default: 1.0
                            /*  value: platformInterface.nct72_get_ext_offset.integer       */          // Default: average of from and to
                            //                            endLabel: "127°c"            // Default: to
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

                            property var nct72_remote_offset_frac_values: platformInterface.nct72_remote_offset_frac.values
                            onNct72_remote_offset_frac_valuesChanged: {
                                fractionComboBox3.model = nct72_remote_offset_frac_values
                            }

                            property var nct72_remote_offset_frac_value: platformInterface.nct72_remote_offset_frac.value
                            onNct72_remote_offset_frac_valueChanged: {
                                for(var i = 0; i < fractionComboBox3.model.length; ++i){
                                    if( fractionComboBox3.model[i].toString() === nct72_remote_offset_frac_value)
                                    {
                                        fractionComboBox3.currentIndex = i
                                        return;
                                    }
                                }
                            }
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
                        //label: "<b> Remote THERM Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width: parent.width/2                 // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        property var nct72_remote_therm_limit_caption: platformInterface.nct72_remote_therm_limit.caption
                        onNct72_remote_therm_limit_captionChanged: {
                            thermSlider.label = nct72_remote_therm_limit_caption
                        }
                        property var nct72_remote_therm_limit_value: platformInterface.nct72_remote_therm_limit.value
                        onNct72_remote_therm_limit_valueChanged: {
                            thermSlider.value = nct72_remote_therm_limit_value
                        }
                        property var nct72_therm_limit_scales: platformInterface.nct72_remote_therm_limit.scales
                        onNct72_therm_limit_scalesChanged: {
                            thermSlider.endLabel = nct72_therm_limit_scales[0]
                            thermSlider.startLabel = nct72_therm_limit_scales[1]
                            thermSlider.from = nct72_therm_limit_scales[1]
                            thermSlider.to = nct72_therm_limit_scales[0]
                            thermSlider.stepSize = nct72_therm_limit_scales[2]
                        }


                        onMoved: {
                            platformInterface.nct72_remote_therm_limit_value.update(value.toString())

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
                        property var nct72_lthrm_caption: platformInterface.nct72_lthrm.caption
                        onNct72_lthrm_captionChanged: {
                            lthrm.label = nct72_lthrm_caption
                        }

                        property var nct72_lthrm_value: platformInterface.nct72_lthrm.value
                        onNct72_lthrm_valueChanged: {

                            if(nct72_lthrm_value === "0") {
                                console.log("tanya",nct72_lthrm_value)
                                lthrm.status = "red"
                            }
                            else  lthrm.status = "green"
                        }

                        property var nct72_lthrm_state: platformInterface.nct72_lthrm.state
                        onNct72_lthrm_stateChanged: {
                            if(nct72_lthrm_state === "enabled"){
                                lthrm.enabled = true
                                lthrm.opacity = 1.0
                            }
                            else if (nct72_lthrm_state === "disabled"){
                                lthrm.enabled = false
                                lthrm.opacity = 1.0

                            }
                            else {
                                lthrm.opacity = 0.5
                                lthrm.enabled = false
                            }
                        }

                        SGStatusLight{
                            id: lthrm
                            label: "LTHRM"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30

                        }

                        property var nct72_llow_caption: platformInterface.nct72_llow.caption
                        onNct72_llow_captionChanged: {
                            llow.label = nct72_llow_caption
                        }

                        property var nct72_llow_value: platformInterface.nct72_llow.value
                        onNct72_llow_valueChanged: {
                            if(nct72_llow_value === "0") {
                                llow.status = "red"
                            }
                            else  llow.status = "green"
                        }

                        property var nct72_llow_state: platformInterface.nct72_llow.state
                        onNct72_llow_stateChanged: {
                            if(nct72_llow_state === "enabled"){
                                llow.enabled = true
                                llow.opacity = 1.0
                            }
                            else if (nct72_lhigh_state === "disabled"){
                                llow.enabled = false
                                llow.opacity = 1.0

                            }
                            else {
                                llow.opacity = 0.5
                                llow.enabled = false
                            }
                        }

                        SGStatusLight{
                            id: llow
                            label: "LLOW"
                            fontSize: ratioCalc * 20
                            Layout.alignment: Qt.AlignCenter
                            lightSize: ratioCalc * 30
                        }

                        property var nct72_lhigh_caption: platformInterface.nct72_lhigh.caption
                        onNct72_lhigh_captionChanged: {
                            lhigh.label = nct72_lhigh_caption
                        }

                        property var nct72_lhigh_value: platformInterface.nct72_lhigh.value
                        onNct72_lhigh_valueChanged: {
                            if(nct72_lhigh_value === "0") {
                                lhigh.status = "red"
                            }
                            else  lhigh.status = "green"
                        }

                        property var nct72_lhigh_state: platformInterface.nct72_lhigh.state
                        onNct72_lhigh_stateChanged: {
                            if(nct72_lhigh_state === "enabled"){
                                lhigh.enabled = true
                                lhigh.opacity = 1.0
                            }
                            else if (nct72_lhigh_state === "disabled"){
                                lhigh.enabled = false
                                lhigh.opacity = 1.0

                            }
                            else {
                                lhigh.opacity = 0.5
                                lhigh.enabled = false
                            }
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
                        //label: "<b> Local Low Limit:</b>"         // Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width:  parent.width/1.5                   // Default: 200
                        stepSize: 1.0                // Default: 1.0
                        //value: platformInterface.nct72_get_int_low_lim.value               // Default: average of from and to
                        endLabel: "127°c"            // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        onMoved: {
                            platformInterface.nct72_local_low_limit_value.update(value.toString())
                        }
                        property var nct72_local_low_limit_caption: platformInterface.nct72_local_low_limit.caption
                        onNct72_local_low_limit_captionChanged: {
                            locallimitSlider.label = nct72_local_low_limit_caption
                        }
                        property var nct72_local_low_limit_value: platformInterface.nct72_local_low_limit.value
                        onNct72_local_low_limit_valueChanged: {
                            locallimitSlider.value = nct72_local_low_limit_value
                        }
                        property var nct72_local_low_limit_scales: platformInterface.nct72_local_low_limit.scales
                        onNct72_local_low_limit_scalesChanged: {
                            locallimitSlider.endLabel = nct72_local_low_limit_scales[0]
                            locallimitSlider.startLabel = nct72_local_low_limit_scales[1]
                            locallimitSlider.from = nct72_local_low_limit_scales[1]
                            locallimitSlider.to = nct72_local_low_limit_scales[0]
                            locallimitSlider.stepSize = nct72_local_low_limit_scales[2]
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
                        //label: "<b> Local High Limit:</b>"         // Default: "" (if not entered, label will not appear)
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

                        onMoved: {
                            platformInterface.nct72_local_high_limit_value.update(value.toString())
                        }

                        property var nct72_local_high_limit_caption: platformInterface.nct72_local_high_limit.caption
                        onNct72_local_high_limit_captionChanged: {
                            localhighSlider.label = nct72_local_high_limit_caption
                        }
                        property var nct72_local_high_limit_value: platformInterface.nct72_local_high_limit.value
                        onNct72_local_high_limit_valueChanged: {
                            localhighSlider.value = nct72_local_high_limit_value
                        }
                        property var nct72_local_high_limit_scales: platformInterface.nct72_local_high_limit.scales
                        onNct72_local_high_limit_scalesChanged: {
                            localhighSlider.endLabel = nct72_local_high_limit_scales[0]
                            localhighSlider.startLabel = nct72_local_high_limit_scales[1]
                            localhighSlider.from = nct72_local_high_limit_scales[1]
                            localhighSlider.to = nct72_local_high_limit_scales[0]
                            localhighSlider.stepSize = nct72_local_high_limit_scales[2]
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
                        /*  label: "<b> Local THERM Limit:</b>"         */// Default: "" (if not entered, label will not appear)
                        textColor: "black"           // Default: "black"
                        labelLeft: false             // Default: true
                        width: parent.width/1.5                 // Default: 200
                        /*     stepSize: 1.0                // Default: 1.0
                        value: 20                 // Default: average of from and to
                        endLabel: "255°c"      */      // Default: to
                        showToolTip: true            // Default: true
                        toolTipDecimalPlaces: 0      // Default: 0
                        grooveColor: "#ddd"          // Default: "#dddddd"
                        grooveFillColor: "lightgreen"// Default: "#888888"
                        live: false
                        property var nct72_local_therm_limit_caption: platformInterface.nct72_local_therm_limit.caption
                        onNct72_local_therm_limit_captionChanged: {
                            localthermSlider.label = nct72_local_therm_limit_caption
                        }
                        property var nct72_local_therm_limit_value: platformInterface.nct72_local_therm_limit.value
                        onNct72_local_therm_limit_valueChanged: {
                            localthermSlider.value = nct72_local_therm_limit_value
                        }
                        property var nct72_local_therm_limit_scales: platformInterface.nct72_local_therm_limit.scales
                        onNct72_local_therm_limit_scalesChanged: {
                            localthermSlider.endLabel = nct72_local_therm_limit_scales[0]
                            localthermSlider.startLabel = nct72_local_therm_limit_scales[1]
                            localthermSlider.from = nct72_local_therm_limit_scales[1]
                            localthermSlider.to = nct72_local_therm_limit_scales[0]
                            localthermSlider.stepSize = nct72_local_therm_limit_scales[2]
                        }

                        onMoved:{
                            platformInterface.nct72_local_therm_limit_value.update(value.toString())
                        }

                    }
                }
            }
        }
    }
}

