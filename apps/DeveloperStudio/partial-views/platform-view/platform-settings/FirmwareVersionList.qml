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
import tech.strata.notifications 1.0

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.logger 1.0

ColumnLayout {
    id: firmwareList
    spacing: 0
    Layout.topMargin: 10

    property alias firmwareRepeater: firmwareRepeater

    ColumnLayout{
        id: firmwareVersions
        visible: firmwareRepeater.model.count > 0

        SGText {
            text: "Latest firmware available:"
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

        Connections {
            // Note: does not works if placed inside firmwareRepeater
            target: sdsModel.firmwareUpdater

            onJobFinished: {
                if (firmwareRepeater.flashingDeviceInProgress && (deviceId === platformStack.device_id)) {
                    firmwareRepeater.flashingDeviceInProgress = false
                }
            }

            onJobError: {
                if (firmwareRepeater.flashingDeviceInProgress && (deviceId === platformStack.device_id)) {
                    console.warn(Logger.devStudioCategory, "Failure during firmware flashing:", errorString)
                }
            }
        }

        ListView {
            id: firmwareRepeater
            model: []
            clip: true
            spacing: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: contentHeight

            ScrollBar.vertical: ScrollBar {
                id: firmwareScrollbar
                policy: ScrollBar.AlwaysOn
                visible: firmwareRepeater.height < firmwareRepeater.contentHeight
            }

            property bool flashingDeviceInProgress: false // one of the firmwares is being flashed to this device

            Component.onCompleted: {
                firmwareRepeater.flashingDeviceInProgress = sdsModel.firmwareUpdater.isFirmwareUpdateInProgress(platformStack.device_id)
            }

            delegate: Rectangle {
                id: firmwareRow
                width: firmwareHeader.width
                height: firmwareDataColumn.height

                property bool flashingFirmwareInProgress: false // this particular firmware is being flashed to device

                Connections {
                    target: sdsModel.firmwareUpdater

                    onJobProgressUpdate: {
                        if (firmwareRow.flashingFirmwareInProgress && (deviceId === platformStack.device_id)) {
                            flashStatus.processUpdateFirmwareJobProgress(status, progress)
                        }
                    }

                    onJobFinished: {
                        if (firmwareRow.flashingFirmwareInProgress && (deviceId === platformStack.device_id)) {
                            flashStatus.processUpdateFirmwareJobFinished(errorString)
                        }
                    }
                }

                ColumnLayout {
                    id: firmwareDataColumn
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
                            id: firmwareDescription
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignRight
                            color: "#666"
                            elide: Text.ElideRight
                            wrapMode: Text.Wrap
                            horizontalAlignment: Text.AlignRight
                            text: currentStatus !== "" ? currentStatus : (installMouse.enabled ? "Download and flash firmware" : "")
                            property string currentStatus: ""

                            Connections {
                                target: firmwareRepeater

                                onFlashingDeviceInProgressChanged: {
                                    if (firmwareRepeater.flashingDeviceInProgress && firmwareDescription.currentStatus !== "") {
                                        firmwareDescription.currentStatus = ""
                                    }
                                }
                            }
                        }

                        Item {
                            id: imageContainer
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                            Layout.rightMargin: firmwareScrollbar.visible ? firmwareScrollbar.width : 0

                            SGIcon {
                                id: installIcon
                                anchors {
                                    fill: parent
                                }
                                source: model.installed ? "qrc:/sgimages/check-circle.svg" : "qrc:/sgimages/download.svg"
                                iconColor: {
                                    if (platformStack.connected === false || firmwareRepeater.flashingDeviceInProgress) {
                                        return "#ddd" // disabled - light greyed out
                                    } else if (model.installed) {
                                        return "lime"
                                    } else {
                                        return "#666" // enabled - dark grey
                                    }
                                }
                                visible: firmwareRow.flashingFirmwareInProgress === false

                                MouseArea {
                                    id: installMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: model.installed || firmwareRepeater.flashingDeviceInProgress || platformStack.connected === false ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    enabled: model.installed === false && !firmwareRepeater.flashingDeviceInProgress && platformStack.connected

                                    onClicked: {
                                        if (platformStack.firmware_version !== "") {
                                            if (SGVersionUtils.greaterThan(model.version, platformStack.firmware_version)) {
                                                flashStatus.startFlash(false)
                                                return
                                            }

                                            warningPop.callback = this
                                            warningPop.open()
                                        } else {
                                            flashStatus.startFlash(false)
                                        }
                                    }

                                    function callback() {
                                        flashStatus.startFlash(false)
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

                        Component.onCompleted: {
                            let payload = sdsModel.firmwareUpdater.getFirmwareUpdateData(platformStack.device_id, model.uri, model.md5)
                            if ((payload.status !== undefined) && (payload.progress !== undefined)) {
                                startFlash(true)
                                processUpdateFirmwareJobProgress(payload.status, payload.progress)
                            }
                        }

                        Connections {
                            target: sdsModel.firmwareUpdater

                            onJobStarted: {
                                if (firmwareRow.flashingFirmwareInProgress === false
                                    && deviceId === platformStack.device_id
                                    && firmwareUri === model.uri
                                    && firmwareMD5 === model.md5)
                                {
                                    let payload = sdsModel.firmwareUpdater.getFirmwareUpdateData(deviceId, firmwareUri, firmwareMD5)
                                    if ((payload.status !== undefined) && (payload.progress !== undefined)) {
                                        flashStatus.startFlash(true)
                                        flashStatus.processUpdateFirmwareJobProgress(payload.status, payload.progress)
                                    }
                                }
                            }
                        }

                        function resetState() {
                            statusText.text = "Initializing..."
                            fillBar.progress = 0.0
                            fillBar.color = "lime"
                            flashStatus.visible = false
                        }

                        function startFlash(already_started) {
                            if ((already_started === false) &&
                                (firmwareRepeater.flashingDeviceInProgress === false)) {
                                already_started = sdsModel.firmwareUpdater.programFirmware(platformStack.device_id, model.uri, model.md5)
                            }

                            if (already_started) {
                                firmwareRow.flashingFirmwareInProgress = true
                                firmwareRepeater.flashingDeviceInProgress = true // call before changing the currentStatus
                                firmwareDescription.currentStatus = "Do not unplug your board during this process"
                                flashStatus.visible = true
                            } else {
                                let error_string = "Unable to start flashing"
                                processUpdateFirmwareJobFinished(error_string)
                            }
                        }

                        function processUpdateFirmwareJobProgress(status, progress) {
                            statusText.text = status
                            fillBar.progress = progress
                        }

                        function processUpdateFirmwareJobFinished(error_string) {
                            let descriptionSuffix = "finished."

                            if (error_string.length !== 0) {
                                descriptionSuffix = "failed: " + error_string
                                notifyFwUpdateFailed(error_string)
                            }

                            resetState()
                            firmwareDescription.currentStatus = "Update firmware " + descriptionSuffix
                            firmwareRow.flashingFirmwareInProgress = false
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
                                    width: barBackground.width * progress // must be bound in case of resize
                                    color: "lime"

                                    property real progress : 0.0
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
        visible: firmwareVersions.visible === false && platformStack.connected
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

    function notifyFwUpdateFailed(text) {
        Notifications.createNotification(
                    "Flash firmware failed",
                    Notifications.Critical,
                    "current",
                    {
                        "description": text,
                        "iconSource": "qrc:/sgimages/exclamation-circle.svg",
                        "actions": [close],
                        "timeout": 0
                    }
                    )
    }
}
