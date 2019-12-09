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
    property var message_log: platformInterface.msg_dbg.msg
    onMessage_logChanged: {
        console.log(message_log)
        if(message_log !== "")
            messageModel.append({message: message_log })
    }

    Rectangle {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }
        color: "white"//"black"


        Text {
            id: name
            text: "Advanced Controls"
            font {
                pixelSize: 60
            }
            color:"black"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top:parent.top
            }
        }
        //        Flickable {
        //            id: flick
        //            anchors.left:parent.left
        //            anchors.leftMargin: 20
        //            anchors.right:parent.right
        //            anchors.rightMargin: 20
        //            anchors.top:name.bottom
        //            anchors.topMargin: 50
        //            anchors.bottom:parent.bottom
        //            anchors.bottomMargin: 50
        //            contentWidth: edit.contentHeight
        //            contentHeight: edit.contentHeight
        //            clip: true

        //            //function to scroll the content to make sure the cursor is
        //            //visible
        //            function ensureVisible(r)
        //            {
        //                if (contentX >= r.x)
        //                    contentX = r.x;
        //                else if (contentX+width <= r.x+r.width)
        //                    contentX = r.x+r.width-width;
        //                if (contentY >= r.y)
        //                    contentY = r.y;
        //                else if (contentY+height <= r.y+r.height)
        //                    contentY = r.y+r.height-height;
        //            }

        //             TextEdit {
        //                 id: edit
        //                 //width: flick.width
        //                 anchors.fill:parent
        //                 focus: true
        //                 wrapMode: TextEdit.Wrap
        //                 onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
        //                 font.family: "Helvetica"
        //                 font.pixelSize: 20
        //                 color:"white"
        //                 //text:"the quick brown fox jumps over the lazy dog"

        ////                Component.onCompleted: {
        ////                    for (var i=0;i<100;i++){
        ////                        text = text + "the quick brown fox jumps over the lazy dog\n"
        ////                    }
        ////                }
        //

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
                anchors.fill: parent
                model: messageModel
                //showMessageIds: true
                //color: "black"
                //statusTextColor: "white"
                //statusBoxColor: "black"
                //fontSizeMultiplier: 20

                ListModel {
                    id: messageModel
                }
            }

        }

    }

    //  }
}



