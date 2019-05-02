import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import "../sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000

    contentItem: Rectangle {
        id: container
        anchors {
            fill: parent
        }
        color: "#DDA"

        Rectangle {
            color: "transparent"
            opacity: .25
            anchors {
                centerIn: parent
            }
            width: minimumWidth
            height: minimumHeight
            border {
                width: 1
                color: "#000"
            }

            Text {
                color:"#000"
                text: "This rectangle represents the minimum height and width of this UI before it degrades to a scrollview"
            }
        }

        Text {
            id: name
            text: "Basic Control View"
            font {
                pixelSize: 60
            }
            color:"white"
            anchors {
                centerIn: parent
            }
        }

        Component.onCompleted: {
            Help.registerTarget(motorSwitch, "This switch's state is set by platform notification and also can send platform commands. It is also sync'ed across Basic and Advanced control views.", 1, "controlHelp")
        }

        SGSwitch {
            id: motorSwitch
            anchors {
                top: name.bottom
                horizontalCenter: name.horizontalCenter
            }
            label: "Motor On/Off"

            // 'checked' state is bound to and sets the
            // _motor_running_control property in PlatformInterface
            checked: platformInterface._motor_running_control
            onCheckedChanged: platformInterface._motor_running_control = checked
        }

        SGCircularGauge {
            id: speedGauge
            anchors {
                top: motorSwitch.bottom
                horizontalCenter: name.horizontalCenter
            }
            height: 200
            width: 200

            value: platformInterface._motor_speed
        }
    }
}



