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

    property var lightSizeValue: 15*factor
    property var switchHeightValue: 15*factor
    property var switchWidthValue: 25*factor
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
                text: "<b>" + qsTr("LED Driver") + "</b>"
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

            Column {
                spacing: 30*factor
                width: parent.width
                padding: defaultPadding
                anchors.verticalCenter: parent.verticalCenter

                Row {
                    id: ledcontrol
                    spacing: 60*factor

                    GridLayout {
                        rowSpacing: 5*factor
                        columnSpacing: 5*factor
                        rows: 4
                        columns: 4

                        SGSwitch {
                            id: switch1
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light1.status = this.checked ? "yellow" : "off" }
                        }

                        SGSwitch {
                            id: switch2
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light2.status = this.checked ? "yellow" : "off" }
                        }

                        SGSwitch {
                            id: switch3
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light3.status = this.checked ? "yellow" : "off" }
                        }

                        SGSwitch {
                            id: switch4
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light4.status = this.checked ? "yellow" : "off" }
                        }

                        SGSwitch {
                            id: switch5
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light5.status = this.checked ? "red" : "off" }
                        }

                        SGSwitch {
                            id: switch6
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light6.status = this.checked ? "red" : "off" }
                        }

                        SGSwitch {
                            id: switch7
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light7.status = this.checked ? "red" : "off" }
                        }

                        SGSwitch {
                            id: switch8
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light8.status = this.checked ? "red" : "off" }
                        }

                        SGSwitch {
                            id: switch9
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light9.status = this.checked ? "orange" : "off" }
                        }

                        SGSwitch {
                            id: switch10
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light10.status = this.checked ? "orange" : "off" }
                        }

                        SGSwitch {
                            id: switch11
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light11.status = this.checked ? "orange" : "off" }
                        }

                        SGSwitch {
                            id: switch12
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light12.status = this.checked ? "orange" : "off" }
                        }

                        SGSwitch {
                            id: switch13
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light13.status = this.checked ? "green" : "off" }
                        }

                        SGSwitch {
                            id: switch14
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light14.status = this.checked ? "green" : "off" }
                        }

                        SGSwitch {
                            id: switch15
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light15.status = this.checked ? "green" : "off" }
                        }

                        SGSwitch {
                            id: switch16
                            switchHeight: switchHeightValue
                            switchWidth: switchWidthValue
                            onCheckedChanged: { light16.status = this.checked ? "green" : "off" }
                        }
                    }

                    GridLayout {
                        rowSpacing: 5*factor
                        columnSpacing: 5*factor
                        rows: 4
                        columns: 4

                        SGStatusLight {
                            id: light1
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light2
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light3
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light4
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light5
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light6
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light7
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light8
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light9
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light10
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light11
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light12
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light13
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light14
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light15
                            lightSize: lightSizeValue
                        }

                        SGStatusLight {
                            id: light16
                            lightSize: lightSizeValue
                        }
                    }
                }

                Column {
                    spacing: 20
                    Row {
                        spacing: 25
                        SGRadioButtonContainer {
                            radioGroup: Column {
                                spacing: 10
                                SGRadioButton {
                                    text: "<b>" + qsTr("Blink 0") + "</b>"
                                    checked: true
                                }
                                SGRadioButton {
                                    text: "<b>" + qsTr("Blink 1") + "</b>"
                                }
                            }
                            anchors.bottom: parent.bottom
                        }

                        SGSubmitInfoBox {
                            label: "<b>" + qsTr("Frequency") + "</b>"
                            textColor: "black"
                            labelLeft: false
                            infoBoxWidth: 100
                            showButton: false
                            unit: "Hz"
                            placeholderText: "0.1 - 1000000"
                            validator: DoubleValidator {
                                bottom: 0.1
                                top: 1000000
                            }
                            anchors.bottom: parent.bottom
                        }

                        SGSubmitInfoBox {
                            label: "<b>" + "PWM" + "</b>"
                            textColor: "black"
                            labelLeft: false
                            infoBoxWidth: 60
                            showButton: false
                            unit: "%"
                            placeholderText: "0 - 100"
                            validator: DoubleValidator {
                                bottom: 0
                                top: 100
                            }
                            anchors.bottom: parent.bottom
                        }
                    }

                    Row {
                        spacing: 20
                        Button {
                            id: applybtn
                            text: qsTr("Apply")
                            anchors.bottom: parent.bottom
                        }

                        Button {
                            id: resetbtn
                            text: qsTr("Reset")
                            anchors.bottom: parent.bottom
                            onClicked: {
                                switch1.checked = false
                                switch2.checked = false
                                switch3.checked = false
                                switch4.checked = false
                                switch5.checked = false
                                switch6.checked = false
                                switch7.checked = false
                                switch8.checked = false
                                switch9.checked = false
                                switch10.checked = false
                                switch11.checked = false
                                switch12.checked = false
                                switch13.checked = false
                                switch14.checked = false
                                switch15.checked = false
                                switch16.checked = false
                            }
                        }
                    }
                }
            }
        }
    }
}
