import QtQuick 2.12
import QtQuick.Layouts 1.12

import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

Rectangle {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200

    // property that reads the initial notification
    property var effi_calc: (((platformInterface.status_voltage_current.vout) * ((platformInterface.status_voltage_current.iout)) * 100) / ((platformInterface.status_voltage_current.vin) * ((platformInterface.status_voltage_current.iin)))).toFixed(3)
    property var vin_calc: ((platformInterface.status_voltage_current.vin)/1000).toFixed(3)
    property var iin_calc: (((platformInterface.status_voltage_current.iin))/1000).toFixed(3)
    property var vout_calc: ((platformInterface.status_voltage_current.vout)/1000).toFixed(3)
    property var iout_calc: (((platformInterface.status_voltage_current.iout))/1000).toFixed(3)
    property var temp_calc: platformInterface.status_temperature_sensor.temperature
    property var pin_calc: (vin_calc * iin_calc).toFixed(3)
    property var pout_calc: (vout_calc * iout_calc).toFixed(3)
    property var pdis_calc: (pin_calc - pout_calc).toFixed(3)

    Rectangle {
        id: container
        anchors.fill: parent
        color: "white"

        Text {
            id: name
            text: "<b> Message notifications coming from CoreInterface <b>"
            font.pixelSize: ratioCalc * 25
            color:"green"
            anchors {
                horizontalCenter: parent.horizontalCenter
                topMargin: 50
                top:parent.top
            }
        }

        Component.onCompleted: {
            Help.registerTarget(navTabs, "These tabs switch between Basic, Advanced, Real-time trend analysis, Load Transient and Core Control views.", 0, "coreControlHelp")
            Help.registerTarget(recording, "A powerful add-in for Microsoft Excel, which allows you to bring data directly into the cells of an Excel spread-sheet. Select the rows you want, Ctrl+C and Ctrl+V to Excel." , 1 , "coreControlHelp")
            Help.registerTarget(clear, "All data is deleted from the data acquisition engine." , 2 , "coreControlHelp")
            Help.registerTarget(messageList, "Every action is logged with all relevant data. A mouse click or drag on the scroll bar, dragging inside the element, or using the mouse's scroll wheel in order to see all message notifications coming from Core Interface." , 3 , "coreControlHelp")
        }

        Rectangle {
            id: setttingControl
            width: parent.width
            height: parent.height/10
            anchors.left:parent.left
            anchors.leftMargin: 20
            anchors.right:parent.right
            anchors.rightMargin: 20
            anchors.top:name.bottom
            anchors.topMargin: 20
            Widget09.SGSwitch {
                id: recording
                anchors {
                    top: parent.top
                    topMargin: 10
                    left: parent.left
                    leftMargin: 20
                }
                label : "Data Acquisition"
                switchWidth: 52
                switchHeight: 26
                textColor: "black"
                handleColor: "white"
                grooveColor: "lightblue"
                grooveFillColor: "red"
                fontSize: 20
                checked: recording.checked
                property var message_log: "(PID)    Vin(V):    "+ vin_calc +"    Iin(A):    "+ iin_calc +"    Vout(V):   "+ vout_calc +"   Iout(A):   "+ iout_calc +"   Efficy.(η)(%):     "+ effi_calc +"   Temp.(°C):      "+ temp_calc +"      Transient:      "+ !platformInterface.systemMode +".    Freq:    "+ platformInterface.frequency +".      Duty(%):   "+ platformInterface.duty +"    Pin(W):    "+ pin_calc +"   Pout(W):    "+ pout_calc +"   Pdis(W):    "+ pdis_calc +""
                onMessage_logChanged: {
                    console.log("debug:",message_log)
                    if(message_log !== "" && recording.checked === true) {
                        for(var j = 0; j < messageList.model.count; j++){messageList.model.get(j).color = "black"
                            if (j > 998) {messageList.clear()}
                        }
                        messageList.append(message_log,"red")}
                    else if(clear.checked === true && recording.checked === false) {messageList.clear()}
                }
            }

            Widget09.SGSwitch {
                id: clear
                anchors {
                    top: parent.top
                    topMargin: 10
                    left: recording.right
                    leftMargin: 100
                }
                label : "Clear Data"
                switchWidth: 52
                switchHeight: 26
                textColor: "black"
                handleColor: "white"
                grooveColor: "lightblue"
                grooveFillColor: "red"
                fontSize: 20
                checked: clear.checked
            }
        }


        Rectangle {
            width: parent.width
            height: (parent.height - name.contentHeight - setttingControl.height)
            anchors.left:parent.left
            anchors.leftMargin: 20
            anchors.right:parent.right
            anchors.rightMargin: 20
            anchors.top:setttingControl.bottom
            anchors.topMargin: 10
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 50
            color: "transparent"

            SGStatusLogBoxSelectableDelegates{
                id: messageList
                anchors.fill: parent
                showMessageIds: true
                filterEnabled: true
                filterRole: "message"  // this role is what is cmd/ctrl-f filters on
                copyRole: "message"
                scrollToEnd: true
                color: "dimgrey"
                statusTextColor: "white"
                statusBoxColor: "black"
                statusBoxBorderColor: "green"
                fontSizeMultiplier: 1.19

                //  Overrides built-in listElementTemplate that enables mouse delegate selection ability
                listElementTemplate: {
                    "message": "",
                    "id": 0,
                    "selected": false,          // required role for selection functionality
                    "stateChanged": false       // required role for selection functionality
                }

                delegate: Rectangle {
                    id: delegatecontainer
                    height: delegateText.height
                    width: ListView.view.width
                    color: model.selected ? "#def" : "white"  // visual indicator of selected status

                    SGText {
                        id: delegateText
                        text: { return (
                                    messageList.showMessageIds ?
                                        model.id + ": " + model.message :
                                        model.message
                                    )}

                        fontSizeMultiplier: messageList.fontSizeMultiplier
                        color: model.color
                        wrapMode: Text.WrapAnywhere
                        width: parent.width
                    }
                }

                function append(message,color) {
                    listElementTemplate.message = message
                    listElementTemplate.color = color
                    model.append( listElementTemplate )
                    return (listElementTemplate.id++)
                }
                function insert(message,index,color){
                    listElementTemplate.message = message
                    listElementTemplate.color = color
                    model.insert(index, listElementTemplate )
                    return (listElementTemplate.id++)
                }
            }
        }

    }
}




