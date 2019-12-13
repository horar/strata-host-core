import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item{
    id:mainmenu
    width: parent.width
    height: parent.height


    property var read_vin : platformInterface.power_notification.vin
    onRead_vinChanged: {
        labelledInfoBox1.info = read_vin + " Vrms"

        if (read_vin === "-"){
            graph1.inputData = 1000
        } else {
            graph1.inputData = read_vin
        }
    }

    property var read_iin :  platformInterface.power_notification.iin
    onRead_iinChanged: {
        labelledInfoBox2.info = read_iin + " Arms"

        if (read_iin === "-"){
            graph3.inputData = 1000
        } else {
            graph3.inputData = read_iin
        }
    }

    property var read_lfin: platformInterface.power_notification.lfin
    onRead_lfinChanged: {
        labelledInfoBox10.info = read_lfin +" Hz"
    }

    property var read_apin: platformInterface.power_notification.apin
    onRead_apinChanged: {
        labelledInfoBox7.info = read_apin +" VA"
    }

    property var read_acpin: platformInterface.power_notification.acpin
    onRead_acpinChanged: {
        labelledInfoBox4.info = read_acpin + " W"

        if (read_acpin === "-"){
            graph5.inputData = 1000
        } else {
            graph5.inputData = read_acpin
        }
    }

    property var read_rpin : platformInterface.power_notification.rpin
    onRead_rpinChanged: {
        labelledInfoBox5.info = read_rpin + " VAR"
    }

    property var read_pfin: platformInterface.power_notification.pfin
    onRead_pfinChanged: {
        labelledInfoBox8.info = read_pfin
    }

    property var read_vout : platformInterface.power_notification.vout
    onRead_voutChanged: {
        labelledInfoBox3.info = read_vout + " V"

        if (read_vout === "-"){
            graph2.inputData = 1000
        } else {
            graph2.inputData = read_vout
        }
    }

    property var read_iout: platformInterface.power_notification.iout
    onRead_ioutChanged: {
        labelledInfoBox6.info = read_iout + " A"

        if (read_iout === "-"){
            graph4.inputData = 1000
        } else {
            graph4.inputData = read_iout
        }
    }

    property var read_pout: platformInterface.power_notification.pout
    onRead_poutChanged: {
        labelledInfoBox9.info = read_pout + " W"

        if (read_pout === "-"){
            graph6.inputData = 1000
        } else {
            graph6.inputData = read_pout
        }
    }

    property var read_loss: platformInterface.power_notification.loss
    onRead_lossChanged: {
        labelledInfoBox11.info = read_loss + " W"
    }

    property var read_n: platformInterface.power_notification.n
    onRead_nChanged: {
        labelledInfoBox12.info = read_n + " %"

        if (read_n === "-"){
            graph0.inputData = 1000
        } else {
            graph0.inputData = read_n
        }
    }

    // for Debug
    function clear_graph(){
        graph0.inputData = 1000
        graph1.inputData = 1000
        graph2.inputData = 1000
        graph3.inputData = 1000
        graph4.inputData = 1000
        graph5.inputData = 1000
        graph6.inputData = 1000
    }

    property bool check_stop_notif_state : platformInterface.state_stop_periodic_noti
    onCheck_stop_notif_stateChanged: {
        if (check_stop_notif_state === true) {
            platformInterface.stop_peroidic_hdl.update()
        }
    }

    property bool check_debug_vol : platformInterface.state_debug_vol
    onCheck_debug_volChanged: {
        if (check_debug_vol === true){
            debugSelector.index = 0;
            platformInterface.measure_voltage_cmd.update()
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_debug_cur : platformInterface.state_debug_cur
    onCheck_debug_curChanged: {
        if (check_debug_cur === true){
            platformInterface.measure_current_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_state_ap_power : platformInterface.state_debug_ap_power
    onCheck_state_ap_powerChanged: {
        if (check_state_ap_power === true){
            platformInterface.measure_apparent_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_state_ac_power : platformInterface.state_debug_ac_power
    onCheck_state_ac_powerChanged: {
        if (check_state_ac_power === true){
            platformInterface.measure_active_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_state_ra_power : platformInterface.state_debug_ra_power
    onCheck_state_ra_powerChanged: {
        if (check_state_ra_power === true){
            platformInterface.measure_reactive_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_debug_lf : platformInterface.state_debug_lf
    onCheck_debug_lfChanged: {
        if (check_debug_lf === true){
            platformInterface.measure_frequency_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_debug_pf : platformInterface.state_debug_pf
    onCheck_debug_pfChanged: {
        if (check_debug_pf === true){
            platformInterface.measure_pf_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_debug_sec : platformInterface.state_debug_sec
    onCheck_debug_secChanged: {
        if (check_debug_sec === true){
            platformInterface.measure_second_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox11.info = "-" + " W"
            labelledInfoBox12.info = "-" + " %"
            clear_graph()
        }
    }

    property bool check_debug_n : platformInterface.state_debug_n
    onCheck_debug_nChanged: {
        if (check_debug_n === true) {
            platformInterface.measure_efficiency_cmd.update()
            labelledInfoBox1.info = "-" + " Vrms"
            labelledInfoBox2.info = "-" + " Arms"
            labelledInfoBox10.info = "-" +" Hz"
            labelledInfoBox7.info = "-" +" VA"
            labelledInfoBox4.info = "-" + " W"
            labelledInfoBox5.info = "-" + " VAR"
            labelledInfoBox8.info = "-"
            labelledInfoBox3.info = "-" + " V"
            labelledInfoBox6.info = "-" + " A"
            labelledInfoBox9.info = "-" + " W"
            clear_graph()
        }
    }

    property bool check_debug_start_notif : platformInterface.state_debug_start_notif
    onCheck_debug_start_notifChanged: {
        if (check_debug_start_notif === true) {
            platformInterface.start_peroidic_hdl.update()
        }
    }

    property var read_vin_cmd : platformInterface.primary_voltage.vin
    onRead_vin_cmdChanged: {
        labelledInfoBox1.info = read_vin_cmd + " Vrms"
    }

    property var read_iin_cmd :  platformInterface.primary_current.iin
    onRead_iin_cmdChanged: {
        labelledInfoBox2.info = read_iin_cmd + " Arms"
    }

    property var read_lfin_cmd: platformInterface.primary_frequency.lfin
    onRead_lfin_cmdChanged: {
        labelledInfoBox10.info = read_lfin_cmd +" Hz"
    }

    property var read_apin_cmd: platformInterface.primary_apparent_power.apin
    onRead_apin_cmdChanged: {
        labelledInfoBox7.info = read_apin_cmd +" VA"
    }

    property var read_acpin_cmd: platformInterface.primary_active_power.acpin
    onRead_acpin_cmdChanged: {
        labelledInfoBox4.info = read_acpin_cmd + " W"
    }

    property var read_rpin_cmd : platformInterface.primary_reactive_power.rpin
    onRead_rpin_cmdChanged: {
        labelledInfoBox5.info = read_rpin_cmd + " VAR"
    }

    property var read_pfin_cmd: platformInterface.primary_power_factor.pfin
    onRead_pfin_cmdChanged: {
        labelledInfoBox8.info = read_pfin_cmd
    }

    property var read_vout_cmd : platformInterface.secondary_power.vout
    onRead_vout_cmdChanged: {
        labelledInfoBox3.info = read_vout_cmd + " V"
    }

    property var read_iout_cmd: platformInterface.secondary_power.iout
    onRead_iout_cmdChanged: {
        labelledInfoBox6.info = read_iout_cmd + " A"
    }

    property var read_pout_cmd: platformInterface.secondary_power.pout
    onRead_pout_cmdChanged: {
        labelledInfoBox9.info = read_pout_cmd + " W"
    }

    property var read_loss_cmd: platformInterface.efficiency_loss.loss
    onRead_loss_cmdChanged: {
        labelledInfoBox11.info = read_loss_cmd + " W"
    }

    property var read_n_cmd: platformInterface.efficiency_loss.n
    onRead_n_cmdChanged: {
        labelledInfoBox12.info = read_n_cmd + " %"
    }
    // end debug

    Rectangle{
        id:title
        width: parent.width/3
        height: parent.height/20
        anchors{
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }
        color:"transparent"
        Text {
            text: "Active Clamp Flyback Power Supply Unit"
            font.pixelSize: 25
            anchors.fill:parent
            color: "black"
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout{
        id:rowright
        width: parent.width
        height:parent.height/2.5
        anchors{
            top: title.bottom
        }

        Rectangle{
            Layout.preferredWidth:parent.width/1.5
            Layout.preferredHeight: parent.height-100

            Rectangle{
                id:rec1
                anchors.fill:parent
                color: "transparent"

                RowLayout {
                    anchors.fill:parent

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : a
                            anchors.fill: parent

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox1
                                infoBoxWidth: 150
                                label: "<b>INPUT VOLTAGE</b>"
                                info: "100.00 Vrms"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox2
                                infoBoxWidth: 150
                                label: "<b>INPUT CURRENT</b>"
                                info: "2.00 Arms"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox3
                                infoBoxWidth: 150
                                label: "<b>OUTPUT VOLTAGE</b>"
                                info: "12.02 V"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : b
                            anchors.fill: parent

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox4
                                infoBoxWidth: 150
                                label: "<b>INPUT (ACTIVE) POWER</b>"
                                info: "120 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox5
                                infoBoxWidth: 150
                                label: "<b>REACTIVE POWER</b>"
                                info: "10 VAR"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox6
                                infoBoxWidth: 150
                                label: "<b>OUTPUT CURRENT</b>"
                                info: "8.50 A"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }

                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : c
                            anchors.fill: parent

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox7
                                infoBoxWidth: 150
                                label: "<b>APPARENT POWER</b>"
                                info: "120 VA"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox8
                                infoBoxWidth: 150
                                label: "<b>POWER FACTOR</b>"
                                info: "0.90"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox9
                                infoBoxWidth: 150
                                label: "<b>OUTPUT POWER</b>"
                                info: "100 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }

                    Rectangle{
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: "transparent"

                        ColumnLayout{
                            id : d
                            anchors.fill: parent

                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox10
                                infoBoxWidth: 150
                                label: "<b>LINE FREQUENCY</b>"
                                info: "50 Hz"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox11
                                infoBoxWidth: 150
                                label: "<b>LOSS (Pin-Pout)</b>"
                                info: "20 W"
                                labelLeft: false
                                Layout.alignment: Qt.AlignCenter
                            }
                            SGLabelledinfoBoxCustomize {
                                id: labelledInfoBox12
                                infoBoxWidth: 150
                                label: "<b>EFFICIENCY</b>"
                                info: "95 %"
                                labelLeft: false

                                Layout.alignment: Qt.AlignCenter
                            }
                        }
                    }
                }
            }


        }
        Rectangle{
            Layout.preferredHeight: parent.height - 80
            Layout.fillWidth: true
            color: "transparent"
            Layout.rightMargin: 5

            Rectangle{
                anchors.fill:parent
                anchors.centerIn: parent

                SGGraphTimed {
                    id: graph0
                    anchors {
                        fill: parent
                    }
                    title: "<b>Efficiency</b>"
                    yAxisTitle: "<b>η [%]</b>"
                    xAxisTitle: "<b>1 sec/div<b>"
                    minYValue: 0
                    maxYValue: 100
                    minXValue: 0
                    maxXValue: 4
                    reverseDirection: true
                }
            }
        }
    }

    Rectangle{
        id:root
        width: parent.width
        height: parent.height/2.2
        anchors.top: rowright.bottom
        color: "transparent"

        SGSegmentedButtonStrip {
            id: graphSelector
            label: "<b>Show Graphs:</b>"
            labelLeft: false
            anchors {
                top: parent.top
                topMargin: 20
                horizontalCenter: parent.horizontalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            exclusive: false
            buttonImplicitWidth: 50
            property int howManyChecked: 0

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                SGSegmentedButton{
                    text: qsTr("Vin")
                    onCheckedChanged: {
                        if (checked) {
                            graph1.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph1.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Vout")
                    onCheckedChanged: {
                        if (checked) {
                            graph2.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph2.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Iin")
                    onCheckedChanged: {
                        if (checked) {
                            graph3.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph3.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Iout")
                    onCheckedChanged: {
                        if (checked) {
                            graph4.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph4.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Pin")
                    onCheckedChanged: {
                        if (checked) {
                            graph5.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph5.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Pout")
                    onCheckedChanged: {
                        if (checked) {
                            graph6.visible = true
                            graphSelector.howManyChecked++
                        } else {
                            graph6.visible = false
                            graphSelector.howManyChecked--
                        }
                    }
                }
            }
        }

        Row {
            id: portGraphs
            anchors {
                top: graphSelector.bottom
                topMargin: 15
                left: parent.left
                right: parent.right
            }
            height:250

            SGGraphTimed {
                id: graph1
                title: "<b>Input Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[V]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0
                maxYValue: 280
                minXValue: 0
                maxXValue: 4
                inputData: 0.0
                reverseDirection: true
            }

            SGGraphTimed {
                id: graph2
                title: "<b>Output Voltage</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[V]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0
                maxYValue: 16
                minXValue: 0
                maxXValue: 4
                reverseDirection: true
            }

            SGGraphTimed {
                id: graph3
                title: "<b>Input Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[A]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0
                maxYValue: 8
                minXValue: 0
                maxXValue: 4
                reverseDirection: true
            }

            SGGraphTimed {
                id: graph4
                title: "<b>Output Current</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[A]</b>"
                xAxisTitle: "<b>1 sec/div</b>"

                minYValue: 0
                maxYValue: 16
                minXValue: 0
                maxXValue: 4
                reverseDirection: true
            }

            SGGraphTimed {
                id: graph5
                title: "<b>Input Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[W]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0
                maxYValue: 128
                minXValue: 0
                maxXValue: 4
                reverseDirection: true
            }

            SGGraphTimed {
                id: graph6
                title: "<b>Output Power</b>"
                visible: false
                anchors {
                    top: portGraphs.top
                    bottom: portGraphs.bottom
                    bottomMargin:0
                }
                width: portGraphs.width /  Math.max(1, graphSelector.howManyChecked)
                yAxisTitle: "<b>[W]</b>"
                xAxisTitle: "<b>1 sec/div</b>"
                minYValue: 0
                maxYValue: 128
                minXValue: 0
                maxXValue: 4
                reverseDirection: true
            }
        }
    }

    Rectangle{
        id:bottom
        width: parent.width
        height: parent.height/10
        anchors.top: root.bottom
        color: "transparent"

        SGSegmentedButtonStrip {
            id: debugSelector
            label: "<b>Debug button (one time measure):</b>"
            labelLeft: false
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
            }
            textColor: "#666"
            activeTextColor: "white"
            radius: 4
            buttonHeight: 25
            exclusive: true
            buttonImplicitWidth: 50
            property int howManyChecked: 0

            segmentedButtons: GridLayout {
                columnSpacing: 2
                rowSpacing: 2

                SGSegmentedButton{
                    text: qsTr("Vin")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = true
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Iin")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = true
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("ap power")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = true
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("ac power")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = true
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("ra power")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = true
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Line freq")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = true
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("PF")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = true
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Secondary")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = true
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("n loss")
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = true
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = true
                        platformInterface.state_debug_start_notif = false
                    }
                }

                SGSegmentedButton{
                    text: qsTr("Start Graph")
                    checked: true
                    onCheckedChanged: {
                        platformInterface.state_stop_periodic_noti = false
                        platformInterface.state_debug_vol = false
                        platformInterface.state_debug_cur = false
                        platformInterface.state_debug_ap_power = false
                        platformInterface.state_debug_ac_power = false
                        platformInterface.state_debug_ra_power = false
                        platformInterface.state_debug_lf = false
                        platformInterface.state_debug_pf = false
                        platformInterface.state_debug_sec = false
                        platformInterface.state_debug_n = false
                        platformInterface.state_debug_start_notif = true
                    }
                }
            }
        }
    }

    Component.onCompleted:  {
         Help.registerTarget(portGraphs, "The graph is displayed in below when tab menu is selected. The graph is hidden when tab menu is diselected.", 2, "Help1")
         Help.registerTarget(graph0, "Efficiency Graph is showing here.", 1, "Help1")
         Help.registerTarget(rec1, "Input Voltage, Current, Power, Outout Voltage, Current, Power, Line frequency, loss and Power factor are displaying here.", 0, "Help1")
     }
}
