import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id:setupcontrol
    width: parent.width
    height: parent.height

    Component.onCompleted: {

        platformInterface.system_init.update()

        sgSwitch1.checked = false
        sgSwitch2.enabled = false
        sgSwitch3.enabled = false
        sgSwitch4.enabled = false
        sgSwitch5.enabled = false
        sgSwitch6.enabled = false
        sgSwitch7.enabled = false

        sgSlider1.enabled = false
        sgSlider1.value = 50;
        sgSlider2.enabled = false
        sgSlider2.value = 0.3
        sgSlider3.enabled = false
        sgSlider3.value = 0.3
        sgSlider4.enabled = false
        sgSlider4.value = 0.3
        sgSlider5.enabled = false
        sgSlider5.value = 0.3
        sgSlider6.enabled = false
        sgSlider6.value = 0.3
        sgSlider7.enabled = false
        sgSlider7.value = 0.3
        sgSlider8.enabled = false
        sgSlider9.enabled = false
        sgSlider10.enabled = false

    }

    property bool check_boost_enable_state: platformInterface.boost_enable_state
    onCheck_boost_enable_stateChanged: {
        if(check_boost_enable_state === true){
            sgSwitch1.checked = true
            sgSwitch2.enabled = true
            sgSwitch3.enabled = true
            sgSwitch4.enabled = true
            sgSwitch5.enabled = true
            sgSwitch6.enabled = true
            sgSwitch7.enabled = true

            sgSlider1.enabled = true

            platformInterface.set_boost_enable.update(1)

        }
        else if(check_boost_enable_state === false){
            sgSwitch1.checked = false
            sgSwitch2.enabled = false
            sgSwitch3.enabled = false
            sgSwitch4.enabled = false
            sgSwitch5.enabled = false
            sgSwitch6.enabled = false
            sgSwitch7.enabled = false

            sgSlider1.enabled = false
            sgSlider2.enabled = false
            sgSlider3.enabled = false
            sgSlider4.enabled = false
            sgSlider5.enabled = false
            sgSlider6.enabled = false
            sgSlider7.enabled = false
            sgSlider8.enabled = false
            sgSlider9.enabled = false
            sgSlider10.enabled = false

            platformInterface.buck1_enable_state = false
            platformInterface.buck2_enable_state = false
            platformInterface.buck3_enable_state = false
            platformInterface.buck4_enable_state = false
            platformInterface.buck5_enable_state = false
            platformInterface.buck6_enable_state = false

            platformInterface.buck1_led_state = false
            platformInterface.buck2_led_state = false
            platformInterface.buck3_led_state = false
            platformInterface.buck4_led_state = false
            platformInterface.buck5_led_state = false
            platformInterface.buck6_led_state = false

            platformInterface.set_boost_enable.update(0)

            platformInterface.auto_addr_enable_state = false

        }
    }

    property bool check_boost_led_state: platformInterface.boost_led_state
    onCheck_boost_led_stateChanged: {
        if(check_boost_led_state === true){
            sgStatusLight1.status = "green"
        }
        else sgStatusLight1.status = "off"
    }

    property bool check_buck1_enable_state: platformInterface.buck1_enable_state
    onCheck_buck1_enable_stateChanged: {
        if (check_buck1_enable_state === true){
            sgSwitch2.checked = true
            sgSlider2.enabled = true
        }
        else if (check_buck1_enable_state === false){
            sgSwitch2.checked = false
            sgSlider2.enabled = false
        }
    }

    property bool check_buck1_led_state: platformInterface.buck1_led_state
    onCheck_buck1_led_stateChanged: {
        if(check_buck1_led_state === true){
            sgStatusLight2.status = "green"
        } else if (check_buck1_led_state === false) {
            sgStatusLight2.status = "off"
        }
    }

    property bool check_buck2_enable_state: platformInterface.buck2_enable_state
    onCheck_buck2_enable_stateChanged: {
        if (check_buck2_enable_state === true){
            sgSwitch3.checked = true
            sgSlider3.enabled = true
        }
        else if (check_buck2_enable_state === false){
            sgSwitch3.checked = false
            sgSlider3.enabled = false
        }
    }

    property bool check_buck2_led_state: platformInterface.buck2_led_state
    onCheck_buck2_led_stateChanged: {
        if(check_buck2_led_state === true){
            sgStatusLight3.status = "green"
        }
        else if(check_buck2_led_state === false){
            sgStatusLight3.status = "off"
        }
    }

    property bool check_buck3_enable_state: platformInterface.buck3_enable_state
    onCheck_buck3_enable_stateChanged: {
        if (check_buck3_enable_state === true){
            sgSwitch4.checked = true
            sgSlider4.enabled = true
        }
        else if (check_buck3_enable_state === false){
            sgSwitch4.checked = false
            sgSlider4.enabled = false
        }
    }

    property bool check_buck3_led_state: platformInterface.buck3_led_state
    onCheck_buck3_led_stateChanged: {
        if(check_buck3_led_state === true){
            sgStatusLight4.status = "green"
        }
        else if(check_buck3_led_state === false){
            sgStatusLight4.status = "off"
        }
    }

    property bool check_buck4_enable_state: platformInterface.buck4_enable_state
    onCheck_buck4_enable_stateChanged: {
        if (check_buck4_enable_state === true){
            sgSwitch5.checked = true
            sgSlider5.enabled = true
            sgSlider8.enabled = true
        }
        else if (check_buck4_enable_state === false){
            sgSwitch5.checked = false
            sgSlider5.enabled = false
            sgSlider8.enabled = false
        }
    }

    property bool check_buck4_led_state: platformInterface.buck4_led_state
    onCheck_buck4_led_stateChanged: {
        if(check_buck4_led_state === true){
            sgStatusLight5.status = "green"
        }
        else if(check_buck4_led_state === false){
            sgStatusLight5.status = "off"
        }
    }

    property bool check_buck5_enable_state: platformInterface.buck5_enable_state
    onCheck_buck5_enable_stateChanged: {
        if (check_buck5_enable_state === true){
            sgSwitch6.checked = true
            sgSlider6.enabled = true
            sgSlider9.enabled = true
        }
        else if (check_buck5_enable_state === false){
            sgSwitch6.checked = false
            sgSlider6.enabled = false
            sgSlider9.enabled = false
        }
    }

    property bool check_buck5_led_state: platformInterface.buck5_led_state
    onCheck_buck5_led_stateChanged: {
        if(check_buck5_led_state === true){
            sgStatusLight6.status = "green"
        }
        else if(check_buck5_led_state === false){
            sgStatusLight6.status = "off"
        }
    }

    property bool check_buck6_enable_state: platformInterface.buck6_enable_state
    onCheck_buck6_enable_stateChanged: {
        if (check_buck6_enable_state === true){
            sgSwitch7.checked = true
            sgSlider7.enabled = true
            sgSlider10.enabled = true
        }
        else if (check_buck6_enable_state === false){
            sgSwitch7.checked = false
            sgSlider7.enabled = false
            sgSlider10.enabled = false
        }
    }

    property bool check_buck6_led_state: platformInterface.buck6_led_state
    onCheck_buck6_led_stateChanged: {
        if(check_buck6_led_state === true){
            sgStatusLight7.status = "green"
        }
        else if(check_buck6_led_state === false){
            sgStatusLight7.status = "off"
        }
    }


    property var boost_status: platformInterface.boost_state.state
    onBoost_statusChanged: {
        if(boost_status === "boost_on") {
            sgStatusLight1.status = "green"
        }
        else if(boost_status === "boost_off") {
            sgStatusLight1.status = "off"
        }
    }

    property var buck_status: platformInterface.buck_state.state
    onBuck_statusChanged: {
        if(buck_status === "buck1_on") {
            platformInterface.buck1_led_state = true
        }
        else if(buck_status === "buck1_off"){
            platformInterface.buck1_led_state = false
        }

        if(buck_status === "buck2_on") {
            platformInterface.buck2_led_state = true
        }
        else if(buck_status === "buck2_off"){
            platformInterface.buck2_led_state = false
        }

        if(buck_status === "buck3_on") {
            platformInterface.buck3_led_state = true
        }
        else if(buck_status === "buck3_off"){
            platformInterface.buck3_led_state = false
        }

        if(buck_status === "buck4_on") {
            platformInterface.buck4_led_state = true
        }
        else if(buck_status === "buck4_off"){
            platformInterface.buck4_led_state = false
        }

        if(buck_status === "buck5_on") {
            platformInterface.buck5_led_state = true
        }
        else if(buck_status === "buck5_off"){
            platformInterface.buck5_led_state = false
        }

        if(buck_status === "buck6_on") {
            platformInterface.buck6_led_state = true
        }
        else if(buck_status === "buck6_off"){
            platformInterface.buck6_led_state = false
        }
    }

    RowLayout{
        anchors.fill: parent

        Rectangle{
            id: rec1
            Layout.preferredWidth:parent.width/3
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 50
            color:"transparent"

            ColumnLayout{
                spacing: 10
                anchors.fill:parent
                SGSlideCustomize{
                    id: sgSlider1
                    label: "<b>Boost Voltage:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    width: parent.width/1.5
                    Layout.alignment: Qt.AlignCenter
                    stepSize: 0.1
                    value: 50
                    from: 20
                    to: 60
                    startLabel: "20"
                    endLabel: "60"
                    showToolTip: true
                    toolTipDecimalPlaces: 1
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.boost_v_control.update(value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider2
                    label: "<b>Buck1 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    width: parent.width/1.5
                    Layout.alignment: Qt.AlignCenter
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(1,value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider3
                    label: "<b>Buck2 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    width: parent.width/1.5
                    Layout.alignment: Qt.AlignCenter
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(2,value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider4
                    label: "<b>Buck3 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    width: parent.width/1.5
                    Layout.alignment: Qt.AlignCenter
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(3,value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider5
                    label: "<b>Buck4 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    width: parent.width/1.5
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(4,value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider6
                    label: "<b>Buck5 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    width: parent.width/1.5
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(5,value)
                    }
                }

                SGSlideCustomize{
                    id:sgSlider7
                    label: "<b>Buck6 Peak Current:</b>"
                    textColor: "black"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter

                    width: parent.width/1.5
                    stepSize: 0.01
                    value: 0.3
                    from: 0.3
                    to: 1.5
                    startLabel: "0.3"
                    endLabel: "1.5"
                    showToolTip: true
                    toolTipDecimalPlaces: 2
                    grooveColor: "#ddd"
                    grooveFillColor: "lightgreen"
                    live: false
                    labelTopAligned: false
                    inputBox: true

                    onSlider_valueChanged: {
                        platformInterface.buck_i_control.update(6,value)
                    }
                }
            }
        }

        Rectangle{
            id: rec2
            Layout.preferredWidth:parent.width/6
            Layout.preferredHeight: parent.height-50
            Layout.leftMargin: 50
            color:"transparent"

            ColumnLayout{
                anchors.fill: parent

                SGSwitch{
                    id: sgSwitch1

                    label: "<b>Boost Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked){
                            platformInterface.boost_enable_state = true
                        }
                        else  {
                            platformInterface.boost_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch2
                    label: "<b>Buck1 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked){
                            platformInterface.set_buck_enable.update(1,1)
                            platformInterface.buck1_enable_state = true
                        } else {
                            platformInterface.set_buck_enable.update(1,0)
                            platformInterface.buck1_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch3
                    label: "<b>Buck2 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked){
                            platformInterface.set_buck_enable.update(2,1)
                            platformInterface.buck2_enable_state = true
                        }else {
                            platformInterface.set_buck_enable.update(2,0)
                            platformInterface.buck2_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch4
                    label: "<b>Buck3 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked){
                            platformInterface.set_buck_enable.update(3,1)
                            platformInterface.buck3_enable_state = true
                        }else {
                            platformInterface.set_buck_enable.update(3,0)
                            platformInterface.buck3_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch5
                    label: "<b>Buck4 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked){
                            platformInterface.set_buck_enable.update(4,1)
                            platformInterface.buck4_enable_state = true
                        }else {
                            platformInterface.set_buck_enable.update(4,0)
                            platformInterface.buck4_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch6
                    label: "<b>Buck5 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked) {
                            platformInterface.set_buck_enable.update(5,1)
                            platformInterface.buck5_enable_state = true
                        }else {
                            platformInterface.set_buck_enable.update(5,0)
                            platformInterface.buck5_enable_state = false
                        }
                    }
                }

                SGSwitch{
                    id: sgSwitch7
                    label: "<b>Buck6 Enable:</b>"
                    labelLeft: false
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignCenter
                    switchWidth: parent.width/3
                    switchHeight: parent.height/25
                    textColor: "black"
                    handleColor: "white"
                    grooveColor: "#ccc"
                    grooveFillColor: "#0cf"
                    onToggled: {
                        if(checked) {
                            platformInterface.set_buck_enable.update(6,1)
                            platformInterface.buck6_enable_state = true
                        }else {
                            platformInterface.set_buck_enable.update(6,0)
                            platformInterface.buck6_enable_state = false
                        }
                    }
                }
            }
        }

        Rectangle{
            id: rec3
            Layout.preferredWidth:parent.width/3
            Layout.preferredHeight: parent.height-40
            color: "transparent"
            Layout.rightMargin: 50

            ColumnLayout{
                anchors.fill: parent

                SGStatusLight{
                    id: sgStatusLight1
                    label: "<b>Boost Status:</b>"
                    labelLeft: false
                    lightSize: 50
                    textColor: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter
                    status: "off"

                }

                SGStatusLight{
                    id: sgStatusLight2
                    label: "<b>Buck1 Status:</b>"
                    labelLeft: false
                    lightSize: 50
                    textColor: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight3
                    label: "<b>Buck2 Status:</b>"
                    labelLeft: false
                    lightSize: 50
                    textColor: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                SGStatusLight{
                    id: sgStatusLight4
                    label: "<b>Buck3 Status:</b>"
                    labelLeft: false
                    lightSize: 50
                    textColor: "black"
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignCenter

                }

                RowLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sgStatusLight5
                        label: "<b>Buck4 Status:</b>"
                        labelLeft: false
                        lightSize: 50
                        textColor: "black"
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 20

                    }
                    SGSlideCustomize{
                        id:sgSlider8
                        label: "<b>Buck4 Dimming:</b>"
                        textColor: "black"
                        labelLeft: false
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width/1.5
                        stepSize: 1.0
                        value: 50
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100"
                        showToolTip: false
                        toolTipDecimalPlaces: 0
                        grooveColor: "#ddd"
                        grooveFillColor: "lightgreen"
                        live: false
                        labelTopAligned: false
                        inputBox: true

                        onSlider_valueChanged: {
                            platformInterface.dim_control.update(4,value)
                        }
                    }
                }

                RowLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sgStatusLight6
                        label: "<b>Buck5 Status:</b>"
                        labelLeft: false
                        lightSize: 50
                        textColor: "black"
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 20

                    }
                    SGSlideCustomize{
                        id:sgSlider9
                        label: "<b>Buck5 Dimming:</b>"
                        textColor: "black"
                        labelLeft: false
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width/1.5
                        stepSize: 1.0
                        value: 50
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100"
                        showToolTip: false
                        toolTipDecimalPlaces: 0
                        grooveColor: "#ddd"
                        grooveFillColor: "lightgreen"
                        live: false
                        labelTopAligned: false
                        inputBox: true

                        onSlider_valueChanged: {
                            platformInterface.dim_control.update(5,value)
                        }
                    }
                }

                RowLayout{
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    SGStatusLight{
                        id: sgStatusLight7
                        label: "<b>Buck6 Status:</b>"
                        labelLeft: false
                        lightSize: 50
                        textColor: "black"
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 20

                    }
                    SGSlideCustomize{
                        id:sgSlider10
                        label: "<b>Buck6 Dimming:</b>"
                        textColor: "black"
                        labelLeft: false
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        width: parent.width/1.5
                        stepSize: 1.0
                        value: 50
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100"
                        showToolTip: false
                        toolTipDecimalPlaces: 0
                        grooveColor: "#ddd"
                        grooveFillColor: "lightgreen"
                        live: false
                        labelTopAligned: false
                        inputBox: true

                        onSlider_valueChanged: {
                            platformInterface.dim_control.update(6,value)
                        }
                    }
                }
            }
        }

        Component.onCompleted:  {
            Help.registerTarget(sgSwitch1, "Boost Enable control switch, All sliders and siwtches will be able to control after Boost Enable switch is ON, if OFF all switched and sliders will be disabled.", 0, "Help4")
            Help.registerTarget(sgSlider1, "Boost set point voltage select.", 2, "Help4")
            Help.registerTarget(sgStatusLight1, "LED indicator for Boost Enable, LED green if Boost Enable is ON.", 1, "Help4")
            Help.registerTarget(sgSwitch2, "Buck1 to 6 Enable control swith.", 3, "Help4")
            Help.registerTarget(sgSlider2, "Buck1 o 6 current setting", 5, "Help4")
            Help.registerTarget(sgStatusLight2, "LED indicator for Buck Enable, LED green if Buck1 to 6 Enable switch is ON", 4, "Help4")
            Help.registerTarget(sgSlider8, "Buck4 to 6 dimming control, 0 - 100 [%], slider is avairable when Buck Enable switch is ON", 6, "Help4")
        }
    }
}



