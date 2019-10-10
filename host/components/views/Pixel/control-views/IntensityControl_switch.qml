import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.7
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    width: parent.width
    height: parent.height

    property var check_system_init_status: platformInterface.system_init_status.init_state
    onCheck_system_init_statusChanged: {
        if (check_system_init_status === "OK"){
            sgSwitch_auto_addr.enabled = false
            platformInterface.system_init.update()
            platformInterface.pxn_autoaddr.update(1)
            platformInterface.auto_addr_enable_state = true
            sgSwitch_auto_addr.enabled = true
        }
    }

    property bool auto_addr_sw_status: platformInterface.auto_addr_enable_state
    onAuto_addr_sw_statusChanged: {

        if(auto_addr_sw_status === false){
            platformInterface.buck1_enable_state = false
            platformInterface.buck2_enable_state = false
            platformInterface.buck3_enable_state = false
            platformInterface.buck4_enable_state = false
            platformInterface.buck5_enable_state = false
            platformInterface.buck6_enable_state = false

            platformInterface.boost_enable_state = false

            platformInterface.buck1_led_state = false
            platformInterface.buck2_led_state = false
            platformInterface.buck3_led_state = false
            platformInterface.buck4_led_state = false
            platformInterface.buck5_led_state = false
            platformInterface.buck6_led_state = false

            platformInterface.set_boost_enable.update(0)

        }else {
            platformInterface.boost_enable_state = true
            platformInterface.buck1_enable_state = true
            platformInterface.buck2_enable_state = true
            platformInterface.buck3_enable_state = true

            platformInterface.set_boost_enable.update(1)
            platformInterface.set_buck_enable.update(1,1)
            platformInterface.set_buck_enable.update(2,1)
            platformInterface.set_buck_enable.update(3,1)

        }
    }

    property var auto_addr_status: platformInterface.auto_addressing.state
    onAuto_addr_statusChanged: {

        if(auto_addr_status === "config_OK") {
            sgStatusLight.status = "green"
            sgSwitch_auto_addr.enabled = true
            platformInterface.auto_addr_enable_state = true
        }else if (auto_addr_status === "config_NG"){
            sgStatusLight.status = "red"
            platformInterface.auto_addr_enable_state = false
        }else {
            sgStatusLight.status = "off"
            platformInterface.auto_addr_enable_state = false
            sgSwitch_auto_addr.enabled = true
        }
    }

    RowLayout{
        anchors.fill: parent
        Rectangle{
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height-130
            color: "transparent"

            Rectangle{
                id: last
                width: parent.width/3
                height: parent.height/1.08
                color: "transparent"
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                RowLayout{

                    width: parent.width/4
                    height:parent.height/4
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    SGSwitch {
                        id: sgSwitch_auto_addr
                        label: "Auto addressing ON"
                        Layout.alignment: Qt.AlignCenter
//                        enabled:false
                        checked: platformInterface.auto_addr_enable_state

                        onToggled: {
                            if(checked) {
                                platformInterface.system_init.update()
                                platformInterface.pxn_autoaddr.update(1)
                                platformInterface.auto_addr_enable_state = true
                                sgSwitch_auto_addr.enabled = false
                            } else {
                                platformInterface.pxn_autoaddr.update(0)
                                sgStatusLight.status = "off"
                                platformInterface.auto_addr_enable_state = false
                                sgSwitch_auto_addr.enabled = false
                            }
                            platformInterface.auto_addr_enable_state = checked
                        }
                    }
                    Rectangle{
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignHCenter
                        Layout.fillWidth: true
                        Layout.leftMargin: 10
                        color: "transparent"

                        SGStatusLight {
                            id: sgStatusLight
                            status: "off"           // Default: "off" (other options: "green", "yellow", "orange", "red")
                            anchors.centerIn: parent
                            lightSize: 50
                        }
                    }
                }
            }
        }
        Component.onCompleted:  {
            Help.registerTarget(sgSwitch_auto_addr, "Auto Addressing start when switch is turned on. Also Boost and Buck Enable are controlled automatically by GUI so LED are flusing seveal times. After Auto Addressing finish, all enable switches can select", 0, "Help3")
            Help.registerTarget(sgStatusLight, "LED indicator for Auto addressing, LED becomes green after auto addressing procedure finished.", 1, "Help3")
        }
    }
}


