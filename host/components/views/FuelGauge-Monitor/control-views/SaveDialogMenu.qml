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
    //property alias saving_variable: saving_variable
    property alias save_file_dialogbox: save_file_dialogbox
    height: 350
    color: "transparent"
    width: 300//rect243.width//350     //rect243.height//200 // virtualtextarea
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
    property var counter_count:0
    property var fw_cell_voltage: +platformInterface.telemetry.cell_voltage
    onFw_cell_voltageChanged:{
        counter_count++
        if(counter_count==2){
             save_file_dialogbox.text = ""
        }
        else
            save_file_dialogbox.text = save_file_dialogbox.text  + ":" +platformInterface.telemetry.cell_temp + "," + platformInterface.telemetry.cell_voltage + "\n"
         }
    property var clears_log_data: +logSwitch.clear_log_data
    onClears_log_dataChanged:{
     if (+logSwitch.clear_log_data==1){save_file_dialogbox.text = ""}
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
                 opensavedaialoguemenu.visible=true
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
                id: openFileDialog
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: save_file_dialogbox.text = openFile(openFileDialog.fileUrl)
            }
            FileDialog {
                id: saveFileDialog
                selectExisting: false
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: { saveFile(saveFileDialog.fileUrl, (virtualtextarea.text + save_file_dialogbox.text))
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
                    MenuItem {
                        text: qsTr("Exit")
                        onTriggered: Qt.quit();
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
                text: "Save"//Save
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
                text: "Open"//Save
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
