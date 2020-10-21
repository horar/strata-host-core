import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: intensitycontrol
    property var sgSwitch_label: "<b>Watch Dog<br>Off</b>"  // YI
    property var sgSwitch_off: false // default value the switch is off

    SGAccordion {
        id: accordion
        anchors.fill: parent

        accordionItems: Column {
            SGAccordionItem {
                id: led1
                title: "<b>LED1 String Dimming</b>"
                open: true
                contents: IntensityControl_led1 {
                    height: text1.contentHeight + 300
                    width: parent.width

                    Text {
                        id: text1
                        anchors.fill: parent
                    }
                }
            }

            SGAccordionItem {
                id: led2
                title: "<b>LED2 String Dimming</b>"
                contents: IntensityControl_led2 {
                    height: text2.contentHeight + 300
                    width: parent.width

                    Text {
                        id: text2
                        anchors.fill: parent
                    }
                }
            }

            SGAccordionItem {
                id: led3
                title: "<b>LED3 String Dimming</b>"
                contents: IntensityControl_led3 {
                    height: text3.contentHeight + 300
                    width: parent.width

                    Text {
                        id: text3
                        anchors.fill: parent
                    }
                }
            }


            SGAccordionItem {
                id: led4
                title: "<b></b>"
                open: true
                contents: IntensityControl_switch {
                    id: intensityControl_switch
                    height: text4.contentHeight +200
                    width: parent.width

                    property var sgSwitch_label: intensitycontrol.sgSwitch_label
                    onSgSwitch_labelChanged: {
                        sgSwitch_wd.label = sgSwitch_label
                    }
                    property var sgSwitch_off: intensitycontrol.sgSwitch_off
                    onSgSwitch_offChanged: {
                        sgSwitch_wd.checked = sgSwitch_off
                    }

                    Text {
                        id: text4
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
