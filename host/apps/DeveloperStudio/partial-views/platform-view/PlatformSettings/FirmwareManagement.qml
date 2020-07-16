import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: firmwareColumn

    property Item activeFirmware: null
    property bool flashingInProgress: false

    Component.onCompleted: {
        loadFirmware()
    }

    function spoofCommand() {  // TODO REMOVE
        let notification = JSON.stringify({
                                              "hcs::notification":{
                                                  "type":"firmware_info",
                                                  "list":[
                                                      {
                                                          "file": "201/fab/351bf129b05fb37797c8d8f0c1e16db5.bin", /// file from DP
                                                          "md5": "351bf129b05fb37797c8d8f0c1e16db5",
                                                          "name": "firmware",
                                                          "timestamp": "2019-11-04 17:16:48 -DP",
                                                          "version": "1.1.0"
                                                      },
                                                      {
                                                          "file": "72ddcc10-2d18-4316-8170-5223162e54cf/logic-gates-debug-1.0.0.bin", // file on local docker
                                                          "md5": "c235b03d6e0621357c16c49fa5219dac",
                                                          "name": "firmware",
                                                          "timestamp": "2019-11-04 17:16:48",
                                                          "version": "1.0.0"
                                                      },
                                                      {
                                                          "file": "72ddcc10-2d18-4316-8170-5223162e54cf/logic-gates-debug-1.0.1.bin", // file on local docker
                                                          "md5": "6cab6d69f38b582bda638fe6fb512ba8",
                                                          "name": "firmware",
                                                          "timestamp": "2020-11-04 17:16:48",
                                                          "version": "1.0.1"
                                                      },
                                                  ],
                                                  "device_id": platformStack.device_id
                                              }
                                          })
        coreInterface.spoofCommand(notification)
    }

    Connections {
        target: coreInterface
        onFirmwareInfo: {
            if (payload.device_id === platformStack.device_id) {
                parseFirmwareInfo(payload)
            }
        }
        onFirmwareProgress: {
            if (payload.device_id === platformStack.device_id) {
                activeFirmware.parseProgress(payload)
            }
        }
    }

    Connections {
        target: platformStack
        onConnectedChanged: {
            loadFirmware()
        }
        onFirmware_versionChanged: {
            for (let i = 0; i < firmwareListModel.count; i++) {
                let firmware = firmwareListModel.get(i)
                if (firmware.version === platformStack.firmware_version) {
                    firmware.installed = true
                } else {
                    firmware.installed = false
                }
            }
        }
    }

    function loadFirmware() {
        // todo: merge this with CS-681 to pick up device id
        //        if (platformStack.connected && firmwareListModel.status === "initialized") {
        //            coreInterface.getFirmwareInfo(platformStack.deviceId)
        firmwareListModel.status = "loading"
        spoofCommand() // TODO REMOVE
        //        }
    }

    function parseFirmwareInfo (firmwareInfo) {
        firmwareListModel.clear()

        for (let i = 0; i < firmwareInfo.list.length; i++) {
            let firmware = firmwareInfo.list[i]
            if (firmware.version === platformStack.firmware_version) {
                firmware.installed = true
            } else {
                firmware.installed = false
            }

            firmwareListModel.append(firmware)
        }

        if (firmwareListModel.count > 0) {
            firmwareListModel.status = "loaded"
        }
    }

    function clearDescriptions () {
        for (let i = 0; i < firmwareVersions.children.length; i++) {
            if (firmwareVersions.children[i].objectName === "firmwareRow") {
                firmwareVersions.children[i].description = ""
            }
        }
    }

    ListModel {
        id: firmwareListModel
        property int currentIndex: 0
        property string status: 'initialized'
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
                playing: firmwareListModel.status !== "loaded"
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
                    switch (firmwareListModel.status) {
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
            text: platformStack.firmware_version
            font.bold: true
            font.pixelSize: 18
            visible: firmwareListModel.status === "loaded"
        }

        ColumnLayout{
            id: firmwareVersions
            visible: firmwareListModel.status === "loaded"

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
                model: firmwareListModel
                delegate: Rectangle {
                    id: firmwareRow
                    Layout.preferredHeight: column.height
                    Layout.fillWidth: true
                    objectName: "firmwareRow"

                    property bool flashingInProgress: false
                    property alias description: description.text

                    onFlashingInProgressChanged: {
                        firmwareColumn.flashingInProgress = flashingInProgress
                    }

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

                            Text {
                                id: description
                                color: "#bbb"
                            }

                            Item {
                                id: imageContainer
                                Layout.preferredHeight: 30
                                Layout.preferredWidth: 30

                                SGIcon {
                                    id: installIcon
                                    anchors {
                                        fill: parent
                                    }
                                    source: model.installed ? "qrc:/sgimages/check-circle-solid.svg" : "qrc:/sgimages/download-solid.svg"
                                    iconColor: model.installed ? "lime" : firmwareColumn.flashingInProgress ? "#ddd" : "#666"
                                    visible: firmwareRow.flashingInProgress === false

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: model.installed || firmwareColumn.flashingInProgress ? Qt.ArrowCursor : Qt.PointingHandCursor
                                        enabled: model.installed === false && !firmwareColumn.flashingInProgress

                                        onClicked: {
                                            // if (version < installed version)
                                            // warningPop.delegateDownload = download
                                            // warningPop.open()
                                            if (firmwareColumn.flashingInProgress === false) {
                                                flashingInProgress = true
                                                flashStatus.resetState()
                                                firmwareColumn.clearDescriptions()
                                                description.text = "Do not unplug your board during this process"

                                                let updateFirmwareCommand = {
                                                    "hcs::cmd": "update_firmware",
                                                    "payload": {
                                                        "device_id": platformStack.device_id,
                                                        "path": model.file,
                                                        "md5": model.md5
                                                    }
                                                }
                                                coreInterface.sendCommand(JSON.stringify(updateFirmwareCommand));
                                                flashStatus.visible = true
                                                activeFirmware = flashStatus
                                            }
                                        }
                                    }
                                }

                                AnimatedImage {
                                    id: indicator
                                    anchors {
                                        fill: parent
                                    }
                                    source: "qrc:/images/loading.gif"
                                    visible: !installIcon.visible

                                    onVisibleChanged: {
                                        if (visible) {
                                            indicator.playing = true
                                        } else {
                                            indicator.playing = false
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            id: flashStatus
                            visible: false
                            Layout.fillWidth: true
                            Layout.preferredHeight: statusColumn.height

                            function resetState() {
                                statusText.text = "Initializing..."
                                fillBar.width = 0
                                fillBar.color = "lime"
                                flashStatus.visible = false
                                description.text = ""
                            }

                            function parseProgress (payload) {
                                switch (payload.operation) {
                                case "download":
                                    switch (payload.status) {
                                    case "running":
                                        switch (payload.total) {
                                        case -1:
                                            statusText.text = "Downloading... " + payload.complete + "bytes downloaded"
                                            fillBar.width = (barBackground.width * .25) * (payload.complete / 121528)
                                            break
                                        default:
                                            statusText.text = "Downloading... " + (100 * (payload.complete / payload.total)).toFixed(0) + "% complete"
                                            fillBar.width = (barBackground.width * .25) * (payload.complete / payload.total)
                                            break
                                        }
                                        break;
                                    case "failure":
                                        statusText.text = "Download failed: " + payload.download_error
                                        break;
                                    }
                                    break;
                                case "prepare":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Preparing..."
                                        fillBar.width = barBackground.width * .25
                                        break;
                                    case "failure":
                                        statusText.text = "Preparation failed: " + payload.prepare_error
                                        break;
                                    }
                                    break;
                                case "backup":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Backing up firmware... "
                                        switch (payload.total) {
                                        case -1:
                                            if (payload.complete > -1 ) {
                                                statusText.text += payload.complete + " chunks complete"
                                            }
                                            fillBar.width = barBackground.width * .5
                                            break
                                        default:
                                            statusText.text += (100 * (payload.complete / payload.total)).toFixed(0) + "% complete"
                                            fillBar.width = (barBackground.width * .5) + (barBackground.width * .25) * (payload.complete / payload.total)
                                            break
                                        }
                                        break;
                                    case "failure":
                                        statusText.text = "Preparation failed: " + payload.backup_error
                                        break;
                                    }
                                    break;
                                case "flash":
                                    switch (payload.status) {
                                    case "running":
                                        statusText.text = "Flashing firmware... "
                                        if (payload.total > -1) {
                                            statusText.text += "" + (100 * (payload.complete / payload.total)).toFixed(0) + "% complete"
                                            fillBar.width = (barBackground.width * .75) + (barBackground.width * .25) * (payload.complete / payload.total)
                                        } else {
                                            fillBar.width = barBackground.width * .75
                                        }
                                        break;
                                    case "failure":
                                        break;
                                    }
                                    break;
                                case "restore":
                                    // todo: need to determine this process behavior no working case for this
                                    break;
                                case "finished":
                                    switch (payload.status) {
                                    case "unsuccess":
                                    case "failure":
                                        resetState()
                                        description.text = "Firmware installation failed"

                                        let keys = Object.keys(payload)
                                        for (let j = 0; j < keys.length; j++) {
                                            if (keys[j].endsWith("_error") && payload[keys[j]] !== "") {
                                                description.text += ": " + payload[keys[j]]
                                                break;
                                            }
                                        }
                                        flashingInProgress = false
                                        break
                                    case "success":
                                        resetState()
                                        description.text = "Firmware installation succeeded"
                                        flashingInProgress = false
                                        break
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
                                    color: "#444"
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

                                    RowLayout {
                                        // Hash marks separating state progress
                                        anchors {
                                            fill: parent
                                        }

                                        Repeater {
                                            model: 4

                                            Item {
                                                Layout.fillWidth: true
                                                Layout.fillHeight: true

                                                Rectangle {
                                                    height: parent.height
                                                    width: 2
                                                    anchors {
                                                        horizontalCenter: parent.right
                                                    }
                                                    visible: index !== 3
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
        }
    }
}
