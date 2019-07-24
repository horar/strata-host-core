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
    property real lightSizeValue: 25*factor

    // notification
    property var sw1: platformInterface.mechanical_buttons_noti_sw1
    property var sw2: platformInterface.mechanical_buttons_noti_sw2
    property var sw3: platformInterface.mechanical_buttons_noti_sw3
    property var sw4: platformInterface.mechanical_buttons_noti_sw4

    onSw1Changed: {
        led1.status = sw1.value ? "green" : "off"
    }

    onSw2Changed: {
        led2.status = sw2.value ? "green" : "off"
    }

    onSw3Changed: {
        led3.status = sw3.value ? "green" : "off"
    }

    onSw4Changed: {
        led4.status = sw4.value ? "green" : "off"
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
                text: "<b>" + qsTr("Mechanical Buttons") + "</b>"
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
                spacing: 20*factor
                SGStatusLight {
                    id: led1
                    label: "<b>" + qsTr("SW1") + "</b>"
                    labelLeft: false
                    lightSize: lightSizeValue
                }
                SGStatusLight {
                    id: led2
                    label: "<b>" + qsTr("SW2") + "</b>"
                    labelLeft: false
                    lightSize: lightSizeValue
                }
                SGStatusLight {
                    id: led3
                    label: "<b>" + qsTr("SW3") + "</b>"
                    labelLeft: false
                    lightSize: lightSizeValue
                }
                SGStatusLight {
                    id: led4
                    label: "<b>" + qsTr("SW4") + "</b>"
                    labelLeft: false
                    lightSize: lightSizeValue
                }

                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
