import QtQuick 2.9
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import tech.strata.sgwidgets 0.9
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: intensitycontrol
    property string sgSwitch_label: "<b>Watch Dog Off</b>"  // YI
    property bool sgSwitch_off: false // default value the switch is off
    onSgSwitch_labelChanged: {
        intensityControl_switch.sgSwitch_wd.label = sgSwitch_label
        console.info(sgSwitch_label)
    }

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
                    sgSwitch_wd.label: sgSwitch_label  // YI
                    sgSwitch_wd.checked: sgSwitch_off

                    Text {
                        id: text4
                        anchors.fill: parent
                    }
                }
            }
        }
    }
}
