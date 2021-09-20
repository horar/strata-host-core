/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

ColumnLayout {
    id: firmwareList
    spacing: 0
    Layout.topMargin: 10

    property alias firmwareRepeater: firmwareRepeater
    property alias firmwareVersions: firmwareVersions

    ColumnLayout{
        id: firmwareVersions
        visible: firmwareRepeater.model.count > 0

        SGText {
            text: "Firmware versions available:"
            fontSizeMultiplier: 1.38
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

                SGText {
                    Layout.preferredWidth:60
                    Layout.leftMargin: 5
                    text: "Version"
                    font.italic: true
                }

                SGText {
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

                        SGText {
                            id: versionText
                            Layout.preferredWidth: 60
                            text: model.version
                            fontSizeMultiplier: 1.38
                            color: "#666"
                        }

                        SGText {
                            text: model.timestamp
                            Layout.fillWidth: true
                            fontSizeMultiplier: 1.38
                            color: "#666"
                        }

                        SGText {
                            id: description
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            color: "#666"
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignRight
                            text: defaultText

                            property string defaultText: !model.installed && installMouse.enabled ? "Download and flash firmware" : ""
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
                                source: model.installed ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/download.svg"
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
                                    id: installMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: model.installed || firmwareColumn.flashingInProgress || platformStack.connected === false ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    enabled: model.installed === false && !firmwareColumn.flashingInProgress && platformStack.connected

                                    onClicked: {
                                        if (platformStack.firmware_version !== "") {
                                            if (SGVersionUtils.greaterThan(model.version, platformStack.firmware_version)) {
                                                flashStatus.startFlash()
                                                return
                                            }

                                            warningPop.callback = this
                                            warningPop.open()
                                        } else {
                                            flashStatus.startFlash()
                                        }
                                    }

                                    function callback() {
                                        flashStatus.startFlash()
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
                            description.text = Qt.binding(() => description.defaultText)
                        }

                        function startFlash() {
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
                                    statusText.text = "Flashing failed: " + payload.flash_error
                                    break;
                                }
                                break;
                            case "restore":
                                switch (payload.status) {
                                case "running":
                                    statusText.text = "Restoring firmware... "
                                    if (payload.total > -1) {
                                        statusText.text += "" + (100 * (payload.complete / payload.total)).toFixed(0) + "% complete"
                                        fillBar.width = (barBackground.width * .75) + (barBackground.width * .25) * (payload.complete / payload.total)
                                    } else {
                                        fillBar.width = barBackground.width * .75
                                    }
                                    break;
                                case "failure":
                                    statusText.text = "Restoration failed: " + payload.restore_error
                                    break;
                                }
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

                            SGText {
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
            source: "qrc:/sgimages/exclamation-circle.svg"
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            iconColor: "#aaa"
        }

        SGText {
            fontSizeMultiplier: 1.38
            color: "#666"
            text: "No firmware files are available for flashing to this platform"
        }
    }
}
