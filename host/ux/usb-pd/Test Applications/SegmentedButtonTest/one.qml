import QtQuick 2.6
import QtQuick.Controls 2.2
import QtQuick.Window 2.2

Rectangle{
    id:one
    opacity: 1
    anchors.fill:parent

    ScrollView{
        id:theScrollView
        anchors.fill:parent
        clip: true
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOn

        Component.onCompleted: {
            console.log("content height=",theColumn.height,"scroll view height=",theScrollView.height)
        }


        Column{
            id:theColumn

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 1000
                font.family: "helvetica"
            }

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 1000
                font.family: "helvetica"
            }

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }

            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }
            Text{
                anchors.horizontalCenter: parent.horizontalCenter
                text:"one"
                font.pointSize: 100
                font.family: "helvetica"
            }

        }//column

    }   //scroll view

}
