import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/help_layout_manager.js" as Help

Widget09.SGResponsiveScrollView {
    id: root

    minimumHeight: 800
    minimumWidth: 1000
    scrollBarColor: "gray"
    Component.onCompleted: {
        Help.registerTarget(name, "Place holder for Advanced control view help messages", 0, "AdvanceControlHelp")
    }

    Item {
        id: container
        parent: root.contentItem
        anchors {
            fill: parent
        }

        Text {
            id: name
            width: contentWidth
            height: contentHeight
            text: "Advanced view Control Tab or Other Supporting Tabs: \nShould be used for more detailed UI implementations such as register map tables or advanced functionality. \nTake the idea of walking the user into evaluating the board by ensuring the board is instantly functional \nwhen powered on and then dive into these advanced features."
            font {
                pixelSize: 20
            }
            anchors {
                centerIn: parent
            }
        }

//        SGAlignedLabel {
//            id: motorSwitchLabel
//            target: motorSwitch
//            text: "Motor On/Off"
//            anchors {
//                top: name.bottom
//                horizontalCenter: name.horizontalCenter
//            }
//            alignment: SGAlignedLabel.SideTopCenter

//            SGSwitch {
//                id: motorSwitch
//                width: 50
//                checked: basic.io.checked
//                onCheckedChanged: {
//                    basic.io.checked = checked

//                    // basic.firstCommand.text = JSON.stringify(basic.my_cmd_simple_obj,null,4)
//                }

//                // 'checked' state is bound to and sets the
//                // _motor_running_control property in PlatformInterface
//                //checked: platformInterface._motor_running_control
//                //onCheckedChanged: platformInterface._motor_running_control = checked
//            }
//        }
    }
}



