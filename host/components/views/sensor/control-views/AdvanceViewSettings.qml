import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Item {
    anchors.fill: parent

    Component.onCompleted:  {
        //setSensorsValue()
    }

    property var sensorArray: []
    property var eachSensor: []
    function setSensorsValue() {
        for(var i = 1600; i >= 100; i-=100){

            sensorArray.push(i)

        }
        cin07CREF.model = sensorArray
        cin815CREF.model = sensorArray
    }


    property var touch_mode_states: platformInterface.touch_mode
    onTouch_mode_statesChanged: {
        modeSwitchLabel.text = "<b>" + qsTr(platformInterface.touch_mode.caption) + "</b>"


        if(platformInterface.touch_mode.value === "Interval")
            modeSwitch.checked = true
        else modeSwitch.checked = false

        if(platformInterface.touch_mode.state === "enabled"){
            modeSwitchContainer.enabled = true
        }
        else if(platformInterface.touch_mode.state === "disabled"){
            modeSwitchContainer.enabled = false
        }
        else {
            modeSwitchContainer.enabled = false
            modeSwitchContainer.opacity = 0.5
        }
        modeSwitch.checkedLabel = platformInterface.touch_mode.values[0]
        modeSwitch.uncheckedLabel = platformInterface.touch_mode.values[1]

    }

    property var touch_average_count: platformInterface.touch_average_count
    onTouch_average_countChanged: {
        avgCountLabel.text = "<b>" + qsTr(platformInterface.touch_average_count.caption) + "</b>"

        avgCount.model = platformInterface.touch_average_count.values
        for(var i = 0; i < avgCount.model.length; ++i) {
            console.log(avgCount.model[i])
            if(platformInterface.touch_average_count.value === avgCount.model[i].toString()){
                avgCount.currentIndex = i
            }
        }

        if(platformInterface.touch_average_count.state === "enabled"){
            avgcountContainer.enabled = true
        }
        else if(platformInterface.touch_average_count.state === "disabled"){
            avgcountContainer.enabled = false
        }
        else {
            avgcountContainer.enabled = false
            avgcountContainer.opacity = 0.5
        }
    }

    property var touch_filter_parameter1_states: platformInterface.touch_filter_parameter1
    onTouch_filter_parameter1_statesChanged: {
        filter1Label.text = "<b>" +  platformInterface.touch_filter_parameter1.caption + "</b>"
        filter1.text =  platformInterface.touch_filter_parameter1.value
        if(platformInterface.touch_filter_parameter1.state === "enabled"){
            filter1Container.enabled = true
        }
        else if(platformInterface.touch_filter_parameter1.state === "disabled"){
            filter1Container.enabled = false
        }
        else {
            filter1Container.enabled = false
            filter1Container.opacity = 0.5
        }

    }

    property var touch_filter_parameter2_states: platformInterface.touch_filter_parameter2
    onTouch_filter_parameter2_statesChanged: {
        filter2Label.text = "<b>" +  platformInterface.touch_filter_parameter2.caption + "</b>"
        filter2.text =  platformInterface.touch_filter_parameter2.value
        if(platformInterface.touch_filter_parameter2.state === "enabled"){
            filter2Container.enabled = true
        }
        else if(platformInterface.touch_filter_parameter2.state === "disabled"){
            filter2Container.enabled = false
        }
        else {
            filter2Container.enabled = false
            filter2Container.opacity = 0.5
        }

    }

    property var touch_dct1_state: platformInterface.touch_dct1
    onTouch_dct1_stateChanged: {
        debouce1Label.text = "<b>" +  platformInterface.touch_dct1.caption + "</b>"
        debouce1.text = platformInterface.touch_dct1.value

        if(platformInterface.touch_dct1.state === "enabled"){
            debouce1Container.enabled = true
        }
        else if(platformInterface.touch_dct1.state === "disabled"){
            debouce1Container.enabled = false
        }
        else {
            debouce1Container.enabled = false
            debouce1Container.opacity = 0.5
        }

    }

    property var touch_dct2_state: platformInterface.touch_dct2
    onTouch_dct2_stateChanged: {
        debouce2Label.text = "<b>" +  platformInterface.touch_dct2.caption + "</b>"
        debouce2.text = platformInterface.touch_dct2.value

        if(platformInterface.touch_dct2.state === "enabled"){
            debouce2Container.enabled = true
        }
        else if(platformInterface.touch_dct2.state === "disabled"){
            debouce2Container.enabled = false
        }
        else {
            debouce2Container.enabled = false
            debouce2Container.opacity = 0.5
        }

    }

    property var touch_sival_state: platformInterface.touch_sival
    onTouch_sival_stateChanged: {
        shortIntervalLabel.text = "<b>" +  platformInterface.touch_sival.caption + "</b>"
        shortInterval.text =  platformInterface.touch_sival.value
        if(platformInterface.touch_sival.state === "enabled"){
            shortIntervalContainer.enabled = true
        }
        else if(platformInterface.touch_sival.state === "disabled"){
            shortIntervalContainer.enabled = false
        }
        else {
            shortIntervalContainer.enabled = false
            shortIntervalContainer.opacity = 0.5
        }
    }

    property var touch_lival_state: platformInterface.touch_lival
    onTouch_lival_stateChanged: {
        longIntervalLabel.text = "<b>" +  platformInterface.touch_lival.caption + "</b>"
        longInterval.text = platformInterface.touch_lival.value

        if( platformInterface.touch_lival.state === "enabled"){
            longIntervalContainer.enabled = true
        }
        else if( platformInterface.touch_lival.state === "disabled"){
            longIntervalContainer.enabled = false
        }
        else {
            longIntervalContainer.enabled = false
            longIntervalContainer.opacity = 0.5
        }

    }

    property var touch_si_dc_cyc_state: platformInterface.touch_si_dc_cyc
    onTouch_si_dc_cyc_stateChanged: {
        shortIntervalDynLabel.text = "<b>" +  platformInterface.touch_si_dc_cyc.caption + "</b>"
        shortIntervalDyn.text = platformInterface.touch_si_dc_cyc.value

        if( platformInterface.touch_si_dc_cyc.state === "enabled"){
            shortIntervalDynContainer.enabled = true
        }
        else if( platformInterface.touch_si_dc_cyc.state === "disabled"){
            shortIntervalDynContainer.enabled = false
        }
        else {
            shortIntervalDynContainer.enabled = false
            shortIntervalDynContainer.opacity = 0.5
        }

    }

    property var touch_dc_plus_state: platformInterface.touch_dc_plus
    onTouch_dc_plus_stateChanged: {
        dynoffcalCountPlusLabel.text = "<b>" +  platformInterface.touch_dc_plus.caption + "</b>"
        dynoffcalCountPlus.text = platformInterface.touch_dc_plus.value

        if( platformInterface.touch_dc_plus.state === "enabled"){
            dynoffcalCountPlusContainer.enabled = true
        }
        else if( platformInterface.touch_dc_plus.state === "disabled"){
            dynoffcalCountPlusContainer.enabled = false
        }
        else {
            dynoffcalCountPlusContainer.enabled = false
            dynoffcalCountPlusContainer.opacity = 0.5
        }

    }

    property var touch_dc_minus_state: platformInterface.touch_dc_minus
    onTouch_dc_minus_stateChanged: {
        dynoffcalCountMinusLabel.text = platformInterface.touch_dc_minus.caption
        dynoffcalCountMinus.text = platformInterface.touch_dc_minus.value

        if( platformInterface.touch_dc_minus.state === "enabled"){
            dynoffcalCountMinusContainer.enabled = true
        }
        else if( platformInterface.touch_dc_minus.state === "disabled"){
            dynoffcalCountMinusContainer.enabled = false
        }
        else {
            dynoffcalCountMinusContainer.enabled = false
            dynoffcalCountMinusContainer.opacity = 0.5
        }

    }

    property var touch_sc_cdac_state: platformInterface.touch_sc_cdac
    onTouch_sc_cdac_stateChanged: {
        staticCalibrationLabel.text = platformInterface.touch_sc_cdac.caption
        staticCalibration.model = platformInterface.touch_sc_cdac.values

        for(var i = 0; i < staticCalibration.model.length; ++i) {
            if(platformInterface.touch_sc_cdac.value === staticCalibration.model[i].toString()){
                staticCalibration.currentIndex = i
            }
        }

        if(touch_sc_cdac_state.state === "enabled"){
            staticCalibrationContainer.enabled = true
        }
        else if(touch_sc_cdac_state.state === "disabled"){
            staticCalibrationContainer.enabled = false
        }
        else {
            staticCalibrationContainer.enabled = false
            staticCalibrationContainer.opacity = 0.5
        }

    }

    property var touch_dc_mode_state: platformInterface.touch_dc_mode
    onTouch_dc_mode_stateChanged: {
        dynLabel.text = touch_dc_mode_state.caption
        if(touch_dc_mode_state.value === "Threshold")
            dynSwitch.checked = true
        else dynSwitch.checked = false

        if(touch_dc_mode_state.state === "enabled"){
            dynSwitchContainer.enabled = true
        }
        else if(touch_dc_mode_state.state === "disabled"){
            dynSwitchContainer.enabled = false
        }
        else {
            dynSwitchContainer.enabled = false
            dynSwitchContainer.opacity = 0.5
        }

        dynSwitch.checkedLabel = platformInterface.touch_dc_mode.values[0]
        dynSwitch.uncheckedLabel = platformInterface.touch_dc_mode.values[1]

    }

    property var touch_off_thres_mode_state: platformInterface.touch_off_thres_mode
    onTouch_off_thres_mode_stateChanged: {
        offsetLabel.text = touch_off_thres_mode_state.caption

        if(touch_off_thres_mode_state.value === "0.5 Peak")
            offsetSwitch.checked = true
        else offsetSwitch.checked = false


        if(touch_off_thres_mode_state.state === "enabled"){
            offsetContainer.enabled = true
        }
        else if(touch_off_thres_mode_state.state === "disabled"){
            offsetContainer.enabled = false
        }
        else {
            offsetContainer.enabled = false
            offsetContainer.opacity = 0.5
        }

        offsetSwitch.checkedLabel = touch_off_thres_mode_state.values[0]
        offsetSwitch.uncheckedLabel = touch_off_thres_mode_state.values[1]

    }

    property var touch_cref0_7_state: platformInterface.touch_cref0_7
    onTouch_cref0_7_stateChanged: {
        cin07SwitchLabel.text = touch_cref0_7_state.caption

        if(touch_cref0_7_state.value === "CREF+CADD")
            cin07Switch.checked = true
        else cin07Switch.checked = false


        if(touch_cref0_7_state.state === "enabled"){
            cin07SwitchContainer.enabled = true
        }
        else if(touch_cref0_7_state.state === "disabled"){
            cin07SwitchContainer.enabled = false
        }
        else {
            cin07SwitchContainer.enabled = false
            cin07SwitchContainer.opacity = 0.5
        }

        cin07Switch.checkedLabel = touch_cref0_7_state.values[0]
        cin07Switch.uncheckedLabel = touch_cref0_7_state.values[1]
    }

    property var touch_cref8_15_state: platformInterface.touch_cref8_15
    onTouch_cref8_15_stateChanged: {
        cin815SwitchLabel.text = touch_cref8_15_state.caption

        if(touch_cref8_15_state.value === "CREF+CADD")
            cin815Switch.checked = true
        else cin815Switch.checked = false


        if(touch_cref8_15_state.state === "enabled"){
            cin815SwitchContainer.enabled = true
        }
        else if(touch_cref8_15_state.state === "disabled"){
            cin815SwitchContainer.enabled = false
        }
        else {
            cin815SwitchContainer.enabled = false
            cin815SwitchContainer.opacity = 0.5
        }

        cin815Switch.checkedLabel = touch_cref8_15_state.values[0]
        cin815Switch.uncheckedLabel = touch_cref8_15_state.values[1]
    }

    property var touch_li_start_state: platformInterface.touch_li_start
    onTouch_li_start_stateChanged: {
        longIntervalStartLabel.text = touch_li_start_state.caption
        longIntervalStartSlider.to = touch_li_start_state.scales[0]
        longIntervalStartSlider.from = touch_li_start_state.scales[1]
        longIntervalStartSlider.stepSize = touch_li_start_state.scales[2]

        longIntervalStartSlider.value = touch_li_start_state.value

        if(touch_li_start_state.state === "enabled"){
            longIntervalStartSliderContainer.enabled = true
        }
        else if(touch_li_start_state.state === "disabled"){
            longIntervalStartSliderContainer.enabled = false
        }
        else {
            longIntervalStartSliderContainer.enabled = false
            longIntervalStartSliderContainer.opacity = 0.5
        }
    }

    property var touch_first_gain8_15_state: platformInterface.touch_first_gain8_15
    onTouch_first_gain8_15_stateChanged: {
        cin815CREFLabel.text = touch_first_gain8_15_state.caption

        cin815CREF.model = touch_first_gain8_15_state.values
        for(var i = 0; i < cin815CREF.model.length; ++i) {
            if(touch_first_gain8_15_state.value === cin815CREF.model[i].toString()){
                cin815CREF.currentIndex = i
            }
        }

        if(touch_first_gain8_15_state.state === "enabled"){
            cin815CREFContainer.enabled = true
        }
        else if(touch_first_gain8_15_state.state === "disabled"){
            cin815CREFContainer.enabled = false
        }
        else {
            cin815CREFContainer.enabled = false
            cin815CREFContainer.opacity = 0.5
        }
    }
    property var touch_first_gain0_7_state: platformInterface.touch_first_gain0_7
    onTouch_first_gain0_7_stateChanged: {
        cin07CREFLabel.text = touch_first_gain0_7_state.caption

        cin07CREF.model = touch_first_gain0_7_state.values
        for(var i = 0; i < cin07CREF.model.length; ++i) {
            if(touch_first_gain0_7_state.value === cin07CREF.model[i].toString()){
                cin07CREF.currentIndex = i
            }
        }

        if(touch_first_gain0_7_state.state === "enabled"){
            cin07CREFContainer.enabled = true
        }
        else if(touch_first_gain0_7_state.state === "disabled"){
            cin07CREFContainer.enabled = false
        }
        else {
            cin07CREFContainer.enabled = false
            cin07CREFContainer.opacity = 0.5
        }
    }



    property var  touch_calerr_state: platformInterface.touch_calerr
    onTouch_calerr_stateChanged: {
        calerrLabel.text = touch_calerr_state.caption
        if(touch_calerr_state.state === "enabled"){
            calerrLightContainer.enabled = true
        }
        else if(touch_calerr_state.state === "disabled"){
            calerrLightContainer.enabled = false
        }
        else {
            calerrLightContainer.enabled = false
            calerrLightContainer.opacity = 0.5
        }

    }


    property var  touch_syserr_state: platformInterface.touch_syserr
    onTouch_syserr_stateChanged: {
        syserrLabel.text = touch_syserr_state.caption
        if(touch_syserr_state.state === "enabled"){
            syserrLightContainer.enabled = true
        }
        else if(touch_syserr_state.state === "disabled"){
            syserrLightContainer.enabled = false
        }
        else {
            syserrLightContainer.enabled = false
            syserrLightContainer.opacity = 0.5
        }

    }

    ColumnLayout {
        anchors.fill:parent

        Rectangle{
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                id: primarySettings
                text: "Primary Settings"
                font.bold: true
                font.pixelSize: ratioCalc * 15
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line1
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: primarySettings.bottom
                    topMargin: 7
                }
            }
            ColumnLayout {
                anchors {
                    top: line1.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                spacing: 20
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill:parent
                        Rectangle {
                            id: modeSwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: modeSwitchLabel
                                target: modeSwitch
                                text: "<b>" + qsTr("Mode") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideTopLeft

                                anchors.verticalCenter: parent.verticalCenter
                                CustomizeSwitch {
                                    id: modeSwitch
                                    labelsInside: false
                                    uncheckedLabel: "Sleep"
                                    checkedLabel: "Interval"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    checked: false
                                    onToggled: {
                                        if(checked)
                                            platformInterface.touch_mode_value.update("Interval")
                                        else  platformInterface.touch_mode_value.update("Sleep")
                                    }
                                }
                            }
                        }


                        Rectangle {
                            id: cin07SwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:cin07SwitchLabel
                                target: cin07Switch
                                // text:  "CIN0-7 CREF "
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                CustomizeSwitch {
                                    id: cin07Switch
                                    labelsInside: false
                                    //                                    checkedLabel: "CREF \n + CREFADD"
                                    //                                    uncheckedLabel: "CREF"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onToggled:  {
                                        if(checked)
                                            platformInterface.touch_cref0_7_value.update("CREF+CADD")
                                        else platformInterface.touch_cref0_7_value.update("CREF")

                                    }
                                }
                            }
                        }


                        Rectangle {
                            id: cin815SwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:cin815SwitchLabel
                                target: cin815Switch
                                //text:  "CIN8-15 CREF "
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                CustomizeSwitch {
                                    id: cin815Switch
                                    labelsInside: false
                                    //checkedLabel: "CREF \n + CREFADD"
                                    //uncheckedLabel: "CREF"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onToggled:  {
                                        if(checked)
                                            platformInterface.touch_cref8_15_value.update("CREF+CADD")
                                        else  platformInterface.touch_cref8_15_value.update("CREF")

                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill:parent
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGButton {
                                id:  exportButton
                                text: qsTr("Export Register")
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: platformInterface.touch_export_registers_value.update()

                                }

                            }
                        }
                        Rectangle {
                            id: cin07CREFContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: cin07CREFLabel
                                target: cin07CREF
                                //text: "CIN0-7 1st Gain (fF)"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true

                                SGComboBox {
                                    id: cin07CREF
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onActivated: {
                                        platformInterface.touch_first_gain0_7_value.update(currentText)
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: cin815CREFContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: cin815CREFLabel
                                target: cin815CREF
                                // text: "CIN8-15 1st Gain (fF)"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true

                                SGComboBox {
                                    id: cin815CREF
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onActivated: {
                                        platformInterface.touch_first_gain8_15_value.update(currentText)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                id: miscSettings
                text: "Miscellaneous Settings"
                font.bold: true
                font.pixelSize: ratioCalc * 15
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line2
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: miscSettings.bottom
                    topMargin: 7
                }
            }
            ColumnLayout {
                anchors {
                    top: line2.bottom
                    topMargin: 5
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                spacing: 20

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout{
                        anchors.fill:parent
                        Rectangle {
                            id: avgcountContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: avgCountLabel
                                target: avgCount
                                text: "Average Count"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true

                                SGComboBox {
                                    id: avgCount
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    model: [8,16,32,64,128]
                                    onActivated: {
                                        platformInterface.touch_average_count_value.update(currentText)
                                    }
                                }
                            }
                        }


                        Rectangle {
                            id: offsetContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:offsetLabel
                                target: offsetSwitch
                                // text:  "Touch Offset Threshold"
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                CustomizeSwitch {
                                    id: offsetSwitch
                                    labelsInside: false
                                    //                                    checkedLabel: "0.75 Peak"
                                    //                                    uncheckedLabel: "0.5 Peak"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onToggled:  {
                                        if(checked)
                                            platformInterface.touch_off_thres_mode_value.update("0.75")
                                        else platformInterface.touch_off_thres_mode_value.update("0.5")
                                    }
                                }
                            }
                        }
                        Rectangle {
                            id: debouce1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: debouce1Label
                                target: debouce1
                                // text:  "<b>Debouce Count (Off to On)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: debouce1
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"

                                    onAccepted: {
                                        platformInterface.touch_dct1_value.update(text)
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout{
                        anchors.fill:parent
                        Rectangle {
                            id: filter1Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            SGAlignedLabel {
                                id: filter1Label
                                target: filter1
                                //text:  "<b>Filter Parameter 1</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: filter1
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-15"
                                    validator: IntValidator { }
                                    onAccepted: {
                                        platformInterface.touch_filter_parameter1_value.update(text)
                                    }



                                }
                            }
                        }
                        Rectangle {
                            id: filter2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: filter2Label
                                target: filter2
                                //text:  "<b>Filter Parameter 2</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: filter2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-15"
                                    validator: IntValidator {
                                        top: 15
                                        bottom: 0
                                    }
                                    onAccepted: {
                                        platformInterface.touch_filter_parameter2_value.update(text)
                                    }



                                }
                            }
                        }
                        Rectangle {
                            id: debouce2Container
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: debouce2Label
                                target: debouce2
                                //text:  "<b>Debouce Count (Off to On)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: debouce2
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator {
                                        top: 255
                                        bottom: 0
                                    }
                                    onAccepted: {
                                        platformInterface.touch_dct2_value.update(text)
                                    }

                                }
                            }
                        }
                    }
                }
            }

        }
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                id: internalSettings
                text: "Interval & calibration"
                font.bold: true
                font.pixelSize: ratioCalc * 15
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line3
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: internalSettings.bottom
                    topMargin: 7
                }
            }
            ColumnLayout {
                anchors {
                    top: line3.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                spacing: 30

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill:parent
                        Rectangle {
                            id: shortIntervalContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: shortIntervalLabel
                                target: shortInterval
                                //text:  "<b>Short Interval Time (ms)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: shortInterval
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator{
                                        top: platformInterface.touch_sival.scales[0]
                                        bottom: platformInterface.touch_sival.scales[1]
                                    }

                                    onAccepted: {
                                        platformInterface.touch_sival_value.update(text)
                                    }

                                }
                            }
                        }

                        Rectangle {
                            id: longIntervalContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: longIntervalLabel
                                target: longInterval
                                //text:  "<b>Long Interval Time (ms)</b>"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: longInterval
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-355"
                                    validator: IntValidator{
                                        top: platformInterface.touch_lival.scales[0]
                                        bottom: platformInterface.touch_lival.scales[1]
                                    }
                                    onAccepted: {
                                        platformInterface.touch_lival_value.update(text)
                                    }

                                }
                            }
                        }

                        Rectangle {
                            id: dynSwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:dynLabel
                                target: dynSwitch
                                //text:  "Dyn Off Cal Mode"
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                CustomizeSwitch {
                                    id: dynSwitch
                                    labelsInside: false
                                    //                                    checkedLabel: "Threshold"
                                    //                                    uncheckedLabel: "Enabled \n Text"
                                    textColor: "black"              // Default: "black"
                                    handleColor: "white"            // Default: "white"
                                    grooveColor: "#ccc"             // Default: "#ccc"
                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                    checked: false
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    onToggled:  {
                                        if(checked)
                                            platformInterface.touch_dc_mode_value.update("Threshold")
                                        else  platformInterface.touch_dc_mode_value.update("Enabled Text")

                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout {
                        anchors.fill:parent

                        Rectangle{
                            id: longIntervalStartSliderContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: longIntervalStartLabel
                                target: longIntervalStartSlider
                                //text: "Long Interval Start Intervals"
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent

                                SGSlider {
                                    id: longIntervalStartSlider
                                    width: longIntervalStartSliderContainer.width - 10
                                    live: false
                                    //                                    from: 0
                                    //                                    to: 1020
                                    //                                    stepSize: 150
                                    //value: 0
                                    fontSizeMultiplier: ratioCalc * 0.8
                                    inputBox.validator: DoubleValidator {
                                        top: longIntervalStartSlider.to
                                        bottom: longIntervalStartSlider.from
                                    }
                                    onUserSet: {
                                        platformInterface.touch_li_start_value.update(value)
                                    }

                                }
                            }
                        }
                        Rectangle{
                            id: staticCalibrationContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: staticCalibrationLabel
                                target: staticCalibration
                                //text: "Static Calibration CDAC (pF)"
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent
                                fontSizeMultiplier: ratioCalc * 0.9
                                font.bold : true

                                SGComboBox {
                                    id: staticCalibration
                                    fontSizeMultiplier: ratioCalc * 0.9

                                }
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    RowLayout {
                        anchors.fill:parent
                        Rectangle {
                            id: dynoffcalCountPlusContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: dynoffcalCountPlusLabel
                                target: dynoffcalCountPlus
                                //text:  "Dyn Off Cal Count Plus"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: dynoffcalCountPlus
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator {
                                        top: platformInterface.touch_dc_plus.scales[0]
                                        bottom: platformInterface.touch_dc_plus.scales[1]
                                    }

                                    onAccepted: {
                                        platformInterface.touch_dc_plus_value.update(text)
                                    }

                                }
                            }
                        }
                        Rectangle {
                            id: dynoffcalCountMinusContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: dynoffcalCountMinusLabel
                                target: dynoffcalCountMinus
                                //text:  "Dyn Off Cal Count Minus"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter

                                SGSubmitInfoBox {
                                    id: dynoffcalCountMinus
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator {
                                        top: platformInterface.touch_dc_minus.scales[0]
                                        bottom: platformInterface.touch_dc_minus.scales[1]
                                    }
                                    onAccepted: {
                                        platformInterface.touch_dc_minus_value.update(text)
                                    }

                                }
                            }
                        }

                        Rectangle {
                            id: shortIntervalDynContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: shortIntervalDynLabel
                                target: shortIntervalDyn
                                //text:  "Short Interval Dyn Off Cal Cycles"
                                font.bold: true
                                alignment: SGAlignedLabel.SideTopLeft
                                fontSizeMultiplier: ratioCalc
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: -10

                                SGSubmitInfoBox {
                                    id: shortIntervalDyn
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator {
                                        top: platformInterface.touch_si_dc_cyc.scales[0]
                                        bottom:platformInterface.touch_si_dc_cyc.scales[1]
                                    }

                                    onAccepted: {
                                        platformInterface.touch_sc_cdac_value.update(text)
                                    }

                                }
                            }
                        }
                    }
                }
            }

        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height/6
            Text {
                id: systemDebug
                text: "System/debug"
                font.bold: true
                font.pixelSize: ratioCalc * 15
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 5
                }
            }

            Rectangle {
                id: line4
                height: 2
                Layout.alignment: Qt.AlignCenter
                width: parent.width
                border.color: "lightgray"
                radius: 2
                anchors {
                    top: systemDebug.bottom
                    topMargin: 7
                }
            }

            ColumnLayout {
                anchors {
                    top: line4.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                spacing: 20
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGButton {
                                id:  forceButton
                                text: qsTr("Wakeup")
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: platformInterface.touch_wakeup_value.update()

                                }

                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGButton {
                                id:  hardwareButton
                                text: qsTr("Hardware Reset")
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: platformInterface.touch_hw_reset_value.update()

                                }

                            }
                        }
                        Rectangle {
                            id: syserrLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: syserrLabel
                                target: syserrLight
                                font.bold: true
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: syserrLight
                                    width: 30

                                }
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    RowLayout{
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                        }
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGButton {
                                id:  softwareButton
                                text: qsTr("Software Reset")
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: platformInterface.touch_sw_reset_value.update()
                                }

                            }
                        }
                        Rectangle {
                            id: calerrLightContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: calerrLabel
                                target: calerrLight
                                font.bold: true
                                //text: "<b>" + qsTr("CALERR") + "</b>"
                                fontSizeMultiplier: ratioCalc * 0.9
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.centerIn: parent
                                SGStatusLight {
                                    id: calerrLight
                                    width: 30

                                }
                            }

                        }
                    }
                }

            }

        }

    }
}
