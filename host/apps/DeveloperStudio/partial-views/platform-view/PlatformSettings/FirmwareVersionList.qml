import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: firmwareList
    spacing: 0
    Layout.topMargin: 10

    property alias firmwareRepeater: firmwareRepeater

    ColumnLayout{
        id: firmwareVersions
        visible: firmwareRepeater.model.count > 0

        Text {
            text: "Firmware versions available:"
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
                    Layout.preferredWidth:60
                    Layout.leftMargin: 5
                    text: "Version"
                    font.italic: true
                }

                Text {
                    Layout.fillWidth: true
                    text: "Date Released"
                    font.italic: true
                }
            }
        }

        Repeater {
            id: firmwareRepeater
            model: []
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
                        Layout.preferredHeight: 30
                        spacing: 30

                        Text {
                            id: versionText
                            Layout.preferredWidth: 60
                            text: model.version
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
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            color: "#bbb"
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignRight
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
                                iconColor: {
                                    if (platformStack.connected === false || firmwareColumn.flashingInProgress) {
                                        return "#ddd" // disabled - light greyed out
                                    } else if (model.installed) {
                                        return "lime"
                                    } else {
                                        return "#666" // enabled - dark grey
                                    }
                                }
                                visible: firmwareRow.flashingInProgress === false

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: model.installed || firmwareColumn.flashingInProgress || platformStack.connected === false ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    enabled: model.installed === false && !firmwareColumn.flashingInProgress && platformStack.connected

                                    onClicked: {
                                        // todo if (version < installed version)
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
                                                    "path": model.uri,
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
                        Layout.fillWidth: true
                        Layout.preferredHeight: statusColumn.height
                        visible: false

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
                                Layout.preferredHeight: 8
                                Layout.fillWidth: true
                                color: "grey"
                                clip: true

                                Rectangle {
                                    id: fillBar
                                    height: barBackground.height
                                    width: 0
                                    color: "lime"
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

    RowLayout {
        id: noFirmwareFound
        spacing: 10
        visible: firmwareVersions.visible === false
        Layout.maximumHeight: visible ? implicitHeight : 0

        SGIcon {
            source: "qrc:/sgimages/exclamation-circle-solid.svg"
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            iconColor: "#aaa"
        }

        Text {
            font.pixelSize: 18
            color: "#666"
            text: "No firmware files are available for flashing to this platform"
        }
    }
}
