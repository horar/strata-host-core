import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import "framework"

Item {

    Label{
        id: signalLossLabel
        anchors {verticalCenter:buttonRow.verticalCenter
                  right: buttonRow.left
                  rightMargin: 10
        }
        horizontalAlignment: Text.AlignRight
        font.family: "helvetica"
        font.pointSize: 24
        text:"Signal Loss:"
    }

    ButtonGroup {
        buttons: buttonRow.children
        onClicked: {

        }
    }

    Row {
        id:buttonRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/4

        SGLeftSegmentedButton{width: 100; text:"3 dB" }
        SGMiddleSegmentedButton{width: 100; text:"6 dB" }
        SGRightSegmentedButton{width: 100; text:"9 dB"}
    }

    Text{
        anchors.centerIn: parent
        font.family: "helvetica"
        font.pointSize: 72
        text: "Data Path"
    }

    Label{
        id: statusLabel
        anchors {verticalCenter:statusIndicator.verticalCenter
                  right: signalLossLabel.right
        }
        horizontalAlignment: Text.AlignRight
        font.family: "helvetica"
        font.pointSize: 24
        text:"Status:"
    }

    Rectangle{
        id:statusIndicator
        color:"red"
        height:70
        width:70
        radius: 35
        anchors{bottom:parent.bottom
                bottomMargin: parent.height/8
                left: buttonRow.left
        }
    }

    Label{
        id:statusMessage
        font.family: "helvetica"
        font.pointSize: 24
        color:"red"
        text:"Please flip the connection to port 1"
        anchors{verticalCenter: statusLabel.verticalCenter
                left: statusIndicator.right
                leftMargin: 15
        }
    }
}
