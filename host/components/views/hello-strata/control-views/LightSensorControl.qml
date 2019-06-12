import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660*0.4
    minimumWidth: 850/3

    signal zoom

    property var defaultMargin: 20
    property var defaultPadding: 20
    property var factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)

    Rectangle {
        id: container
        parent: root.contentItem
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
                text: "<b>" + qsTr("Light Sensor") + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                anchors.left: parent.left
                padding: defaultPadding

                width: parent.width - btn.width - defaultPadding
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                text: qsTr("Zoom")
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
                top:header.bottom
                bottom: parent.bottom
                left:parent.left
                right:parent.right
            }

            Row {
                spacing: 10

                SGLabelledInfoBox {
                    label: "<b>" + "Lux (lx)" + "</b>"
                    labelLeft: false
                    info: "800"
                }
                Column {
                    spacing: 10

                    Row {
                        spacing: 35

                        Column {
                            spacing: 10

                            SGSwitch {
                                label: "<b>" + qsTr("Sleep/Active") + "</b>"
                                labelLeft: false
                                checkedLabel: qsTr("Active")
                                uncheckedLabel: qsTr("Sleep")
                            }

                            SGSwitch {
                                label: "<b>" + qsTr("Start/Stop") + "</b>"
                                labelLeft: false
                                checkedLabel: qsTr("Start")
                                uncheckedLabel: qsTr("Stop")
                            }
                        }

                        SGComboBox {
                            label: "<b>" + qsTr("Integration Time") + "</b>"
                            labelLeft: false
                            model: ["12.5ms", "100ms", "200ms", "Manual"]
                            comboBoxWidth: 100
                        }

                        SGComboBox {
                            label: "<b>" + qsTr("Gain") + "</b>"
                            labelLeft: false
                            model: ["0.25", "1", "2", "8"]
                            comboBoxWidth: 100
                        }
                    }

                    SGSlider {
                        label:"<b>" + qsTr("Sensitivity") + "</b>"
                        textColor: "black"
                        labelLeft: false
                        width: root.width*0.7
                        stepSize: 0.01
                        from: 66.7
                        to: 150
                        startLabel: "66.7%"
                        endLabel: "150%"
                        toolTipDecimalPlaces: 2
                    }
                }
                anchors {
                    top: name.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
