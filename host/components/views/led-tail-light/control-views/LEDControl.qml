import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width

    property var helpTourCount: 0

    Item {
        id: filterHelpContainer1
        property point topLeft
        property point bottomRight
        width:  (out11ENLED.width) * 13.2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out11ENLED.mapToItem(root, 0,  0)
            bottomRight = out0ENLED.mapToItem(root, out0ENLED.width, out0ENLED.height)
        }
    }

    Item {
        id: filterHelpContainer2
        property point topLeft
        property point bottomRight
        width:  (out11interExterLED.width) * 13.2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out11interExterLED.mapToItem(root, 0,  0)
            bottomRight = out0interExterLED.mapToItem(root, out0interExterLED.width, out0interExterLED.height)
        }
    }

    Item {
        id: filterHelpContainer3
        property point topLeft
        property point bottomRight
        width:  (out11pwmEnableLED.width) * 13.2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out11pwmEnableLED.mapToItem(root, 0,  0)
            bottomRight = out0pwmEnableLED.mapToItem(root, out0pwmEnableLED.width, out0pwmEnableLED.height)
        }
    }

    Item {
        id: filterHelpContainer4
        property point topLeft
        property point bottomRight
        width:  (out11faultStatusLEDContainer.width) * 13.2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out11faultStatusLEDContainer.mapToItem(root, 0,  0)
            bottomRight = out0faultStatusLEDContainer.mapToItem(root, out0faultStatusLEDContainer.width, out0faultStatusLEDContainer.height)
        }
    }

    Item {
        id: filterHelpContainer5
        property point topLeft
        property point bottomRight
        width:  (out11dutyContainer.width) * 13.2
        height: (bottomRight.y - topLeft.y)
        x: topLeft.x
        y: topLeft.y
        function update() {
            topLeft = out11dutyContainer.mapToItem(root, 0,  0)
            bottomRight = out0dutyContainer.mapToItem(root, out0dutyContainer.width, out0dutyContainer.height)
        }
    }

    onWidthChanged: {
        filterHelpContainer1.update()
        filterHelpContainer2.update()
        filterHelpContainer3.update()
        filterHelpContainer4.update()
        filterHelpContainer5.update()
    }
    onHeightChanged: {
        filterHelpContainer1.update()
        filterHelpContainer2.update()
        filterHelpContainer3.update()
        filterHelpContainer4.update()
        filterHelpContainer5.update()
    }

    Connections {
        target: Help.utility
        onTour_runningChanged:{
            filterHelpContainer1.update()
            filterHelpContainer2.update()
            filterHelpContainer3.update()
            filterHelpContainer4.update()
            filterHelpContainer5.update()
        }
    }

    Connections{
        target: helpMouse
        onClicked: {
            if(visible) {
                if(helpTourCount === 0) {
                    Help.registerTarget(partNumber, "Indication of LED driver part assembled on PCB. The part number is reported to the user interface based on state of a GPIO pin PD9, low = NCV7684, high = NCV7685. The other LED driver can be installed if the state of the PD9 pin properly reflects the installed LED driver. See schematic and user manual for details on conversion to alternate LED driver.", 0, "ledDriverHelp")
                    Help.registerTarget(enableOutput,"Toggles the output enable pin of the NCV7685. The NCV7684 does not support output enable.",1,"ledDriverHelp")
                    Help.registerTarget(gobalCurrentSetSlider,"Sets the maximum current for each individual LED channel. A minimum 0mA set value may create an error in the SC_Iset indicator.",2,"ledDriverHelp")
                    Help.registerTarget(pwmenableOutput,"Activates the PWM dimming feature of the LED driver. User interface controls related to PWM will be disabled when PWM is disabled.",3,"ledDriverHelp")
                    Help.registerTarget(lockPWMDutyEN,"Locks together the PWM enable or disable state for all LED channels. Use OUT1 PWM Enable switch to control all channels when locked together.",4,"ledDriverHelp")
                    Help.registerTarget(lockPWMDuty,"Locks together the PWM duty cycle for all LED channels. Use OUT1 PWM Duty slider to control all channels when locked together. The duty cycles are always locked together for the NCV7684 because it only has one duty cycle for all channels.",5,"ledDriverHelp")
                    Help.registerTarget(pwmLinearLog,"Selects between logarithmic and linear translation of PWM Duty value.",6,"ledDriverHelp")
                    Help.registerTarget(pwmFrequency,"Sets the PWM frequency. This list varies depending on if the NCV7684 or NCV7685 is connected.",7,"ledDriverHelp")
                    Help.registerTarget(filterHelpContainer1, "Toggles each LED on or off. This control is ignored if PWM is enabled for a specific channel.", 8, "ledDriverHelp")
                    Help.registerTarget(filterHelpContainer2, "Toggles each LED to use either onboard LEDs or externally connected LEDs through 24 pin header at the top of the PCB.", 9, "ledDriverHelp")
                    Help.registerTarget(filterHelpContainer3, "Toggles PWM for each LED channel on or off. If PWM is disabled, these controls will also be disabled." , 10, "ledDriverHelp")
                    Help.registerTarget(filterHelpContainer4, "Indicates fault on each LED channel. Disabled unless I2C/SAM Open Load Diagnostic control set to 'Diagnostic Only' or 'Auto Retry' and diagRange indicator is green (VLED above DIAGEN threshold)." , 11, "ledDriverHelp")
                    Help.registerTarget(filterHelpContainer5, "Sets the duty cycle of the PWM for each LED channel with 128 step resolution. Maximum and minimum duty cycles will switch LED fully on and off respectively. If PWM is disabled, these controls will also be disabled. The duty cycles are always locked together for the NCV7684 because it does not have this capability. The duty cycles for the NCV7685 can be individually controlled or locked together using the Lock PWM Duty Together control.", 12, "ledDriverHelp")
                    Help.registerTarget(diag,"Generic diagnostic error when any LED channel is in an error mode or when I2C Status Registers contain error.",13,"ledDriverHelp")
                    Help.registerTarget(openLoadDiagnostic,"Sets the diagnostic state of the LED driver in I2C mode. This control will be disabled unless diagRange is on.\n\nNo Diagnostic = No open load detection is performed\n\nAuto Retry = During open load fault, 1) DIAG pin is pulled low, 2) low current is imposed on faulty channel only, 3) other channels turned off. If fault is recovered DIAG is released and normal operation continues.\n\nDiagnostic Only = During open load fault, the DIAG pin is pulled low with no change to current regulation. DIAG is released when the fault is recovered.",14,"ledDriverHelp")
                    Help.registerTarget(scIset,"Set when the ISET pin is short-circuited to ground. A minimum 0mA set value in Global Current Set (ISET) control may create this error.",15,"ledDriverHelp")
                    Help.registerTarget(i2Cerr,"Set if an error has been detected during the I2C communication. Reset on register read.",16,"ledDriverHelp")
                    Help.registerTarget(uv,"Set if under voltage condition when VS is below VSUV (4.1V typical). All channels will be turned off.",17,"ledDriverHelp")
                    Help.registerTarget(diagRange,"Set when divided voltage is above the VDiagenTH threshold and reset when below. Default voltage threshold is fixed on this PCB to 7.5V. User can adjust this threshold with the onboard potentiometer by removing lower divider resistor and shorting jumper.",18,"ledDriverHelp")
                    Help.registerTarget(tw,"Thermal warning that is set when junction temperature is above the Tjwar_on threshold (140°C typical) and reset on register read and when temperature is below Tjwar_on minus Tjsd_hys threshold (127.5Â°C typical).",19,"ledDriverHelp")
                    Help.registerTarget(tsd,"Thermal shutdown set when junction temperature is above the TSD threshold (170°C typical) and reset on register read and when temperature is below TSD minus Tjsd_hys threshold (157.5Â°C typical).",20,"ledDriverHelp")
                    Help.registerTarget(diagerr,"Set when the DIAG pin is forced low externally.",21,"ledDriverHelp")
                    Help.registerTarget(ol,"Set when at least one LED channel is in an open load and resets after load is applied. Disabled unless I2C/SAM Open Load Diagnostic control set to 'Diagnostic Only' or 'Auto Retry' and diagRange indicator is green (VLED above DIAGEN threshold). The OL indicator may flicker or show no error when open load is detected in 'Diagnostic Only' because the OL register bit is repetitively reset by the LED driver.",22,"ledDriverHelp")
                    helpTourCount++
                    Help.startHelpTour("ledDriverHelp")
                }
                else   {
                    Help.startHelpTour("ledDriverHelp")
                }
            }
        }
    }

    Component.onCompleted: {

    }

    function setStateForPWMDuty(pwmDutyid,index)
    {
        if(index !== "undefined") {
            if(index === 0) {
                pwmDutyid.enabled = true
                pwmDutyid.opacity = 1.0
            }
            else if (index === 1) {
                pwmDutyid.enabled = false
                pwmDutyid.opacity = 1.0
            }
            else {
                pwmDutyid.enabled = false
                pwmDutyid.opacity = 0.5
            }
        }
    }

    function setOutEnState(outputEnable,index) {
        if(index !==  "undefined")  {
            if(index === 0) {
                outputEnable.enabled = true
                outputEnable.opacity = 1.0
            }
            else if(index === 1) {
                outputEnable.enabled = false
                outputEnable.opacity = 1.0
            }
            else {
                outputEnable.enabled = false
                outputEnable.opacity = 0.5
            }
        }
    }

    function setStatesForControls (theId, index){
        if(index !== null && index !== undefined)  {
            if(index === 0) {
                theId.enabled = true
                theId.opacity = 1.0
            }
            else if(index === 1) {
                theId.enabled = false
                theId.opacity = 1.0
            }
            else {
                theId.enabled = false
                theId.opacity = 0.5
            }
        }
    }

    property var led_out_en: platformInterface.led_out_en
    onLed_out_enChanged: {
        ledoutEnLabel.text =  led_out_en.caption
        setOutEnState(out0ENLED,led_out_en.states[0])
        setOutEnState(out1ENLED,led_out_en.states[1])
        setOutEnState(out2ENLED,led_out_en.states[2])
        setOutEnState(out3ENLED,led_out_en.states[3])
        setOutEnState(out4ENLED,led_out_en.states[4])
        setOutEnState(out5ENLED,led_out_en.states[5])
        setOutEnState(out6ENLED,led_out_en.states[6])
        setOutEnState(out7ENLED,led_out_en.states[7])
        setOutEnState(out8ENLED,led_out_en.states[8])
        setOutEnState(out9ENLED,led_out_en.states[9])
        setOutEnState(out10ENLED,led_out_en.states[10])
        setOutEnState(out11ENLED,led_out_en.states[11])


        if(led_out_en.values[0] === true)
            out0ENLED.checked = true
        else out0ENLED.checked = false

        if(led_out_en.values[1] === true)
            out1ENLED.checked = true
        else out1ENLED.checked = false

        if(led_out_en.values[2] === true)
            out2ENLED.checked = true
        else out2ENLED.checked = false

        if(led_out_en.values[3] === true)
            out3ENLED.checked = true
        else out3ENLED.checked = false

        if(led_out_en.values[4] === true)
            out4ENLED.checked = true
        else out4ENLED.checked = false

        if(led_out_en.values[5] === true)
            out5ENLED.checked = true
        else out5ENLED.checked = false

        if(led_out_en.values[6] === true)
            out6ENLED.checked = true
        else out6ENLED.checked = false

        if(led_out_en.values[7] === true)
            out7ENLED.checked = true
        else out7ENLED.checked = false

        if(led_out_en.values[8] === true)
            out8ENLED.checked = true
        else out8ENLED.checked = false

        if(led_out_en.values[9] === true)
            out9ENLED.checked = true
        else out9ENLED.checked = false

        if(led_out_en.values[10] === true)
            out10ENLED.checked = true
        else out10ENLED.checked = false

        if(led_out_en.values[11] === true)
            out11ENLED.checked = true
        else out11ENLED.checked = false

        platformInterface.outputEnable0 = led_out_en.values[0]
        platformInterface.outputEnable1 = led_out_en.values[1]
        platformInterface.outputEnable2 = led_out_en.values[2]
        platformInterface.outputEnable3 = led_out_en.values[3]
        platformInterface.outputEnable4 = led_out_en.values[4]
        platformInterface.outputEnable5 = led_out_en.values[5]
        platformInterface.outputEnable6 = led_out_en.values[6]
        platformInterface.outputEnable7 = led_out_en.values[7]
        platformInterface.outputEnable8 = led_out_en.values[8]
        platformInterface.outputEnable9 = led_out_en.values[9]
        platformInterface.outputEnable10 = led_out_en.values[10]
        platformInterface.outputEnable11 = led_out_en.values[11]



    }

    property var led_out_en_states: platformInterface.led_out_en_states.states
    onLed_out_en_statesChanged: {
        setOutEnState(out0ENLED,led_out_en_states[0])
        setOutEnState(out1ENLED,led_out_en_states[1])
        setOutEnState(out2ENLED,led_out_en_states[2])
        setOutEnState(out3ENLED,led_out_en_states[3])
        setOutEnState(out4ENLED,led_out_en_states[4])
        setOutEnState(out5ENLED,led_out_en_states[5])
        setOutEnState(out6ENLED,led_out_en_states[6])
        setOutEnState(out7ENLED,led_out_en_states[7])
        setOutEnState(out8ENLED,led_out_en_states[8])
        setOutEnState(out9ENLED,led_out_en_states[9])
        setOutEnState(out10ENLED,led_out_en_states[10])
        setOutEnState(out11ENLED,led_out_en_states[11])
    }

    property var led_out_en_values: platformInterface.led_out_en_values.values
    onLed_out_en_valuesChanged:  {

        if(led_out_en_values[0] === true)
            out0ENLED.checked = true
        else out0ENLED.checked = false

        if(led_out_en_values[1] === true)
            out1ENLED.checked = true
        else out1ENLED.checked = false

        if(led_out_en_values[2] === true)
            out2ENLED.checked = true
        else out2ENLED.checked = false

        if(led_out_en_values[3] === true)
            out3ENLED.checked = true
        else out3ENLED.checked = false

        if(led_out_en_values[4] === true)
            out4ENLED.checked = true
        else out4ENLED.checked = false

        if(led_out_en_values[5] === true)
            out5ENLED.checked = true
        else out5ENLED.checked = false

        if(led_out_en_values[6] === true)
            out6ENLED.checked = true
        else out6ENLED.checked = false

        if(led_out_en_values[7] === true)
            out7ENLED.checked = true
        else out7ENLED.checked = false

        if(led_out_en_values[8] === true)
            out8ENLED.checked = true
        else out8ENLED.checked = false

        if(led_out_en_values[9] === true)
            out9ENLED.checked = true
        else out9ENLED.checked = false

        if(led_out_en_values[10] === true)
            out10ENLED.checked = true
        else out10ENLED.checked = false

        if(led_out_en_values[11] === true)
            out11ENLED.checked = true
        else out11ENLED.checked = false

        platformInterface.outputEnable0 =led_out_en_values[0]
        platformInterface.outputEnable1 = led_out_en_values[1]
        platformInterface.outputEnable2 =led_out_en_values[2]
        platformInterface.outputEnable3 = led_out_en_values[3]
        platformInterface.outputEnable4 = led_out_en_values[4]
        platformInterface.outputEnable5 = led_out_en_values[5]
        platformInterface.outputEnable6 = led_out_en_values[6]
        platformInterface.outputEnable7 = led_out_en_values[7]
        platformInterface.outputEnable8 = led_out_en_values[8]
        platformInterface.outputEnable9 = led_out_en_values[9]
        platformInterface.outputEnable10 = led_out_en_values[10]
        platformInterface.outputEnable11 = led_out_en_values[11]
    }


    property var led_ext: platformInterface.led_ext
    onLed_extChanged: {
        externalLED.text = led_ext.caption
        if(led_ext.values[0] === true)
            out0interExterLED.checked = true
        else out0interExterLED.checked = false

        if(led_ext.values[1] === true)
            out1interExterLED.checked = true
        else out1interExterLED.checked = false

        if(led_ext.values[2] === true)
            out2interExterLED.checked = true
        else out2interExterLED.checked = false

        if(led_ext.values[3] === true)
            out3interExterLED.checked = true
        else out3interExterLED.checked = false

        if(led_ext.values[4] === true)
            out4interExterLED.checked = true
        else out4interExterLED.checked = false

        if(led_ext.values[5] === true)
            out5interExterLED.checked = true
        else out5interExterLED.checked = false

        if(led_ext.values[6] === true)
            out6interExterLED.checked = true
        else out6interExterLED.checked = false

        if(led_ext.values[7] === true)
            out7interExterLED.checked = true
        else out7interExterLED.checked = false

        if(led_ext.values[8] === true)
            out8interExterLED.checked = true
        else out8interExterLED.checked = false

        if(led_ext.values[9] === true)
            out9interExterLED.checked = true
        else out9interExterLED.checked = false

        if(led_ext.values[10] === true)
            out10interExterLED.checked = true
        else out10interExterLED.checked = false

        if(led_ext.values[11] === true)
            out11interExterLED.checked = true
        else out11interExterLED.checked = false

        platformInterface.outputExt0 = led_ext.values[0]
        platformInterface.outputExt1 = led_ext.values[1]
        platformInterface.outputExt2 = led_ext.values[2]
        platformInterface.outputExt3 = led_ext.values[3]
        platformInterface.outputExt4 = led_ext.values[4]
        platformInterface.outputExt5 = led_ext.values[5]
        platformInterface.outputExt6 = led_ext.values[6]
        platformInterface.outputExt7 = led_ext.values[7]
        platformInterface.outputExt8 = led_ext.values[8]
        platformInterface.outputExt9 = led_ext.values[9]
        platformInterface.outputExt10 = led_ext.values[10]
        platformInterface.outputExt11 = led_ext.values[11]



        setStatesForControls(out0interExterLED,led_ext.states[0])
        setStatesForControls(out1interExterLED,led_ext.states[1])
        setStatesForControls(out2interExterLED,led_ext.states[2])
        setStatesForControls(out3interExterLED,led_ext.states[3])
        setStatesForControls(out4interExterLED,led_ext.states[4])
        setStatesForControls(out5interExterLED,led_ext.states[5])
        setStatesForControls(out6interExterLED,led_ext.states[6])
        setStatesForControls(out7interExterLED,led_ext.states[7])
        setStatesForControls(out8interExterLED,led_ext.states[8])
        setStatesForControls(out9interExterLED,led_ext.states[9])
        setStatesForControls(out10interExterLED,led_ext.states[10])
        setStatesForControls(out11interExterLED,led_ext.states[11])


    }

    property var led_ext_values: platformInterface.led_ext_values.values
    onLed_ext_valuesChanged:  {
        if(led_ext_values[0] === true)
            out0interExterLED.checked = true
        else out0interExterLED.checked = false

        if(led_ext_values[1] === true)
            out1interExterLED.checked = true
        else out1interExterLED.checked = false

        if(led_ext_values[2] === true)
            out2interExterLED.checked = true
        else out2interExterLED.checked = false

        if(led_ext_values[3] === true)
            out3interExterLED.checked = true
        else out3interExterLED.checked = false

        if(led_ext_values[4] === true)
            out4interExterLED.checked = true
        else out4interExterLED.checked = false

        if(led_ext_values[5] === true)
            out5interExterLED.checked = true
        else out5interExterLED.checked = false

        if(led_ext_values[6] === true)
            out6interExterLED.checked = true
        else out6interExterLED.checked = false

        if(led_ext_values[7] === true)
            out7interExterLED.checked = true
        else out7interExterLED.checked = false

        if(led_ext_values[8] === true)
            out8interExterLED.checked = true
        else out8interExterLED.checked = false

        if(led_ext_values[9] === true)
            out9interExterLED.checked = true
        else out9interExterLED.checked = false

        if(led_ext_values[10] === true)
            out10interExterLED.checked = true
        else out10interExterLED.checked = false

        if(led_ext_values[11] === true)
            out11interExterLED.checked = true
        else out11interExterLED.checked = false

        platformInterface.outputExt0 = led_ext_values[0]
        platformInterface.outputExt1 = led_ext_values[1]
        platformInterface.outputExt2 = led_ext_values[2]
        platformInterface.outputExt3 = led_ext_values[3]
        platformInterface.outputExt4 = led_ext_values[4]
        platformInterface.outputExt5 = led_ext_values[5]
        platformInterface.outputExt6 = led_ext_values[6]
        platformInterface.outputExt7 = led_ext_values[7]
        platformInterface.outputExt8 = led_ext_values[8]
        platformInterface.outputExt9 = led_ext_values[9]
        platformInterface.outputExt10 = led_ext_values[10]
        platformInterface.outputExt11 = led_ext_values[11]
    }

    property var led_ext_states: platformInterface.led_ext_states.states
    onLed_ext_statesChanged: {
        setStatesForControls(out0interExterLED,led_ext_states[0])
        setStatesForControls(out1interExterLED,led_ext_states[0])
        setStatesForControls(out2interExterLED,led_ext_states[0])
        setStatesForControls(out3interExterLED,led_ext_states[0])
        setStatesForControls(out4interExterLED,led_ext_states[0])
        setStatesForControls(out5interExterLED,led_ext_states[0])
        setStatesForControls(out6interExterLED,led_ext_states[0])
        setStatesForControls(out7interExterLED,led_ext_states[0])
        setStatesForControls(out8interExterLED,led_ext_states[0])
        setStatesForControls(out9interExterLED,led_ext_states[0])
        setStatesForControls(out10interExterLED,led_ext_states[0])
        setStatesForControls(out11interExterLED,led_ext_states[0])


    }

    property var led_fault_status: platformInterface.led_fault_status
    onLed_fault_statusChanged: {
        faultText.text = led_fault_status.caption
        if(led_fault_status.values[0] === false)
            out0faultStatusLED.status = SGStatusLight.Off
        else  out0faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[1] === false)
            out1faultStatusLED.status = SGStatusLight.Off
        else  out1faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[2] === false)
            out2faultStatusLED.status = SGStatusLight.Off
        else  out2faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[3] === false)
            out3faultStatusLED.status = SGStatusLight.Off
        else  out3faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[4] === false)
            out4faultStatusLED.status = SGStatusLight.Off
        else  out4faultStatusLED.status = SGStatusLight.Red


        if(led_fault_status.values[5] === false)
            out5faultStatusLED.status = SGStatusLight.Off
        else  out5faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[6] === false)
            out6faultStatusLED.status = SGStatusLight.Off
        else  out6faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[7] === false)
            out7faultStatusLED.status = SGStatusLight.Off
        else  out7faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[8] === false)
            out8faultStatusLED.status = SGStatusLight.Off
        else  out8faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[9] === false)
            out9faultStatusLED.status = SGStatusLight.Off
        else  out9faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[10] === false)
            out10faultStatusLED.status = SGStatusLight.Off
        else  out10faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status.values[11] === false)
            out11faultStatusLED.status = SGStatusLight.Off
        else  out11faultStatusLED.status = SGStatusLight.Red

        setStatesForControls(out0faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out1faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out2faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out3faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out4faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out5faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out6faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out7faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out8faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out9faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out10faultStatusLED,led_fault_status.states[0])
        setStatesForControls(out11faultStatusLED,led_fault_status.states[0])

    }

    property var led_fault_status_values: platformInterface.led_fault_status_values.values
    onLed_fault_status_valuesChanged: {
        if(led_fault_status_values[0] === false)
            out0faultStatusLED.status = SGStatusLight.Off
        else  out0faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[1] === false)
            out1faultStatusLED.status = SGStatusLight.Off
        else  out1faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[2] === false)
            out2faultStatusLED.status = SGStatusLight.Off
        else  out2faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[3] === false)
            out3faultStatusLED.status = SGStatusLight.Off
        else  out3faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[4] === false)
            out4faultStatusLED.status = SGStatusLight.Off
        else  out4faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[5] === false)
            out5faultStatusLED.status = SGStatusLight.Off
        else  out5faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[6] === false)
            out6faultStatusLED.status = SGStatusLight.Off
        else  out6faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[7] === false)
            out7faultStatusLED.status = SGStatusLight.Off
        else  out7faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[8] === false)
            out8faultStatusLED.status = SGStatusLight.Off
        else  out8faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[9] === false)
            out9faultStatusLED.status = SGStatusLight.Off
        else  out9faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[10] === false)
            out10faultStatusLED.status = SGStatusLight.Off
        else  out10faultStatusLED.status = SGStatusLight.Red

        if(led_fault_status_values[11] === false)
            out11faultStatusLED.status = SGStatusLight.Off
        else  out11faultStatusLED.status = SGStatusLight.Red

    }


    property var led_fault_status_states: platformInterface.led_fault_status_states.states
    onLed_fault_status_statesChanged: {

        setStatesForControls(out0faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out1faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out2faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out3faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out4faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out5faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out6faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out7faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out8faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out9faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out10faultStatusLED,led_fault_status_states[0])
        setStatesForControls(out11faultStatusLED,led_fault_status_states[0])


    }

    property var led_pwm_enables: platformInterface.led_pwm_enables
    onLed_pwm_enablesChanged: {
        pwmEnableText.text = led_pwm_enables.caption

        out0pwmEnableLED.checked = led_pwm_enables.values[0]
        platformInterface.outputPwm0 = led_pwm_enables.values[0]

        platformInterface.outputPwm1 = led_pwm_enables.values[1]
        out1pwmEnableLED.checked = led_pwm_enables.values[1]

        platformInterface.outputPwm2 = led_pwm_enables.values[2]
        out2pwmEnableLED.checked = led_pwm_enables.values[2]

        platformInterface.outputPwm3 = led_pwm_enables.values[3]
        out3pwmEnableLED.checked = led_pwm_enables.values[3]

        platformInterface.outputPwm4 = led_pwm_enables.values[4]
        out4pwmEnableLED.checked = led_pwm_enables.values[4]

        platformInterface.outputPwm5 = led_pwm_enables.values[5]
        out5pwmEnableLED.checked = led_pwm_enables.values[5]

        platformInterface.outputPwm6 = led_pwm_enables.values[6]
        out6pwmEnableLED.checked = led_pwm_enables.values[6]

        platformInterface.outputPwm7 = led_pwm_enables.values[7]
        out7pwmEnableLED.checked = led_pwm_enables.values[7]

        platformInterface.outputPwm8 = led_pwm_enables.values[8]
        out8pwmEnableLED.checked = led_pwm_enables.values[8]

        platformInterface.outputPwm9 = led_pwm_enables.values[9]
        out9pwmEnableLED.checked = led_pwm_enables.values[9]

        platformInterface.outputPwm10 = led_pwm_enables.values[10]
        out10pwmEnableLED.checked = led_pwm_enables.values[10]

        platformInterface.outputPwm11 = led_pwm_enables.values[11]
        out11pwmEnableLED.checked = led_pwm_enables.values[11]


        setStatesForControls(out0pwmEnableLED,led_pwm_enables.states[0])
        setStatesForControls(out1pwmEnableLED,led_pwm_enables.states[1])
        setStatesForControls(out2pwmEnableLED,led_pwm_enables.states[2])
        setStatesForControls(out3pwmEnableLED,led_pwm_enables.states[3])
        setStatesForControls(out4pwmEnableLED,led_pwm_enables.states[4])
        setStatesForControls(out5pwmEnableLED,led_pwm_enables.states[5])
        setStatesForControls(out6pwmEnableLED,led_pwm_enables.states[6])
        setStatesForControls(out7pwmEnableLED,led_pwm_enables.states[7])
        setStatesForControls(out8pwmEnableLED,led_pwm_enables.states[8])
        setStatesForControls(out9pwmEnableLED,led_pwm_enables.states[9])
        setStatesForControls(out10pwmEnableLED,led_pwm_enables.states[10])
        setStatesForControls(out11pwmEnableLED,led_pwm_enables.states[11])
    }

    property var led_pwm_enables_values: platformInterface.led_pwm_enables_values.values
    onLed_pwm_enables_valuesChanged: {
        out0pwmEnableLED.checked = led_pwm_enables_values[0]
        platformInterface.outputPwm0 = led_pwm_enables_values[0]

        platformInterface.outputPwm1 = led_pwm_enables_values[1]
        out1pwmEnableLED.checked = led_pwm_enables_values[1]

        out2pwmEnableLED.checked = led_pwm_enables_values[2]
        platformInterface.outputPwm2 = led_pwm_enables_values[2]

        platformInterface.outputPwm3 = led_pwm_enables_values[3]
        out3pwmEnableLED.checked = led_pwm_enables_values[3]

        platformInterface.outputPwm4 = led_pwm_enables_values[4]
        out4pwmEnableLED.checked = led_pwm_enables_values[4]

        platformInterface.outputPwm5 = led_pwm_enables_values[5]
        out5pwmEnableLED.checked = led_pwm_enables_values[5]

        platformInterface.outputPwm6 = led_pwm_enables_values[6]
        out6pwmEnableLED.checked = led_pwm_enables_values[6]

        platformInterface.outputPwm7 = led_pwm_enables_values[7]
        out7pwmEnableLED.checked = led_pwm_enables_values[7]

        platformInterface.outputPwm8 = led_pwm_enables_values[8]
        out8pwmEnableLED.checked = led_pwm_enables_values[8]

        platformInterface.outputPwm9 = led_pwm_enables_values[9]
        out9pwmEnableLED.checked = led_pwm_enables_values[9]

        platformInterface.outputPwm10 = led_pwm_enables_values[10]
        out10pwmEnableLED.checked = led_pwm_enables_values[10]

        platformInterface.outputPwm11 = led_pwm_enables_values[11]
        out11pwmEnableLED.checked = led_pwm_enables_values[11]

    }

    property var led_pwm_enables_states: platformInterface.led_pwm_enables_states.states
    onLed_pwm_enables_statesChanged: {

        setStatesForControls(out0pwmEnableLED,led_pwm_enables_states[0])
        setStatesForControls(out1pwmEnableLED,led_pwm_enables_states[1])
        setStatesForControls(out2pwmEnableLED,led_pwm_enables_states[2])
        setStatesForControls(out3pwmEnableLED,led_pwm_enables_states[3])
        setStatesForControls(out4pwmEnableLED,led_pwm_enables_states[4])
        setStatesForControls(out5pwmEnableLED,led_pwm_enables_states[5])
        setStatesForControls(out6pwmEnableLED,led_pwm_enables_states[6])
        setStatesForControls(out7pwmEnableLED,led_pwm_enables_states[7])
        setStatesForControls(out8pwmEnableLED,led_pwm_enables_states[8])
        setStatesForControls(out9pwmEnableLED,led_pwm_enables_states[9])
        setStatesForControls(out10pwmEnableLED,led_pwm_enables_states[10])
        setStatesForControls(out11pwmEnableLED,led_pwm_enables_states[11])
    }


    property var led_pwm_duty: platformInterface.led_pwm_duty
    onLed_pwm_dutyChanged: {
        out0duty.value = led_pwm_duty.values[0]
        out1duty.value = led_pwm_duty.values[1]
        out2duty.value = led_pwm_duty.values[2]
        out3duty.value = led_pwm_duty.values[3]
        out4duty.value = led_pwm_duty.values[4]

        out5duty.value = led_pwm_duty.values[5]
        out6duty.value = led_pwm_duty.values[6]
        out7duty.value = led_pwm_duty.values[7]

        out8duty.value = led_pwm_duty.values[8]
        out9duty.value = led_pwm_duty.values[9]
        out10duty.value = led_pwm_duty.values[10]
        out11duty.value = led_pwm_duty.values[11]

        platformInterface.outputDuty0 = led_pwm_duty.values[0]
        platformInterface.outputDuty1 = led_pwm_duty.values[1]
        platformInterface.outputDuty2 = led_pwm_duty.values[2]
        platformInterface.outputDuty3 = led_pwm_duty.values[3]
        platformInterface.outputDuty4 = led_pwm_duty.values[4]
        platformInterface.outputDuty5 = led_pwm_duty.values[5]
        platformInterface.outputDuty6 = led_pwm_duty.values[6]
        platformInterface.outputDuty7 = led_pwm_duty.values[7]
        platformInterface.outputDuty8 = led_pwm_duty.values[8]
        platformInterface.outputDuty9 = led_pwm_duty.values[9]
        platformInterface.outputDuty10 = led_pwm_duty.values[10]
        platformInterface.outputDuty11 =  led_pwm_duty.values[11]


        out0duty.from = led_pwm_duty.scales[1]
        out0duty.to = led_pwm_duty.scales[0]

        setStateForPWMDuty(out0duty,led_pwm_duty.states[0])
        setStateForPWMDuty(out1duty,led_pwm_duty.states[1])
        setStateForPWMDuty(out2duty,led_pwm_duty.states[2])
        setStateForPWMDuty(out3duty,led_pwm_duty.states[3])
        setStateForPWMDuty(out4duty,led_pwm_duty.states[4])
        setStateForPWMDuty(out5duty,led_pwm_duty.states[5])
        setStateForPWMDuty(out6duty,led_pwm_duty.states[6])
        setStateForPWMDuty(out7duty,led_pwm_duty.states[7])
        setStateForPWMDuty(out8duty,led_pwm_duty.states[8])
        setStateForPWMDuty(out9duty,led_pwm_duty.states[9])
        setStateForPWMDuty(out10duty,led_pwm_duty.states[10])
        setStateForPWMDuty(out11duty,led_pwm_duty.states[11])

    }



    property var led_pwm_duty_values: platformInterface.led_pwm_duty_values.values
    onLed_pwm_duty_valuesChanged: {
        out0duty.value = led_pwm_duty_values[0]
        out1duty.value = led_pwm_duty_values[1]
        out2duty.value = led_pwm_duty_values[2]
        out3duty.value = led_pwm_duty_values[3]
        out4duty.value = led_pwm_duty_values[4]
        out5duty.value = led_pwm_duty_values[5]
        out6duty.value = led_pwm_duty_values[6]
        out7duty.value = led_pwm_duty_values[7]
        out8duty.value = led_pwm_duty_values[8]
        out9duty.value = led_pwm_duty_values[9]
        out10duty.value = led_pwm_duty_values[10]
        out11duty.value = led_pwm_duty_values[11]

        platformInterface.outputDuty0 = led_pwm_duty_values[0]
        platformInterface.outputDuty1 = led_pwm_duty_values[1]
        platformInterface.outputDuty2 = led_pwm_duty_values[2]
        platformInterface.outputDuty3 = led_pwm_duty_values[3]
        platformInterface.outputDuty4 = led_pwm_duty_values[4]
        platformInterface.outputDuty5 = led_pwm_duty_values[5]
        platformInterface.outputDuty6 = led_pwm_duty_values[6]
        platformInterface.outputDuty7 = led_pwm_duty_values[7]
        platformInterface.outputDuty8 = led_pwm_duty_values[8]
        platformInterface.outputDuty9 = led_pwm_duty_values[9]
        platformInterface.outputDuty10 = led_pwm_duty_values[10]
        platformInterface.outputDuty11 =  led_pwm_duty_values[11]

    }

    RowLayout {
        anchors.fill: parent
        spacing: 10
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 10
        Rectangle {
            id: leftSetting
            Layout.fillHeight: true
            Layout.preferredWidth: root.width/3.5
            color: "transparent"
            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    ColumnLayout{
                        anchors.fill: parent
                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"
                            Text {
                                id: generalSettingHeading
                                text: "General Settings"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
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
                                radius: 1.5
                                anchors {
                                    top: generalSettingHeading.bottom
                                    topMargin: 7
                                }
                            }
                        }
                        Rectangle{
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"

                            SGAlignedLabel {
                                id: partNumberLabel
                                target: partNumber
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: 5
                                anchors.left: parent.left
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2

                                font.bold : true
                                SGInfoBox{
                                    id: partNumber
                                    height:  35 * ratioCalc
                                    width: 120 * ratioCalc

                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                }

                                property var led_part_number: platformInterface.led_part_number
                                onLed_part_numberChanged: {
                                    partNumberLabel.text = led_part_number.caption
                                    setStatesForControls(partNumber,led_part_number.states[0])

                                    partNumber.text = led_part_number.value
                                }

                                property var led_part_number_caption: platformInterface.led_part_number_caption.caption
                                onLed_part_number_captionChanged: {
                                    partNumberLabel.text = led_part_number_caption
                                }

                                property var led_part_number_states: platformInterface.led_part_number_states.states
                                onLed_part_number_statesChanged: {
                                    setStatesForControls(partNumber,led_part_number_states[0])
                                }

                                property var led_part_number_value: platformInterface.led_part_number_value.value
                                onLed_part_number_valueChanged: {
                                    partNumber.text = led_part_number_value
                                }

                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: enableOutputLabel
                                target: enableOutput

                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: enableOutput
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_led_oen.update(true)
                                        else platformInterface.set_led_oen.update(false)
                                    }

                                    property var led_oen: platformInterface.led_oen
                                    onLed_oenChanged: {
                                        enableOutputLabel.text = led_oen.caption
                                        setStatesForControls(enableOutput,led_oen.states[0])

                                        if(led_oen.value === true)
                                            enableOutput.checked = true
                                        else  enableOutput.checked = false
                                    }

                                    property var led_oen_caption: platformInterface.led_oen_caption.caption
                                    onLed_oen_captionChanged : {
                                        enableOutputLabel.text = led_oen_caption
                                    }

                                    property var led_oen_states: platformInterface.led_oen_states.states
                                    onLed_oen_statesChanged : {
                                        setStatesForControls(enableOutput,led_oen_states[0])
                                    }

                                    property var led_oen_value: platformInterface.led_oen_value.value
                                    onLed_oen_valueChanged : {
                                        if(led_oen_value === true)
                                            enableOutput.checked = true
                                        else  enableOutput.checked = false


                                    }

                                }
                            }
                        }

                        Rectangle {
                            id: gobalCurrentSetContainer
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: gobalCurrentSetLabel
                                target: gobalCurrentSetSlider
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                alignment: SGAlignedLabel.SideTopLeft
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                SGSlider {
                                    id: gobalCurrentSetSlider
                                    width: gobalCurrentSetContainer.width/1.2
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 1.2
                                    inputBox.validator: DoubleValidator {
                                        top: gobalCurrentSetSlider.to
                                        bottom: gobalCurrentSetSlider.from
                                    }
                                    inputBoxWidth: gobalCurrentSetContainer.width - gobalCurrentSetSlider.width
                                    onUserSet: {
                                        platformInterface.set_led_iset.update(value)
                                    }
                                }

                                property var led_iset: platformInterface.led_iset
                                onLed_isetChanged:{
                                    gobalCurrentSetLabel.text = led_iset.caption
                                    gobalCurrentSetSlider.toText.text = led_iset.scales[0] + "mA"
                                    gobalCurrentSetSlider.to = led_iset.scales[0]
                                    gobalCurrentSetSlider.fromText.text = led_iset.scales[1] + "mA"
                                    gobalCurrentSetSlider.from = led_iset.scales[1]
                                    gobalCurrentSetSlider.stepSize = led_iset.scales[2]
                                    setStatesForControls(gobalCurrentSetLabel,led_iset.states[0])
                                    gobalCurrentSetSlider.value = led_iset.value
                                }

                                property var led_iset_caption: platformInterface.led_iset_caption.caption
                                onLed_iset_captionChanged:{
                                    gobalCurrentSetLabel.text = led_iset_caption
                                }

                                property var led_iset_scales: platformInterface.led_iset_scales.scales
                                onLed_iset_scalesChanged: {
                                    gobalCurrentSetSlider.toText.text = led_iset_scales[0] + "mA"
                                    gobalCurrentSetSlider.to = led_iset_scales[0]
                                    gobalCurrentSetSlider.fromText.text = led_iset_scales[1] + "mA"
                                    gobalCurrentSetSlider.from = led_iset_scales[1]
                                    gobalCurrentSetSlider.stepSize = led_iset_scales[2]

                                }

                                property var led_iset_states: platformInterface.led_iset_states.states
                                onLed_iset_statesChanged:{
                                    setStatesForControls(gobalCurrentSetLabel,led_iset_states[0])

                                }

                                property var led_iset_value: platformInterface.led_iset_value.value
                                onLed_iset_valueChanged: {
                                    gobalCurrentSetSlider.value = led_iset_value
                                }
                            }
                        }
                    }
                } // end of first column

                Rectangle{
                    Layout.preferredHeight: parent.height/2.1
                    Layout.fillWidth: true
                    color: "transparent"

                    ColumnLayout{
                        anchors.fill: parent

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"

                            Text {
                                id: pwmSettingHeading
                                text: "PWM Settings"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    top: parent.top
                                    topMargin: 5
                                }
                            }

                            Rectangle {
                                id: line2
                                height: 1.5
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: pwmSettingHeading.bottom
                                    topMargin: 7
                                }
                            }
                        }
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            SGAlignedLabel {
                                id: pwmenableOutputLabel
                                target: pwmenableOutput
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: pwmenableOutput
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    onToggled: {
                                        if(checked)
                                            platformInterface.set_led_pwm_enable.update(true)
                                        else platformInterface.set_led_pwm_enable.update(false)
                                    }

                                    property var led_pwm_enable: platformInterface.led_pwm_enable
                                    onLed_pwm_enableChanged: {
                                        pwmenableOutputLabel.text = led_pwm_enable.caption
                                        setStatesForControls(pwmenableOutput,led_pwm_enable.states[0])
                                        if(led_pwm_enable.value === true)
                                            pwmenableOutput.checked = true
                                        else  pwmenableOutput.checked = false
                                    }

                                    property var led_pwm_enable_caption: platformInterface.led_pwm_enable_caption.caption
                                    onLed_pwm_enable_captionChanged : {
                                        pwmenableOutputLabel.text = led_pwm_enable_caption
                                    }

                                    property var led_pwm_enable_states: platformInterface.led_pwm_enable_states.states
                                    onLed_pwm_enable_statesChanged : {
                                        setStatesForControls(pwmenableOutput,led_pwm_enable_states[0])
                                    }

                                    property var led_pwm_enable_value: platformInterface.led_pwm_enable_value.value
                                    onLed_pwm_enable_valueChanged : {
                                        if(led_pwm_enable_value === true)
                                            pwmenableOutput.checked = true
                                        else  pwmenableOutput.checked = false


                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: lockPWMDutyENLabel
                                target: lockPWMDutyEN
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter

                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                horizontalAlignment: Text.AlignHCenter

                                SGSwitch {
                                    id: lockPWMDutyEN
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    onToggled: {
                                        platformInterface.set_led_pwm_en_lock.update(checked)
                                    }

                                    property var led_pwm_en_lock: platformInterface.led_pwm_en_lock
                                    onLed_pwm_en_lockChanged: {
                                        lockPWMDutyENLabel.text = led_pwm_en_lock.caption
                                        setStatesForControls(lockPWMDutyEN,led_pwm_en_lock.states[0])
                                        if(led_pwm_en_lock.value === true)
                                            lockPWMDutyEN.checked = true
                                        else  lockPWMDutyEN.checked = false

                                    }

                                    property var led_pwm_en_lock_caption: platformInterface.led_pwm_en_lock_caption.caption
                                    onLed_pwm_en_lock_captionChanged : {
                                        lockPWMDutyENLabel.text = led_pwm_en_lock_caption
                                    }

                                    property var led_pwm_en_lock_states: platformInterface.led_pwm_en_lock_states.states
                                    onLed_pwm_en_lock_statesChanged : {
                                        setStatesForControls(lockPWMDutyEN,led_pwm_en_lock_states[0])
                                    }

                                    property var led_pwm_en_lock_value: platformInterface.led_pwm_en_lock_value.value
                                    onLed_pwm_en_lock_valueChanged : {
                                        if(led_pwm_en_lock_value === true)
                                            lockPWMDutyEN.checked = true
                                        else  lockPWMDutyEN.checked = false


                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: lockPWMDutyLabel
                                target: lockPWMDuty
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter

                                }
                                SGSwitch {
                                    id: lockPWMDuty
                                    labelsInside: true
                                    checkedLabel: "On"
                                    uncheckedLabel: "Off"
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    checked: false
                                    onToggled: {
                                        platformInterface.set_led_pwm_duty_lock.update(checked)
                                    }

                                    property var led_pwm_duty_lock: platformInterface.led_pwm_duty_lock
                                    onLed_pwm_duty_lockChanged: {
                                        lockPWMDutyLabel.text = led_pwm_duty_lock.caption
                                        setStatesForControls(lockPWMDuty,led_pwm_duty_lock.states[0])
                                        if(led_pwm_duty_lock.value === true)
                                            lockPWMDuty.checked = true
                                        else  lockPWMDuty.checked = false
                                    }

                                    property var led_pwm_duty_lock_caption: platformInterface.led_pwm_duty_lock_caption.caption
                                    onLed_pwm_duty_lock_captionChanged : {
                                        lockPWMDutyLabel.text = led_pwm_duty_lock_caption
                                    }

                                    property var led_pwm_duty_lock_states: platformInterface.led_pwm_duty_lock_states.states
                                    onLed_pwm_duty_lock_statesChanged : {
                                        setStatesForControls(lockPWMDuty,led_pwm_duty_lock_states[0])
                                    }

                                    property var led_pwm_duty_lock_value: platformInterface.led_pwm_duty_lock_value.value
                                    onLed_pwm_duty_lock_valueChanged : {
                                        if(led_pwm_duty_lock_value === true)
                                            lockPWMDuty.checked = true
                                        else  lockPWMDuty.checked = false


                                    }
                                }
                            }
                        }




                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: pwmLinearLogLabel
                                target: pwmLinearLog
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGSwitch {
                                    id: pwmLinearLog
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    onToggled:  {
                                        platformInterface.pwm_lin_state = checked
                                        platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                  checked,
                                                                                  [platformInterface.outputDuty0,
                                                                                   platformInterface.outputDuty1,
                                                                                   platformInterface.outputDuty2,
                                                                                   platformInterface.outputDuty3,
                                                                                   platformInterface.outputDuty4,
                                                                                   platformInterface.outputDuty5,
                                                                                   platformInterface.outputDuty6,
                                                                                   platformInterface.outputDuty7,
                                                                                   platformInterface.outputDuty8,
                                                                                   platformInterface.outputDuty9,
                                                                                   platformInterface.outputDuty10,
                                                                                   platformInterface.outputDuty11

                                                                                  ], [
                                                                                      platformInterface.outputPwm0,
                                                                                      platformInterface.outputPwm1,
                                                                                      platformInterface.outputPwm2,
                                                                                      platformInterface.outputPwm3,
                                                                                      platformInterface.outputPwm4,
                                                                                      platformInterface.outputPwm5,
                                                                                      platformInterface.outputPwm6,
                                                                                      platformInterface.outputPwm7,
                                                                                      platformInterface.outputPwm8,
                                                                                      platformInterface.outputPwm9,
                                                                                      platformInterface.outputPwm10,
                                                                                      platformInterface.outputPwm11])


                                    }

                                    property var led_linear_log: platformInterface.led_linear_log
                                    onLed_linear_logChanged: {
                                        pwmLinearLogLabel.text = led_linear_log.caption
                                        setStatesForControls(pwmLinearLog,led_linear_log.states[0])
                                        pwmLinearLog.checkedLabel = led_linear_log.values[0]
                                        pwmLinearLog.uncheckedLabel = led_linear_log.values[1]

                                        if(led_linear_log.value === "Linear") {
                                            pwmLinearLog.checked = true
                                            platformInterface.pwm_lin_state = true
                                        }
                                        else {
                                            pwmLinearLog.checked = false
                                            platformInterface.pwm_lin_state = false
                                        }
                                    }


                                    property var led_linear_log_caption: platformInterface.led_linear_log_caption.caption
                                    onLed_linear_log_captionChanged: {
                                        pwmLinearLogLabel.text = led_linear_log_caption
                                    }

                                    property var led_linear_log_states: platformInterface.led_linear_log_states.states
                                    onLed_linear_log_statesChanged: {
                                        setStatesForControls(pwmLinearLog,led_linear_log_states[0])
                                    }

                                    property var led_linear_log_values: platformInterface.led_linear_log_values.values
                                    onLed_linear_log_valuesChanged: {
                                        pwmLinearLog.checkedLabel = led_linear_log_values[0]
                                        pwmLinearLog.uncheckedLabel = led_linear_log_values[1]
                                    }

                                    property var led_linear_log_value: platformInterface.led_linear_log_value.value
                                    onLed_linear_log_valueChanged: {
                                        if(led_linear_log_value === "Linear") {
                                            pwmLinearLog.checked = true
                                            platformInterface.pwm_lin_state = true
                                        }
                                        else  {
                                            pwmLinearLog.checked = false
                                            platformInterface.pwm_lin_state = false
                                        }
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: pwmFrequencyLabel
                                target: pwmFrequency
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                }
                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                font.bold : true

                                SGComboBox {
                                    id: pwmFrequency
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc

                                    onActivated: {
                                        platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                  platformInterface.pwm_lin_state,
                                                                                  [platformInterface.outputDuty0,
                                                                                   platformInterface.outputDuty1,
                                                                                   platformInterface.outputDuty2,
                                                                                   platformInterface.outputDuty3,
                                                                                   platformInterface.outputDuty4,
                                                                                   platformInterface.outputDuty5,
                                                                                   platformInterface.outputDuty6,
                                                                                   platformInterface.outputDuty7,
                                                                                   platformInterface.outputDuty8,
                                                                                   platformInterface.outputDuty9,
                                                                                   platformInterface.outputDuty10,
                                                                                   platformInterface.outputDuty11

                                                                                  ], [
                                                                                      platformInterface.outputPwm0,
                                                                                      platformInterface.outputPwm1,
                                                                                      platformInterface.outputPwm2,
                                                                                      platformInterface.outputPwm3,
                                                                                      platformInterface.outputPwm4,
                                                                                      platformInterface.outputPwm5,
                                                                                      platformInterface.outputPwm6,
                                                                                      platformInterface.outputPwm7,
                                                                                      platformInterface.outputPwm8,
                                                                                      platformInterface.outputPwm9,
                                                                                      platformInterface.outputPwm10,
                                                                                      platformInterface.outputPwm11])
                                    }

                                    property var led_pwm_freq: platformInterface.led_pwm_freq
                                    onLed_pwm_freqChanged: {
                                        pwmFrequencyLabel.text = led_pwm_freq.caption
                                        setStatesForControls(pwmFrequency,led_pwm_freq.states[0])

                                        pwmFrequency.model = led_pwm_freq.values

                                        for(var a = 0; a < pwmFrequency.model.length; ++a) {
                                            if(led_pwm_freq.value === pwmFrequency.model[a].toString()){
                                                pwmFrequency.currentIndex = a
                                            }
                                        }
                                    }

                                    property var led_pwm_freq_caption: platformInterface.led_pwm_freq_caption.caption
                                    onLed_pwm_freq_captionChanged: {
                                        pwmFrequencyLabel.text = led_pwm_freq_caption
                                    }

                                    property var led_pwm_freq_states: platformInterface.led_pwm_freq_states.states
                                    onLed_pwm_freq_statesChanged: {
                                        setStatesForControls(pwmFrequency,led_pwm_freq_states[0])
                                    }

                                    property var led_pwm_freq_values: platformInterface.led_pwm_freq_values.values
                                    onLed_pwm_freq_valuesChanged: {
                                        pwmFrequency.model = led_pwm_freq_values
                                    }

                                    property var led_pwm_freq_value: platformInterface.led_pwm_freq_value.value
                                    onLed_pwm_freq_valueChanged: {
                                        for(var a = 0; a < pwmFrequency.model.length; ++a) {
                                            if(led_pwm_freq_value === pwmFrequency.model[a].toString()){
                                                pwmFrequency.currentIndex = a
                                            }
                                        }
                                    }
                                }
                            }
                        }

                    }
                }
                Rectangle {
                    Layout.preferredHeight: parent.height/5
                    Layout.fillWidth: true
                    color: "transparent"
                    ColumnLayout{
                        anchors.fill: parent

                        Rectangle{
                            Layout.fillWidth: true
                            Layout.preferredHeight: parent.height/9
                            color: "transparent"

                            Text {
                                id: diagHeading
                                text: "Diagnostic"
                                font.bold: true
                                font.pixelSize: ratioCalc * 20
                                color: "#696969"
                                anchors {
                                    top: parent.top
                                    topMargin: 5
                                }
                            }

                            Rectangle {
                                id: line3
                                height: 1.5
                                Layout.alignment: Qt.AlignCenter
                                width: parent.width
                                border.color: "lightgray"
                                radius: 2
                                anchors {
                                    top: diagHeading.bottom
                                    topMargin: 7
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    color: "transparent"

                                    SGAlignedLabel {
                                        id: diagLabel
                                        target: diag

                                        font.bold: true
                                        alignment: SGAlignedLabel.SideTopCenter
                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                        anchors.centerIn: parent

                                        SGStatusLight {
                                            id: diag
                                            width: 30

                                            property var led_diag: platformInterface.led_diag
                                            onLed_diagChanged: {
                                                diagLabel.text =  led_diag_caption
                                                setStatesForControls(diagLabel,led_diag.states[0])


                                                if(led_diag.value === false)
                                                    diag.status = SGStatusLight.Off

                                                else  diag.status = SGStatusLight.Red
                                            }

                                            property var led_diag_caption: platformInterface.led_diag_caption.caption
                                            onLed_diag_captionChanged: {
                                                diagLabel.text =  led_diag.caption


                                            }

                                            property var led_diag_states: platformInterface.led_diag_states.states
                                            onLed_diag_statesChanged: {
                                                setStatesForControls(diagLabel,led_diag_states[0])
                                            }

                                            property var led_diag_value: platformInterface.led_diag_value.value
                                            onLed_diag_valueChanged: {
                                                if(led_diag_value === false) {
                                                    diag.status = SGStatusLight.Off
                                                }
                                                else  diag.status = SGStatusLight.Red
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/1.5
                                    color: "transparent"
                                    SGAlignedLabel {
                                        id: openLoadLabel
                                        target: openLoadDiagnostic
                                        alignment: SGAlignedLabel.SideTopCenter
                                        anchors {
                                            left: parent.left
                                            verticalCenter: parent.verticalCenter
                                        }

                                        fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                        font.bold : true

                                        SGComboBox {
                                            id: openLoadDiagnostic
                                            fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                            onActivated: {
                                                platformInterface.set_led_diag_mode.update(currentText)
                                            }

                                            property var led_open_load_diagnostic: platformInterface.led_open_load_diagnostic
                                            onLed_open_load_diagnosticChanged: {
                                                openLoadLabel.text = led_open_load_diagnostic.caption
                                                setStatesForControls(openLoadDiagnostic,led_open_load_diagnostic.states[0])

                                                openLoadDiagnostic.model = led_open_load_diagnostic.values

                                                for(var a = 0; a < openLoadDiagnostic.model.length; ++a) {
                                                    if(led_open_load_diagnostic.value === openLoadDiagnostic.model[a].toString()){
                                                        openLoadDiagnostic.currentIndex = a
                                                    }
                                                }
                                            }

                                            property var led_open_load_diagnostic_caption: platformInterface.led_open_load_diagnostic_caption.caption
                                            onLed_open_load_diagnostic_captionChanged: {
                                                openLoadLabel.text = led_open_load_diagnostic_caption
                                            }

                                            property var led_open_load_diagnostic_states: platformInterface.led_open_load_diagnostic_states.states
                                            onLed_open_load_diagnostic_statesChanged: {
                                                setStatesForControls(openLoadDiagnostic,led_open_load_diagnostic_states[0])
                                            }

                                            property var led_open_load_diagnostic_values: platformInterface.led_open_load_diagnostic_values.values
                                            onLed_open_load_diagnostic_valuesChanged: {
                                                openLoadDiagnostic.model = led_open_load_diagnostic_values
                                            }

                                            property var led_open_load_diagnostic_value: platformInterface.led_open_load_diagnostic_value.value
                                            onLed_open_load_diagnostic_valueChanged: {
                                                for(var a = 0; a < openLoadDiagnostic.model.length; ++a) {
                                                    if(led_open_load_diagnostic_value === openLoadDiagnostic.model[a].toString()){
                                                        openLoadDiagnostic.currentIndex = a
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
        }

        Rectangle {
            id: rightSetting
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"
            ColumnLayout {
                anchors.fill: parent
                anchors.right: parent.right
                anchors.rightMargin: 20

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/20
                    color: "transparent"
                    Text {
                        id: channelHeading
                        text: "Individual Channel Configuration"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line4
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: channelHeading.bottom
                            topMargin: 7
                        }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: parent.height/1.37
                    Layout.fillWidth: true
                    color: "transparent"

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 15
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/8
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: ledoutEnLabel
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter

                                                property var led_out_en_caption: platformInterface.led_out_en_caption.caption
                                                onLed_out_en_captionChanged: {
                                                    ledoutEnLabel.text =  led_out_en_caption
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: externalLED
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter


                                                property var led_ext_caption: platformInterface.led_ext_caption.caption
                                                onLed_ext_captionChanged: {
                                                    externalLED.text = led_ext_caption
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id: pwmEnableText
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter

                                                property var led_pwm_enables_caption: platformInterface.led_pwm_enables_caption.caption
                                                onLed_pwm_enables_captionChanged: {
                                                    pwmEnableText.text =  led_pwm_enables_caption
                                                }

                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGText {
                                                id:faultText
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter
                                                font.bold: true

                                                property var led_fault_status_caption: platformInterface.led_fault_status_caption.caption
                                                onLed_fault_status_captionChanged: {
                                                    faultText.text =  led_fault_status_caption
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            SGText {
                                                id: pwmDutyText
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.left: parent.left
                                                anchors.verticalCenter: parent.verticalCenter

                                                property var led_pwm_duty_caption: platformInterface.led_pwm_duty_caption.caption
                                                onLed_pwm_duty_captionChanged: {
                                                    pwmDutyText.text = led_pwm_duty_caption
                                                }
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT12") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGSwitch {
                                                id: out11ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     true
                                                                    ] )

                                                        platformInterface.outputEnable11 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     false
                                                                    ])

                                                        platformInterface.outputEnable11 = false

                                                    }

                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out11interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     true
                                                                    ] )

                                                        platformInterface.outputExt11 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     false
                                                                    ])

                                                        platformInterface.outputExt11 = false


                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out11pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm11 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }


                                            }
                                        }

                                        Rectangle {
                                            id: out11faultStatusLEDContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            id: out11dutyContainer
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out11duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                value: 50
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out11duty.from = led_pwm_duty_scales[1]
                                                    out11duty.to = led_pwm_duty_scales[0]
                                                    out11duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states11: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states11Changed: {
                                                    setStateForPWMDuty(out11duty,led_pwm_duty_states11[11])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty11 =  out11duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }
                                            }
                                        }
                                    }
                                }


                                Rectangle{

                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT11") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     true,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable10 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     false,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable10 = false

                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     true,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt10 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     false,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt10 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out10pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm10 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out10faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out10duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out10duty.from = led_pwm_duty_scales[1]
                                                    out10duty.to = led_pwm_duty_scales[0]
                                                    out10duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states10: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states10Changed: {
                                                    setStateForPWMDuty(out10duty,led_pwm_duty_states10[10])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty10 =  out10duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }
                                            }
                                        }
                                    }
                                }


                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT10") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     true,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable9 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     false,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable9 = false

                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     true,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt9 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     false,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt9 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out9pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm9 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out9faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out9duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out9duty.from = led_pwm_duty_scales[1]
                                                    out9duty.to = led_pwm_duty_scales[0]
                                                    out9duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states9: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states9Changed: {
                                                    setStateForPWMDuty(out9duty,led_pwm_duty_states9[9])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty9 =  out9duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT9") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out8ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     true,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable8 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     false,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable8 = false

                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out8interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     true,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt8 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     false,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt8 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGSwitch {
                                                id: out8pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm8 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out8faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out8duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out8duty.from = led_pwm_duty_scales[1]
                                                    out8duty.to = led_pwm_duty_scales[0]
                                                    out8duty.value = led_pwm_duty_scales[2]
                                                }
                                                property var led_pwm_duty_states8: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states8Changed: {
                                                    setStateForPWMDuty(out8duty,led_pwm_duty_states8[8])
                                                }


                                                onUserSet: {

                                                    platformInterface.outputDuty8 =  out8duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }




                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT8") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     true,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable7 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     false,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable7 = false

                                                    }


                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     true,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt7 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     false,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt7 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out7pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm7 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out7faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out7duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0

                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out7duty.from = led_pwm_duty_scales[1]
                                                    out7duty.to = led_pwm_duty_scales[0]
                                                    out7duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states7: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states7Changed: {
                                                    setStateForPWMDuty(out7duty,led_pwm_duty_states7[7])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty7 =  out7duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }



                                            }
                                        }

                                    }
                                }


                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT7") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out6ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     true,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable6 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     false,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable6 = false

                                                    }

                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out6interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     true,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt6 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     false,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt6 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out6pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    platformInterface.outputPwm6 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],  [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out6faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out6duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out6duty.from = led_pwm_duty_scales[1]
                                                    out6duty.to = led_pwm_duty_scales[0]
                                                    out6duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states6: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states6Changed: {
                                                    setStateForPWMDuty(out6duty,led_pwm_duty_states6[6])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty6 =  out6duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }





                                            }
                                        }

                                    }
                                }



                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT6") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     true,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable5 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     false,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable5 = false

                                                    }

                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     true,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt5 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     false,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt5 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out5pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm5 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [ platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],  [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out5faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }

                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out5duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out5duty.from = led_pwm_duty_scales[1]
                                                    out5duty.to = led_pwm_duty_scales[0]
                                                    out5duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states5: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states5Changed: {
                                                    setStateForPWMDuty(out5duty,led_pwm_duty_states5[5])
                                                }


                                                onUserSet: {
                                                    platformInterface.outputDuty5 =  out5duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],
                                                                                              [ platformInterface.outputPwm0,
                                                                                               platformInterface.outputPwm1,
                                                                                               platformInterface.outputPwm2,
                                                                                               platformInterface.outputPwm3,
                                                                                               platformInterface.outputPwm4,
                                                                                               platformInterface.outputPwm5,
                                                                                               platformInterface.outputPwm6,
                                                                                               platformInterface.outputPwm7,
                                                                                               platformInterface.outputPwm8,
                                                                                               platformInterface.outputPwm9,
                                                                                               platformInterface.outputPwm10,
                                                                                               platformInterface.outputPwm11])

                                                }


                                            }
                                        }

                                    }
                                }


                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT5") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     true,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable4 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     false,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11
                                                                    ] )
                                                        platformInterface.outputEnable4 = false

                                                    }


                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     true,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt4 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     false,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt4 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out4pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    platformInterface.outputPwm4 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out4faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out4duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.0
                                                slider_start_color2: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out4duty.from = led_pwm_duty_scales[1]
                                                    out4duty.to = led_pwm_duty_scales[0]
                                                    out4duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states4: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states4Changed: {
                                                    setStateForPWMDuty(out4duty,led_pwm_duty_states4[4])
                                                }


                                                onUserSet: {
                                                    platformInterface.outputDuty4 =  out4duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }



                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT4") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle{
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out3ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     true,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable3 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     false,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable3 = false

                                                    }


                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out3interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     true,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt3 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     false,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt3 = false

                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out3pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"
                                                handleColor: "white"
                                                grooveColor: "#ccc"
                                                grooveFillColor: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm3 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out3faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out3duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out3duty.from = led_pwm_duty_scales[1]
                                                    out3duty.to = led_pwm_duty_scales[0]
                                                    out3duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states3: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states3Changed: {
                                                    setStateForPWMDuty(out3duty,led_pwm_duty_states3[3])
                                                }
                                                onUserSet: {
                                                    platformInterface.outputDuty3 =  out3duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }
                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            SGText {
                                                text: "<b>" + qsTr("OUT3") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     true,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable2 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     platformInterface.outputEnable1,
                                                                     false,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable2 = false
                                                    }

                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     true,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt2 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     platformInterface.outputExt1,
                                                                     false,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt2 = false
                                                    }
                                                }
                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out2pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    platformInterface.outputPwm2 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out2faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            // color: "red"

                                            CustomizeRGBSlider {
                                                id: out2duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out2duty.from = led_pwm_duty_scales[1]
                                                    out2duty.to = led_pwm_duty_scales[0]
                                                    out2duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states2: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states2Changed: {
                                                    setStateForPWMDuty(out2duty,led_pwm_duty_states2[2])
                                                }

                                                onUserSet:  {
                                                    platformInterface.outputDuty2 =  out2duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }




                                            }
                                        }

                                    }
                                }
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    ColumnLayout {
                                        id: outputExternalLEDContainer
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10

                                            SGText {
                                                text: "<b>" + qsTr("OUT2") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out1ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     true,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable1 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [platformInterface.outputEnable0,
                                                                     false,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable1 = false

                                                    }



                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true


                                            SGSwitch {
                                                id: out1interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     true,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt1 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [platformInterface.outputExt0,
                                                                     false,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11

                                                                    ] )
                                                        platformInterface.outputExt1 = false

                                                    }
                                                }


                                            }
                                        }
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out1pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    platformInterface.outputPwm1 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }

                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out1faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out1duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out1duty.from = led_pwm_duty_scales[1]
                                                    out1duty.to = led_pwm_duty_scales[0]
                                                    out1duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states1: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states1Changed: {
                                                    setStateForPWMDuty(out1duty,led_pwm_duty_states1[1])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty1 =  out1duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }



                                            }
                                        }

                                    }
                                }

                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    //color: "blue"

                                    ColumnLayout {
                                        id: outputENContainer
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                id: text1
                                                text: "<b>" + qsTr("OUT1") + "</b>"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGSwitch {
                                                id: out0ENLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent
                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_out_en.update(
                                                                    [true,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable0 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_out_en.update(
                                                                    [false,
                                                                     platformInterface.outputEnable1,
                                                                     platformInterface.outputEnable2,
                                                                     platformInterface.outputEnable3,
                                                                     platformInterface.outputEnable4,
                                                                     platformInterface.outputEnable5,
                                                                     platformInterface.outputEnable6,
                                                                     platformInterface.outputEnable7,
                                                                     platformInterface.outputEnable8,
                                                                     platformInterface.outputEnable9,
                                                                     platformInterface.outputEnable10,
                                                                     platformInterface.outputEnable11

                                                                    ] )
                                                        platformInterface.outputEnable0 = false
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true

                                            SGSwitch {
                                                id: out0interExterLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
                                                                    [true,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt0 = true
                                                    }
                                                    else {
                                                        platformInterface.set_led_ext.update(
                                                                    [false,
                                                                     platformInterface.outputExt1,
                                                                     platformInterface.outputExt2,
                                                                     platformInterface.outputExt3,
                                                                     platformInterface.outputExt4,
                                                                     platformInterface.outputExt5,
                                                                     platformInterface.outputExt6,
                                                                     platformInterface.outputExt7,
                                                                     platformInterface.outputExt8,
                                                                     platformInterface.outputExt9,
                                                                     platformInterface.outputExt10,
                                                                     platformInterface.outputExt11
                                                                    ] )
                                                        platformInterface.outputExt0 = false

                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGSwitch {
                                                id: out0pwmEnableLED
                                                labelsInside: true
                                                checkedLabel: "On"
                                                uncheckedLabel: "Off"
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    platformInterface.outputPwm0 = checked
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ], [
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])

                                                }
                                            }
                                        }

                                        Rectangle {
                                            id: out0faultStatusLEDContainer
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            id: out0dutyContainer
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out0duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out0duty.from = led_pwm_duty_scales[1]
                                                    out0duty.to = led_pwm_duty_scales[0]
                                                    out0duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_states0: platformInterface.led_pwm_duty_states.states
                                                onLed_pwm_duty_states0Changed: {
                                                    setStateForPWMDuty(out0duty,led_pwm_duty_states0[0])
                                                }

                                                onUserSet: {
                                                    platformInterface.outputDuty0 =  out0duty.value.toFixed(0)
                                                    platformInterface.set_led_pwm_conf.update(pwmFrequency.currentText,
                                                                                              platformInterface.pwm_lin_state,
                                                                                              [platformInterface.outputDuty0,
                                                                                               platformInterface.outputDuty1,
                                                                                               platformInterface.outputDuty2,
                                                                                               platformInterface.outputDuty3,
                                                                                               platformInterface.outputDuty4,
                                                                                               platformInterface.outputDuty5,
                                                                                               platformInterface.outputDuty6,
                                                                                               platformInterface.outputDuty7,
                                                                                               platformInterface.outputDuty8,
                                                                                               platformInterface.outputDuty9,
                                                                                               platformInterface.outputDuty10,
                                                                                               platformInterface.outputDuty11

                                                                                              ],[
                                                                                                  platformInterface.outputPwm0,
                                                                                                  platformInterface.outputPwm1,
                                                                                                  platformInterface.outputPwm2,
                                                                                                  platformInterface.outputPwm3,
                                                                                                  platformInterface.outputPwm4,
                                                                                                  platformInterface.outputPwm5,
                                                                                                  platformInterface.outputPwm6,
                                                                                                  platformInterface.outputPwm7,
                                                                                                  platformInterface.outputPwm8,
                                                                                                  platformInterface.outputPwm9,
                                                                                                  platformInterface.outputPwm10,
                                                                                                  platformInterface.outputPwm11])
                                                }


                                            }
                                        }

                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle{
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height/20
                    color: "transparent"
                    Text {
                        id: i2cStatusHeading
                        text: "I2C Status Registers"
                        font.bold: true
                        font.pixelSize: ratioCalc * 20
                        color: "#696969"
                        anchors {
                            top: parent.top
                            topMargin: 5
                        }
                    }

                    Rectangle {
                        id: line5
                        height: 1.5
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width
                        border.color: "lightgray"
                        radius: 2
                        anchors {
                            top: i2cStatusHeading.bottom
                            topMargin: 7
                        }
                    }
                }


                Rectangle {
                    id: i2cStatusSettingContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    color: "transparent"
                    Rectangle {
                        id: i2cLEDS
                        anchors.fill: parent
                        color: "transparent"

                        RowLayout{
                            anchors.fill: parent
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: scIsetLabel
                                    target: scIset
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: scIset
                                        width: 30

                                        property var led_sc_iset: platformInterface.led_sc_iset
                                        onLed_sc_isetChanged: {
                                            scIsetLabel.text =  led_sc_iset_caption

                                        }

                                        property var led_sc_iset_caption: platformInterface.led_sc_iset_caption.caption
                                        onLed_sc_iset_captionChanged: {
                                            scIsetLabel.text =  led_sc_iset_caption

                                            setStatesForControls(scIsetLabel,led_sc_iset.states[0])

                                            if(led_sc_iset.value === false) {
                                                scIset.status = SGStatusLight.Off
                                            }
                                            else  scIset.status = SGStatusLight.Red
                                        }

                                        property var led_sc_iset_states: platformInterface.led_sc_iset_states.states
                                        onLed_sc_iset_statesChanged: {
                                            setStatesForControls(scIsetLabel,led_sc_iset_states[0])
                                        }

                                        property var led_sc_iset_value: platformInterface.led_sc_iset_value.value
                                        onLed_sc_iset_valueChanged: {
                                            if(led_sc_iset_value === false) {
                                                scIset.status = SGStatusLight.Off
                                            }
                                            else  scIset.status = SGStatusLight.Red
                                        }

                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: i2CerrLabel
                                    target: i2Cerr
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: i2Cerr
                                        width: 30

                                        property var led_i2cerr: platformInterface.led_i2cerr
                                        onLed_i2cerrChanged: {
                                            i2CerrLabel.text =  led_i2cerr.caption
                                            setStatesForControls(i2CerrLabel,led_i2cerr.states[0])
                                            if(led_i2cerr.value === false) {
                                                i2Cerr.status = SGStatusLight.Off
                                            }
                                            else  i2Cerr.status = SGStatusLight.Red
                                        }

                                        property var led_i2cerr_caption: platformInterface.led_i2cerr_caption.caption
                                        onLed_i2cerr_captionChanged: {
                                            i2CerrLabel.text =  led_i2cerr_caption
                                        }

                                        property var led_i2cerr_states: platformInterface.led_i2cerr_states.states
                                        onLed_i2cerr_statesChanged: {
                                            setStatesForControls(i2CerrLabel,led_i2cerr_states[0])
                                        }

                                        property var led_i2cerr_value: platformInterface.led_i2cerr_value.value
                                        onLed_i2cerr_valueChanged: {
                                            if(led_i2cerr_value === false) {
                                                i2Cerr.status = SGStatusLight.Off
                                            }
                                            else  i2Cerr.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: uvLabel
                                    target: uv
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: uv
                                        width: 30

                                        property var led_uv: platformInterface.led_uv
                                        onLed_uvChanged: {
                                            uvLabel.text =  led_uv_caption
                                            setStatesForControls(uvLabel,led_uv.states[0])
                                            if(led_uv.value === false)
                                                uv.status = SGStatusLight.Off

                                            else  uv.status = SGStatusLight.Red
                                        }

                                        property var led_uv_caption: platformInterface.led_uv_caption.caption
                                        onLed_uv_captionChanged: {
                                            uvLabel.text =  led_uv_caption
                                        }

                                        property var led_uv_states: platformInterface.led_uv_states.states
                                        onLed_uv_statesChanged: {
                                            setStatesForControls(uvLabel,led_uv_states[0])
                                        }

                                        property var led_uv_value: platformInterface.led_uv_value.value
                                        onLed_uv_valueChanged: {
                                            if(led_uv_value === false)
                                                uv.status = SGStatusLight.Off

                                            else  uv.status = SGStatusLight.Red
                                        }

                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: diagRangeLabel
                                    target: diagRange
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagRange
                                        width: 30

                                        property var led_diagrange: platformInterface.led_diagrange
                                        onLed_diagrangeChanged: {
                                            diagRangeLabel.text =  led_diagrange.caption
                                            setStatesForControls(diagRangeLabel,led_diagrange.states[0])

                                            if(led_diagrange.value === false)
                                                diagRange.status = SGStatusLight.Off

                                            else  diagRange.status = SGStatusLight.Green
                                        }

                                        property var led_diagrange_caption: platformInterface.led_diagrange_caption.caption
                                        onLed_diagrange_captionChanged: {
                                            diagRangeLabel.text =  led_diagrange_caption
                                        }

                                        property var led_diagrange_states: platformInterface.led_diagrange_states.states
                                        onLed_diagrange_statesChanged: {
                                            setStatesForControls(diagRangeLabel,led_diagrange_states[0])
                                        }

                                        property var led_diagrange_value: platformInterface.led_diagrange_value.value
                                        onLed_diagrange_valueChanged: {
                                            if(led_diagrange_value === false)
                                                diagRange.status = SGStatusLight.Off
                                            else  diagRange.status = SGStatusLight.Green
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: twLabel
                                    target: tw
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tw
                                        width: 30

                                        property var led_tw: platformInterface.led_tw
                                        onLed_twChanged:{
                                            twLabel.text =  led_tw_caption
                                            setStatesForControls(twLabel,led_tw.states[0])

                                            if(led_tw.value === false)
                                                tw.status = SGStatusLight.Off

                                            else  tw.status = SGStatusLight.Red
                                        }

                                        property var led_tw_caption: platformInterface.led_tw_caption.caption
                                        onLed_tw_captionChanged: {
                                            twLabel.text =  led_tw_caption
                                        }

                                        property var led_tw_states: platformInterface.led_tw_states.states
                                        onLed_tw_statesChanged: {
                                            setStatesForControls(twLabel,led_tw_states[0])
                                        }

                                        property var led_tw_value: platformInterface.led_tw_value.value
                                        onLed_tw_valueChanged: {
                                            if(led_tw_value === false)
                                                tw.status = SGStatusLight.Off

                                            else  tw.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: tsdLabel
                                    target: tsd
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tsd
                                        width: 30
                                        property var led_tsd: platformInterface.led_tsd
                                        onLed_tsdChanged: {
                                            tsdLabel.text =  led_tsd_caption
                                            setStatesForControls(tsdLabel,led_tsd.states[0])
                                            if(led_tsd.value === false)
                                                tsd.status = SGStatusLight.Off

                                            else  tsd.status = SGStatusLight.Red
                                        }

                                        property var led_tsd_caption: platformInterface.led_tsd_caption.caption
                                        onLed_tsd_captionChanged: {
                                            tsdLabel.text =  led_tsd_caption
                                        }

                                        property var led_tsd_states: platformInterface.led_tsd_states.states
                                        onLed_tsd_statesChanged: {
                                            setStatesForControls(tsdLabel,led_tsd_states[0])
                                        }

                                        property var led_tsd_value: platformInterface.led_tsd_value.value
                                        onLed_tsd_valueChanged: {
                                            if(led_tsd_value === false)
                                                tsd.status = SGStatusLight.Off

                                            else  tsd.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: diagerrLabel
                                    target: diagerr

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagerr
                                        width: 30

                                        property var led_diagerr: platformInterface.led_diagerr
                                        onLed_diagerrChanged: {
                                            diagerrLabel.text =  led_diagerr.caption
                                            setStatesForControls(diagerrLabel,led_diagerr.states[0])

                                            if(led_diagerr.value === false)
                                                diagerr.status = SGStatusLight.Off

                                            else  diagerr.status = SGStatusLight.Red

                                        }

                                        property var led_diagerr_caption: platformInterface.led_diagerr_caption.caption
                                        onLed_diagerr_captionChanged: {
                                            diagerrLabel.text =  led_diagerr_caption
                                        }

                                        property var led_diagerr_states: platformInterface.led_tsd_states.states
                                        onLed_diagerr_statesChanged: {
                                            setStatesForControls(diagerrLabel,led_diagerr_states[0])
                                        }

                                        property var led_diagerr_value: platformInterface.led_diagerr_value.value
                                        onLed_diagerr_valueChanged: {
                                            if(led_diagerr_value === false)
                                                diagerr.status = SGStatusLight.Off

                                            else  diagerr.status = SGStatusLight.Red
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                color: "transparent"
                                SGAlignedLabel {
                                    id: olLabel
                                    target: ol

                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc === 0 ? 1.0 : ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: ol
                                        width: 30
                                        property var led_ol: platformInterface.led_ol
                                        onLed_olChanged: {
                                            olLabel.text =  led_ol.caption
                                            setStatesForControls(olLabel,led_ol.states[0])
                                            if(led_ol.value === false)
                                                ol.status = SGStatusLight.Off

                                            else ol.status = SGStatusLight.Red
                                        }

                                        property var led_ol_caption: platformInterface.led_ol_caption.caption
                                        onLed_ol_captionChanged: {
                                            olLabel.text =  led_ol_caption
                                        }

                                        property var led_ol_states: platformInterface.led_ol_states.states
                                        onLed_ol_statesChanged: {
                                            setStatesForControls(olLabel,led_ol_states[0])
                                        }

                                        property var led_ol_value: platformInterface.led_ol_value.value
                                        onLed_ol_valueChanged: {
                                            if(led_ol_value === false)
                                                ol.status = SGStatusLight.Off

                                            else  ol.status = SGStatusLight.Red
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


