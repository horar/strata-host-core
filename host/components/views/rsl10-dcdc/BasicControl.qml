import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 0.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.3
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/sgwidgets"
import "qrc:/images"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property bool state: false
    property string warningVin: multiplePlatform.warningHVVinLable
    property string vinlable: ""
    property string labelTest: ""
    property real ratioCalc: root.width / 1200

    // property that reads the initial notification
    property string read_enable_state: platformInterface.initial_status.enable_status
    onRead_enable_stateChanged: {
        if(read_enable_state === "on") {
            platformInterface.enabled = true
            platformInterface.pause_periodic = false
        }
        else  {
            platformInterface.enabled = false
            platformInterface.pause_periodic = true
        }
    }

    property string read_dio14_state: platformInterface.initial_status.dio14_status
    onRead_dio14_stateChanged: {
        if(read_dio14_state === "on") {
            dio14Light.status = "green"        }
        else  {
            dio14Light.status = "red"
        }
    }

    property string read_vin_mon: {platformInterface.status_voltage_current.vin}
    onRead_vin_monChanged: {

        platformInterface.enabled = true

        if(multiplePlatform.minVin > ((platformInterface.status_voltage_current.vin)/1000)) {
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN NOT Ready < "+ multiplePlatform.minVin +"V"

            dio12Switch.enabled  = true
            dio12Switch.opacity = 1.0
            dio13Switch.enabled  = true
            dio13Switch.opacity = 0.2
            dio04Switch.enabled  = true
            dio04Switch.opacity = 0.2
            dio14Light.enabled  = true
            dio14Light.opacity = 1.0
        }

        else if(multiplePlatform.nominalVin < ((platformInterface.status_voltage_current.vin)/1000)) {
            dio12Switch.checked = false
            dio13Switch.checked = false
            dio04Switch.checked = false
            ledLight.status = "red"
            vinlable = "under"
            ledLight.label = "VIN NOT Ready > "+ multiplePlatform.nominalVin +"V"
            dio12Switch.enabled  = false
            dio12Switch.opacity = 0.2
            dio13Switch.enabled  = false
            dio13Switch.opacity = 0.2
            dio04Switch.enabled  = false
            dio04Switch.opacity = 0.2
            dio14Light.enabled  = true
            dio14Light.opacity = 1.0
            platformInterface.set_dio12.update("off")
            platformInterface.set_dio13.update("off")
            platformInterface.set_dio04.update("off")
        }

        else {
            ledLight.status = "green"
            vinlable = "over"
            ledLight.label = "VIN Ready"

            dio12Switch.enabled  = true
            dio12Switch.opacity = 1.0

            if(multiplePlatform.dio13 === false) {
                dio13Switch.enabled  = true
                dio13Switch.opacity = 0.2
            }
            else if(multiplePlatform.dio04 === false && multiplePlatform.jumperDIO04 === false) {
                dio04Switch.enabled  = true
                dio04Switch.opacity = 0.2
            }
            else if(multiplePlatform.dio14 === false) {
                dio14Light.enabled  = true
                dio14Light.opacity = 0.2
            }
            else  {
                dio13Switch.enabled  = true
                dio13Switch.opacity = 1.0
                dio04Switch.enabled  = true
                dio04Switch.opacity = 1.0
                dio14Light.enabled  = true
                dio14Light.opacity = 1.0
            }
        }
    }

    Component.onCompleted:  {
        multiplePlatform.check_class_id()
        //platformInterface.read_initial_status.update()
        Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0, "basicHelp")
        Help.registerTarget(basicImage, "The center image shows the board configuration.", 4, "basicHelp")
        Help.registerTarget(dimmensionalModeSpace, "Dimmensional space mode for the center image.", 5, "basicHelp")
        Help.registerTarget(ledLight, "The LED will light up green when input voltage is ready and lower than" + " "+ multiplePlatform.nominalVin +"V.It will light up red when greater than "+ " "+ multiplePlatform.nominalVin + "V to warn the user that input voltage is too high.", 1, "basicHelp")
        Help.registerTarget(inputVoltage,"Input voltage is shown here in Volts.", 2 , "basicHelp")
        Help.registerTarget(inputCurrent,"Input current is shown here in milliamps.", 3 , "basicHelp")
        Help.registerTarget(outputCurrent,"Output current is shown here in milliamps.", 11, "basicHelp")
        Help.registerTarget(outputVoltage,"Output voltage is shown here in Volts.", 10, "basicHelp")
        Help.registerTarget(dio12Switch, "This switch enables or disables DIO12.", 6, "basicHelp")
        Help.registerTarget(dio13Switch, "This switch enables or disables DIO13.", 7, "basicHelp")
        Help.registerTarget(dio04Switch, "This switch enables or disables DIO04.", 8, "basicHelp")
        Help.registerTarget(dio14Light, "The LED will light up green when input DIO14 will be high.", 9, "basicHelp")

    }

    FontLoader {
        id: icons
        source: "sgwidgets/fonts/sgicons.ttf"
    }

    Rectangle{
        anchors.fill: parent
        width : parent.width
        height: parent.height


        Rectangle {
            id: pageLable
            width: parent.width/2
            height: parent.height/ 12
            anchors {
                top: parent.top
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            Text {
                id: pageText
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                }
                text:  multiplePlatform.partNumber
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "green"
            }
            Text {
                id: pageText2
                anchors {
                    top: pageText.bottom
                    horizontalCenter: parent.horizontalCenter
                }
                text: multiplePlatform.title
                font.pixelSize: (parent.width + parent.height)/ 15
                color: "blue"

            }
        }
        Rectangle{
            width: parent.width
            height: parent.height - parent.height/12
            anchors{
                top: pageLable.bottom
                topMargin: 100
                left: parent.left
                leftMargin: 20
                right: parent.right
                rightMargin: 20

            }

            Rectangle {
                id:left
                width: parent.width/5
                height: parent.height - parent.height/3
                anchors {
                    top:parent.top
                    topMargin: parent.height/12
                    left: parent.left
                    leftMargin: 0
                }
                color: "transparent"
                border.color: "transparent"
                border.width: 5
                radius: 10

                Rectangle {
                    id: textContainer2
                    width: parent.width/3
                    height: parent.height/10

                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: containerLabel2
                        text: "Input"
                        anchors{
                            fill: parent
                            centerIn: parent
                        }
                        font.pixelSize: height/1.5
                        font.bold: true
                        //fontSizeMode: Text.Fit
                    }

                }
                Rectangle {
                    id: line
                    height: 2
                    width: parent.width

                    anchors {
                        top: textContainer2.bottom
                        topMargin: 2
                        left: parent.left
                        leftMargin: 5
                    }
                    border.color: "grey"
                    radius: 2
                }
                SGStatusLight {
                    id: ledLight
                    // Optional Configuration:
                    label: "VIN Ready < "+ multiplePlatform.nominalVin +"V"
                    anchors {
                        top : line.bottom
                        topMargin : 40
                        horizontalCenter: parent.horizontalLeft
                    }
                    width: parent.width
                    height: parent.height/10
                    lightSize: (parent.width + parent.height)/23
                    fontSize:  (parent.width + parent.height)/40

                    property string vinMonitor: {platformInterface.status_voltage_current.vin}
                    onVinMonitorChanged:  {
                        if(multiplePlatform.minVin > ((platformInterface.status_voltage_current.vin)/1000)) {
                            ledLight.status = "red"
                            vinlable = "under"
                            ledLight.label = "VIN NOT Ready < "+ multiplePlatform.minVin +"V"
                        }
                        else if(multiplePlatform.nominalVin < ((platformInterface.status_voltage_current.vin)/1000)) {
                            ledLight.status = "red"
                            vinlable = "under"
                            ledLight.label = "VIN NOT Ready > "+ multiplePlatform.nominalVin +"V"
                        }
                        else {
                            ledLight.status = "green"
                            vinlable = "over"
                            ledLight.label = "VIN Ready"
                        }
                    }
                }

                Rectangle {
                    id: warningBox2
                    color: "red"
                    anchors {
                        top: ledLight.bottom
                        topMargin: 20
                        horizontalCenter: parent.horizontalLeft
                        horizontalCenterOffset: parent.width/20
                    }
                    width: parent.width
                    height: parent.height/10

                    Text {
                        id: warningText2
                        anchors {
                            centerIn: warningBox2
                        }
                        text: "<b>Max. input voltage "+ multiplePlatform.nominalVin +"V</b>"
                        font.pixelSize: ratioCalc * 12
                        color: "white"
                    }

                    Text {
                        id: warningIconleft
                        anchors {
                            right: warningText2.left
                            verticalCenter: warningText2.verticalCenter
                            rightMargin: 5
                        }
                        text: "\ue80e"
                        font.family: icons.name
                        font.pixelSize: (parent.width + parent.height)/19
                        color: "white"
                    }

                    Text {
                        id: warningIconright
                        anchors {
                            left: warningText2.right
                            verticalCenter: warningText2.verticalCenter
                            leftMargin: 5
                        }
                        text: "\ue80e"
                        font.family: icons.name
                        font.pixelSize: (parent.width + parent.height)/19
                        color: "white"
                    }
                }

                SGLabelledInfoBox {
                    id: inputVoltage
                    label: ""
                    info: {
                        if(multiplePlatform.showDecimal === true) {((platformInterface.status_voltage_current.vin)/1000).toFixed(3)}
                        else {((platformInterface.status_voltage_current.vin)/1000).toFixed(0)}
                    }

                    infoBoxColor: if (multiplePlatform.nominalVin < ((platformInterface.status_voltage_current.vin)/1000)) {"red"}
                                  else{"lightblue"}
                    infoBoxBorderColor: "grey"
                    infoBoxBorderWidth: 3

                    unit: "V"
                    infoBoxWidth: parent.width/1.5
                    infoBoxHeight : parent.height/12
                    fontSize :  (parent.width + parent.height)/37
                    unitSize: (parent.width + parent.height)/35
                    anchors {
                        top : warningBox2.bottom
                        topMargin : parent.height/4.5
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset:  (width - inputCurrent.width)/2
                    }
                }

                SGLabelledInfoBox {
                    id: inputCurrent
                    label: ""
                    info: {
                        if(multiplePlatform.current === "A") {(((platformInterface.status_voltage_current.iin))/1000).toFixed(3)}
                        else {((platformInterface.status_voltage_current.iin)).toFixed(0)}
                    }

                    infoBoxColor: "lightgreen"
                    infoBoxBorderColor: "grey"
                    infoBoxBorderWidth: 3

                    unit: if(multiplePlatform.current === "mA") {"mA"}
                          else{"A"}
                    infoBoxWidth: parent.width/1.5
                    infoBoxHeight :  parent.height/12
                    fontSize :   (parent.width + parent.height)/37
                    unitSize: (parent.width + parent.height)/35
                    anchors {
                        top : inputVoltage.bottom
                        topMargin : 20
                        horizontalCenter: parent.horizontalCenter
                    }
                }


            }

            Rectangle {
                id: gauge
                width: (3*parent.width/5)
                height: parent.height - parent.height/3
                anchors{
                    left: left.right
                    top:parent.top
                    topMargin: parent.height/20
                }

                Image {
                    id:basicImage
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width
                    source:{
                        if(multiplePlatform.eeprom_ID === "15411d3f-829f-4b65-b607-13e8dec840aa" && platformInterface.dimmensionalMode === true) {"images/ncv81599D_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "1ae9e1e7-a268-4302-8c3a-280f0aa095a5" && platformInterface.dimmensionalMode === true) {"images/ncv330_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "3ef8bbc6-92ff-4c98-b9ae-ca7e7c47d180" && platformInterface.dimmensionalMode === true) {"images/ncv6357_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "3ea08e05-0bcd-4a4a-86ec-79a1ca9750cd" && platformInterface.dimmensionalMode === true) {"images/ncv91300_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "abd65a0b-3229-44a4-a97c-38ea3c24f990" && platformInterface.dimmensionalMode === true) {"images/ncv890430_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "266f22e5-dc05-4819-b565-e5fb8035984e" && platformInterface.dimmensionalMode === true) {"images/ncv48920_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "d4937f24-219a-4648-a711-2f6e902b6f1c" && platformInterface.dimmensionalMode === true) {"images/quarter_brick_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "b519cdcb-5068-4483-b88e-155813fae915" && platformInterface.dimmensionalMode === true) {"images/ncv816x_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "26ebc2ba-9bab-4bdd-97b6-09b5b8cbdf9e" && platformInterface.dimmensionalMode === true) {"images/ncv6323_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "cce0f32e-ee1e-44aa-81a3-0801a71048ce" && platformInterface.dimmensionalMode === true) {"images/ncv6922_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "2286e1e0-4035-46b9-b197-4d729653c101" && platformInterface.dimmensionalMode === true) {"images/ncv896530_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "264" && platformInterface.dimmensionalMode === true) {"images/LV_DCDC_Ecosystem_3D.gif"}
                        else if(multiplePlatform.eeprom_ID === "15411d3f-829f-4b65-b607-13e8dec840aa" && platformInterface.dimmensionalMode === false) {"images/ncv81599D_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "1ae9e1e7-a268-4302-8c3a-280f0aa095a5" && platformInterface.dimmensionalMode === false) {"images/ncv330_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "3ef8bbc6-92ff-4c98-b9ae-ca7e7c47d180" && platformInterface.dimmensionalMode === false) {"images/ncv6357_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "3ea08e05-0bcd-4a4a-86ec-79a1ca9750cd" && platformInterface.dimmensionalMode === false) {"images/ncv91300_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "abd65a0b-3229-44a4-a97c-38ea3c24f990" && platformInterface.dimmensionalMode === false) {"images/ncv890430_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "266f22e5-dc05-4819-b565-e5fb8035984e" && platformInterface.dimmensionalMode === false) {"images/ncv48920_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "d4937f24-219a-4648-a711-2f6e902b6f1c" && platformInterface.dimmensionalMode === false) {"images/quarter_brick_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "b519cdcb-5068-4483-b88e-155813fae915" && platformInterface.dimmensionalMode === false) {"images/ncv816x_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "26ebc2ba-9bab-4bdd-97b6-09b5b8cbdf9e" && platformInterface.dimmensionalMode === false) {"images/ncv6323_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "cce0f32e-ee1e-44aa-81a3-0801a71048ce" && platformInterface.dimmensionalMode === false) {"images/ncv6922_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "2286e1e0-4035-46b9-b197-4d729653c101" && platformInterface.dimmensionalMode === false) {"images/ncv896530_2D.gif"}
                        else if(multiplePlatform.eeprom_ID === "264" && platformInterface.dimmensionalMode === false) {"images/LV_DCDC_Ecosystem_2D.gif"}
                    }
                    width: parent.width - parent.width/20
                    height: parent.height + (parent.height/6)
                    anchors.centerIn: parent
                    //fillMode: Image.PreserveAspectFit
                    mipmap:true
                    opacity:1
                }

                Image {
                    id:basicImageLed
                    Layout.preferredHeight: parent.height
                    Layout.preferredWidth: parent.width
                    source: "images/led_3d.gif"
                    width: parent.width - parent.width/20
                    height: parent.height - 20
                    anchors.centerIn: parent
                    //fillMode: Image.PreserveAspectFit
                    mipmap:true
                    visible: platformInterface.pause_periodic === false && platformInterface.dimmensionalMode === true ? true : false

                }
                SGRadioButtonContainer {
                    id: dimmensionalModeSpace
                    anchors {
                        top: basicImageLed.bottom
                        topMargin: 60

                    }
                    labelLeft: false
                    exclusive: true

                    radioGroup: GridLayout {
                        columnSpacing: 10
                        rowSpacing: 10
                        // Optional properties to access specific buttons cleanly from outside
                        property alias twoDimmensional : twoDimmensional
                        property alias threeDimmensional: threeDimmensional

                        SGRadioButton {
                            id: threeDimmensional
                            text: "3D"
                            checked: platformInterface.dimmensionalMode
                            onCheckedChanged: {
                                if (checked) {
                                    console.log("3D")
                                    platformInterface.dimmensionalMode = true
                                }
                                else {
                                    console.log("Top")
                                    platformInterface.dimmensionalMode = false
                                }
                            }
                        }

                        SGRadioButton {
                            id: twoDimmensional
                            text: "Top"
                            checked : !threeDimmensional.checked
                        }
                    }
                }
            }

            Rectangle {
                id:right
                width: parent.width/5
                height: parent.height - parent.height/3
                anchors {
                    top:parent.top
                    topMargin: parent.height/12
                    left: gauge.right
                    right: parent.right
                    rightMargin: 0
                }
                color: "transparent"
                border.color: "transparent"
                border.width: 5
                radius: 10

                Rectangle {
                    id: textContainer
                    width: parent.width/3
                    height: parent.height/10
                    anchors {
                        top: parent.top
                        topMargin: 20
                        horizontalCenter: parent.horizontalCenter
                    }
                    Text {
                        id: containerLabel
                        text: "Output"
                        anchors{
                            fill: parent
                            centerIn: parent
                        }
                        font.pixelSize: height/1.5
                        font.bold: true
                        //fontSizeMode: Text.Fit
                    }
                }

                Rectangle {
                    id: line2
                    height: 2
                    width: parent.width - 9

                    anchors {
                        top: textContainer.bottom
                        topMargin: 2
                        left: parent.left
                        leftMargin: 5
                    }
                    border.color: "grey"
                    radius: 2
                }

                SGSwitch {
                    id: dio12Switch
                    anchors {
                        top: line2.bottom
                        topMargin :  parent.height/15
                        horizontalCenter: parent.horizontalLeft
                    }
                    label : if(multiplePlatform.dio12 === true && multiplePlatform.jumperDIO12 === false) {"EN"}
                            else if(multiplePlatform.dio12 === true && multiplePlatform.jumperDIO12 === true) {"EN/IO2"}
                            else if(multiplePlatform.dio12 === false && multiplePlatform.jumperDIO12 === true) {"EN1/EN3"}
                            else if(multiplePlatform.dio12 === false && multiplePlatform.jumperDIO12 === false) {"EN1"}
                    switchWidth: parent.width/4            // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: parent.height/15              // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "green"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/37
                    checked: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {dio12Switch.checked}
                             else{platformInterface.set_dio12.update("off")}
                    onToggled: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {
                                   platformInterface.dio12_enabled = checked
                                   if(checked){
                                       platformInterface.set_dio12.update("on")
                                   }
                                   else{
                                       platformInterface.set_dio12.update("off")
                                   }
                               }
                               else{platformInterface.set_dio12.update("off")}
                }

                SGToolTipPopup {
                    id: dio12SgToolTipPopupEN
                    height: parent.height/10
                    showOn: if(multiplePlatform.dio12 === true && multiplePlatform.jumperDIO12 === false) {!dio12Switch.checked} else {false}
                    anchors {
                        bottom: dio12Switch.top
                        horizontalCenter: dio12Switch.right
                    }
                    content: Text {
                        text: "For EN place a jumper \n in header EN/IO2"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGToolTipPopup {
                    id: dio12SgToolTipPopupENIO2
                    height: parent.height/10
                    showOn: if(multiplePlatform.dio12 === true && multiplePlatform.jumperDIO12 === true) {!dio12Switch.checked} else {false}
                    anchors {
                        bottom: dio12Switch.top
                        horizontalCenter: dio12Switch.right
                    }
                    content: Text {
                        text: "Select EN or IO2 by a jumper \n in header EN/IO2"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGToolTipPopup {
                    id: dio12SgToolTipPopupEN1EN3
                    height: parent.height/10
                    showOn: if(multiplePlatform.dio12 === false && multiplePlatform.jumperDIO12 === true) {!dio12Switch.checked} else {false}
                    anchors {
                        bottom: dio12Switch.top
                        horizontalCenter: dio12Switch.right
                    }
                    content: Text {
                        text: "For EN1 place a jumper \n in header EN/IO2"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGToolTipPopup {
                    id: dio12SgToolTipPopupEN3EN1
                    height: parent.height/10
                    showOn: if(multiplePlatform.dio12 && multiplePlatform.jumperDIO12 === true) {dio12Switch.checked} else {false}
                    anchors {
                        bottom: dio12Switch.top
                        horizontalCenter: dio12Switch.right
                    }
                    content: Text {
                        text: "For EN3 remove the jumper \n in header EN/IO2"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGToolTipPopup {
                    id: dio12SgToolTipPopupEN1
                    height: parent.height/10
                    showOn: if(multiplePlatform.dio12 === false && multiplePlatform.jumperDIO12 === false) {!dio12Switch.checked} else {false}
                    anchors {
                        bottom: dio12Switch.top
                        horizontalCenter: dio12Switch.right
                    }
                    content: Text {
                        text: "For EN1 place a jumper \n in header EN/IO2"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                SGSwitch {
                    id: dio13Switch
                    anchors {
                        top: dio12Switch.top
                        topMargin: parent.height/10
                        horizontalCenter: parent.horizontalLeft
                    }
                    label : if(multiplePlatform.dio13 === true && multiplePlatform.jumperDIO13 === false) {"EN4"}
                            else if(multiplePlatform.dio13 === true && multiplePlatform.jumperDIO13 === true) {"INT"}
                            else if(multiplePlatform.dio13 === false) {"N/A"}
                    switchWidth: parent.width/4            // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: parent.height/15              // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "green"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/37
                    checked: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {platformInterface.dio13_enabled}
                             else{platformInterface.set_dio13.update("off")}
                    onToggled: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {
                                   platformInterface.dio13_enabled = checked
                                   if(checked){
                                       platformInterface.set_dio13.update("on")
                                   }
                                   else{
                                       platformInterface.set_dio13.update("off")
                                   }
                               }
                               else{platformInterface.set_dio13.update("off")}
                }


                SGToolTipPopup {
                    id: dio13SgToolTipPopupEN4
                    height: parent.height/20
                    showOn: if(multiplePlatform.dio13 === true && multiplePlatform.jumperDIO13 === false) {!dio13Switch.checked} else {false}
                    anchors {
                        bottom: dio13Switch.top
                        horizontalCenter: dio13Switch.right
                    }
                    content: Text {
                        text: qsTr("For EN4 remove the jumper in header EN/IO2")
                        color: "white"
                    }
                }


                SGSwitch {
                    id: dio04Switch
                    anchors {
                        top: dio13Switch.top
                        topMargin: parent.height/10
                        horizontalCenter: parent.horizontalLeft
                    }
                    label : if(multiplePlatform.dio04 === true && multiplePlatform.jumperDIO04 === false) {"VSEL"}
                            else if(multiplePlatform.dio04 === true && multiplePlatform.jumperDIO04 === true) {"VSEL-DISCH"}
                            else if(multiplePlatform.dio04 === false && multiplePlatform.jumperDIO04 === true) {"EN2"}
                            else if(multiplePlatform.dio04 === false && multiplePlatform.jumperDIO04 === false) {"N/A"}
                    switchWidth: parent.width/4            // Default: 52 (change for long custom checkedLabels when labelsInside)
                    switchHeight: parent.height/15              // Default: 26
                    textColor: "black"              // Default: "black"
                    handleColor: "white"            // Default: "white"
                    grooveColor: "#ccc"             // Default: "#ccc"
                    grooveFillColor: "green"         // Default: "#0cf"
                    fontSizeLabel: (parent.width + parent.height)/37
                    checked: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {platformInterface.dio04_enabled}
                             else{platformInterface.set_dio04.update("off")}
                    onToggled: if (multiplePlatform.vinScale > ((platformInterface.status_voltage_current.vin)/1000)) {
                                   platformInterface.dio04_enabled = checked
                                   if(checked){
                                       platformInterface.set_dio04.update("on")
                                   }
                                   else{
                                       platformInterface.set_dio04.update("off")
                                   }
                               }
                               else{platformInterface.set_dio04.update("off")}
                }


                SGToolTipPopup {
                    id: dio04SgToolTipPopupIO0EN2
                    height: parent.height/20
                    showOn: if(multiplePlatform.dio04 === false && multiplePlatform.jumperDIO04 === true) {!dio04Switch.checked} else {false}
                    anchors {
                        bottom: dio04Switch.top
                        horizontalCenter: dio04Switch.right
                    }
                    content: Text {
                        text: qsTr("For EN2 remove the jumper in header EN/IO2")
                        color: "white"
                    }
                }

                SGStatusLight {
                    id: dio14Light
                    label: if(multiplePlatform.dio14 === true) {"PG"}
                           else {"N/A"}
                    anchors {
                        top: dio04Switch.top
                        topMargin: parent.height/10
                        horizontalCenter: parent.horizontalLeft
                    }

                    lightSize: (parent.width + parent.height)/23
                    fontSize:  (parent.width + parent.height)/37

                    property string vinMonitor: {platformInterface.status_voltage_current.vout}
                    onVinMonitorChanged:  {

                        if((multiplePlatform.minVout1 > ((platformInterface.status_voltage_current.vout)/1000)) && platformInterface.dio12_enabled === false) {
                            dio14Light.status = "red"
                        }
                        else if((multiplePlatform.minVout3 > ((platformInterface.status_voltage_current.vout)/1000)) && platformInterface.dio12_enabled === true) {
                            dio14Light.status = "red"
                        }
                        else if((multiplePlatform.minVout2 > ((platformInterface.status_voltage_current.vout)/1000)) && platformInterface.dio04_enabled === true) {
                            dio14Light.status = "red"
                        }
                        else if((multiplePlatform.minVout4 > ((platformInterface.status_voltage_current.vout)/1000)) && platformInterface.dio13_enabled === true) {
                            dio14Light.status = "red"
                        }
                        else {
                            dio14Light.status = "green"
                        }
                    }
                }


                SGLabelledInfoBox {
                    id: outputVoltage
                    label: ""
                    info: {
                        if(multiplePlatform.showDecimal === true) {((platformInterface.status_voltage_current.vout)/1000).toFixed(3)}
                        else {((platformInterface.status_voltage_current.vout)/1000).toFixed(0)}
                    }

                    infoBoxColor: "lightblue"
                    infoBoxBorderColor: "grey"
                    infoBoxBorderWidth: 3

                    unit: "V"
                    infoBoxWidth: parent.width/1.5
                    infoBoxHeight : parent.height/12
                    fontSize :  (parent.width + parent.height)/37
                    unitSize: (parent.width + parent.height)/35

                    anchors {
                        top : dio04Switch.bottom
                        topMargin : parent.height/5
                        horizontalCenter: parent.horizontalCenter
                        horizontalCenterOffset:  10
                    }
                }

                SGLabelledInfoBox {
                    id: outputCurrent
                    label: ""
                    info: {
                        if(multiplePlatform.current === "A") {(((platformInterface.status_voltage_current.iout))/1000).toFixed(3)}
                        else {((platformInterface.status_voltage_current.iout)).toFixed(0)}
                    }

                    infoBoxColor: "lightgreen"
                    infoBoxBorderColor: "grey"
                    infoBoxBorderWidth: 3

                    unit: if(multiplePlatform.current === "mA") {"mA"}
                          else{"A"}
                    infoBoxWidth: parent.width/1.5
                    infoBoxHeight :  parent.height/12
                    fontSize :   (parent.width + parent.height)/37
                    unitSize: (parent.width + parent.height)/35
                    anchors {
                        top : outputVoltage.bottom
                        topMargin : 20
                        horizontalCenter: outputVoltage.horizontalCenter
                        horizontalCenterOffset:  0
                    }

                }


            }

        }

    }
}


