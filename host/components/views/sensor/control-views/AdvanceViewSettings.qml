import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import "qrc:/js/help_layout_manager.js" as Help
import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import QtQuick.Dialogs 1.2

Item {
    id: root
    anchors.fill: parent

    property string regDataToStore: ""
    property alias cin07CREFid: cin07CREF
    property var modeSelection: interval



    MouseArea {
        id: containMouseArea
        anchors.fill:root
        onClicked: forceActiveFocus()


    }
    function openFile(fileUrl) {
        var request = new XMLHttpRequest();
        request.open("GET", fileUrl, false);
        request.send(null);
        return request.responseText;
    }

    function saveFile(fileUrl, text) {
        var request = new XMLHttpRequest();
        request.open("PUT", fileUrl, false);
        request.send(text);
        return request.status;
    }

    Connections {
        target: coreInterface
        onNotification: {
            try {
                var abc =  JSON.parse(payload)
                if(abc.value === "touch_export_reg_value")
                {
                    regDataToStore += "[" + payload + "\n" + ","
                }
                if(abc.value === "touch_export_data_value")

                {
                    regDataToStore += payload + "]"
                }

            }
            catch(error) {
                if(error instanceof SyntaxError) {
                    console.log("Notification JSON is invalid, ignoring")
                }
            }
        }
    }

    //    property var touch_export_reg_value: platformInterface.touch_export_reg_value.value
    //    onTouch_export_reg_valueChanged: {

    //        console.log( platformInterface.touch_export_reg_value)
    //        //regDataToStore = touch_export_reg_value
    //    }

    FileDialog {
        id: saveFileDialog
        selectExisting: false
        nameFilters: ["Text files (*.txt)", "All files (*)"]
        onAccepted: saveFile(saveFileDialog.fileUrl, regDataToStore)
    }

    property var sensor_status_value:  platformInterface.sensor_status_value.value
    onSensor_status_valueChanged: {
        if(sensor_status_value === "defaults") {
            if(controlContainer.currentIndex === 4) {
                set_default_LC717_values()
            }
        }
        //        else if(sensor_status_value === "touch_register_sleep") {
        //            isSleepPopupOpen = true
        //            sleepPopup.open()

        //        }
        //        else if(sensor_status_value === "close_popup") {
        //            if(isSleepPopupOpen === true) {
        //                sleepPopup.close()
        //                isSleepPopupOpen = false
        //            }

        //        }
    }



    property var sensor_defaults_value: platformInterface.sensor_defaults_value.value
    onSensor_defaults_valueChanged: {
        if(sensor_defaults_value === "1") {
            set_default_LC717_values()
        }
    }


    property var touch_mode_caption: platformInterface.touch_mode_caption
    onTouch_mode_captionChanged: {
        modeSwitchLabel.text = "<b>" + qsTr(touch_mode_caption.caption) + "</b>"
    }

    property var touch_mode_value: platformInterface.touch_mode_value.value
    onTouch_mode_valueChanged: {
        if(touch_mode_value === "Interval")
            interval.checked = true

        else sleep.checked = true
    }

    property var touch_mode_state: platformInterface.touch_mode_state.state
    onTouch_mode_stateChanged: {
        if(touch_mode_state === "enabled"){
            modeSwitchContainer.enabled = true
            modeSwitchContainer.opacity = 1.0
        }
        else if(touch_mode_state === "disabled"){
            modeSwitchContainer.enabled = false
            modeSwitchContainer.opacity = 1.0
        }
        else {
            modeSwitchContainer.enabled = false
            modeSwitchContainer.opacity = 0.5
        }
    }

    //    property var touch_mode_values: platformInterface.touch_mode_values.values
    //    onTouch_mode_valuesChanged: {
    //        modeSwitch.checkedLabel = touch_mode_values[0]
    //        modeSwitch.uncheckedLabel = touch_mode_values[1]
    //    }


    property var touch_average_count_caption: platformInterface.touch_average_count_caption
    onTouch_average_count_captionChanged: {
        avgCountLabel.text = "<b>" + qsTr(touch_average_count_caption.caption) + "</b>"

    }

    property var touch_average_count_value: platformInterface.touch_average_count_value.value
    onTouch_average_count_valueChanged: {
        for(var i = 0; i < avgCount.model.length; ++i) {
            if(touch_average_count_value === avgCount.model[i].toString()){
                avgCount.currentIndex = i
            }
        }
    }

    property var touch_average_count_state: platformInterface.touch_average_count_state
    onTouch_average_count_stateChanged: {
        if(touch_average_count_state.state === "enabled"){
            avgcountContainer.enabled = true
            avgcountContainer.opacity = 1.0
        }
        else if(touch_average_count_state.state === "disabled"){
            avgcountContainer.enabled = false
            avgcountContainer.opacity = 1.0
        }
        else {
            avgcountContainer.enabled = false
            avgcountContainer.opacity = 0.5
        }
    }

    property var touch_filter_parameter1_caption: platformInterface.touch_filter_parameter1_caption
    onTouch_filter_parameter1_captionChanged: {
        filter1Label.text = "<b>" +  touch_filter_parameter1_caption.caption + "</b>"
    }

    property var touch_filter_parameter1_value: platformInterface.touch_filter_parameter1_value.value
    onTouch_filter_parameter1_valueChanged: {
        filter1.text =  touch_filter_parameter1_value
    }

    property var touch_filter_parameter1_state: platformInterface.touch_filter_parameter1_state
    onTouch_filter_parameter1_stateChanged: {
        if(touch_filter_parameter1_state.state === "enabled"){
            filter1Container.enabled = true
            filter1Container.opacity = 1.0
        }
        else if(touch_filter_parameter1_state.state === "disabled"){
            filter1Container.enabled = false
            filter1Container.opacity = 1.0
        }
        else {
            filter1Container.enabled = false
            filter1Container.opacity = 0.5
        }
    }



    property var touch_filter_parameter2_caption: platformInterface.touch_filter_parameter2_caption
    onTouch_filter_parameter2_captionChanged: {
        filter2Label.text = "<b>" +  touch_filter_parameter2_caption.caption + "</b>"
    }

    property var touch_filter_parameter2_value: platformInterface.touch_filter_parameter2_value.value
    onTouch_filter_parameter2_valueChanged: {
        filter2.text =  touch_filter_parameter2_value
    }

    property var touch_filter_parameter2_state: platformInterface.touch_filter_parameter2_state
    onTouch_filter_parameter2_stateChanged: {
        if(touch_filter_parameter2_state.state === "enabled"){
            filter2Container.enabled = true
            filter2Container.opacity = 1.0
        }
        else if(touch_filter_parameter2_state.state === "disabled"){
            filter2Container.enabled = false
            filter2Container.opacity = 1.0
        }
        else {
            filter2Container.enabled = false
            filter2Container.opacity = 0.5
        }
    }



    property var touch_dct1_caption: platformInterface.touch_dct1_caption
    onTouch_dct1_captionChanged: {
        debouce1Label.text = "<b>" +  touch_dct1_caption.caption + "</b>"
    }

    property var touch_dct1_value: platformInterface.touch_dct1_value.value
    onTouch_dct1_valueChanged: {
        debouce1.text = touch_dct1_value
    }

    property var touch_dct1_state: platformInterface.touch_dct1_state
    onTouch_dct1_stateChanged: {
        if(touch_dct1_state.state === "enabled"){
            debouce1Container.enabled = true
        }
        else if(touch_dct1_state.state === "disabled"){
            debouce1Container.enabled = false
        }
        else {
            debouce1Container.enabled = false
            debouce1Container.opacity = 0.5
        }
    }


    property var touch_dct2_caption: platformInterface.touch_dct2_caption
    onTouch_dct2_captionChanged: {
        debouce2Label.text = "<b>" +  touch_dct2_caption.caption + "</b>"
    }

    property var touch_dct2_value: platformInterface.touch_dct2_value.value
    onTouch_dct2_valueChanged: {
        debouce2.text = touch_dct2_value
    }

    property var touch_dct2_state: platformInterface.touch_dct2_state
    onTouch_dct2_stateChanged: {
        if(touch_dct2_state.state === "enabled"){
            debouce2Container.enabled = true
        }
        else if(touch_dct2_state.state === "disabled"){
            debouce2Container.enabled = false
        }
        else {
            debouce2Container.enabled = false
            debouce2Container.opacity = 0.5
        }
    }



    property var touch_sival_caption: platformInterface.touch_sival_caption
    onTouch_sival_captionChanged: {
        shortIntervalLabel.text =  touch_sival_caption.caption
    }

    property var touch_sival_value: platformInterface.touch_sival_value.value
    onTouch_sival_valueChanged: {
        shortInterval.text =  touch_sival_value
    }

    property var touch_sival_state: platformInterface.touch_sival_state
    onTouch_sival_stateChanged: {
        if(touch_sival_state.state === "enabled"){
            shortIntervalContainer.enabled = true
            shortIntervalContainer.opacity = 1.0
        }
        else if(touch_sival_state.state === "disabled"){
            shortIntervalContainer.enabled = false
            shortIntervalContainer.opacity = 1.0
        }
        else {
            shortIntervalContainer.enabled = false
            shortIntervalContainer.opacity = 0.5
        }
    }


    property var touch_lival_caption: platformInterface.touch_lival_caption
    onTouch_lival_captionChanged: {
        longIntervalLabel.text =  touch_lival_caption.caption
    }

    property var touch_lival_value: platformInterface.touch_lival_value.value
    onTouch_lival_valueChanged: {
        longInterval.text = touch_lival_value
    }

    property var touch_lival_state: platformInterface.touch_lival_state
    onTouch_lival_stateChanged: {
        if(touch_lival_state.state === "enabled"){
            longIntervalContainer.enabled = true
            longIntervalContainer.opacity = 1.0
        }
        else if(touch_lival_state.state === "disabled"){
            longIntervalContainer.enabled = false
            longIntervalContainer.opacity = 1.0
        }
        else {
            longIntervalContainer.enabled = false
            longIntervalContainer.opacity = 0.5
        }
    }


    property var touch_si_dc_cyc_caption: platformInterface.touch_si_dc_cyc_caption
    onTouch_si_dc_cyc_captionChanged: {
        shortIntervalDynLabel.text = "<b>" +  touch_si_dc_cyc_caption.caption + "</b>"
    }

    property var touch_si_dc_cycl_value: platformInterface.touch_si_dc_cycl_value.value
    onTouch_si_dc_cycl_valueChanged: {
        shortIntervalDyn.text = touch_si_dc_cycl_value
    }

    property var touch_si_dc_cyc_state: platformInterface.touch_si_dc_cyc_state
    onTouch_si_dc_cyc_stateChanged: {
        if( touch_si_dc_cyc_state.state === "enabled"){
            shortIntervalDynContainer.enabled = true
            shortIntervalDynContainer.opacity = 1.0
        }
        else if(touch_si_dc_cyc_state.state === "disabled"){
            shortIntervalDynContainer.enabled = false
            shortIntervalDynContainer.opacity = 1.0
        }
        else {
            shortIntervalDynContainer.enabled = false
            shortIntervalDynContainer.opacity = 0.5
        }
    }


    property var touch_dc_plus_caption: platformInterface.touch_dc_plus_caption
    onTouch_dc_plus_captionChanged: {
        dynoffcalCountPlusLabel.text = "<b>" + touch_dc_plus_caption.caption + "</b>"
    }

    property var touch_dc_plus_value: platformInterface.touch_dc_plus_value.value
    onTouch_dc_plus_valueChanged: {
        dynoffcalCountPlus.text = touch_dc_plus_value
    }

    property var touch_dc_plus_state: platformInterface.touch_dc_plus_state
    onTouch_dc_plus_stateChanged: {
        if( touch_dc_plus_state.state === "enabled"){
            dynoffcalCountPlusContainer.enabled = true
            dynoffcalCountPlusContainer.opacity = 1.0
        }
        else if(touch_dc_plus_state.state === "disabled"){
            dynoffcalCountPlusContainer.enabled = false
            dynoffcalCountPlusContainer.opacity = 1.0
        }
        else {
            dynoffcalCountPlusContainer.enabled = false
            dynoffcalCountPlusContainer.opacity = 0.5
        }
    }

    property var touch_dc_minus_caption: platformInterface.touch_dc_minus_caption
    onTouch_dc_minus_captionChanged: {
        dynoffcalCountMinusLabel.text = touch_dc_minus_caption.caption
    }

    property var touch_dc_minus_value: platformInterface.touch_dc_minus_value.value
    onTouch_dc_minus_valueChanged: {
        dynoffcalCountMinus.text = touch_dc_minus_value
    }

    property var touch_dc_minus_state: platformInterface.touch_dc_minus_state
    onTouch_dc_minus_stateChanged:{
        if(touch_dc_minus_state.state === "enabled"){
            dynoffcalCountMinusContainer.enabled = true
            dynoffcalCountMinusContainer.opacity = 1.0
        }
        else if(touch_dc_minus_state.state === "disabled"){
            dynoffcalCountMinusContainer.enabled = false
            dynoffcalCountMinusContainer.opacity = 1.0
        }
        else {
            dynoffcalCountMinusContainer.enabled = false
            dynoffcalCountMinusContainer.opacity = 0.5
        }
    }

    property var touch_sc_cdacs_caption: platformInterface.touch_sc_cdacs_caption
    onTouch_sc_cdacs_captionChanged: {
        staticCalibrationLabel.text = touch_sc_cdacs_caption.caption
    }

    property var touch_sc_cdac_values: platformInterface.touch_sc_cdac_values.values
    onTouch_sc_cdac_valuesChanged: {
        staticCalibration.model = touch_sc_cdac_values
    }

    property var touch_sc_cdac_value: platformInterface.touch_sc_cdac_value.value
    onTouch_sc_cdac_valueChanged: {
        for(var i = 0; i < staticCalibration.model.length; ++i) {
            if(touch_sc_cdac_value === staticCalibration.model[i].toString()){
                staticCalibration.currentIndex = i
            }
        }
    }


    property var touch_sc_cdac_state: platformInterface.touch_sc_cdac_state
    onTouch_sc_cdac_stateChanged: {
        if(touch_sc_cdac_state.state === "enabled"){
            staticCalibrationContainer.enabled = true
            staticCalibrationContainer.opacity = 1.0
        }
        else if(touch_sc_cdac_state.state === "disabled"){
            staticCalibrationContainer.enabled = false
            staticCalibrationContainer.opacity = 1.0
        }
        else {
            staticCalibrationContainer.enabled = false
            staticCalibrationContainer.opacity = 0.5
        }
    }


    property var touch_dc_mode_caption: platformInterface.touch_dc_mode_caption
    onTouch_dc_mode_captionChanged: {
        dynLabel.text = touch_dc_mode_caption.caption
    }

    //    property var touch_dc_mode_values: platformInterface.touch_dc_mode_values.values
    //    onTouch_dc_mode_valuesChanged: {

    //        dynSwitch.checkedLabel = touch_dc_mode_values[0]
    //        dynSwitch.uncheckedLabel =touch_dc_mode_values[1]
    //    }

    property var touch_dc_mode_value: platformInterface.touch_dc_mode_value.value
    onTouch_dc_mode_valueChanged: {
        if(touch_dc_mode_value === "Threshold")
            threshold.checked = true
        else enabled.checked = true
    }


    property var touch_dc_mode_state: platformInterface.touch_dc_mode_state
    onTouch_dc_mode_stateChanged: {
        if(touch_dc_mode_state.state === "enabled"){
            dynSwitchContainer.enabled = true
            dynSwitchContainer.opacity = 1.0
        }
        else if(touch_dc_mode_state.state === "disabled"){
            dynSwitchContainer.enabled = false
            dynSwitchContainer.opacity = 1.0
        }
        else {
            dynSwitchContainer.enabled = false
            dynSwitchContainer.opacity = 0.5
        }
    }


    property var touch_off_thres_mode_caption: platformInterface.touch_off_thres_mode_caption
    onTouch_off_thres_mode_captionChanged: {
        offsetLabel.text = touch_off_thres_mode_caption.caption
    }

    //    property var touch_off_thres_mode_values: platformInterface.touch_off_thres_mode_values.values
    //    onTouch_off_thres_mode_valuesChanged: {
    //        offsetSwitch.checkedLabel = touch_off_thres_mode_values[0]
    //        offsetSwitch.uncheckedLabel = touch_off_thres_mode_values[1]
    //    }

    property var touch_off_thres_mode_value: platformInterface.touch_off_thres_mode_value.value
    onTouch_off_thres_mode_valueChanged: {
        if(touch_off_thres_mode_value === "0.5 Peak")
            peak2.checked = true
        else peak1.checked = true

    }

    property var touch_off_thres_mode_state: platformInterface.touch_off_thres_mode_state
    onTouch_off_thres_mode_stateChanged: {
        if(touch_off_thres_mode_state.state === "enabled"){
            offsetContainer.enabled = true
            offsetContainer.opacity = 1.0
        }
        else if(touch_off_thres_mode_state.state === "disabled"){
            offsetContainer.enabled = false
            offsetContainer.opacity = 1.0
        }
        else {
            offsetContainer.enabled = false
            offsetContainer.opacity = 0.5
        }
    }


    property var touch_cref0_7_caption: platformInterface.touch_cref0_7_caption
    onTouch_cref0_7_captionChanged: {
        cin07SwitchLabel.text = touch_cref0_7_caption.caption
    }

    property var touch_cref0_7_value: platformInterface.touch_cref0_7_value.value
    onTouch_cref0_7_valueChanged: {
        if(touch_cref0_7_value === "CREF+CADD")
            cREFCADD.checked = true
        else
            cREF.checked = true
    }

    //    property var touch_cref0_7_values: platformInterface.touch_cref0_7_values.values
    //    onTouch_cref0_7_valuesChanged: {
    //        cin07Switch.checkedLabel = touch_cref0_7_values[0]
    //        cin07Switch.uncheckedLabel = touch_cref0_7_values[1]
    //    }

    property var touch_cref0_7_state: platformInterface.touch_cref0_7_state
    onTouch_cref0_7_stateChanged: {
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
    }

    property var touch_cref8_15_caption: platformInterface.touch_cref8_15_caption
    onTouch_cref8_15_captionChanged: {
        cin815SwitchLabel.text = touch_cref8_15_caption.caption
    }

    //    property var touch_cref8_157_values: platformInterface.touch_cref8_157_values.values
    //    onTouch_cref8_157_valuesChanged: {

    //        cin815Switch.checkedLabel = touch_cref8_157_values[0]
    //        cin815Switch.uncheckedLabel = touch_cref8_157_values[1]
    //    }
    property var touch_cref8_15_value: platformInterface.touch_cref8_15_value.value
    onTouch_cref8_15_valueChanged: {
        if(touch_cref8_15_value === "CREF+CADD")
            cREFCADDCin815.checked = true
        else cREFCin815.checked = true

    }
    property var touch_cref8_15_state: platformInterface.touch_cref8_15_state
    onTouch_cref8_15_stateChanged: {
        if(touch_cref8_15_state.state === "enabled"){
            cin815SwitchContainer.enabled = true
            cin815SwitchContainer.opacity = 1.0
        }
        else if(touch_cref8_15_state.state === "disabled"){
            cin815SwitchContainer.enabled = false
            cin815SwitchContainer.opacity = 1.0
        }
        else {
            cin815SwitchContainer.enabled = false
            cin815SwitchContainer.opacity = 0.5
        }
    }

    property var touch_li_start_caption: platformInterface.touch_li_start_caption
    onTouch_li_start_captionChanged: {
        longIntervalStartLabel.text = touch_li_start_caption.caption
    }

    property var touch_li_start_scales: platformInterface.touch_li_start_scales
    onTouch_li_start_scalesChanged: {
        longIntervalStartSlider.to = touch_li_start_scales.scales[0]
        longIntervalStartSlider.from = touch_li_start_scales.scales[1]
        longIntervalStartSlider.stepSize = touch_li_start_scales.scales[2]
    }

    property var touch_li_start_value: platformInterface.touch_li_start_value.value
    onTouch_li_start_valueChanged: {
        longIntervalStartSlider.value = touch_li_start_value
    }

    property var touch_li_start_state: platformInterface.touch_li_start_state
    onTouch_li_start_stateChanged: {
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

    property var touch_first_gain8_15_caption: platformInterface.touch_first_gain8_15_caption
    onTouch_first_gain8_15_captionChanged : {
        cin815CREFLabel.text = touch_first_gain8_15_caption.caption
    }

    property var touch_first_gain8_15_values: platformInterface.touch_first_gain8_15_values.values
    onTouch_first_gain8_15_valuesChanged: {
        cin815CREF.model = touch_first_gain8_15_values
    }

    property var touch_first_gain8_15_value: platformInterface.touch_first_gain8_15_value.value
    onTouch_first_gain8_15_valueChanged: {
        console.log(touch_first_gain8_15_value)
        for(var i = 0; i < cin815CREF.model.length; ++i) {
            if(i === 0 || i === 15) {
                if(touch_first_gain8_15_value === cin815CREF.model[i].slice(0,-3).toString()){
                    cin815CREF.currentIndex = i
                }
            }
            else {
                if(touch_first_gain8_15_value === cin815CREF.model[i].toString()){
                    cin815CREF.currentIndex = i
                }
            }
        }
    }

    property var touch_first_gain8_15_state: platformInterface.touch_first_gain8_15_state.state
    onTouch_first_gain8_15_stateChanged: {

        if(touch_first_gain8_15_state === "enabled"){
            cin815CREFContainer.enabled = true
        }
        else if(touch_first_gain8_15_state=== "disabled"){
            cin815CREFContainer.enabled = false
        }
        else {
            cin815CREFContainer.enabled = false
            cin815CREFContainer.opacity = 0.5
        }
    }


    property var touch_first_gain0_7_caption: platformInterface.touch_first_gain0_7_caption
    onTouch_first_gain0_7_captionChanged:{
        cin07CREFLabel.text = touch_first_gain0_7_caption.caption
    }

    property var touch_first_gain0_7_values: platformInterface.touch_first_gain0_7_values.values
    onTouch_first_gain0_7_valuesChanged: {
        cin07CREF.model = touch_first_gain0_7_values
    }

    property var touch_first_gain0_7_value: platformInterface.touch_first_gain0_7_value.value
    onTouch_first_gain0_7_valueChanged:{
        for(var i = 0; i < cin07CREF.model.length; ++i) {
            if(i === 0 || i === 15) {
                if(touch_first_gain0_7_value === cin07CREF.model[i].slice(0,-3).toString()){
                    cin07CREF.currentIndex = i
                }
            }
            else {
                if(touch_first_gain0_7_value === cin07CREF.model[i].toString()){
                    cin07CREF.currentIndex = i
                }
            }
        }
    }

    property var touch_first_gain0_7_state: platformInterface.touch_first_gain0_7_state.state
    onTouch_first_gain0_7_stateChanged: {

        if(touch_first_gain0_7_state === "enabled"){
            cin07CREFContainer.enabled = true
        }
        else if(touch_first_gain0_7_state === "disabled"){
            cin07CREFContainer.enabled = false
        }
        else {
            cin07CREFContainer.enabled = false
            cin07CREFContainer.opacity = 0.5
        }
    }



    property var touch_calerr_caption: platformInterface.touch_calerr_caption
    onTouch_calerr_captionChanged:  {
        calerrLabel.text = touch_calerr_caption.caption
    }

    property var touch_calerr_value: platformInterface.touch_calerr_value.value
    onTouch_calerr_valueChanged: {
        if(touch_calerr_value === "0")
            calerrLight.status = SGStatusLight.Off
        else calerrLight.status = SGStatusLight.Red
    }

    function set_default_LC717_values() {

        platformInterface.touch_register_cin = platformInterface.default_touch_register_cin
        platformInterface.touch_cin_en_values = platformInterface.default_touch_cin_en.values
        touch_cin_thres_values_lc717 = platformInterface.default_touch_cin_thres.values
        touch_second_gain_values_lc717 = platformInterface.default_touch_second_gain.values
        touch_mode_value = platformInterface.default_touch_mode.value
        touch_average_count_value = platformInterface.default_touch_average_count.value
        touch_filter_parameter1_value = platformInterface.default_touch_filter_parameter1.value
        touch_filter_parameter2_value = platformInterface.default_touch_filter_parameter2.value
        touch_dct1_value = platformInterface.default_touch_dct1.value
        touch_dct2_value = platformInterface.default_touch_dct2.value
        touch_sival_value = platformInterface.default_touch_sival.value
        touch_lival_value = platformInterface.default_touch_lival.value
        touch_si_dc_cycl_value = platformInterface.default_touch_si_dc_cyc.value
        touch_dc_plus_value = platformInterface.default_touch_dc_plus.value
        touch_dc_minus_value = platformInterface.touch_dc_minus.value
        touch_sc_cdac_value = platformInterface.default_touch_sc_cdac.value
        touch_dc_mode_value = platformInterface.default_touch_dc_mode.value
        touch_off_thres_mode_value = platformInterface.default_touch_off_thres_mode.value
        touch_cref0_7_value = platformInterface.default_touch_cref0_7.value
        touch_cref8_15_value =  platformInterface.default_touch_cref8_15.value
        touch_li_start_value = platformInterface.default_touch_li_start.value
        touch_first_gain0_7_value = platformInterface.default_touch_first_gain0_7.value
        touch_first_gain0_7_state = platformInterface.default_touch_first_gain0_7.state
        touch_first_gain8_15_state = platformInterface.default_touch_first_gain8_15.state
        touch_first_gain8_15_value = platformInterface.default_touch_first_gain8_15.value

        var default_touch_calerr = platformInterface.default_touch_calerr.value
        if(default_touch_calerr === "0")
            calerrLight.status = SGStatusLight.Off
        else calerrLight.status = SGStatusLight.Red

        var touch_syserr_value = platformInterface.default_touch_syserr.value
        if(touch_syserr_value === "0")
            syserrLight.status = SGStatusLight.Off
        else syserrLight.status = SGStatusLight.Red

        eachSensor = []

    }

    property var touch_calerr_state: platformInterface.touch_calerr_state.state
    onTouch_calerr_stateChanged: {
        if(touch_calerr_state === "enabled") {

            calerrLightContainer.enabled = true
            calerrLightContainer.opacity = 1.0
        }
        else if (touch_calerr_state === "disabled") {
            calerrLightContainer.enabled = false
            calerrLightContainer.opacity = 1.0
        }
        else {
            calerrLightContainer.enabled = false
            calerrLightContainer.opacity = 0.5
        }
    }


    property var touch_syserr_caption: platformInterface.touch_syserr_caption
    onTouch_syserr_captionChanged: {
        syserrLabel.text = touch_syserr_caption.caption
    }

    property var touch_syserr_value: platformInterface.touch_syserr_value.value
    onTouch_syserr_valueChanged: {
        if(touch_syserr_value === "0")
            syserrLight.status = SGStatusLight.Off
        else syserrLight.status = SGStatusLight.Red
    }

    property var touch_syserr_state: platformInterface.touch_syserr_state.state
    onTouch_syserr_stateChanged: {
        if(touch_syserr_state === "enabled") {
            syserrLightContainer.enabled = true
            syserrLightContainer.opacity = 1.0
        }
        else if (touch_syserr_state === "disabled") {
            syserrLightContainer.enabled = false
            syserrLightContainer.opacity = 1.0
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
            Layout.preferredHeight: parent.height/4
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
                                target: modeRadioButton
                                text: "<b>" + qsTr("Mode") + "</b>"
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideTopLeft

                                anchors.verticalCenter: parent.verticalCenter

                                SGRadioButtonContainer {
                                    id: modeRadioButton
                                    columns: 1
                                    SGRadioButton {
                                        id: interval
                                        text: "Interval"
                                        checked: true
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        radioSize:  ratioCalc * 15
                                        onToggled: {
                                            if(checked)

                                                platformInterface.set_touch_mode_value.update("Interval")
                                            else
                                                platformInterface.set_touch_mode_value.update("Sleep")

                                        }
                                    }

                                    SGRadioButton {
                                        id: sleep
                                        text: "Sleep"
                                        radioSize:  ratioCalc * 15
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_mode_value.update("Sleep")
                                            else
                                                platformInterface.set_touch_mode_value.update("Interval")
                                        }

                                    }

                                }

                                //                                CustomizeSwitch {
                                //                                    id: modeSwitch
                                //                                    labelsInside: false
                                //                                    uncheckedLabel: "Sleep"
                                //                                    checkedLabel: "Interval"
                                //                                    textColor: "black"              // Default: "black"
                                //                                    handleColor: "white"            // Default: "white"
                                //                                    grooveColor: "#ccc"             // Default: "#ccc"
                                //                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                //                                    fontSizeMultiplier: ratioCalc

                                //                                    checked: false
                                //                                    onToggled: {
                                //                                        if(checked)
                                //                                            platformInterface.set_touch_mode_value.update("Interval")
                                //                                        else  platformInterface.set_touch_mode_value.update("Sleep")
                                //                                    }
                                //                                }
                            }
                        }


                        Rectangle {
                            id: cin07SwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:cin07SwitchLabel
                                target: cin07radioButton
                                // text:  "CIN0-7 CREF "
                                font.bold: true
                                fontSizeMultiplier: ratioCalc

                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter


                                SGRadioButtonContainer {
                                    id: cin07radioButton
                                    columns: 1
                                    SGRadioButton {
                                        id: cREFCADD
                                        text: "CREF+CADD"
                                        checked: true
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        radioSize:  ratioCalc * 15
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_cref0_7_value.update("CREF+CADD")
                                            else
                                                platformInterface.set_touch_cref0_7_value.update("CREF")

                                        }
                                    }

                                    SGRadioButton {
                                        id: cREF
                                        text: "CREF"
                                        radioSize:  ratioCalc * 15
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_cref0_7_value.update("CREF")
                                            else
                                                platformInterface.set_touch_cref0_7_value.update("CREF+CADD")
                                        }

                                    }

                                }
                                //                                CustomizeSwitch {
                                //                                    id: cin07Switch
                                //                                    labelsInside: false
                                //                                    //                                    checkedLabel: "CREF \n + CREFADD"
                                //                                    //                                    uncheckedLabel: "CREF"
                                //                                    textColor: "black"              // Default: "black"
                                //                                    handleColor: "white"            // Default: "white"
                                //                                    grooveColor: "#ccc"             // Default: "#ccc"
                                //                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                //                                    checked: false
                                //                                    fontSizeMultiplier: ratioCalc * 0.9
                                //                                    onToggled:  {
                                //                                        if(checked)
                                //                                            platformInterface.set_touch_cref0_7_value.update("CREF+CADD")
                                //                                        else platformInterface.set_touch_cref0_7_value.update("CREF")

                                //                                    }
                                //                                }
                            }
                        }


                        Rectangle {
                            id: cin815SwitchContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:cin815SwitchLabel
                                target: cin815radioButton
                                //text:  "CIN8-15 CREF "
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                SGRadioButtonContainer {
                                    id: cin815radioButton
                                    columns: 1
                                    SGRadioButton {
                                        id: cREFCADDCin815
                                        text: "CREF+CADD"
                                        checked: true
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        radioSize:  ratioCalc * 15
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_cref8_15_value.update("CREF+CADD")
                                            else
                                                platformInterface.set_touch_cref8_15_value.update("CREF")

                                        }
                                    }

                                    SGRadioButton {
                                        id: cREFCin815
                                        text: "CREF"
                                        radioSize:  ratioCalc * 15
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_cref8_15_value.update("CREF")
                                            else
                                                platformInterface.set_touch_cref8_15_value.update("CREF+CADD")
                                        }

                                    }

                                }

                                //                                CustomizeSwitch {
                                //                                    id: cin815Switch
                                //                                    labelsInside: false
                                //                                    //checkedLabel: "CREF \n + CREFADD"
                                //                                    //uncheckedLabel: "CREF"
                                //                                    textColor: "black"              // Default: "black"
                                //                                    handleColor: "white"            // Default: "white"
                                //                                    grooveColor: "#ccc"             // Default: "#ccc"
                                //                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                //                                    checked: false
                                //                                    fontSizeMultiplier: ratioCalc * 0.9
                                //                                    onToggled:  {
                                //                                        if(checked)
                                //                                            platformInterface.set_touch_cref8_15_value.update("CREF+CADD")
                                //                                        else  platformInterface.set_touch_cref8_15_value.update("CREF")

                                //                                    }
                                //                                }
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
                                    onClicked: {

                                        platformInterface.set_touch_export_registers.update()
                                        saveFileDialog.open()

                                    }

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
                                fontSizeMultiplier: ratioCalc
                                font.bold : true



                                SGComboBox {
                                    id: cin07CREF
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    KeyNavigation.tab: cin815CREF
                                    onActivated: {
                                        if(currentIndex === 0 || currentIndex === 15)
                                            platformInterface.set_touch_first_gain0_7_value.update(currentText.slice(0,-3))
                                        else  platformInterface.set_touch_first_gain0_7_value.update(currentText)
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
                                fontSizeMultiplier: ratioCalc
                                font.bold : true

                                SGComboBox {
                                    id: cin815CREF
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    KeyNavigation.tab: avgCount
                                    onActivated: {
                                        platformInterface.set_touch_first_gain8_15_value.update(currentText)
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
            Layout.preferredHeight: parent.height/4
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
                                fontSizeMultiplier: ratioCalc
                                font.bold : true

                                SGComboBox {
                                    id: avgCount
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    model: [8,16,32,64,128]
                                    KeyNavigation.tab: filter1
                                    onActivated: {
                                        platformInterface.set_touch_average_count_value.update(currentText)
                                    }
                                }
                            }
                        }


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
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }


                                    KeyNavigation.tab: debouce1
                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 15) {
                                            filter1.text = 15
                                        }
                                        if (value < 0) {
                                            filter1.text = 0
                                        }
                                        platformInterface.set_touch_filter_parameter1_value.update(filter1.text)
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
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: filter2

                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            debouce1.text = 255
                                        }
                                        if (value < 0) {
                                            debouce1.text = 0
                                        }
                                        platformInterface.set_touch_dct1_value.update(debouce1.text)

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
                            id: offsetContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id:offsetLabel
                                target: offsetradioButton
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter

                                SGRadioButtonContainer {
                                    id: offsetradioButton
                                    columns: 1
                                    SGRadioButton {
                                        id: peak1
                                        text: "0.75 Peak"
                                        checked: true
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        radioSize:  ratioCalc * 15
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_off_thres_mode_value.update("0.75 Peak")
                                            else platformInterface.set_touch_off_thres_mode_value.update("0.5 Peak")

                                        }
                                    }

                                    SGRadioButton {
                                        id: peak2
                                        text: "0.5 Peak"
                                        radioSize:  ratioCalc * 15
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        onToggled: {
                                            if(checked)
                                                platformInterface.set_touch_off_thres_mode_value.update("0.5 Peak")
                                            else platformInterface.set_touch_off_thres_mode_value.update("0.75 Peak")

                                        }

                                    }

                                }

                                //                                CustomizeSwitch {
                                //                                    id: offsetSwitch
                                //                                    labelsInside: false

                                //                                    textColor: "black"              // Default: "black"
                                //                                    handleColor: "white"            // Default: "white"
                                //                                    grooveColor: "#ccc"             // Default: "#ccc"
                                //                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                //                                    checked: false
                                //                                    fontSizeMultiplier: ratioCalc * 0.9
                                //                                    onToggled:  {
                                //                                        if(checked)
                                //                                            platformInterface.set_touch_off_thres_mode_value.update("0.75 Peak")
                                //                                        else platformInterface.set_touch_off_thres_mode_value.update("0.5 Peak")
                                //                                    }
                                //                                }
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
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: debouce2


                                    onEditingFinished: {
                                        var value = parseInt(text)
                                        if(value > 15) {
                                            filter2.text = 15
                                        }
                                        if (value < 0) {
                                            filter2.text = 0
                                        }
                                        platformInterface.set_touch_filter_parameter2_value.update(filter2.text)

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
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: shortInterval
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            debouce2.text = 255
                                        }
                                        if (value < 0) {
                                            debouce2.text = 0
                                        }
                                        platformInterface.set_touch_dct2_value.update(debouce2.text)

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
                text: "Interval & Calibration"
                font.bold: true
                font.pixelSize: ratioCalc * 15
                color: "#696969"
                anchors {
                    top: parent.top
                    topMargin: 2
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
                    topMargin: 6
                }
            }
            ColumnLayout {
                anchors {
                    top: line3.bottom
                    topMargin: 10
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: 5
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
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }

                                    KeyNavigation.tab: longInterval
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            shortInterval.text = 255
                                        }
                                        if (value < 0) {
                                            shortInterval.text = 0
                                        }
                                        platformInterface.set_touch_sival_value.update(shortInterval.text)

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
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: longIntervalStartSlider.inputBox
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 355) {
                                            longInterval.text = 355
                                        }
                                        if (value < 0) {
                                            longInterval.text = 0
                                        }
                                        platformInterface.set_touch_lival_value.update(longInterval.text)

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
                                target: dynradioButton
                                //text:  "Dyn Off Cal Mode"
                                font.bold: true
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter


                                SGRadioButtonContainer {
                                    id: dynradioButton
                                    columns: 1
                                    SGRadioButton {
                                        id: threshold
                                        text: "Threshold"
                                        checked: true
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        radioSize:  ratioCalc * 15
                                        onToggled:  {
                                            if(checked)
                                                platformInterface.set_touch_dc_mode_value.update("Threshold")
                                            else  platformInterface.set_touch_dc_mode_value.update("Enabled")

                                        }
                                    }

                                    SGRadioButton {
                                        id: enabled
                                        text: "Enabled"
                                        radioSize:  ratioCalc * 15
                                        fontSizeMultiplier: ratioCalc * 0.8
                                        onToggled:  {
                                            if(checked)
                                                platformInterface.set_touch_dc_mode_value.update("Enabled")
                                            else  platformInterface.set_touch_dc_mode_value.update("Threshold")

                                        }
                                    }

                                }

                                //                                CustomizeSwitch {
                                //                                    id: dynSwitch
                                //                                    labelsInside: false
                                //                                    //                                    checkedLabel: "Threshold"
                                //                                    //                                    uncheckedLabel: "Enabled \n Text"
                                //                                    textColor: "black"              // Default: "black"
                                //                                    handleColor: "white"            // Default: "white"
                                //                                    grooveColor: "#ccc"             // Default: "#ccc"
                                //                                    grooveFillColor: "#0cf"         // Default: "#0cf"
                                //                                    checked: false
                                //                                    fontSizeMultiplier: ratioCalc * 0.9
                                //                                    onToggled:  {
                                //                                        if(checked)
                                //                                            platformInterface.set_touch_dc_mode_value.update("Threshold")
                                //                                        else  platformInterface.set_touch_dc_mode_value.update("Enabled")

                                //                                    }
                                //                                }
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
                            Layout.preferredWidth: parent.width/1.6
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: longIntervalStartLabel
                                target: longIntervalStartSlider
                                fontSizeMultiplier: ratioCalc
                                font.bold : true
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.centerIn: parent

                                SGSlider {
                                    id: longIntervalStartSlider
                                    width: longIntervalStartSliderContainer.width - 10
                                    live: false

                                    fontSizeMultiplier: ratioCalc * 0.8
                                    KeyNavigation.tab: staticCalibration
                                    inputBox.validator: DoubleValidator {
                                        top: longIntervalStartSlider.to
                                        bottom: longIntervalStartSlider.from
                                    }
                                    onUserSet: {
                                        platformInterface.set_touch_li_start_value.update(value)
                                    }

                                }
                            }
                        }
                        Rectangle{
                            id: staticCalibrationContainer
                            Layout.preferredWidth: parent.width/3.2
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: staticCalibrationLabel
                                target: staticCalibration

                                alignment: SGAlignedLabel.SideTopLeft

                                fontSizeMultiplier: ratioCalc
                                font.bold : true
                                anchors.verticalCenter: parent.verticalCenter
                                SGComboBox {
                                    id: staticCalibration
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    KeyNavigation.tab: dynoffcalCountPlus
                                    onActivated: {
                                        platformInterface.set_touch_sc_cdac_value.update(currentText)
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
                        spacing: 15
                        Rectangle {
                            id: dynoffcalCountPlusContainer
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            SGAlignedLabel {
                                id: dynoffcalCountPlusLabel
                                target: dynoffcalCountPlus

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
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: dynoffcalCountMinus
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            dynoffcalCountPlus.text = 255
                                        }
                                        if (value < 0) {
                                            dynoffcalCountPlus.text = 0
                                        }
                                        platformInterface.set_touch_dc_plus_value.update(dynoffcalCountPlus.text)
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
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }

                                    KeyNavigation.tab: shortIntervalDyn
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            dynoffcalCountMinus.text = 255
                                        }
                                        if (value < 0) {
                                            dynoffcalCountMinus.text = 0
                                        }
                                        platformInterface.set_touch_dc_minus_value.update(dynoffcalCountMinus.text)

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
                                anchors.leftMargin: -7

                                SGSubmitInfoBox {
                                    id: shortIntervalDyn
                                    fontSizeMultiplier: ratioCalc * 0.9
                                    width: 100 * ratioCalc
                                    placeholderText: "0-255"
                                    validator: IntValidator {
                                        bottom:  -2147483647
                                        top: 2147483647
                                    }
                                    KeyNavigation.tab: cin07CREF
                                    onEditingFinished: {
                                        var value = parseInt(text)

                                        if(value > 255) {
                                            shortIntervalDyn.text = 255
                                        }
                                        if (value < 0) {
                                            shortIntervalDyn.text = 0
                                        }
                                        platformInterface.set_touch_si_dc_cyc.update(shortIntervalDyn.text)
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
            Layout.preferredHeight: parent.height/9
            Text {
                id: systemDebug
                text: "System & Debug"
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
                                text: qsTr("Static Offset \n Calibration")
                                anchors.verticalCenter: parent.verticalCenter
                                fontSizeMultiplier: ratioCalc
                                color: checked ? "#353637" : pressed ? "#cfcfcf": hovered ? "#eee" : "#e0e0e0"
                                hoverEnabled: true
                                MouseArea {
                                    hoverEnabled: true
                                    anchors.fill: parent
                                    cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        warningPopup.open()
                                        platformInterface.set_touch_static_offset_cal.update()
                                        popupMessage = "Performing Static Offset Calibration"
                                    }

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
                                    onClicked: {
                                        warningPopup.open()
                                        popupMessage = "Performing Hardware Reset"
                                        platformInterface.touch_reset.update()
                                        //set_default_LC717_values()



                                    }



                                }

                            }
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
                                    onClicked: {
                                        warningPopup.open()
                                        platformInterface.set_touch_sw_reset_value.update()
                                        popupMessage = "Performing Software Reset"
                                        //set_default_LC717_values()
                                    }
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
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                SGStatusLight {
                                    id: syserrLight
                                    width: 30

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
                                fontSizeMultiplier: ratioCalc
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
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
