import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import QtWebEngine 1.0
import "AdvancedViews"
import "qrc:/js/help_layout_manager.js" as Help

Rectangle{
    id: root

    property bool showConsole: true

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
            //console.log("button column is now",height)
        }

        Rectangle{
            id:tabSelectorView
            color:"black"
            anchors.fill:parent
            parent: demoButonScrollView.contentItem
            border.color:"black"

            Text {
                id: demoTabTitle
                text: "Demos"
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
                id:demoButtonGroup
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
                    text:"One-to-One"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "../images/oneToOneDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true
                    checked:true

                    onCheckedChanged: {
                        if (checked){
                            console.log("demo 1 selected")
                            demoStackLayout.currentIndex = 0
                        }
                    }
                }
                SGButton{
                    id:demo2Button
                    width: parent.width
                    height: 130
                    text:"One-to-Many"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "../images/oneToManyDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked){
                            demoStackLayout.currentIndex = 1
                        }
                    }
                }
                SGButton{
                    id:demo3Button
                    width: parent.width
                    height: 130
                    text:"Relay"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "../images/relayDemo.png"
                    iconSize:100
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked){
                            demoStackLayout.currentIndex = 2
                        }
                    }
                }
//                SGButton{
//                    id:demo4Button
//                    width: parent.width
//                    height: 130
//                    text:"Multiple Model"
//                    fontSizeMultiplier:1.5
//                    color:"white"
//                    icon.source: "../images/multipleModelsDemo.png"
//                    iconSize:100
//                    display: Button.TextUnderIcon
//                    checkable:true

//                    onCheckedChanged: {
//                        if (checked){
//                            demoStackLayout.currentIndex = 3
//                            }
//                    }
//                }
                SGButton{
                    id:demo5Button
                    width: parent.width
                    height: 130
                    text:"Sensor"
                    fontSizeMultiplier:1.5
                    color:"white"
                    icon.source: "../images/sensorIconFullBar.svg"
                    iconSize:50
                    display: Button.TextUnderIcon
                    checkable:true

                    onCheckedChanged: {
                        if (checked){
                            demoStackLayout.currentIndex = 3
                        }
                    }
                }
//                SGButton{
//                    id:demo6Button
//                    width: parent.width
//                    height: 130
//                    text:"cloud"
//                    fontSizeMultiplier:1.5
//                    color:"white"
//                    icon.source: "../images/cloud.png"
//                    iconSize:75
//                    display: Button.TextUnderIcon
//                    checkable:true

//                    onCheckedChanged: {
//                        if (checked){
//                            demoStackLayout.currentIndex = 4
//                        }
//                    }
//                }

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
        border.color:"transparent"




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

//            MultipleModelDemo {
//                id: rectangleFour
//            }

            SensorDemo {
                id: rectangleFive
            }

//            CloudDemo {
//                id: rectangleSix
//            }
        }

        Rectangle{
            id:demoTabDivider
            anchors.left:parent.left
            anchors.leftMargin: 0
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            width:1
            color:"grey"
        }

        Rectangle{
            id:demoConsoleDivider
            anchors.right:parent.right
            anchors.rightMargin: 1
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            width:1
            color:"grey"
        }
    }

    Widget09.SGSegmentedButtonStrip {
        id: rightViewSelectorStrip

        anchors.left: parent.left
        anchors.leftMargin: parent.width * .8
        anchors.top:parent.top
        anchors.right:parent.right

        labelLeft: false
        textColor: "#666"
        activeTextColor: "white"
        radius: 4
        buttonHeight: 30
        exclusive: true
        buttonImplicitWidth: 50
        hoverEnabled:false
        enabled: !container.inOverCurrentProtection

        segmentedButtons: GridLayout {
            columnSpacing: 2
            rowSpacing: 2

            Widget09.SGSegmentedButton{
                id:nodeCommunicationsSegmentedButton
                text: qsTr("Node Communications")
                activeColor: "dimgrey"
                inactiveColor: "gainsboro"
                textActiveColor: "white"
                checked: true
                buttonText.font.pixelSize: 18
                onClicked: root.showConsole = true
            }

            Widget09.SGSegmentedButton{
                id:helpSegmentedButton
                text: qsTr("")
                activeColor: "dimgrey"
                inactiveColor: "gainsboro"
                textActiveColor: "white"
                buttonText.font.pixelSize: 18
                onClicked: root.showConsole = false

                Image{
                    id:questionMarkImage
                    anchors.centerIn: parent
                    height:25
                    width:25
                    source: helpSegmentedButton.checked ? "../images/question-circle-white.svg" : "qrc:/sgimages/question-circle.svg"
                    fillMode: Image.PreserveAspectFit
                    mipmap:true
                    opacity:helpSegmentedButton.checked ? .8 : .3
                }
            }

        }
    }


    Rectangle{
        id:helpViewContainer
        anchors.left: parent.left
        anchors.leftMargin: parent.width * .75
        anchors.top:rightViewSelectorStrip.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.right:parent.right
        color:"white"
        visible: !root.showConsole

        WebEngineView {
             id: webView
             anchors.fill: parent
             url: "../images/HTML/mesh_help.html"
            }
    }

    Widget09.SGResponsiveScrollView {
        id: consoleScrollView

        anchors.left: parent.left
        anchors.leftMargin: parent.width * .75
        anchors.top:rightViewSelectorStrip.bottom
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.right:parent.right
        visible: root.showConsole


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
                width: parent.width
                height: (parent.height)
                anchors.left:parent.left
                anchors.leftMargin: 10
                anchors.right:parent.right
                anchors.rightMargin: 10
                anchors.top:parent.top
                //anchors.topMargin: 50
                anchors.bottom:parent.bottom
                anchors.bottomMargin: 50
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
        anchors.bottom:consoleScrollView.bottom
        anchors.bottomMargin: 10
        visible:showConsole

        text:"Clear"

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

    Rectangle{
        id:consoleSendView
        anchors.left: consoleScrollView.left
        anchors.top:consoleScrollView.bottom
        anchors.bottom: parent.bottom
        anchors.right:parent.right
        visible:showConsole

        SGSubmitInfoBox{
            id:commandLineInput
            anchors {
               //horizontalCenter: parent.horizontalCenter
               verticalCenter:parent.verticalCenter
               left:parent.left
               leftMargin:10
               right:parent.right
               rightMargin: 10
               }
            horizontalAlignment: Text.AlignLeft

            onAccepted: {
                //console.log("sending:",commandLineInput.text)
                let object = JSON.parse(commandLineInput.text)
                try{
                    if (!object) throw "incorrect JSON";
                    CorePlatformInterface.send(object)
                    commandLineInput.text = "";  //clear the text after submitting
                }
                catch(err){
                    console.log("incorrect JSON command")
                }


            }


        }

    }
}



