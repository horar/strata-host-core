/*
 * Copyright (c) 2018-2022 onsemi.
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
import tech.strata.theme 1.0

ColumnLayout {
    id: firmwareList
    spacing: 0
    Layout.topMargin: 10

    property alias firmwareModel: firmwareListView.model
    property string timestampFormat: "MMM dd yyyy, hh:mm:ss"

    ColumnLayout{
        id: firmwareVersions
        visible: firmwareListView.model.count > 0 && (platformStack.firmwareIsOutOfDate || sdsModel.debugFeaturesEnabled)

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
                    Layout.preferredWidth: 60
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
            // Note: does not work if placed inside firmwareListView
            target: sdsModel.firmwareUpdater

            onJobFinished: {
                if (firmwareListView.flashingDeviceInProgress && (deviceId === platformStack.device_id)) {
                    firmwareListView.flashingDeviceInProgress = false
                }
            }

            onJobError: {
                if (firmwareListView.flashingDeviceInProgress && (deviceId === platformStack.device_id)) {
                    console.warn(Logger.devStudioCategory, "Failure during firmware flashing:", errorString)
                }
            }
        }

        ListView {
            id: firmwareListView
            model: []
            clip: true
            spacing: 5
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: contentHeight

            ScrollBar.vertical: ScrollBar {
                id: firmwareScrollbar
                policy: ScrollBar.AlwaysOn
                visible: firmwareListView.height < firmwareListView.contentHeight
            }

            property bool flashingDeviceInProgress: false // one of the firmwares is being flashed to this device

            Component.onCompleted: {
                firmwareListView.flashingDeviceInProgress = sdsModel.firmwareUpdater.isFirmwareUpdateInProgress(platformStack.device_id)
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
                        Layout.preferredHeight: versionText.height < 30 ? 30 : versionText.height
                        spacing: 30

                        SGText {
                            id: versionText
                            Layout.preferredWidth: 60
                            text: model.version
                            fontSizeMultiplier: 1.38
                            color: "#666"
                            wrapMode: Text.Wrap
                        }

                        SGText {
                            text: SGUtilsCpp.formatDateTimeWithOffsetFromUtc(model.timestamp, timestampFormat)
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
                            horizontalAlignment: Text.AlignRight
                            text: currentStatus !== "" ? currentStatus : (installMouse.enabled ? "Download and flash firmware" : "")
                            property string currentStatus: ""

                            Connections {
                                target: firmwareListView

                                onFlashingDeviceInProgressChanged: {
                                    if (firmwareListView.flashingDeviceInProgress && firmwareDescription.currentStatus !== "") {
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
                                    if (platformStack.connected === false || firmwareListView.flashingDeviceInProgress) {
                                        return "#ddd" // disabled - light greyed out
                                    } else if (model.installed) {
                                        return Theme.palette.success
                                    } else {
                                        return "#666" // enabled - dark grey
                                    }
                                }
                                visible: firmwareRow.flashingFirmwareInProgress === false

                                MouseArea {
                                    id: installMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: model.installed || firmwareListView.flashingDeviceInProgress || platformStack.connected === false ? Qt.ArrowCursor : Qt.PointingHandCursor
                                    enabled: model.installed === false && !firmwareListView.flashingDeviceInProgress && platformStack.connected

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
                            fillBar.color = Theme.palette.success
                            flashStatus.visible = false
                        }

                        function startFlash(already_started) {
                            if ((already_started === false) &&
                                (firmwareListView.flashingDeviceInProgress === false)) {
                                already_started = sdsModel.firmwareUpdater.programFirmware(platformStack.device_id, model.uri, model.md5)
                            }

                            if (already_started) {
                                firmwareRow.flashingFirmwareInProgress = true
                                firmwareListView.flashingDeviceInProgress = true // call before changing the currentStatus
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
                                    color: Theme.palette.success

                                    property real progress : 0.0
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: firmwareUpToDate
        Layout.preferredHeight: 50
        Layout.fillWidth: true
        Layout.topMargin: 5
        color: "#eee"
        visible: firmwareVersions.visible === false && platformStack.connected

        RowLayout {
            anchors.verticalCenter: firmwareUpToDate.verticalCenter
            spacing: 15

            SGIcon {
                iconColor: "#999"
                source: "qrc:/sgimages/check-circle.svg"
                Layout.preferredHeight: 30
                Layout.preferredWidth: 30
                Layout.leftMargin: 10
            }

            SGText {
                fontSizeMultiplier: 1.38
                color: "#666"
                text: {
                    if (firmwareListView.model.count === 0) {
                        return "No firmware files are available for flashing to this platform"
                    } else {
                        return "Up to date! No newer version available"
                    }
                }
            }
        }
    }

    function notifyFwUpdateFailed(text) {
        Notifications.createNotification(
                    "Flash firmware failed",
                    Notifications.Critical,
                    "current",
                    platformStack,
                    {
                        "description": text,
                        "iconSource": "qrc:/sgimages/exclamation-circle.svg",
                        "actions": [close],
                        "timeout": 0
                    }
                    )
    }
}
