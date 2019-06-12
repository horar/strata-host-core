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
                text: "<b>" + qsTr("Potentiometer to ADC") + "</b>"
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
                top: header.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            Row {
                spacing: 50

                SGSwitch {
                    switchHeight: 15*factor
                    switchWidth: 25*factor
                    onCheckedChanged: {
                        if (this.checked) {
                            gauge.unitLabel = ""
                            gauge.value = 0
                            gauge.tickmarkStepSize = 512
                            gauge.minimumValue = 0
                            gauge.maximumValue = 4096
                        }
                        else {
                            gauge.unitLabel = "v"
                            gauge.value = 1
                            gauge.minimumValue = 0
                            gauge.maximumValue = 3.3
                            gauge.tickmarkStepSize = 0.5
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }

                SGCircularGauge {
                    id: gauge
                    width: Math.min(content.height,content.width)*0.8
                    height: Math.min(content.height,content.width)*0.8
                    unitLabel: "v"
                    value: 1
                    tickmarkStepSize: 0.5
                    minimumValue: 0
                    maximumValue: 3.3
                }

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
