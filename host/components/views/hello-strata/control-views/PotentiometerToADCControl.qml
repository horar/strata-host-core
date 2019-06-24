import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 0.9

import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root

    property real minimumHeight
    property real minimumWidth

    signal zoom

    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    // UI state & notification
    property string mode:platformInterface.pot_ui_mode
    property var value: platformInterface.pot_noti

    onModeChanged: {
        sgswitch.checked = mode === "bits"
    }

    onValueChanged: {
        if (mode === "volts") {
            voltGauge.value = value.cmd_data
        }
        else {
            bitsGauge.value = value.cmd_data
        }
    }

    // hide in tab view
    property bool hideHeader: false
    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            content.anchors.top = container.top
            container.border.width = 0
        }
        else {
            header.visible = true
            content.anchors.top = header.bottom
            container.border.width = 1
        }
    }

    Rectangle {
        id: container
        anchors.fill:parent
        border {
            width: 1
            color: "lightgrey"
        }

        Item {
            id: header
            anchors {
                top:parent.top
                left:parent.left
                right:parent.right
            }
            height: Math.max(name.height,btn.height)

            Text {
                id: name
                text: "<b>" + qsTr("Potentiometer") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                anchors.left: parent.left
                padding: defaultPadding

                width: parent.width - btn.width - defaultPadding
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Maximize")
                anchors {
                    top: parent.top
                    right: parent.right
                    margins: defaultMargin
                }

                height: btnText.contentHeight+6*factor
                width: btnText.contentWidth+20*factor

                contentItem: Text {
                    id: btnText
                    text: btn.text
                    font.pixelSize: 10*factor
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: zoom()
            }
        }

        Item {
            id: content
            anchors {
                top: header.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Row {
                spacing: 50

                SGSwitch {
                    id: sgswitch
                    switchHeight: 32
                    switchWidth: 65
                    label: "Volts/Bits"
                    labelLeft: false
                    checkedLabel: "Bits"
                    uncheckedLabel: "Volts"

                    onCheckedChanged: {
                        if (this.checked) {
                            if (platformInterface.pot_ui_mode !== "bits") {
                                platformInterface.pot_mode.update("bits")
                                platformInterface.pot_ui_mode = "bits"
                            }
                            bitsGauge.visible = true
                            voltGauge.visible = false
                        }
                        else {
                            if (platformInterface.pot_ui_mode !== "volts") {
                                platformInterface.pot_mode.update("volts")
                                platformInterface.pot_ui_mode = "volts"
                            }
                            voltGauge.visible = true
                            bitsGauge.visible = false
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: Math.min(content.height,content.width)*0.8
                    height: Math.min(content.height,content.width)*0.8
                    SGCircularGauge {
                        id: voltGauge
                        visible: true
                        anchors.fill: parent
                        unitLabel: "V"
                        value: 1
                        tickmarkStepSize: 0.5
                        minimumValue: 0
                        maximumValue: 3.3
                    }
                    SGCircularGauge {
                        id: bitsGauge
                        visible: false
                        anchors.fill: parent
                        unitLabel: "Bits"
                        value: 0
                        tickmarkStepSize: 512
                        minimumValue: 0
                        maximumValue: 4096
                    }
                }

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
