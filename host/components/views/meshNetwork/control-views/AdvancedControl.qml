import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "AdvancedViews"

import "qrc:/js/help_layout_manager.js" as Help
Rectangle{
    id: root

    Widget09.SGResponsiveScrollView {
        id: demoButonScrollView

        anchors.left:parent.left
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        width:parent.width*.15
        scrollBarColor:"lightgrey"


        minimumHeight: 850
        minimumWidth: parent.width * .15

        onHeightChanged: {
            console.log("button column is now",height)
        }

        Rectangle{
            id:tabSelectorView
            color:"black"
            anchors.fill:parent
            parent: demoButonScrollView.contentItem
            border.color:"black"

            Text {
                id: demoTabTitle
                text: "demos"
                font {
                    pixelSize: 24
                }
                color:"white"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top:parent.top
                }
            }

            ButtonGroup {
                buttons: buttonColumn.children
            }

            Column{
                id: buttonColumn
                anchors.top: demoTabTitle.bottom
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.bottom:parent.bottom
                spacing:1

                SGButton{
                    id:demo1Button
                    width: parent.width
                    height: 130
                    text:"one-to-one"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/oneToOneDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true
                    checked:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 0
                    }
                }
                SGButton{
                    id:demo2Button
                    width: parent.width
                    height: 130
                    text:"one-to-many"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/oneToManyDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 1
                    }
                }
                SGButton{
                    id:demo3Button
                    width: parent.width
                    height: 130
                    text:"relay"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/relayDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 2
                    }
                }
                SGButton{
                    id:demo4Button
                    width: parent.width
                    height: 130
                    text:"multiple model"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/multipleModelsDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 3
                    }
                }
                SGButton{
                    id:demo5Button
                    width: parent.width
                    height: 130
                    text:"sensor"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/sensorIcon.png"
                    iconSize:50
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 4
                    }
                }
                SGButton{
                    id:demo6Button
                    width: parent.width
                    height: 130
                    text:"cloud"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "qrc:/views/meshNetwork/images/cloud.png"
                    iconSize:75
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked)
                            demoStackLayout.currentIndex = 5
                    }
                }

            }
        }
    }

    Rectangle{
        id:demoContentView
        color:"white"
        anchors.left:demoButonScrollView.right
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        width:parent.width*.6
        border.color:"blue"



        StackLayout {
            id: demoStackLayout
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                left: parent.left
            }

            OneToOneDemo {
                id: rectangleOne
            }

            OneToManyDemo {
                id: rectangleTwo
            }

            RelayDemo {
                id: rectangleThree
            }

            MultipleModelDemo {
                id: rectangleFour
            }

            SensorDemo {
                id: rectangleFive
            }

            CloudDemo {
                id: rectangleSix
            }
        }

    }



    Widget09.SGResponsiveScrollView {
        id: consoleScrollView

        anchors.left: parent.left
        anchors.leftMargin: parent.width * .75
        anchors.top:parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 100
        anchors.right:parent.right


        minimumHeight: 800
        minimumWidth: parent.width * .25

        property var message_array : []
        property var message_log: platformInterface.msg_dbg.msg
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
            parent: consoleScrollView.contentItem
            anchors {
                fill: parent
            }
            color: "dimgrey"


            Text {
                id: name
                text: "Node Communications"
                font {
                    pixelSize: 24
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

    Button{
        id:resetButton

        anchors.right: parent.right
        anchors.rightMargin: 20
        anchors.top:parent.top
        anchors.topMargin: 50

        text:"clear"

        contentItem: Text {
                text: resetButton.text
                font.pixelSize: 20
                opacity: enabled ? 1.0 : 0.3
                color: "grey"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                color: resetButton.down ? "lightgrey" : "transparent"
                border.color: "grey"
                border.width: 2
                radius: 10
            }
    }

    Rectangle{
        id:consoleSendView
        anchors.left: consoleScrollView.left
        anchors.top:consoleScrollView.bottom
        anchors.bottom: parent.bottom
        anchors.right:parent.right

        Text {
            id: consoleSendName
            text: "Command View"
            font {
                pixelSize: 24
            }
            color:"black"
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter:parent.verticalCenter
            }
        }
    }
}



