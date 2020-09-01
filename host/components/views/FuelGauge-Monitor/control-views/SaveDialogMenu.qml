import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface
import tech.strata.logger 1.0
import QtCharts 2.0
import QtQuick.Dialogs 1.2
Rectangle {
    id: root2
    property  alias opensavedaialoguemenu:opensavedaialoguemenu
    property alias get_measurement_start:get_measurement_start
    //property alias saving_variable: saving_variable:-:
    property alias save_file_dialogbox: save_file_dialogbox
    property var my_log_time:0
    property var time_data:[]
    height: 350
    color: "transparent"
    width: 300
    border {
        width: 1
        color: "transparent"
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
    //Error correction for Data_text_area  LOG DATA PRINT
    Timer{
        id:get_measurement_start
        interval: +(virtualtextarea.realtimelog*1000) //1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: {
            if(logSwitch.checked === true){ platformInterface.get_measurement_value.update("")}
        }
    }
    property var my_last_time: 0
    property var fw_cell_voltage: +platformInterface.telemetry.cell_voltage
    onFw_cell_voltageChanged:{
        if(platformInterface.telemetry.log_indicator !=="black"){
            //Data-only-->time is excluded //if(platformInterface.telemetry.log_indicator !=="black"){
            time_data=":" +platformInterface.telemetry.cell_temp + "," + platformInterface.telemetry.cell_voltage + "\n"
            my_last_time=(new Date().toLocaleString(Qt.locale(),"yyyy/MM/dd h:mm:ss"))
            save_file_dialogbox.collect_collect.push(time_data)
        }
    }
    property var clears_log_data: +logSwitch.clear_log_data
    onClears_log_dataChanged:{
        if (+logSwitch.clear_log_data==1){save_file_dialogbox.collect_collect = []}
    }

    Item {
        id: element1
        anchors {
            fill: root2
            margins: 1
        }

        clip: true
        Button{
            id:open_show_menus
            text: "Export Log"
            width: parent.width*0.7
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked:{
                //opensavedaialoguemenu.visible=true
                saveFileDialog.open()
            }
        }
        ApplicationWindow {
            id:opensavedaialoguemenu
            visible: false
            width: 530
            height: 670
            title: qsTr("Please save  your log data")

            ScrollView {
                id: frame
                clip: true
                width: parent.width
                height: parent.height*0.436// 288
                anchors.bottom: parent.bottom
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                Flickable {
                    id:flickble
                    contentHeight: 4000//(350 + counter_count)
                    width: parent.width
                    Rectangle {
                        id : rectangle
                        color: "transparent"
                        radius: 6
                        anchors.top: parent.top
                        border.width: 5
                        border.color: "white"
                        anchors.topMargin: 0
                        anchors.fill: parent

                        TextArea {
                            id:save_file_dialogbox
                            property var collect_collect:[]
                            anchors.bottom: parent.bottom
                            width: parent.width*0.99
                            height: parent.height*0.4
                            font.pixelSize: 11
                            focus: true
                            persistentSelection: true
                            selectByMouse: true
                            anchors.fill: parent
                            anchors.topMargin: 0
                            text: ""
                        }
                    }
                }
            }

            FileDialog {
                id: openFileDialog  //not implemented now in UI open is disabled
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: save_file_dialogbox.collect_collect = openFile(openFileDialog.fileUrl)
            }
            FileDialog {
                id: saveFileDialog
                selectExisting: false
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: { saveFile(saveFileDialog.fileUrl, (virtualtextarea.text + save_file_dialogbox.collect_collect.join("")+ "Stop_time= "+my_last_time))
                    opensavedaialoguemenu.visible=false
                }
            }
            menuBar: MenuBar {

                /*   Menu {
                title: qsTr("File")
                MenuItem {
                    text: qsTr("&Open")
                    onTriggered: openFileDialog.open()
                }
                MenuItem {
                    text: qsTr("&Save")
                    onTriggered: saveFileDialog.open()
                }

                }*/
            }

            Rectangle{
                id:logs_datas
                height: parent.height*0.57// 358
                color: "transparent"
                width: parent.width
                border.width: 14
                border.color: "white"
                anchors.top: parent.top
                //anchors.bottomMargin: 1

                TextArea {
                    id:log_info_box
                    anchors.top: parent.top
                    font.pixelSize: parent.height*0.03// 11
                    persistentSelection: true
                    text: virtualtextarea.text
                }
            }

            Rectangle{
                id:saveopenmenus
                height: 45
                color: "#eff6f9"
                width: parent.width
                border.width: 0
                border.color: "lightgray"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                Button{
                    id:savebutton
                    height: 43
                    anchors.bottom: parent.bottom
                    width: parent.width*0.35
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    text: "Save"		//Save
                    onClicked: { saveFileDialog.open()
                        //opensavedaialoguemenu.visible=false
                    }
                }
                /* Button{
                id:openbutton
                height: 43
                anchors.bottom: parent.bottom
                width: parent.width*0.3
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Open"		//Save
                onClicked: openFileDialog.open()
                }*/
                Button{
                    id:exitbutton
                    height: 43
                    anchors.bottom: parent.bottom
                    width: parent.width*0.35
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    text: "Exit"//Save
                    onClicked:  opensavedaialoguemenu.close()
                }
            }
        }
    }
}
