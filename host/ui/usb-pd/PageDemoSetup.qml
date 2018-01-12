import QtQuick 2.0

Item {
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"


    }
    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "./images/icons/onLogoGreenWithText.png"
    }

    Text {
        text:"PD + Redriver Demo Setup"
        horizontalAlignment: Text.AlignHCenter
        font.family: "Helvetica"
        font.pointSize: 36
        color: "grey"
        anchors{ left: parent.left;
            right: parent.right;
            top: parent.top;
            topMargin: parent.height/10
        }
    }

    Image {
        //anchors.fill: parent

        fillMode: Image.PreserveAspectFit
        anchors { fill:parent }
        //anchors { centerIn: parent; }
        source: "./images/demoSetup.png"
    }

}
