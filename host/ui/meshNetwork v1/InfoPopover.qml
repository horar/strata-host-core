import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12

Item {

    height:200
    width:100
    property int leftMargin:20
    property int modelsRightMargin:50
    property int modelsPreferredRowHeight:30
    property int sectionItemFontSize:15
    property alias title:title.text

    property bool hasLEDModel:false
    property bool hasBuzzerModel:false
    property bool hasVibrationModel:false
    property bool hasNoModels: (!hasLEDModel && !hasBuzzerModel && !hasVibrationModel)


    Rectangle{
        id:background
        anchors.fill:parent
        color:"lightgrey"
        opacity:.85
        border.color:"grey"
        radius:10
    }

    Text{
        id:title
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top:parent.top
        anchors.topMargin: 10
        text:"Node Info"
        font.pixelSize:24
    }

    Text{
        id:modelsText
        anchors.top:title.bottom
        anchors.topMargin: 20
        anchors.left:parent.left
        anchors.leftMargin:leftMargin
        text:"Models:"
        font.pixelSize:18
    }

    GridLayout{
        id:modelColumn
        anchors.top:modelsText.bottom
        anchors.topMargin: 0
        anchors.left:parent.left
        anchors.leftMargin:modelsRightMargin
        columns:4
        rows:4
        rowSpacing: 0



        Text{
            id:noModelText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight:hasNoModels ? modelsPreferredRowHeight : 0
            horizontalAlignment: Text.AlignRight
            text:"None"
            font.pixelSize: 18
            visible: hasNoModels
            Layout.columnSpan: 4

        }

        //second row
        Text{
            id:ledText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight: hasLEDModel ? modelsPreferredRowHeight : 0
            horizontalAlignment: Text.AlignRight
            text:"LED:"
            font.pixelSize:sectionItemFontSize
            visible: hasLEDModel
        }


        Button{
            id:ledButton
            Layout.preferredHeight: hasLEDModel ? 18 : 0
            Layout.bottomMargin: 10
            text:"on/off"
            visible: hasLEDModel


            contentItem: Text {
                text: ledButton.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                font.pixelSize: 12
                opacity: enabled ? 1.0 : 0.3
                color: ledButton.down ? "white" : "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 40
                color: ledButton.down ? "dimgrey" : "grey"
                border.width: 1
                border.color:ledButton.down ? "grey" : "black"
                radius: 10
            }

            onClicked:{
                //send a message to the object group
                console.log("led on/off");
            }
        }

        Slider{
            id:ledBrightnessSlider
            //Layout.fillWidth: true
            Layout.preferredHeight: hasLEDModel ? modelsPreferredRowHeight : 0
            Layout.preferredWidth: 85
            Layout.bottomMargin: 10
            visible: hasLEDModel
            from: 0
            to:100
        }

        Button{
            id:ledColorButton
            Layout.preferredHeight: hasLEDModel ? 18 : 0
            Layout.bottomMargin: 10
            text:"color"
            implicitWidth: 50
            visible: hasLEDModel


            contentItem: Text {
                text: ledColorButton.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                font.pixelSize: 12
                opacity: enabled ? 1.0 : 0.3
                color: ledColorButton.down ? "white" : "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 50
                color: ledColorButton.down ? "dimgrey" : "grey"
                border.width: 1
                border.color:ledColorButton.down ? "grey" : "black"
                radius: 10
            }

            onClicked:{
                //send a message to the object group to change color
                console.log("set color");
            }
        }

        Text{
            id:buzzerText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight: hasBuzzerModel ? modelsPreferredRowHeight : 0
            horizontalAlignment: Text.AlignRight
            text:"Buzzer:"
            font.pixelSize:sectionItemFontSize
            visible: hasBuzzerModel
        }

        Button{
            id:buzzerButton
            Layout.preferredHeight: hasBuzzerModel ? 18 : 0
            Layout.bottomMargin: 10
            text:"buzz"
            implicitWidth: 50
            visible: hasBuzzerModel
            Layout.columnSpan: 3


            contentItem: Text {
                text: buzzerButton.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                font.pixelSize: 12
                opacity: enabled ? 1.0 : 0.3
                color: buzzerButton.down ? "white" : "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 50
                color: buzzerButton.down ? "dimgrey" : "grey"
                border.width: 1
                border.color:buzzerButton.down ? "grey" : "black"
                radius: 10
            }

            onClicked:{
                //send a message to the object group to buzz
                console.log("buzz");
            }
        }


        Text{
            id:vibrationText
            width:100
            Layout.fillWidth: true
            Layout.preferredHeight: hasVibrationModel ? modelsPreferredRowHeight : 0
            horizontalAlignment: Text.AlignRight
            text:"Vibration:"
            font.pixelSize:sectionItemFontSize
            visible: hasVibrationModel
        }
        Button{
            id:vibrationButton
            Layout.preferredHeight: hasVibrationModel ? 18 : 0
            Layout.bottomMargin: 10
            text:"vibrate"
            implicitWidth: 60
            visible: hasVibrationModel
            Layout.columnSpan: 3


            contentItem: Text {
                text: vibrationButton.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -1
                font.pixelSize: 12
                opacity: enabled ? 1.0 : 0.3
                color: vibrationButton.down ? "white" : "black"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                color: vibrationButton.down ? "dimgrey" : "grey"
                border.width: 1
                border.color:vibrationButton.down ? "grey" : "black"
                radius: 10
            }

            onClicked:{
                //send a message to the object group to buzz
                console.log("vibrate");
            }
        }


    }


    Text{
        id:nodeTypeText
        anchors.top:modelColumn.bottom
        anchors.topMargin: 10
        anchors.left:parent.left
        anchors.leftMargin:leftMargin
        text:"NodeType:"
        font.pixelSize:18
    }
    ColumnLayout {
        id:nodeTypeColumn
        anchors.left:nodeTypeText.right
        anchors.leftMargin: 10
        anchors.top:nodeTypeText.top
        spacing: 0
        RadioButton {
            Layout.preferredHeight: modelsPreferredRowHeight
            checked: true
            text: qsTr("Relay")
            font.pixelSize: sectionItemFontSize
        }
        RadioButton {
            Layout.preferredHeight: modelsPreferredRowHeight
            text: qsTr("Friend")
            font.pixelSize: sectionItemFontSize
        }

    }


    Button{
        id:closeButton
        anchors.bottom:parent.bottom
        anchors.bottomMargin: 20
        anchors.horizontalCenter: parent.horizontalCenter
        height:30
        text:"close"
        font.pixelSize:18

        contentItem: Text {
            text: closeButton.text
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -1
            font.pixelSize: 24
            opacity: enabled ? 1.0 : 0.3
            color: closeButton.down ? "red" : "black"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        background: Rectangle {
            implicitWidth: 80
            color: "grey"
            border.width: 1
            border.color:"darkgrey"
            radius: 10
        }

        onClicked:{
            parent.visible = false
        }
    }


}
