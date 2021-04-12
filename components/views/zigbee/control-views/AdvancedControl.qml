import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    property var message_array : []
    property var message_log: platformInterface.debug_notification.message
    onMessage_logChanged: {
        console.log("debug:",message_log)
        if(message_log !== "") {
            for(var j = 0; j < messageList.model.count; j++){
                messageList.model.get(j).color = "black"
            }

            messageList.append(message_log,"white")

        }
    }

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        color: "dimgrey"//"white"


        Text {
            id: name
            text: "Node Communications"
            font {
                pixelSize: 60
            }
            color:"white"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top:parent.top
            }
        }

        Rectangle {
            width: parent.width
            height: (parent.height - name.contentHeight)
            anchors.left:parent.left
            anchors.leftMargin: 20
            anchors.right:parent.right
            anchors.rightMargin: 20
            anchors.top:name.bottom
            anchors.topMargin: 50
            anchors.bottom:parent.bottom
            anchors.bottomMargin: 50
            color: "transparent"
            SGStatusLogBox{
                id: messageList
                anchors.fill: parent
                //model: messageModel
                //showMessageIds: true
                color: "dimgrey"
                //statusTextColor: "white"
                //statusBoxColor: "black"
                statusBoxBorderColor: "dimgrey"
                fontSizeMultiplier: 2

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
                    color:"dimgrey"

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



