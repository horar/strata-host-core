import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.sgwidgets 1.0

import "qrc:/js/help_layout_manager.js" as Help

SGResponsiveScrollView {
    id: root

    minimumHeight: 660*0.3
    minimumWidth: 850/3

    signal zoom

    property var defaultMargin: 20
    property var defaultPadding: 20
    property var factor: Math.min(root.height/minimumHeight,root.width/minimumWidth)
    property bool hideHeader: false

    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            content.anchors.top = container.top
        }
        else {
            header.visible = true
            content.anchors.top = header.bottom
        }
    }

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
                text: "<b>" + qsTr("PWM Heat Generator") + "</b>"
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
                top:header.bottom
                bottom: parent.bottom
                left:parent.left
                right:parent.right
            }

            Row {
                spacing: defaultPadding
                height: parent.height
                padding: defaultPadding

                Column {
                    spacing: defaultPadding
                    SGSlider {
                        id: pwmslider
                        label:"<b>" + qsTr("PWM Positive Duty Cycle (%)") + "</b>"
                        textColor: "black"
                        labelLeft: false
                        width: content.width*0.4
                        stepSize: 0.01
                        from: 0
                        to: 100
                        startLabel: "0"
                        endLabel: "100 %"
                        toolTipDecimalPlaces: 2
                    }

                    SGStatusLight {
                        id: alertLED
                        label: "<b>" + qsTr("OS/ALERT") + "</b>"
                    }

                    anchors.verticalCenter: parent.verticalCenter
                }

                SGCircularGauge {
                    id: gauge
                    width: Math.min(content.height,content.width)*0.8
                    height: Math.min(content.height,content.width)*0.8
                    unitLabel: "C"
                    value: 30
                    tickmarkStepSize: 10
                    minimumValue: -55
                    maximumValue: 125
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
