import QtQuick 2.0

Item {
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"

        // PROOF OF CONCEPT BANNER
//        Rectangle {
//            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
//            width: parent.width * 0.70; height: 30;
//            color: "red"
//            radius: 4
//            Label {
//                anchors { centerIn: parent }
//                text: "SPYGLASS PROOF OF CONCEPT WITH LAB CLOUD"
//                color: "white"
//                font.bold: true
//            }
//        }
    }
    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "./images/icons/onLogoGreenWithText.png"
    }
    Text{
        font.family: "helvetica"
        font.pointSize: 29
        text:"PD + Redriver Demo Setup"
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 50 }
        z: 2
    }
    Image {
        //anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        anchors { /*centerIn: parent;*/ top: parent.top; topMargin: 130 }
        source: "./images/CES_Demo_Setup.PNG"
    }

}
