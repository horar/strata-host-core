import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    anchors.centerIn: parent
    height: parent.height
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width


    property var led_out_en: platformInterface.led_out_en
    onLed_out_enChanged: {
        ledoutEnLabel.text =  led_out_en.caption

        if(led_out_en.state === "enabled") {
            out0ENLED.enabled = true
            out0ENLED.opacity = 1.0
            out1ENLED.enabled = true
            out1ENLED.opacity = 1.0
            out2ENLED.enabled = true
            out2ENLED.opacity = 1.0
            out3ENLED.enabled = true
            out3ENLED.opacity = 1.0
            out4ENLED.enabled = true
            out4ENLED.opacity = 1.0
            out5ENLED.enabled = true
            out5ENLED.opacity = 1.0
            out6ENLED.enabled = true
            out6ENLED.opacity = 1.0
            out7ENLED.enabled = true
            out7ENLED.opacity = 1.0
            out8ENLED.enabled = true
            out8ENLED.opacity = 1.0
            out9ENLED.enabled = true
            out9ENLED.opacity = 1.0
            out10ENLED.enabled = true
            out10ENLED.opacity = 1.0
            out11ENLED.enabled = true
            out11ENLED.opacity = 1.0

        }
        else if (led_out_en.state === "disabled") {
            out0ENLED.enabled = false
            out0ENLED.opacity = 1.0
            out1ENLED.enabled = false
            out1ENLED.opacity = 1.0
            out2ENLED.enabled = false
            out2ENLED.opacity = 1.0
            out3ENLED.enabled = false
            out3ENLED.opacity = 1.0
            out4ENLED.enabled = false
            out4ENLED.opacity = 1.0
            out5ENLED.enabled = false
            out5ENLED.opacity = 1.0
            out6ENLED.enabled = false
            out6ENLED.opacity = 1.0
            out7ENLED.enabled = false
            out7ENLED.opacity = 1.0
            out8ENLED.enabled = false
            out8ENLED.opacity = 1.0
            out9ENLED.enabled = false
            out9ENLED.opacity = 1.0
            out10ENLED.enabled = false
            out10ENLED.opacity = 1.0
            out11ENLED.enabled = false
            out11ENLED.opacity = 1.0

        }
        else {
            out0ENLED.enabled = false
            out0ENLED.opacity = 0.5
            out1ENLED.enabled = false
            out1ENLED.opacity = 0.5
            out2ENLED.enabled = false
            out2ENLED.opacity = 0.5
            out3ENLED.enabled = false
            out3ENLED.opacity = 0.5
            out4ENLED.enabled = false
            out4ENLED.opacity = 0.5
            out5ENLED.enabled = false
            out5ENLED.opacity = 0.5
            out6ENLED.enabled = false
            out6ENLED.opacity = 0.5
            out7ENLED.enabled = false
            out7ENLED.opacity = 0.5
            out8ENLED.enabled = false
            out8ENLED.opacity = 0.5
            out9ENLED.enabled = false
            out9ENLED.opacity = 0.5
            out10ENLED.enabled = false
            out10ENLED.opacity = 0.5
            out11ENLED.enabled = false
            out11ENLED.opacity = 0.5
        }

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

    }

    property var led_out_en_state: platformInterface.led_out_en_state.state
    onLed_out_en_stateChanged: {
        if(led_out_en_state === "enabled") {
            out0ENLED.enabled = true
            out0ENLED.opacity = 1.0
            out1ENLED.enabled = true
            out1ENLED.opacity = 1.0
            out2ENLED.enabled = true
            out2ENLED.opacity = 1.0
            out3ENLED.enabled = true
            out3ENLED.opacity = 1.0
            out4ENLED.enabled = true
            out4ENLED.opacity = 1.0
            out5ENLED.enabled = true
            out5ENLED.opacity = 1.0
            out6ENLED.enabled = true
            out6ENLED.opacity = 1.0
            out7ENLED.enabled = true
            out7ENLED.opacity = 1.0
            out8ENLED.enabled = true
            out8ENLED.opacity = 1.0
            out9ENLED.enabled = true
            out9ENLED.opacity = 1.0
            out10ENLED.enabled = true
            out10ENLED.opacity = 1.0
            out11ENLED.enabled = true
            out11ENLED.opacity = 1.0

        }
        else if (led_out_en_state === "disabled") {
            out0ENLED.enabled = false
            out0ENLED.opacity = 1.0
            out1ENLED.enabled = false
            out1ENLED.opacity = 1.0
            out2ENLED.enabled = false
            out2ENLED.opacity = 1.0
            out3ENLED.enabled = false
            out3ENLED.opacity = 1.0
            out4ENLED.enabled = false
            out4ENLED.opacity = 1.0
            out5ENLED.enabled = false
            out5ENLED.opacity = 1.0
            out6ENLED.enabled = false
            out6ENLED.opacity = 1.0
            out7ENLED.enabled = false
            out7ENLED.opacity = 1.0
            out8ENLED.enabled = false
            out8ENLED.opacity = 1.0
            out9ENLED.enabled = false
            out9ENLED.opacity = 1.0
            out10ENLED.enabled = false
            out10ENLED.opacity = 1.0
            out11ENLED.enabled = false
            out11ENLED.opacity = 1.0

        }
        else {
            out0ENLED.enabled = false
            out0ENLED.opacity = 0.5
            out1ENLED.enabled = false
            out1ENLED.opacity = 0.5
            out2ENLED.enabled = false
            out2ENLED.opacity = 0.5
            out3ENLED.enabled = false
            out3ENLED.opacity = 0.5
            out4ENLED.enabled = false
            out4ENLED.opacity = 0.5
            out5ENLED.enabled = false
            out5ENLED.opacity = 0.5
            out6ENLED.enabled = false
            out6ENLED.opacity = 0.5
            out7ENLED.enabled = false
            out7ENLED.opacity = 0.5
            out8ENLED.enabled = false
            out8ENLED.opacity = 0.5
            out9ENLED.enabled = false
            out9ENLED.opacity = 0.5
            out10ENLED.enabled = false
            out10ENLED.opacity = 0.5
            out11ENLED.enabled = false
            out11ENLED.opacity = 0.5
        }
    }

    property var led_out_en_values: platformInterface.led_out_en_values.values
    onLed_out_en_valuesChanged:  {
        console.log(platformInterface.led_out_en_values.values)
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

        if(led_ext.state === "enabled") {
            out0interExterLED.enabled = true
            out0interExterLED.opacity = 1.0
            out1interExterLED.enabled = true
            out1interExterLED.opacity = 1.0
            out2interExterLED.enabled = true
            out2interExterLED.opacity = 1.0
            out3interExterLED.enabled = true
            out3interExterLED.opacity = 1.0
            out4interExterLED.enabled = true
            out4interExterLED.opacity = 1.0
            out5interExterLED.enabled = true
            out5interExterLED.opacity = 1.0
            out6interExterLED.enabled = true
            out6interExterLED.opacity = 1.0
            out7interExterLED.enabled = true
            out7interExterLED.opacity = 1.0
            out8interExterLED.enabled = true
            out8interExterLED.opacity = 1.0
            out9interExterLED.enabled = true
            out9interExterLED.opacity = 1.0
            out10interExterLED.enabled = true
            out10interExterLED.opacity = 1.0
            out11interExterLED.enabled = true
            out11interExterLED.opacity = 1.0

        }
        else if (led_ext.state === "disabled") {
            out0interExterLED.enabled = false
            out0interExterLED.opacity = 1.0
            out1interExterLED.enabled = false
            out1interExterLED.opacity = 1.0
            out2interExterLED.enabled = false
            out2interExterLED.opacity = 1.0
            out3interExterLED.enabled = false
            out3interExterLED.opacity = 1.0
            out4interExterLED.enabled = false
            out4interExterLED.opacity = 1.0
            out5interExterLED.enabled = false
            out5interExterLED.opacity = 1.0
            out6interExterLED.enabled = false
            out6interExterLED.opacity = 1.0
            out7interExterLED.enabled = false
            out7interExterLED.opacity = 1.0
            out8interExterLED.enabled = false
            out8interExterLED.opacity = 1.0
            out9interExterLED.enabled = false
            out9interExterLED.opacity = 1.0
            out10interExterLED.enabled = false
            out10interExterLED.opacity = 1.0
            out11interExterLED.enabled = false
            out11interExterLED.opacity = 1.0

        }
        else {
            out0interExterLED.enabled = false
            out0interExterLED.opacity = 0.5
            out1interExterLED.enabled = false
            out1interExterLED.opacity = 0.5
            out2interExterLED.enabled = false
            out2interExterLED.opacity = 0.5
            out3interExterLED.enabled = false
            out3interExterLED.opacity = 0.5
            out4interExterLED.enabled = false
            out4interExterLED.opacity = 0.5
            out5interExterLED.enabled = false
            out5interExterLED.opacity = 0.5
            out6interExterLED.enabled = false
            out6interExterLED.opacity = 0.5
            out7interExterLED.enabled = false
            out7interExterLED.opacity = 0.5
            out8interExterLED.enabled = false
            out8interExterLED.opacity = 0.5
            out9interExterLED.enabled = false
            out9interExterLED.opacity = 0.5
            out10interExterLED.enabled = false
            out10interExterLED.opacity = 0.5
            out11interExterLED.enabled = false
            out11interExterLED.opacity = 0.5
        }


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
    }

    property var led_ext_state: platformInterface.led_ext_state.state
    onLed_ext_stateChanged: {
        if(led_ext_state === "enabled") {
            out0interExterLED.enabled = true
            out0interExterLED.opacity = 1.0
            out1interExterLED.enabled = true
            out1interExterLED.opacity = 1.0
            out2interExterLED.enabled = true
            out2interExterLED.opacity = 1.0
            out3interExterLED.enabled = true
            out3interExterLED.opacity = 1.0
            out4interExterLED.enabled = true
            out4interExterLED.opacity = 1.0
            out5interExterLED.enabled = true
            out5interExterLED.opacity = 1.0
            out6interExterLED.enabled = true
            out6interExterLED.opacity = 1.0
            out7interExterLED.enabled = true
            out7interExterLED.opacity = 1.0
            out8interExterLED.enabled = true
            out8interExterLED.opacity = 1.0
            out9interExterLED.enabled = true
            out9interExterLED.opacity = 1.0
            out10interExterLED.enabled = true
            out10interExterLED.opacity = 1.0
            out11interExterLED.enabled = true
            out11interExterLED.opacity = 1.0

        }
        else if (led_ext_state === "disabled") {
            out0interExterLED.enabled = false
            out0interExterLED.opacity = 1.0
            out1interExterLED.enabled = false
            out1interExterLED.opacity = 1.0
            out2interExterLED.enabled = false
            out2interExterLED.opacity = 1.0
            out3interExterLED.enabled = false
            out3interExterLED.opacity = 1.0
            out4interExterLED.enabled = false
            out4interExterLED.opacity = 1.0
            out5interExterLED.enabled = false
            out5interExterLED.opacity = 1.0
            out6interExterLED.enabled = false
            out6interExterLED.opacity = 1.0
            out7interExterLED.enabled = false
            out7interExterLED.opacity = 1.0
            out8interExterLED.enabled = false
            out8interExterLED.opacity = 1.0
            out9interExterLED.enabled = false
            out9interExterLED.opacity = 1.0
            out10interExterLED.enabled = false
            out10interExterLED.opacity = 1.0
            out11interExterLED.enabled = false
            out11interExterLED.opacity = 1.0

        }
        else {
            out0interExterLED.enabled = false
            out0interExterLED.opacity = 0.5
            out1interExterLED.enabled = false
            out1interExterLED.opacity = 0.5
            out2interExterLED.enabled = false
            out2interExterLED.opacity = 0.5
            out3interExterLED.enabled = false
            out3interExterLED.opacity = 0.5
            out4interExterLED.enabled = false
            out4interExterLED.opacity = 0.5
            out5interExterLED.enabled = false
            out5interExterLED.opacity = 0.5
            out6interExterLED.enabled = false
            out6interExterLED.opacity = 0.5
            out7interExterLED.enabled = false
            out7interExterLED.opacity = 0.5
            out8interExterLED.enabled = false
            out8interExterLED.opacity = 0.5
            out9interExterLED.enabled = false
            out9interExterLED.opacity = 0.5
            out10interExterLED.enabled = false
            out10interExterLED.opacity = 0.5
            out11interExterLED.enabled = false
            out11interExterLED.opacity = 0.5
        }
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

        if(led_fault_status.state === "enabled") {
            out0faultStatusLED.enabled = true
            out0faultStatusLED.opacity = 1.0
            out1faultStatusLED.enabled = true
            out1faultStatusLED.opacity = 1.0
            out2faultStatusLED.enabled = true
            out2faultStatusLED.opacity = 1.0
            out3faultStatusLED.enabled = true
            out3faultStatusLED.opacity = 1.0
            out4faultStatusLED.enabled = true
            out4faultStatusLED.opacity = 1.0
            out5faultStatusLED.enabled = true
            out5faultStatusLED.opacity = 1.0
            out6faultStatusLED.enabled = true
            out6faultStatusLED.opacity = 1.0
            out7faultStatusLED.enabled = true
            out7faultStatusLED.opacity = 1.0
            out8faultStatusLED.enabled = true
            out8faultStatusLED.opacity = 1.0
            out9faultStatusLED.enabled = true
            out9faultStatusLED.opacity = 1.0
            out10faultStatusLED.enabled = true
            out10faultStatusLED.opacity = 1.0
            out11faultStatusLED.enabled = true
            out11faultStatusLED.opacity = 1.0

        }
        else if (led_fault_status.state === "disabled") {
            out0faultStatusLED.enabled = false
            out0faultStatusLED.opacity = 1.0
            out1faultStatusLED.enabled = false
            out1faultStatusLED.opacity = 1.0
            out2faultStatusLED.enabled = false
            out2faultStatusLED.opacity = 1.0
            out3faultStatusLED.enabled = false
            out3faultStatusLED.opacity = 1.0
            out4faultStatusLED.enabled = false
            out4faultStatusLED.opacity = 1.0
            out5faultStatusLED.enabled = false
            out5faultStatusLED.opacity = 1.0
            out6faultStatusLED.enabled = false
            out6faultStatusLED.opacity = 1.0
            out7faultStatusLED.enabled = false
            out7faultStatusLED.opacity = 1.0
            out8faultStatusLED.enabled = false
            out8faultStatusLED.opacity = 1.0
            out9faultStatusLED.enabled = false
            out9faultStatusLED.opacity = 1.0
            out10faultStatusLED.enabled = false
            out10faultStatusLED.opacity = 1.0
            out11faultStatusLED.enabled = false
            out11faultStatusLED.opacity = 1.0

        }
        else {
            out0faultStatusLED.enabled = false
            out0faultStatusLED.opacity = 0.5
            out1faultStatusLED.enabled = false
            out1faultStatusLED.opacity = 0.5
            out2faultStatusLED.enabled = false
            out2faultStatusLED.opacity = 0.5
            out3faultStatusLED.enabled = false
            out3faultStatusLED.opacity = 0.5
            out4faultStatusLED.enabled = false
            out4faultStatusLED.opacity = 0.5
            out5faultStatusLED.enabled = false
            out5faultStatusLED.opacity = 0.5
            out6faultStatusLED.enabled = false
            out6faultStatusLED.opacity = 0.5
            out7faultStatusLED.enabled = false
            out7faultStatusLED.opacity = 0.5
            out8faultStatusLED.enabled = false
            out8faultStatusLED.opacity = 0.5
            out9faultStatusLED.enabled = false
            out9faultStatusLED.opacity = 0.5
            out10faultStatusLED.enabled = false
            out10faultStatusLED.opacity = 0.5
            out11faultStatusLED.enabled = false
            out11faultStatusLED.opacity = 0.5
        }

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


    property var led_fault_status_state: platformInterface.led_fault_status_state.state
    onLed_fault_status_stateChanged: {
        if(led_fault_status_state === "enabled") {
            out0faultStatusLED.enabled = true
            out0faultStatusLED.opacity = 1.0
            out1faultStatusLED.enabled = true
            out1faultStatusLED.opacity = 1.0
            out2faultStatusLED.enabled = true
            out2faultStatusLED.opacity = 1.0
            out3faultStatusLED.enabled = true
            out3faultStatusLED.opacity = 1.0
            out4faultStatusLED.enabled = true
            out4faultStatusLED.opacity = 1.0
            out5faultStatusLED.enabled = true
            out5faultStatusLED.opacity = 1.0
            out6faultStatusLED.enabled = true
            out6faultStatusLED.opacity = 1.0
            out7faultStatusLED.enabled = true
            out7faultStatusLED.opacity = 1.0
            out8faultStatusLED.enabled = true
            out8faultStatusLED.opacity = 1.0
            out9faultStatusLED.enabled = true
            out9faultStatusLED.opacity = 1.0
            out10faultStatusLED.enabled = true
            out10faultStatusLED.opacity = 1.0
            out11faultStatusLED.enabled = true
            out11faultStatusLED.opacity = 1.0

        }
        else if (led_fault_status_state === "disabled") {
            out0faultStatusLED.enabled = false
            out0faultStatusLED.opacity = 1.0
            out1faultStatusLED.enabled = false
            out1faultStatusLED.opacity = 1.0
            out2faultStatusLED.enabled = false
            out2faultStatusLED.opacity = 1.0
            out3faultStatusLED.enabled = false
            out3faultStatusLED.opacity = 1.0
            out4faultStatusLED.enabled = false
            out4faultStatusLED.opacity = 1.0
            out5faultStatusLED.enabled = false
            out5faultStatusLED.opacity = 1.0
            out6faultStatusLED.enabled = false
            out6faultStatusLED.opacity = 1.0
            out7faultStatusLED.enabled = false
            out7faultStatusLED.opacity = 1.0
            out8faultStatusLED.enabled = false
            out8faultStatusLED.opacity = 1.0
            out9faultStatusLED.enabled = false
            out9faultStatusLED.opacity = 1.0
            out10faultStatusLED.enabled = false
            out10faultStatusLED.opacity = 1.0
            out11faultStatusLED.enabled = false
            out11faultStatusLED.opacity = 1.0

        }
        else {
            out0faultStatusLED.enabled = false
            out0faultStatusLED.opacity = 0.5
            out1faultStatusLED.enabled = false
            out1faultStatusLED.opacity = 0.5
            out2faultStatusLED.enabled = false
            out2faultStatusLED.opacity = 0.5
            out3faultStatusLED.enabled = false
            out3faultStatusLED.opacity = 0.5
            out4faultStatusLED.enabled = false
            out4faultStatusLED.opacity = 0.5
            out5faultStatusLED.enabled = false
            out5faultStatusLED.opacity = 0.5
            out6faultStatusLED.enabled = false
            out6faultStatusLED.opacity = 0.5
            out7faultStatusLED.enabled = false
            out7faultStatusLED.opacity = 0.5
            out8faultStatusLED.enabled = false
            out8faultStatusLED.opacity = 0.5
            out9faultStatusLED.enabled = false
            out9faultStatusLED.opacity = 0.5
            out10faultStatusLED.enabled = false
            out10faultStatusLED.opacity = 0.5
            out11faultStatusLED.enabled = false
            out11faultStatusLED.opacity = 0.5
        }
    }

    property var led_pwm_enables: platformInterface.led_pwm_enables
    onLed_pwm_enablesChanged: {
        pwmEnableText.text = led_pwm_enables.caption

        if(led_pwm_enables.values[0] === true)
            out0pwmEnableLED.checked = true
        else out0pwmEnableLED.checked = false

        if(led_pwm_enables.values[1] === true)
            out1pwmEnableLED.checked = true
        else out1pwmEnableLED.checked = false

        if(led_pwm_enables.values[2] === true)
            out2pwmEnableLED.checked = true
        else out2pwmEnableLED.checked = false

        if(led_pwm_enables.values[3] === true)
            out3pwmEnableLED.checked = true
        else out3pwmEnableLED.checked = false

        if(led_pwm_enables.values[4] === true)
            out4pwmEnableLED.checked = true
        else out4pwmEnableLED.checked = false

        if(led_pwm_enables.values[5] === true)
            out5pwmEnableLED.checked = true
        else out5pwmEnableLED.checked = false

        if(led_pwm_enables.values[6] === true)
            out6pwmEnableLED.checked = true
        else out6pwmEnableLED.checked = false

        if(led_pwm_enables.values[7] === true)
            out7pwmEnableLED.checked = true
        else out7pwmEnableLED.checked = false

        if(led_pwm_enables.values[8] === true)
            out8pwmEnableLED.checked = true
        else out8pwmEnableLED.checked = false

        if(led_pwm_enables.values[9] === true)
            out9pwmEnableLED.checked = true
        else out9pwmEnableLED.checked = false

        if(led_pwm_enables.values[10] === true)
            out10pwmEnableLED.checked = true
        else out10pwmEnableLED.checked = false

        if(led_pwm_enables.values[11] === true)
            out11pwmEnableLED.checked = true
        else out11pwmEnableLED.checked = false

        if(led_pwm_enables.state === "enabled") {
            out0pwmEnableLED.enabled = true
            out0pwmEnableLED.opacity = 1.0
            out1pwmEnableLED.enabled = true
            out1pwmEnableLED.opacity = 1.0
            out2pwmEnableLED.enabled = true
            out2pwmEnableLED.opacity = 1.0
            out3pwmEnableLED.enabled = true
            out3pwmEnableLED.opacity = 1.0
            out4pwmEnableLED.enabled = true
            out4pwmEnableLED.opacity = 1.0
            out5pwmEnableLED.enabled = true
            out5pwmEnableLED.opacity = 1.0
            out6pwmEnableLED.enabled = true
            out6pwmEnableLED.opacity = 1.0
            out7pwmEnableLED.enabled = true
            out7pwmEnableLED.opacity = 1.0
            out8pwmEnableLED.enabled = true
            out8pwmEnableLED.opacity = 1.0
            out9pwmEnableLED.enabled = true
            out9pwmEnableLED.opacity = 1.0
            out10pwmEnableLED.enabled = true
            out10pwmEnableLED.opacity = 1.0
            out11pwmEnableLED.enabled = true
            out11pwmEnableLED.opacity = 1.0

        }
        else if (led_pwm_enables.state === "disabled") {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 1.0
            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 1.0
            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 1.0
            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 1.0
            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 1.0
            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 1.0
            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 1.0
            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 1.0
            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 1.0
            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 1.0
            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 1.0
            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 1.0

        }
        else {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 0.5
            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 0.5
            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 0.5
            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 0.5
            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 0.5
            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 0.5
            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 0.5
            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 0.5
            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 0.5
            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 0.5
            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 0.5
            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 0.5
        }
    }


    property var led_pwm_enables_values: platformInterface.led_pwm_enables_values.values
    onLed_pwm_enables_valuesChanged: {
        if(led_pwm_enables_values[0] === true)
            out0pwmEnableLED.checked = true
        else out0pwmEnableLED.checked = false

        if(led_pwm_enables_values[1] === true)
            out1pwmEnableLED.checked = true
        else out1pwmEnableLED.checked = false

        if(led_pwm_enables_values[2] === true)
            out2pwmEnableLED.checked = true
        else out2pwmEnableLED.checked = false

        if(led_pwm_enables_values[3] === true)
            out3pwmEnableLED.checked = true
        else out3pwmEnableLED.checked = false

        if(led_pwm_enables_values[4] === true)
            out4pwmEnableLED.checked = true
        else out4pwmEnableLED.checked = false

        if(led_pwm_enables_values[5] === true)
            out5pwmEnableLED.checked = true
        else out5pwmEnableLED.checked = false

        if(led_pwm_enables_values[6] === true)
            out6pwmEnableLED.checked = true
        else out6pwmEnableLED.checked = false

        if(led_pwm_enables_values[7] === true)
            out7pwmEnableLED.checked = true
        else out7pwmEnableLED.checked = false

        if(led_pwm_enables_values[8] === true)
            out8pwmEnableLED.checked = true
        else out8pwmEnableLED.checked = false

        if(led_pwm_enables_values[9] === true)
            out9pwmEnableLED.checked = true
        else out9pwmEnableLED.checked = false

        if(led_pwm_enables_values[10] === true)
            out10pwmEnableLED.checked = true
        else out10pwmEnableLED.checked = false

        if(led_pwm_enables_values[11] === true)
            out11pwmEnableLED.checked = true
        else out11pwmEnableLED.checked = false
    }

    property var led_pwm_enables_state: platformInterface.led_pwm_enables_state.state
    onLed_pwm_enables_stateChanged: {
        if(led_pwm_enables_state === "enabled") {
            out0pwmEnableLED.enabled = true
            out0pwmEnableLED.opacity = 1.0
            out1pwmEnableLED.enabled = true
            out1pwmEnableLED.opacity = 1.0
            out2pwmEnableLED.enabled = true
            out2pwmEnableLED.opacity = 1.0
            out3pwmEnableLED.enabled = true
            out3pwmEnableLED.opacity = 1.0
            out4pwmEnableLED.enabled = true
            out4pwmEnableLED.opacity = 1.0
            out5pwmEnableLED.enabled = true
            out5pwmEnableLED.opacity = 1.0
            out6pwmEnableLED.enabled = true
            out6pwmEnableLED.opacity = 1.0
            out7pwmEnableLED.enabled = true
            out7pwmEnableLED.opacity = 1.0
            out8pwmEnableLED.enabled = true
            out8pwmEnableLED.opacity = 1.0
            out9pwmEnableLED.enabled = true
            out9pwmEnableLED.opacity = 1.0
            out10pwmEnableLED.enabled = true
            out10pwmEnableLED.opacity = 1.0
            out11pwmEnableLED.enabled = true
            out11pwmEnableLED.opacity = 1.0

        }
        else if (led_pwm_enables_state === "disabled") {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 1.0
            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 1.0
            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 1.0
            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 1.0
            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 1.0
            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 1.0
            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 1.0
            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 1.0
            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 1.0
            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 1.0
            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 1.0
            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 1.0

        }
        else {
            out0pwmEnableLED.enabled = false
            out0pwmEnableLED.opacity = 0.5
            out1pwmEnableLED.enabled = false
            out1pwmEnableLED.opacity = 0.5
            out2pwmEnableLED.enabled = false
            out2pwmEnableLED.opacity = 0.5
            out3pwmEnableLED.enabled = false
            out3pwmEnableLED.opacity = 0.5
            out4pwmEnableLED.enabled = false
            out4pwmEnableLED.opacity = 0.5
            out5pwmEnableLED.enabled = false
            out5pwmEnableLED.opacity = 0.5
            out6pwmEnableLED.enabled = false
            out6pwmEnableLED.opacity = 0.5
            out7pwmEnableLED.enabled = false
            out7pwmEnableLED.opacity = 0.5
            out8pwmEnableLED.enabled = false
            out8pwmEnableLED.opacity = 0.5
            out9pwmEnableLED.enabled = false
            out9pwmEnableLED.opacity = 0.5
            out10pwmEnableLED.enabled = false
            out10pwmEnableLED.opacity = 0.5
            out11pwmEnableLED.enabled = false
            out11pwmEnableLED.opacity = 0.5
        }
    }


    property var led_pwm_duty: platformInterface.led_pwm_duty
    onLed_pwm_dutyChanged: {
        pwmDutyText.text = led_pwm_duty.caption

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

        out0duty.from = led_pwm_duty.scales[0]
        out0duty.to = led_pwm_duty.scales[1]
        out0duty.value = led_pwm_duty.scales[2]

        if(led_pwm_duty.state === "enabled") {
            out0duty.enabled = true
            out0duty.opacity = 1.0
        }
        else if(led_pwm_duty.state === "disabled") {
            out0duty.enabled = false
            out0duty.opacity = 1.0
        }
        else {
            out0duty.enabled = false
            out0duty.opacity = 0.5
        }
    }

    RowLayout {
        anchors.fill: parent

        Rectangle {
            id: leftSetting
            Layout.fillHeight: true
            Layout.preferredWidth: root.width/3
            // color: "red"

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                Rectangle{
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    SGAlignedLabel {
                        id: partNumberLabel
                        target: partNumber
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        SGInfoBox{
                            id: partNumber
                            height:  35 * ratioCalc
                            width: 120 * ratioCalc
                            fontSizeMultiplier: ratioCalc * 1.2
                        }

                        property var led_part_number_value: platformInterface.led_part_number_value
                        onLed_part_number_valueChanged: {
                            partNumberLabel.text = led_part_number_value.caption
                            if(led_part_number_value.state === "enabled" ) {
                                partNumber.enabled = true
                                partNumber.opacity = 1.0

                            }
                            else if(led_part_number_value.state === "disabled") {
                                partNumber.enabled = false
                                partNumber.opacity = 1.0
                            }
                            else {
                                partNumber.enabled = false
                                partNumber.opacity = 0.5

                            }

                            partNumber.text = led_part_number_value.value
                        }

                        property var led_part_number_value_caption: platformInterface.led_part_number_value_caption.caption
                        onLed_part_number_value_captionChanged: {
                            partNumberLabel.text = led_part_number_value_caption
                        }

                        property var led_part_number_value_state: platformInterface.led_part_number_value_state.state
                        onLed_part_number_value_stateChanged: {
                            if(led_part_number_value_state === "enabled" ) {
                                partNumber.enabled = true
                                partNumber.opacity = 1.0

                            }
                            else if(led_part_number_value_state === "disabled") {
                                partNumber.enabled = false
                                partNumber.opacity = 1.0
                            }
                            else {
                                partNumber.enabled = false
                                partNumber.opacity = 0.5

                            }
                        }

                        property var led_part_number_value_value: platformInterface.led_part_number_value_value.value
                        onLed_part_number_value_valueChanged: {
                            partNumber.text = led_part_number_value_value
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
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: enableOutput
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            fontSizeMultiplier: ratioCalc
                            checked: false

                            onToggled: {
                                if(checked)
                                    platformInterface.set_led_oen.update(true)
                                else platformInterface.set_led_oen.update(false)
                            }

                            property var led_oen: platformInterface.led_oen
                            onLed_oenChanged: {
                                enableOutputLabel.text = led_oen.caption
                                if(led_oen.state === "enabled" ) {
                                    enableOutput.enabled = true
                                    enableOutput.opacity = 1.0

                                }
                                else if(led_oen.state === "disabled") {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 1.0
                                }
                                else {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 0.5

                                }
                                if(led_oen.value === true)
                                    enableOutput.checked = true
                                else  enableOutput.checked = false
                            }

                            property var led_oen_caption: platformInterface.led_oen_caption.caption
                            onLed_oen_captionChanged : {
                                enableOutputLabel.text = led_oen_caption
                            }

                            property var led_oen_state: platformInterface.led_oen_state.state
                            onLed_oen_stateChanged : {
                                if(led_oen_state === "enabled" ) {
                                    enableOutput.enabled = true
                                    enableOutput.opacity = 1.0

                                }
                                else if(led_oen_state === "disabled") {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 1.0
                                }
                                else {
                                    enableOutput.enabled = false
                                    enableOutput.opacity = 0.5

                                }
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
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmenableOutputLabel
                        target: pwmenableOutput

                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: pwmenableOutput
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            fontSizeMultiplier: ratioCalc
                            checked: false
                            onToggled: {
                                if(checked)
                                    platformInterface.set_led_pwm_enable.update(true)
                                else platformInterface.set_led_pwm_enable.update(false)
                            }

                            property var led_pwm_enable: platformInterface.led_pwm_enable
                            onLed_pwm_enableChanged: {
                                pwmenableOutputLabel.text = led_pwm_enable.caption

                                if(led_pwm_enable.state === "enabled" ) {
                                    pwmenableOutput.enabled = true
                                    pwmenableOutput.opacity = 1.0

                                }
                                else if(led_pwm_enable.state === "disabled") {
                                    pwmenableOutput.enabled = false
                                    pwmenableOutput.opacity = 1.0
                                }
                                else {
                                    pwmenableOutput.enabled = false
                                    enableOutput.opacity = 0.5
                                }

                                if(led_pwm_enable.value === true)
                                    pwmenableOutput.checked = true
                                else  pwmenableOutput.checked = false
                            }

                            property var led_pwm_enable_caption: platformInterface.led_pwm_enable_caption.caption
                            onLed_pwm_enable_captionChanged : {
                                pwmenableOutputLabel.text = led_pwm_enable_caption
                            }

                            property var led_pwm_enable_state: platformInterface.led_pwm_enable_state.state
                            onLed_pwm_enable_stateChanged : {
                                if(led_pwm_enable_state === "enabled" ) {
                                    pwmenableOutput.enabled = true
                                    pwmenableOutput.opacity = 1.0

                                }
                                else if(led_pwm_enable_state === "disabled") {
                                    pwmenableOutput.enabled = false
                                    pwmenableOutput.opacity = 1.0
                                }
                                else {
                                    pwmenableOutput.enabled = false
                                    enableOutput.opacity = 0.5

                                }
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
                        id: lockPWMDutyLabel
                        target: lockPWMDuty
                        //text: "Lock PWM Duty Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGSwitch {
                            id: lockPWMDuty
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            fontSizeMultiplier: ratioCalc
                            checked: false

                            onToggled: {
                                platformInterface.set_led_pwm_duty_lock.update(checke)
                            }


                            property var led_pwm_duty_lock: platformInterface.led_pwm_duty_lock
                            onLed_pwm_duty_lockChanged: {
                                lockPWMDutyLabel.text = led_pwm_duty_lock.caption

                                if(led_pwm_duty_lock.state === "enabled" ) {
                                    lockPWMDuty.enabled = true
                                    lockPWMDuty.opacity = 1.0

                                }
                                else if(led_pwm_duty_lock.state === "disabled") {
                                    lockPWMDuty.enabled = false
                                    lockPWMDuty.opacity = 1.0
                                }
                                else {
                                    lockPWMDuty.enabled = false
                                    lockPWMDuty.opacity = 0.5

                                }
                                if(led_pwm_duty_lock.value === true)
                                    lockPWMDuty.checked = true
                                else  lockPWMDuty.checked = false
                            }

                            property var led_pwm_duty_lock_caption: platformInterface.led_pwm_duty_lock_caption.caption
                            onLed_pwm_duty_lock_captionChanged : {
                                lockPWMDutyLabel.text = led_pwm_duty_lock_caption
                            }

                            property var led_pwm_duty_lock_state: platformInterface.led_pwm_duty_lock_state.state
                            onLed_pwm_duty_lock_stateChanged : {
                                if(led_pwm_duty_lock_state === "enabled" ) {
                                    lockPWMDuty.enabled = true
                                    lockPWMDuty.opacity = 1.0

                                }
                                else if(led_pwm_duty_lock_state === "disabled") {
                                    lockPWMDuty.enabled = false
                                    lockPWMDuty.opacity = 1.0
                                }
                                else {
                                    lockPWMDuty.enabled = false
                                    lockPWMDuty.opacity = 0.5

                                }
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
                        id: lockPWMDutyENLabel
                        target: lockPWMDutyEN
                        // text: "Lock PWM EN Together"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true
                        horizontalAlignment: Text.AlignHCenter

                        SGSwitch {
                            id: lockPWMDutyEN
                            labelsInside: true
                            checkedLabel: "On"
                            uncheckedLabel: "Off"
                            fontSizeMultiplier: ratioCalc
                            checked: false

                            onToggled: {
                                platformInterface.set_led_pwm_en_lock.update(checked)
                            }

                            property var led_pwm_en_lock: platformInterface.led_pwm_en_lock
                            onLed_pwm_en_lockChanged: {
                                lockPWMDutyENLabel.text = led_pwm_en_lock.caption
                                if(led_pwm_en_lock.state === "enabled" ) {
                                    lockPWMDutyEN.enabled = true
                                    lockPWMDutyEN.opacity = 1.0

                                }
                                else if(led_pwm_en_lock.state === "disabled") {
                                    lockPWMDutyEN.enabled = false
                                    lockPWMDutyEN.opacity = 1.0
                                }
                                else {
                                    lockPWMDutyEN.enabled = false
                                    lockPWMDutyEN.opacity = 0.5

                                }
                                if(led_pwm_en_lock.value === true)
                                    lockPWMDutyEN.checked = true
                                else  lockPWMDutyEN.checked = false

                            }

                            property var led_pwm_en_lock_caption: platformInterface.led_pwm_en_lock_caption.caption
                            onLed_pwm_en_lock_captionChanged : {
                                lockPWMDutyENLabel.text = led_pwm_en_lock_caption

                            }

                            property var led_pwm_en_lock_state: platformInterface.led_pwm_en_lock_state.state
                            onLed_pwm_en_lock_stateChanged : {
                                if(led_pwm_en_lock_state === "enabled" ) {
                                    lockPWMDutyEN.enabled = true
                                    lockPWMDutyEN.opacity = 1.0

                                }
                                else if(led_pwm_en_lock_state === "disabled") {
                                    lockPWMDutyEN.enabled = false
                                    lockPWMDutyEN.opacity = 1.0
                                }
                                else {
                                    lockPWMDutyEN.enabled = false
                                    lockPWMDutyEN.opacity = 0.5

                                }
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
                        id: pwmLinearLogLabel
                        target: pwmLinearLog
                        // text: "PWM Linear/Log"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true


                        SGSwitch {
                            id: pwmLinearLog
                            fontSizeMultiplier: ratioCalc

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
                                if(led_linear_log.state === "enabled" ) {
                                    pwmLinearLog.enabled = true
                                    pwmLinearLog.opacity = 1.0

                                }
                                else if(led_linear_log.state === "disabled") {
                                    pwmLinearLog.enabled = false
                                    pwmLinearLog.opacity = 1.0
                                }
                                else {
                                    pwmLinearLog.enabled = false
                                    pwmLinearLog.opacity = 0.5

                                }
                                pwmLinearLog.checkedLabel = led_linear_log.values[0]
                                pwmLinearLog.uncheckedLabel = led_linear_log.values[1]

                                if(led_linear_log.value === "Linear")
                                    pwmLinearLog.checked = true
                                else  pwmLinearLog.checked = false
                            }


                            property var led_linear_log_caption: platformInterface.led_linear_log_caption.caption
                            onLed_linear_log_captionChanged: {
                                pwmLinearLogLabel.text = led_linear_log_caption
                            }

                            property var led_linear_log_state: platformInterface.led_linear_log_state.state
                            onLed_linear_log_stateChanged: {
                                if(led_linear_log_state === "enabled" ) {
                                    pwmLinearLog.enabled = true
                                    pwmLinearLog.opacity = 1.0

                                }
                                else if(led_linear_log_state === "disabled") {
                                    pwmLinearLog.enabled = false
                                    pwmLinearLog.opacity = 1.0
                                }
                                else {
                                    pwmLinearLog.enabled = false
                                    pwmLinearLog.opacity = 0.5

                                }
                            }

                            property var led_linear_log_values: platformInterface.led_linear_log_values.values
                            onLed_linear_log_valuesChanged: {
                                pwmLinearLog.checkedLabel = led_linear_log_values[0]
                                pwmLinearLog.uncheckedLabel = led_linear_log_values[1]
                            }

                            property var led_linear_log_value: platformInterface.led_linear_log_value.value
                            onLed_linear_log_valueChanged: {
                                if(led_linear_log_value === "Linear")
                                    pwmLinearLog.checked = true
                                else  pwmLinearLog.checked = false

                            }
                        }
                    }
                }
                //                Rectangle {
                //                    Layout.fillHeight: true
                //                    Layout.fillWidth: true
                //                    //color: "red"

                //                    SGAlignedLabel {
                //                        id: autoFaultRecoveryLabel
                //                        target: autoFaultRecovery
                //                        text: "Auto Fault Recovery"
                //                        alignment: SGAlignedLabel.SideLeftCenter
                //                        anchors {
                //                            right: parent.right
                //                            verticalCenter: parent.verticalCenter
                //                            rightMargin: 60

                //                        }

                //                        fontSizeMultiplier: ratioCalc * 1.2
                //                        font.bold : true

                //                        SGSwitch {
                //                            id: autoFaultRecovery
                //                            labelsInside: true
                //                            checkedLabel: "On"
                //                            uncheckedLabel: "Off"
                //                            textColor: "black"              // Default: "black"
                //                            handleColor: "white"            // Default: "white"
                //                            grooveColor: "#ccc"             // Default: "#ccc"
                //                            grooveFillColor: "#0cf"         // Default: "#0cf"
                //                            fontSizeMultiplier: ratioCalc
                //                            checked: false
                //                        }
                //                    }
                //                }
                //                Rectangle {
                //                    Layout.fillHeight: true
                //                    Layout.fillWidth: true
                //                    SGAlignedLabel {
                //                        id: label
                //                        target: labelSwitch
                //                        text: "?"
                //                        alignment: SGAlignedLabel.SideLeftCenter
                //                        anchors {
                //                            right: parent.right
                //                            verticalCenter: parent.verticalCenter
                //                            rightMargin: 60

                //                        }

                //                        fontSizeMultiplier: ratioCalc * 1.2
                //                        font.bold : true

                //                        SGSwitch {
                //                            id: labelSwitch
                //                            labelsInside: true
                //                            checkedLabel: "On"
                //                            uncheckedLabel: "Off"
                //                            textColor: "black"              // Default: "black"
                //                            handleColor: "white"            // Default: "white"
                //                            grooveColor: "#ccc"             // Default: "#ccc"
                //                            grooveFillColor: "#0cf"         // Default: "#0cf"
                //                            fontSizeMultiplier: ratioCalc
                //                            checked: false
                //                        }
                //                    }
                //                }
                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: pwmFrequencyLabel
                        target: pwmFrequency
                        // text: "PWM Frequency (Hz)"
                        alignment: SGAlignedLabel.SideLeftCenter
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60

                        }
                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: pwmFrequency
                            fontSizeMultiplier: ratioCalc

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

                                if(led_pwm_freq.state === "enabled" ) {
                                    pwmFrequency.enabled = true
                                    pwmFrequency.opacity = 1.0

                                }
                                else if(led_pwm_freq.state === "disabled") {
                                    pwmFrequency.enabled = false
                                    pwmFrequency.opacity = 1.0
                                }
                                else {
                                    pwmFrequency.enabled = false
                                    pwmFrequency.opacity = 0.5

                                }

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

                            property var led_pwm_freq_state: platformInterface.led_pwm_freq_state.state
                            onLed_pwm_freq_stateChanged: {
                                if(led_pwm_freq_state === "enabled" ) {
                                    pwmFrequency.enabled = true
                                    pwmFrequency.opacity = 1.0

                                }
                                else if(led_pwm_freq_state === "disabled") {
                                    pwmFrequency.enabled = false
                                    pwmFrequency.opacity = 1.0
                                }
                                else {
                                    pwmFrequency.enabled = false
                                    pwmFrequency.opacity = 0.5

                                }
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

                Rectangle {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGAlignedLabel {
                        id: openLoadLabel
                        target: openLoadDiagnostic
                        //text: "I2C Open Load\nDiagnostic"
                        alignment: SGAlignedLabel.SideLeftCenter

                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            rightMargin: 60
                        }

                        fontSizeMultiplier: ratioCalc * 1.2
                        font.bold : true

                        SGComboBox {
                            id: openLoadDiagnostic
                            fontSizeMultiplier: ratioCalc
                            // model: ["No Diagnostic", "Auto Retry", "Detect Only", "No Regulations\nChange"]

                            onActivated: {
                                platformInterface.set_led_diag_mode.update(currentText)
                            }

                            property var led_open_load_diagnostic: platformInterface.led_open_load_diagnostic
                            onLed_open_load_diagnosticChanged: {
                                openLoadLabel.text = led_open_load_diagnostic.caption

                                if(led_open_load_diagnostic.state === "enabled" ) {
                                    openLoadDiagnostic.enabled = true
                                    openLoadDiagnostic.opacity = 1.0

                                }
                                else if(led_open_load_diagnostic.state === "disabled") {
                                    openLoadDiagnostic.enabled = false
                                    openLoadDiagnostic.opacity = 1.0
                                }
                                else {
                                    openLoadDiagnostic.enabled = false
                                    openLoadDiagnostic.opacity = 0.5

                                }

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

                            property var led_open_load_diagnostic_state: platformInterface.led_open_load_diagnostic_state.state
                            onLed_open_load_diagnostic_stateChanged: {
                                if(led_open_load_diagnostic_state === "enabled" ) {
                                    openLoadDiagnostic.enabled = true
                                    openLoadDiagnostic.opacity = 1.0

                                }
                                else if(led_open_load_diagnostic_state === "disabled") {
                                    openLoadDiagnostic.enabled = false
                                    openLoadDiagnostic.opacity = 1.0
                                }
                                else {
                                    openLoadDiagnostic.enabled = false
                                    openLoadDiagnostic.opacity = 0.5

                                }
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

        Rectangle {
            id: rightSetting
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: "transparent"

            ColumnLayout{
                anchors.fill: parent
                anchors.right: parent.right
                anchors.rightMargin: 15


                Rectangle {
                    Layout.preferredHeight: parent.height/1.2
                    Layout.fillWidth: true
                    //color: "red"
                    ColumnLayout {
                        anchors.fill: parent
                        Rectangle {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            //color: "grey"
                            RowLayout {
                                anchors.fill: parent
                                Rectangle {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: parent.width/12
                                    //color: "blue"
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
                                                //text: "<b>" + qsTr("OUT EN") + "</b>"
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
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
                                                //text: "Internal \n External LED"
                                                horizontalAlignment: Text.AlignHCenter
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
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
                                                // text: "<b>" + qsTr("PWM Enable") + "</b>"
                                                font.bold: true
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
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
                                                // text: "<b>" + qsTr("Fault Status") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
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
                                            // color: "red"
                                            SGText {
                                                id: pwmDutyText
                                                font.bold: true
                                                //text: "<b>" + qsTr("PWM Duty (%)") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.right: parent.right
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
                                    //color: "blue"

                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                id: text1
                                                text: "<b>" + qsTr("OUT0") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
                                                anchors.bottom: parent.bottom
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            // color: "blue"


                                            SGSwitch {
                                                id: out0ENLED
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out0faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/3
                                            CustomizeRGBSlider {
                                                id: out0duty
                                                width: 30
                                                height: parent.height
                                                orientation: Qt.Vertical
                                                anchors.centerIn: parent
                                                slider_start_color: 0.1666
                                                decimalPlacesFromStepSize: 0
                                                property var led_pwm_duty_scales: platformInterface.led_pwm_duty_scales.scales
                                                onLed_pwm_duty_scalesChanged: {
                                                    out0duty.from = led_pwm_duty_scales[0]
                                                    out0duty.to = led_pwm_duty_scales[1]
                                                    out0duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out0duty.enabled = true
                                                        out0duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out0duty.enabled = false
                                                        out0duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out0duty.enabled = false
                                                        out0duty.opacity = 0.5
                                                    }
                                                }

                                                onUserSet: {
                                                    console.log("pwm duty", out0duty.value)
                                                    platformInterface.outputDuty0 =  out0duty.value
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
                                                text: "<b>" + qsTr("OUT1") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out1duty.from = led_pwm_duty_scales[0]
                                                    out1duty.to = led_pwm_duty_scales[1]
                                                    out1duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out1duty.enabled = true
                                                        out1duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out1duty.enabled = false
                                                        out1duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out1duty.enabled = false
                                                        out1duty.opacity = 0.5
                                                    }
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
                                    ColumnLayout {
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT2") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
                                                checked: false
                                                anchors.centerIn: parent

                                                onToggled: {
                                                    if(checked) {
                                                        platformInterface.set_led_ext.update(
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
                                                        platformInterface.set_led_ext.update(
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out2duty.from = led_pwm_duty_scales[0]
                                                    out2duty.to = led_pwm_duty_scales[1]
                                                    out2duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out2duty.enabled = true
                                                        out2duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out2duty.enabled = false
                                                        out2duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out2duty.enabled = false
                                                        out2duty.opacity = 0.5
                                                    }
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
                                        anchors.fill: parent
                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: parent.height/10
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT3") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                        platformInterface.outputEnable3 = true

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
                                                textColor: "black"              // Default: "black"
                                                handleColor: "white"            // Default: "white"
                                                grooveColor: "#ccc"             // Default: "#ccc"
                                                grooveFillColor: "#0cf"         // Default: "#0cf"
                                                fontSizeMultiplier: ratioCalc
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
                                                    out3duty.from = led_pwm_duty_scales[0]
                                                    out3duty.to = led_pwm_duty_scales[1]
                                                    out3duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out3duty.enabled = true
                                                        out3duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out3duty.enabled = false
                                                        out3duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out3duty.enabled = false
                                                        out3duty.opacity = 0.5
                                                    }
                                                }

                                                onUserSet:
                                                {
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

                                                //                                                onValueChanged: {
                                                //                                                    platformInterface.outputDuty3 =  out3duty.value.toFixed(0)

                                                //                                                }


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
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out4duty.from = led_pwm_duty_scales[0]
                                                    out4duty.to = led_pwm_duty_scales[1]
                                                    out4duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out4duty.enabled = true
                                                        out4duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out4duty.enabled = false
                                                        out4duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out4duty.enabled = false
                                                        out4duty.opacity = 0.5
                                                    }
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
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT5") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out5duty.from = led_pwm_duty_scales[0]
                                                    out5duty.to = led_pwm_duty_scales[1]
                                                    out5duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out5duty.enabled = true
                                                        out5duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out5duty.enabled = false
                                                        out5duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out5duty.enabled = false
                                                        out5duty.opacity = 0.5
                                                    }
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
                                                text: "<b>" + qsTr("OUT6") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out6duty.from = led_pwm_duty_scales[0]
                                                    out6duty.to = led_pwm_duty_scales[1]
                                                    out6duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out6duty.enabled = true
                                                        out6duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out6duty.enabled = false
                                                        out6duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out6duty.enabled = false
                                                        out6duty.opacity = 0.5
                                                    }
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
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT7") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                        platformInterface.outputExt7 = false
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
                                                                     true,
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out7duty.from = led_pwm_duty_scales[0]
                                                    out7duty.to = led_pwm_duty_scales[1]
                                                    out7duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out7duty.enabled = true
                                                        out7duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out7duty.enabled = false
                                                        out7duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out7duty.enabled = false
                                                        out7duty.opacity = 0.5
                                                    }
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
                                                text: "<b>" + qsTr("OUT8") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out8duty.from = led_pwm_duty_scales[0]
                                                    out8duty.to = led_pwm_duty_scales[1]
                                                    out8duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out8duty.enabled = true
                                                        out8duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out8duty.enabled = false
                                                        out8duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out8duty.enabled = false
                                                        out8duty.opacity = 0.5
                                                    }
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
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT9") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                    out9duty.from = led_pwm_duty_scales[0]
                                                    out9duty.to = led_pwm_duty_scales[1]
                                                    out9duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out9duty.enabled = true
                                                        out9duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out9duty.enabled = false
                                                        out9duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out9duty.enabled = false
                                                        out9duty.opacity = 0.5
                                                    }
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
                                                text: "<b>" + qsTr("OUT10") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                anchors.left: parent.left
                                                anchors.leftMargin: 5
                                                anchors.verticalCenter: parent.verticalCenter
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
                                                    out10duty.from = led_pwm_duty_scales[0]
                                                    out10duty.to = led_pwm_duty_scales[1]
                                                    out10duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out10duty.enabled = true
                                                        out10duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out10duty.enabled = false
                                                        out10duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out10duty.enabled = false
                                                        out10duty.opacity = 0.5
                                                    }
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
                                            //color: "red"
                                            SGText {
                                                text: "<b>" + qsTr("OUT11") + "</b>"
                                                fontSizeMultiplier: ratioCalc * 1.2
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                                fontSizeMultiplier: ratioCalc
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
                                            Layout.fillWidth: true
                                            Layout.fillHeight: true
                                            SGStatusLight {
                                                id: out11faultStatusLED
                                                width: 30
                                                anchors.centerIn: parent
                                            }
                                        }

                                        Rectangle {
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
                                                    out11duty.from = led_pwm_duty_scales[0]
                                                    out11duty.to = led_pwm_duty_scales[1]
                                                    out11duty.value = led_pwm_duty_scales[2]
                                                }

                                                property var led_pwm_duty_state: platformInterface.led_pwm_duty_state.state
                                                onLed_pwm_duty_stateChanged: {
                                                    if(led_pwm_duty_state === "enabled") {
                                                        out11duty.enabled = true
                                                        out11duty.opacity = 1.0
                                                    }
                                                    else if(led_pwm_duty_state === "disabled") {
                                                        out11duty.enabled = false
                                                        out11duty.opacity = 1.0
                                                    }
                                                    else {
                                                        out11duty.enabled = false
                                                        out11duty.opacity = 0.5
                                                    }
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
                            }
                        }

                        Rectangle {
                            id: gobalCurrentSetContainer
                            Layout.preferredHeight: parent.height/10
                            Layout.fillWidth: true
                            SGAlignedLabel {
                                id: gobalCurrentSetLabel
                                target: gobalCurrentSetSlider
                                fontSizeMultiplier: ratioCalc * 1.2
                                font.bold : true
                                alignment: SGAlignedLabel.SideLeftCenter
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                //text: "Gobal Current Set (ISET)"
                                SGSlider {
                                    id: gobalCurrentSetSlider
                                    width: gobalCurrentSetContainer.width/1.5
                                    live: false
                                    fontSizeMultiplier: ratioCalc * 1.2

                                }

                                property var led_iset: platformInterface.led_iset
                                onLed_isetChanged:{
                                    gobalCurrentSetLabel.text = led_iset.caption

                                    gobalCurrentSetSlider.toText.text = led_iset.scales[0] + "mA"
                                    gobalCurrentSetSlider.to = led_iset.scales[0]
                                    gobalCurrentSetSlider.fromText.text = led_iset.scales[1] + "mA"
                                    gobalCurrentSetSlider.from = led_iset.scales[1]
                                    gobalCurrentSetSlider.stepSize = led_iset.scales[2]

                                    if(led_iset.state === "enabled") {
                                        gobalCurrentSetLabel.enabled = true
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else if (led_iset.state === "disabled") {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else  {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 0.5
                                    }

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

                                property var led_iset_state: platformInterface.led_iset_state.state
                                onLed_iset_stateChanged:{
                                    if(led_iset_state === "enabled") {
                                        gobalCurrentSetLabel.enabled = true
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else if (led_iset_state === "disabled") {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 1.0
                                    }
                                    else  {
                                        gobalCurrentSetLabel.enabled = false
                                        gobalCurrentSetLabel.opacity = 0.5
                                    }

                                }


                                property var led_iset_value: platformInterface.led_iset_value.value
                                onLed_iset_valueChanged: {
                                    gobalCurrentSetSlider.value = led_iset_value
                                }



                            }
                        }
                    }
                }


                Rectangle {
                    id: i2cStatusSettingContainer
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    //  color: "red"

                    SGText{
                        id: i2cStatusLable
                        fontSizeMultiplier: ratioCalc * 1.2
                        text: "I2C Status Registers"
                        font.bold: true
                        anchors.top: parent. top
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                    }

                    Rectangle {
                        id: i2cLEDS
                        anchors.top: i2cStatusLable.bottom
                        anchors.centerIn: parent
                        width: parent.width - 100
                        height: parent.height - i2cStatusLable.contentHeight
                        color: "transparent"

                        RowLayout{
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
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diag
                                        width: 30

                                        property var led_diag: platformInterface.led_diag
                                        onLed_diagChanged: {
                                            diagLabel.text =  led_diag_caption
                                        }

                                        property var led_diag_caption: platformInterface.led_diag_caption.caption
                                        onLed_diag_captionChanged: {
                                            diagLabel.text =  led_diag.caption

                                            if(led_diag.state === "enabled") {
                                                diagLabel.enabled = true
                                                diagLabel.opacity = 1.0
                                            }
                                            else if (led_diag.state === "disabled") {
                                                diagLabel.enabled = false
                                                diagLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagLabel.enabled = false
                                                diagLabel.opacity = 0.5
                                            }

                                            if(led_diag.value === false)
                                                diag.status = SGStatusLight.Off

                                            else  diag.status = SGStatusLight.Red
                                        }

                                        property var led_diag_state: platformInterface.led_diag_state.state
                                        onLed_diag_stateChanged: {
                                            if(led_diag_state === "enabled") {
                                                diagLabel.enabled = true
                                                diagLabel.opacity = 1.0
                                            }
                                            else if (led_diag_state === "disabled") {
                                                diagLabel.enabled = false
                                                diagLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagLabel.enabled = false
                                                diagLabel.opacity = 0.5
                                            }
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
                                Layout.fillWidth: true
                                color: "transparent"

                                SGAlignedLabel {
                                    id: scIsetLabel
                                    target: scIset
                                    //text:  "SC_Iset"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
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

                                            if(led_sc_iset.state === "enabled") {
                                                scIsetLabel.enabled = true
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else if (led_sc_iset.state === "disabled") {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else  {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 0.5
                                            }

                                            if(led_sc_iset.value === false) {
                                                scIset.status = SGStatusLight.Off
                                            }
                                            else  scIset.status = SGStatusLight.Red
                                        }

                                        property var led_sc_iset_state: platformInterface.led_sc_iset_state.state
                                        onLed_sc_iset_stateChanged: {
                                            if(led_sc_iset_state === "enabled") {
                                                scIsetLabel.enabled = true
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else if (led_sc_iset_state === "disabled") {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 1.0
                                            }
                                            else  {
                                                scIsetLabel.enabled = false
                                                scIsetLabel.opacity = 0.5
                                            }
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
                                    //text:  "I2Cerr"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: i2Cerr
                                        width: 30

                                        property var led_i2cerr: platformInterface.led_i2cerr
                                        onLed_i2cerrChanged: {
                                            i2CerrLabel.text =  led_i2cerr.caption
                                            if(led_i2cerr.state === "enabled") {
                                                i2CerrLabel.enabled = true
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else if (led_i2cerr.state === "disabled") {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 0.5
                                            }

                                            if(led_i2cerr.value === false) {
                                                i2Cerr.status = SGStatusLight.Off
                                            }
                                            else  i2Cerr.status = SGStatusLight.Red
                                        }

                                        property var led_i2cerr_caption: platformInterface.led_i2cerr_caption.caption
                                        onLed_i2cerr_captionChanged: {
                                            i2CerrLabel.text =  led_i2cerr_caption


                                        }

                                        property var led_i2cerr_state: platformInterface.led_i2cerr_state.state
                                        onLed_i2cerr_stateChanged: {
                                            if(led_i2cerr_state === "enabled") {
                                                i2CerrLabel.enabled = true
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else if (led_i2cerr_state === "disabled") {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                i2CerrLabel.enabled = false
                                                i2CerrLabel.opacity = 0.5
                                            }
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
                                    //text:  "UV"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: uv
                                        width: 30

                                        property var led_uv: platformInterface.led_uv
                                        onLed_uvChanged: {
                                            uvLabel.text =  led_uv_caption
                                            if(led_uv.state === "enabled") {
                                                uvLabel.enabled = true
                                                uvLabel.opacity = 1.0
                                            }
                                            else if (led_uv.state === "disabled") {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 1.0
                                            }
                                            else  {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 0.5
                                            }
                                            if(led_uv.value === false)
                                                uv.status = SGStatusLight.Off

                                            else  uv.status = SGStatusLight.Red
                                        }

                                        property var led_uv_caption: platformInterface.led_uv_caption.caption
                                        onLed_uv_captionChanged: {
                                            uvLabel.text =  led_uv_caption
                                        }

                                        property var led_uv_state: platformInterface.led_uv_state.state
                                        onLed_uv_stateChanged: {
                                            if(led_uv_state === "enabled") {
                                                uvLabel.enabled = true
                                                uvLabel.opacity = 1.0
                                            }
                                            else if (led_uv_state === "disabled") {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 1.0
                                            }
                                            else  {
                                                uvLabel.enabled = false
                                                uvLabel.opacity = 0.5
                                            }
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
                                    //text:  "diagRange"
                                    font.bold: true
                                    alignment: SGAlignedLabel.SideTopCenter
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagRange
                                        width: 30

                                        property var led_diagrange: platformInterface.led_diagrange
                                        onLed_diagrangeChanged: {
                                            diagRangeLabel.text =  led_diagrange.caption

                                            if(led_diagrange.state === "enabled") {
                                                diagRangeLabel.enabled = true
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else if (led_diagrange.state === "disabled") {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 0.5
                                            }

                                            if(led_diagrange.value === false)
                                                diagRange.status = SGStatusLight.Off

                                            else  diagRange.status = SGStatusLight.Red
                                        }

                                        property var led_diagrange_caption: platformInterface.led_diagrange_caption.caption
                                        onLed_diagrange_captionChanged: {
                                            diagRangeLabel.text =  led_diagrange_caption
                                        }

                                        property var led_diagrange_state: platformInterface.led_diagrange_state.state
                                        onLed_diagrange_stateChanged: {
                                            if(led_diagrange_state === "enabled") {
                                                diagRangeLabel.enabled = true
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else if (led_diagrange_state === "disabled") {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagRangeLabel.enabled = false
                                                diagRangeLabel.opacity = 0.5
                                            }
                                        }

                                        property var led_diagrange_value: platformInterface.led_diagrange_value.value
                                        onLed_diagrange_valueChanged: {
                                            if(led_diagrange_value === false)
                                                diagRange.status = SGStatusLight.Off

                                            else  diagRange.status = SGStatusLight.Red
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
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tw
                                        width: 30

                                        property var led_tw: platformInterface.led_tw
                                        onLed_twChanged:{
                                            twLabel.text =  led_tw_caption

                                            if(led_tw.state === "enabled") {
                                                twLabel.enabled = true
                                                twLabel.opacity = 1.0
                                            }
                                            else if (led_tw.state === "disabled") {
                                                twLabel.enabled = false
                                                twLabel.opacity = 1.0
                                            }
                                            else  {
                                                twLabel.enabled = false
                                                twLabel.opacity = 0.5
                                            }

                                            if(led_tw.value === false)
                                                tw.status = SGStatusLight.Off

                                            else  tw.status = SGStatusLight.Red
                                        }

                                        property var led_tw_caption: platformInterface.led_tw_caption.caption
                                        onLed_tw_captionChanged: {
                                            twLabel.text =  led_tw_caption
                                        }

                                        property var led_tw_state: platformInterface.led_tw_state.state
                                        onLed_tw_stateChanged: {
                                            if(led_tw_state === "enabled") {
                                                twLabel.enabled = true
                                                twLabel.opacity = 1.0
                                            }
                                            else if (led_tw_state === "disabled") {
                                                twLabel.enabled = false
                                                twLabel.opacity = 1.0
                                            }
                                            else  {
                                                twLabel.enabled = false
                                                twLabel.opacity = 0.5
                                            }
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
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: tsd
                                        width: 30


                                        property var led_tsd: platformInterface.led_tsd
                                        onLed_tsdChanged: {
                                            tsdLabel.text =  led_tsd_caption
                                            if(led_tsd.state === "enabled") {
                                                tsdLabel.enabled = true
                                                tsdLabel.opacity = 1.0
                                            }
                                            else if (led_tsd.state === "disabled") {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 1.0
                                            }
                                            else  {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 0.5
                                            }
                                            if(led_tsd.value === false)
                                                tsd.status = SGStatusLight.Off

                                            else  tsd.status = SGStatusLight.Red
                                        }

                                        property var led_tsd_caption: platformInterface.led_tsd_caption.caption
                                        onLed_tsd_captionChanged: {
                                            tsdLabel.text =  led_tsd_caption
                                        }

                                        property var led_tsd_state: platformInterface.led_tsd_state.state
                                        onLed_tsd_stateChanged: {
                                            if(led_tsd_state === "enabled") {
                                                tsdLabel.enabled = true
                                                tsdLabel.opacity = 1.0
                                            }
                                            else if (led_tsd_state === "disabled") {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 1.0
                                            }
                                            else  {
                                                tsdLabel.enabled = false
                                                tsdLabel.opacity = 0.5
                                            }
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
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: diagerr
                                        width: 30

                                        property var led_diagerr: platformInterface.led_diagerr
                                        onLed_diagerrChanged: {
                                            diagerrLabel.text =  led_diagerr.caption

                                            if(led_diagerr.state === "enabled") {
                                                diagerrLabel.enabled = true
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else if (led_diagerr.state === "disabled") {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 0.5
                                            }

                                            if(led_diagerr.value === false)
                                                diagerr.status = SGStatusLight.Off

                                            else  diagerr.status = SGStatusLight.Red

                                        }

                                        property var led_diagerr_caption: platformInterface.led_diagerr_caption.caption
                                        onLed_diagerr_captionChanged: {
                                            diagerrLabel.text =  led_diagerr_caption
                                        }

                                        property var led_diagerr_state: platformInterface.led_tsd_state.state
                                        onLed_diagerr_stateChanged: {
                                            if(led_diagerr_state === "enabled") {
                                                diagerrLabel.enabled = true
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else if (led_diagerr_state === "disabled") {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 1.0
                                            }
                                            else  {
                                                diagerrLabel.enabled = false
                                                diagerrLabel.opacity = 0.5
                                            }
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
                                    fontSizeMultiplier: ratioCalc
                                    anchors.centerIn: parent

                                    SGStatusLight {
                                        id: ol
                                        width: 30

                                        property var led_ol: platformInterface.led_ol
                                        onLed_olChanged: {
                                            olLabel.text =  led_ol.caption
                                            if(led_ol.state === "enabled") {
                                                olLabel.enabled = true
                                                olLabel.opacity = 1.0
                                            }
                                            else if (led_ol.state === "disabled") {
                                                olLabel.enabled = false
                                                olLabel.opacity = 1.0
                                            }
                                            else  {
                                                olLabel.enabled = false
                                                olLabel.opacity = 0.5
                                            }
                                            if(led_ol.value === false)
                                                ol.status = SGStatusLight.Off

                                            else ol.status = SGStatusLight.Red
                                        }

                                        property var led_ol_caption: platformInterface.led_ol_caption.caption
                                        onLed_ol_captionChanged: {
                                            olLabel.text =  led_ol_caption
                                        }

                                        property var led_ol_state: platformInterface.led_ol_state.state
                                        onLed_ol_stateChanged: {
                                            if(led_ol_state === "enabled") {
                                                olLabel.enabled = true
                                                olLabel.opacity = 1.0
                                            }
                                            else if (led_ol_state === "disabled") {
                                                olLabel.enabled = false
                                                olLabel.opacity = 1.0
                                            }
                                            else  {
                                                olLabel.enabled = false
                                                olLabel.opacity = 0.5
                                            }
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



