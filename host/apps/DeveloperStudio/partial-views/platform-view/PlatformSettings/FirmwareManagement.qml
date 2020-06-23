import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: firmwareColumn

    Component.onCompleted: {
        //coreInterface.getFirmwareInfo(deviceId) // cmd to be sent when board selected
        //
        // then..
        //
        // list here is based on to-make firmwareManager like documentManager

    }

    Text {
        text: "Firmware Settings:"
        font.bold: true
        font.pixelSize: 18
    }

    Rectangle {
        color: "#aaa"
        Layout.fillWidth: true
        Layout.preferredHeight: 1
    }

    RowLayout {
        id: disconnectedFirmware
        spacing: 10
        Layout.topMargin: 10
        visible: !window.connected

        SGIcon {
            id: disconnectedIcon
            source: "qrc:/sgimages/disconnected.svg"
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            iconColor: "#aaa"
        }

        Text {
            text: "Connect this platform to manage its firmware"
            font.bold: true
            font.pixelSize: 18
            color: disconnectedIcon.iconColor
        }
    }

    ColumnLayout {
        id: connectedFirmwareColumn
        visible: window.connected
        Layout.topMargin: 10

        Text {
            text: "Detected firmware version:"
            font.bold: false
            font.pixelSize: 18
            color: "#666"
        }

        Text {
            text: "Logic Gates v"+ root.firmwareVersion + ", released " + root.firmwareDate
            font.bold: true
            font.pixelSize: 18
        }

        Text {
            text: "Firmware versions available:"
            Layout.topMargin: 10
            font.pixelSize: 18
            color: "#666"
        }

        Rectangle {
            id: firmwareHeader
            Layout.preferredHeight: 20
            Layout.fillWidth: true
            color: "#eee"

            RowLayout {
                width: parent.width
                anchors {
                    verticalCenter: parent.verticalCenter
                }
                spacing: 30

                Text {
                    text: "Version"
                    font.italic: true
                    Layout.preferredWidth:60
                    Layout.leftMargin: 5
                }

                Text {
                    text: "Date Released"
                    font.italic: true
                    Layout.fillWidth: true
                }
            }
        }

        Repeater {
            width: parent.width
            model: firmwareVersions

            delegate: Rectangle {
                Layout.preferredHeight: column.height
                Layout.fillWidth: true

                ColumnLayout {
                    id: column
                    anchors.centerIn: parent
                    width: parent.width

                    RowLayout {
                        Layout.margins: 10
                        spacing: 30

                        Text {
                            text: model.version
                            Layout.preferredWidth: 60
                            font.pixelSize: 18
                            color: "#666"
                        }

                        Text {
                            text: model.timestamp
                            Layout.fillWidth: true
                            font.pixelSize: 18
                            color: "#666"
                        }

                        SGIcon {
                            source: model.installed ? "qrc:/sgimages/check-circle-solid.svg" : "qrc:/sgimages/download-solid.svg"
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                            iconColor: model.installed ? "lime" : "#666"

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: model.installed ? Qt.ArrowCursor : Qt.PointingHandCursor

                                onClicked: {
                                    warningPop.delegateDownload = download
                                    warningPop.open()
                                }
                            }
                        }
                    }

                    Item {
                        id: download
                        visible: false
                        Layout.fillWidth: true
                        Layout.preferredHeight: downloadColumn.height

                        ColumnLayout {
                            id: downloadColumn
                            width: parent.width

                            Text {
                                Layout.leftMargin: 10
                                property real percent: fillBar.width/barBackground.width
                                text: {
                                    if (percent < .6) {
                                        return "Downloading: " + (percent * 166.66).toFixed(0) + "%"
                                    } else if (percent < .8) {
                                        return "Flashing Firmware..."
                                    } else if (percent < 1) {
                                        return "Validating Firmware..."
                                    } else if (percent >= 1){
                                        for (let i = 0; i < firmwareVersions.count; i++) {
                                            firmwareVersions.get(i).installed = false
                                        }
                                        root.firmwareVersion = model.version
                                        model.installed = true
                                        download.visible = false
                                        return "Complete"
                                    }
                                }
                            }

                            Rectangle {
                                id: barBackground
                                color: "grey"
                                Layout.preferredHeight: 8
                                Layout.fillWidth: true
                                clip: true

                                Rectangle {
                                    id: fillBar
                                    color: "lime"
                                    height: barBackground.height
                                    width: 0
                                    onVisibleChanged: {
                                        if (visible)
                                            timer.start()
                                    }

                                    Timer {
                                        id: timer
                                        interval: 16
                                        running: false
                                        repeat: true

                                        property bool downloadDone: false

                                        onTriggered: {
                                            if (fillBar.width < barBackground.width *.6) {
                                                fillBar.width +=3
                                                return
                                            } else if (fillBar.width < barBackground.width ) {
                                                interval = 3000
                                                if(downloadDone){
                                                    fillBar.width += barBackground.width *.2
                                                }
                                                downloadDone = true
                                                return
                                            }
                                            repeat = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: firmwareVersions

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.0.0"
            installed: false
        }

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.1.1"
            installed: false
        }

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.2.2"
            installed: true
        }
    }
}
