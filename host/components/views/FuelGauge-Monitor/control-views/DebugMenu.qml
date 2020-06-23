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
    height: 350
    color: "transparent"
    width: 300//rect243.width//350     //rect243.height//200
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
    Item {
        id: element1
        anchors {
            fill: root2
            margins: 1
        }

        clip: true
       Button{
            id:openshowmenuds
        text: "Export Log"
        width: parent.width*0.7
        anchors.horizontalCenter: parent.horizontalCenter
        //height: 37
        onClicked:{
            opensavedaialoguemenu.visible=true

        }
        TextArea{
        id:textcollxnfor
        visible: false
        text: "Hello man this is test test area"
        }
        }
      //  var x-= fot()
        ApplicationWindow {
            id:opensavedaialoguemenu
            visible: false
            width: 560
            height: 630
            title: qsTr("Save Log Data")

            ScrollView {
                             id: frame
                             clip: true
                             anchors.fill: parent
                             //other properties
                             ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                             Flickable {
                                 contentHeight: 5000
                                 width: parent.width
                                 Rectangle {
                                     id : rectangle
                                     color: "transparent"
                                     radius: 6
                                     //visible: !busyIndicator.running
                                     anchors.fill: parent

                                     TextArea {
                                         //height: parent.
                                         width: parent.width*0.99
                                         height: parent.height*0.85
                                         id: textEdit
                                         focus: true
                                         persistentSelection: true
                                         selectByMouse: true
                                         anchors.fill: parent
                                         text: virtualtextarea.text//
                                    }

                                 }
                             }
                         }

            FileDialog {
                id: openFileDialog
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: textEdit.text = openFile(openFileDialog.fileUrl)
            }
            FileDialog {
                id: saveFileDialog
                selectExisting: false
                nameFilters: ["Text files (*.log)", "All files (*)"]
                onAccepted: { saveFile(saveFileDialog.fileUrl, textEdit.text)
                           opensavedaialoguemenu.visible=false
            } //document.saveFile(fileUrl)

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

           /* TextArea {
                //height: parent.
                width: parent.width*0.99
                height: parent.height*0.85
                id: textEdit
                focus: true
                persistentSelection: true
                selectByMouse: true
                anchors.fill: parent
                text: virtualtextarea.text//
           }

            ScrollBar {
                id: vbar
                hoverEnabled: true
                active: hovered || pressed
                orientation: Qt.Vertical
                size: frame.height / textEdit.height
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
            }*/

            Rectangle{
            id:saveopenmenus
            height: 45
            color: "#eff6f9"
            width: parent.width
            border.width: 0
            border.color: "lightgray"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
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
    Rectangle {
        id: shadow
        anchors.fill: parent.width*0.99
        parent: width*0.85
        visible: false
    }
    DropShadow {
        anchors.fill: shadow
        radius: 10.0
        samples: 30
        source: shadow
        z: -1
    }

}
