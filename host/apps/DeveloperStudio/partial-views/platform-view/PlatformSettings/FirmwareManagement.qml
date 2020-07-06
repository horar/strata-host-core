import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0
import "FirmwareManager.js" as FirmwareManager

ColumnLayout {
    id: firmwareColumn

    property Item activeFirmware: null

    Component.onCompleted: {
        loadFirmware()
    }

    Connections {
        target: coreInterface
        onFirmwareInfo: {
            // todo: merge this with CS-681 to pick up device id
            // if (message.device_id == platformStack.device_id) {
            FirmwareManager.parseFirmwareInfo(payload)
            // }
        }
        onFirmwareProgress: {
            // if (message.device_id == platformStack.device_id) {
            activeFirmware.parseProgress(payload)
            // }
        }
    }

    Connections {
        target: platformStack
        onConnectedChanged: {
            loadFirmware()
        }
    }

    function loadFirmware() {
        // todo: merge this with CS-681 to pick up device id
        //        if (platformStack.connected && FirmwareManager.firmwareListModel.status === "initialized") {
        //            coreInterface.getFirmwareInfo(platformStack.deviceId)
        FirmwareManager.firmwareListModel.status = "loading"
        //        }
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
        visible: !platformStack.connected

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
        visible: platformStack.connected
        Layout.topMargin: 10

        RowLayout {
            spacing: 10

            AnimatedImage {
                id: loaderImage
                height: 40
                width: 40
                playing: FirmwareManager.firmwareListModel.status !== "loaded"
                visible: playing
                source: "qrc:/images/loading.gif"
                opacity: .25

                BrightnessContrast {
                    anchors.fill: loaderImage
                    source: loaderImage
                    brightness: -.5
                }
            }

            Text {
                text: {
                    switch (FirmwareManager.firmwareListModel.status) {
                    case "loading":
                        return "Detecting device firmware version..."
                    case "loaded":
                        return "Device firmware version:"
                    default:
                        return "Initializing..."
                    }
                }
                font.bold: false
                font.pixelSize: 18
                color: "#666"
            }
        }

        Text {
            text: "v " + FirmwareManager.firmwareListModel.deviceVersion + ", released " + FirmwareManager.firmwareListModel.deviceTimestamp
            font.bold: true
            font.pixelSize: 18
            visible: FirmwareManager.firmwareListModel.status === "loaded"
        }

        ColumnLayout{
            id: firmwareVersions
            visible: FirmwareManager.firmwareListModel.status === "loaded"

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
                id: firmwareRepeater
                model: FirmwareManager.firmwareListModel
                width: parent.width

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
                                    enabled: model.installed === false

                                    onClicked: {
                                        // if (version < installed version)
                                        // warningPop.delegateDownload = download
                                        // warningPop.open()
                                        // todo hook up when device_id works
                                        console.log("DEVICE:", platformStack.device_id)
                                        let updateFirmwareCommand = {
                                            "hcs::cmd": "update_firmware",
                                            "payload": {
                                                "device_id": platformStack.device_id,
                                                "path": "201/fab/351bf129b05fb37797c8d8f0c1e16db5.bin", //model.file,
                                                "md5": "351bf129b05fb37797c8d8f0c1e16db5"//model.md5
                                            }
                                        }
                                        coreInterface.sendCommand(JSON.stringify(updateFirmwareCommand));
                                        flashStatus.visible = true
                                        activeFirmware = flashStatus
                                    }
                                }
                            }
                        }

                        Item {
                            id: flashStatus
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: statusColumn.height

                            function parseProgress (payload) {
                                console.log("RECEIVED PROGRESS", JSON.stringify(payload))
                                switch (payload.operation) {
                                case "download":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "" + (100 * (payload.complete / payload.total)).toFixed(0) + "% downloaded"
                                        fillBar.width = (barBackground.width * .5) * (payload.complete / payload.total)
                                        break;
                                    }
                                    break;
                                case "prepare":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Preparing..."
                                        fillBar.width = barBackground.width * (5/8)
                                        break;
                                    }
                                    break;
                                case "backup":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Backing up firmware..."
                                        fillBar.width = barBackground.width * (6/8)
                                        break;
                                    }
                                    break;
                                case "flash":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Flashing firmware..."
                                        fillBar.width = barBackground.width * (7/8)
                                        break;
                                    }
                                    break;
                                case "restore":
                                    break;
                                case "finished":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Firmware installation complete"
                                        fillBar.width = barBackground.width
                                        for (let i = 0; i < FirmwareManager.firmwareListModel.count; i++) {
                                            FirmwareManager.firmwareListModel.get(i).installed = false
                                        }
                                        // todo: rather than set UI like this, reset firmwareListModel and re-query getFirmwareInfo from HCS???
                                        FirmwareManager.firmwareListModel.deviceVersion = model.version
                                        FirmwareManager.firmwareListModel.deviceTimestamp = model.timestamp
                                        model.installed = true
                                        flashStatus.visible = false
                                        break;
                                    }
                                    break;
                                default:
                                    break;
                                }
                            }

                            ColumnLayout {
                                id: statusColumn
                                width: parent.width

                                Text {
                                    id: statusText
                                    Layout.leftMargin: 10
                                    property real percent: fillBar.width/barBackground.width
                                    text: "Initializing..."
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
