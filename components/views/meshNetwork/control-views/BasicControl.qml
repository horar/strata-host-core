import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import QtWebEngine 1.0
import "BasicViews"

Rectangle {
    id: root
    visible: true
    //anchors.fill:parent

    Component.onDestruction: {
        console.log("closing platform")
        consoleDrawer.exit.enabled = false
        consoleDrawer.close();
    }

    Text{
        id:viewComboLabel
        anchors.left: parent.left
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 20
        text: "Virtual Environment:"
        font.pixelSize: 24
    }

   SGComboBox{
       id:basicViewCombo
       anchors.verticalCenter: viewComboLabel.verticalCenter
       anchors.left:viewComboLabel.right
       anchors.leftMargin: 5
       width: 200
       model: [ "Office", "Smart Home"]
       fontSizeMultiplier: 1.75

       onCurrentIndexChanged: {
           if (currentIndex === 0){
                //configure the view for the office
               basicControlContainer.currentIndex = 0
           }
           else if (currentIndex === 1){
               //configure the view for the smart home
              basicControlContainer.currentIndex = 1
            }

       }
   }

   Button{
       id:synchronizeButton

       anchors.left: basicViewCombo.right
       anchors.leftMargin: 10
       anchors.verticalCenter: basicViewCombo.verticalCenter

       text:"Synchronize"

       contentItem: Text {
               text: synchronizeButton.text
               font.pixelSize: 24
               color: "black"
               horizontalAlignment: Text.AlignHCenter
               verticalAlignment: Text.AlignVCenter
               elide: Text.ElideRight
           }

           background: Rectangle {
               implicitWidth: 50
               implicitHeight: 25
               color: synchronizeButton.down ? "grey" : "transparent"
               border.color: "black"
               border.width: 2
               radius: 10
           }

          onClicked: {
              if (basicViewCombo.currentIndex == 0)
                  officeView.sendNodeSwitchCommand();
              else
                  smartHomeView.sendNodeSwitchCommand();          }
   }

   Image{
       id:drawerToggleButton2
       property bool drawerIsOpen: consoleDrawer.visible
       anchors.top:parent.top
       anchors.topMargin: 10
       anchors.right:drawerToggleButton.left
       anchors.rightMargin: 10
       height:30
       width:30
       source: "qrc:/sgimages/question-circle.svg"
       fillMode: Image.PreserveAspectFit
       mipmap:true
       opacity:.3

       MouseArea{
           id:toggleDrawerMouseArea2
           anchors.fill:parent

           onClicked:{
               if (drawerToggleButton2.drawerIsOpen)
                   consoleDrawer.close()
               else{
                   consoleDrawer.showConsole = false;
                   consoleDrawer.open()
               }

           }
       }

   }

   Image{
       id:drawerToggleButton
       property bool drawerIsOpen: consoleDrawer.visible
       anchors.top:parent.top
       anchors.topMargin: 10
       anchors.right:parent.right
       anchors.rightMargin: 10
       height:30
       width:30
       source: "qrc:/sgimages/chevron-left.svg"
       fillMode: Image.PreserveAspectFit
       mipmap:true
       opacity:.3

       MouseArea{
           id:toggleDrawerMouseArea
           anchors.fill:parent

           onClicked:{
               if (drawerToggleButton.drawerIsOpen)
                   consoleDrawer.close()
               else{
                   consoleDrawer.showConsole = true;
                   consoleDrawer.open()
               }
           }
       }

   }


   StackLayout {
       id: basicControlContainer
       anchors {
           top: basicViewCombo.bottom
           bottom: parent.bottom
           right: parent.right
           left: parent.left
       }

       //office view
       Office {
           id: officeView
       }

       //smart home view
       SmartHome {
           id: smartHomeView
       }
   }

   Drawer {
       id:consoleDrawer
           y: 80
           width: root.width * 0.3
           height: root.height
           edge: Qt.RightEdge

           Overlay.modal: Rectangle {
               color: "#66222222"
               Component.onDestruction: {
                   visible = false
                   opacity = 0
               }
           }

           property bool showConsole: true

           Rectangle{
               id:helpViewContainer
               anchors.fill:parent
               color:"white"

               WebEngineView {
                    id: webView
                    anchors.fill: parent
                    url: "../images/HTML/mesh_help.html"
                   }
           }

           Rectangle{
               id:consoleTextContainer
               anchors.left: parent.left
               anchors.top:parent.top
               anchors.right:parent.right
               height:25
               color:"white"
               visible: consoleDrawer.showConsole

               Text {
                   id: consoleText
                   text: "Node Communications"
                   font {
                       pixelSize: 24
                   }
                   color:"black"
                   anchors.horizontalCenter: parent.horizontalCenter
                   anchors.verticalCenter: parent.verticalCenter
               }
           }

           Widget09.SGResponsiveScrollView {
               id: consoleScrollView

               anchors.left: parent.left
               anchors.top:consoleTextContainer.bottom
               anchors.bottom: parent.bottom
               anchors.right:parent.right
               visible:consoleDrawer.showConsole


               minimumHeight: 800
               minimumWidth: parent.width * .25
               scrollBarColor:"darkgrey"

               property var message_array : []
               property var message_log: platformInterface.msg_cli.msg
               onMessage_logChanged: {
                   //console.log("debug:",message_log)
                   if(message_log !== "") {
                       for(var j = 0; j < messageList.model.count; j++){
                           messageList.model.get(j).color = "black"
                       }

                       messageList.append(message_log,"white")

                   }
               }

               Rectangle {
                   id: container
                   parent: consoleScrollView.contentItem
                   anchors {
                       fill: parent
                   }
                   color: "white"

                   Rectangle {
                       id:debugMessageRectangle
                       width: parent.width
                       height: (parent.height)
                       anchors.left:parent.left
                       anchors.leftMargin: 10
                       anchors.right:parent.right
                       anchors.rightMargin: 10
                       anchors.top:parent.top
                       //anchors.topMargin: 50
                       anchors.bottom:parent.bottom
                       color: "transparent"
                       SGStatusLogBox{
                           id: messageList
                           anchors.fill: parent
                           //model: messageModel
                           //showMessageIds: true
                           color: "white"      //background color of the status box
                           //statusTextColor: "white"
                           //statusBoxColor: "black"
                           statusBoxBorderColor: "white"
                           fontSizeMultiplier: .9

                           listElementTemplate : {
                               "message": "",
                               "id": 0,
                               "color": "black"
                           }
                           scrollToEnd: true
                           delegate: Rectangle {
                               id: delegatecontainer
                               height: delegateText.height
                               width: ListView.view.width
                               color:"white"   //text background color

                               SGText {
                                   id: delegateText
                                   text: { return (
                                               messageList.showMessageIds ?
                                                   model.id + ": " + model.message :
                                                   model.message
                                               )}

                                   fontSizeMultiplier: messageList.fontSizeMultiplier
                                   color: "grey"//model.color   //text color
                                   wrapMode: Text.WrapAnywhere
                                   width: parent.width
                               }
                           }

                           function append(message,color) {
                               console.log("appending message")
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

           Button{
               id:clearButton

               anchors.right: parent.right
               anchors.rightMargin: 20
               anchors.top:consoleTextContainer.bottom
               anchors.topMargin: 10
               visible: consoleDrawer.showConsole

               text:"clear"

               contentItem: Text {
                       text: clearButton.text
                       font.pixelSize: 15
                       opacity: enabled ? 1.0 : 0.3
                       color: "lightgrey"
                       horizontalAlignment: Text.AlignHCenter
                       verticalAlignment: Text.AlignVCenter
                       elide: Text.ElideRight
                   }

                   background: Rectangle {
                       implicitWidth: 50
                       implicitHeight: 25
                       color: clearButton.down ? "grey" : "transparent"
                       border.color: "lightgrey"
                       border.width: 2
                       radius: 10
                   }

                  onClicked: {
                      messageList.clear()
                  }
           }

       }//drawer

}
