import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    Button {
        id: button
        x: 10
        y: 164
        width: 151
        height: 131
        text: qsTr("Left Button")
        font.pointSize: 24
    }

    Button {
        id: button1
        x: 236
        y: 164
        width: 169
        height: 131
        text: qsTr("Center Button")
        font.pointSize: 24
    }

    Button {
        id: button2
        x: 474
        y: 164
        width: 154
        height: 131
        text: qsTr("Right Button")
        font.pointSize: 24
    }

    Popup {
            id: popup
            x: 100
            y: 100
            width: 438
            height: 293
            opacity: 0.8
            modal: true
            focus: true
            dim : true
            property int openx
            property int openy

            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

            enter:Transition {
                    NumberAnimation { target: popup; property: "x"; from: popup.openx; to: popup.x; duration: 500 }
                    NumberAnimation { target: popup; property: "y"; from: popup.openy; to: popup.y; duration: 500 }
                    NumberAnimation { target: popup; property: "width"; from: 0; to: popup.width; duration: 500 }
                    NumberAnimation { target: popup; property: "height"; from: 0; to: popup.height; duration: 500 }
                }

            exit: Transition {
                    NumberAnimation { target: popup; property: "x"; from: popup.x; to: popup.openx; duration: 500 }
                    NumberAnimation { target: popup; property: "y"; from: popup.y; to: popup.openy; duration: 500 }
                    NumberAnimation { target: popup; property: "width"; from: popup.width; to: 0; duration: 500 }
                    NumberAnimation { target: popup; property: "height"; from: popup.height; to: 0; duration: 500 }
                }

            onClosed:{
                //reset the values for popup size (since they were overwritten in on exit)
                popup.x = 100
                popup.y = 100
                popup.width = 438
                popup.height =  293
                }

        }

    Connections {
        target: button
        onClicked: {
            popup.openx = button.x + button.width/2
            popup.openy = button.y + button.height/2
            //console.log("x is ", popup.openx, "y is ", popup.openy, "width=", popup.width, "height=", popup.height)
            popup.open()
        }
    }

    Connections {
        target: button1
        onClicked: {
            popup.openx = button1.x + button1.width/2
            popup.openy = button1.y + button1.height/2
            popup.open()
        }
    }

    Connections {
        target: button2
        onClicked: {
            popup.openx = button2.x + button2.width/2
            popup.openy = button2.y + button2.height/2
            popup.open()
        }
    }

}
