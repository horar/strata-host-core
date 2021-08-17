import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtGraphicalEffects 1.12
import tech.strata.notifications 1.0

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

            signal resetDescriptions()

            delegate: Rectangle {
                id: firmwareRow
                Layout.preferredHeight: column.height
                Layout.fillWidth: true
                objectName: "firmwareRow"

                property bool flashingInProgress: false
                property string updateFirmwareJobId
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

                            property string defaultText: installMouse.enabled ? "Download and flash firmware" : ""
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
                            if (firmwareColumn.flashingInProgress === false) {
                                let payload = sdsModel.firmwareManager.acquireUpdateFirmwareData(platformStack.device_id, model.uri, model.md5)
                                if((payload.status !== undefined) && (payload.progress !== undefined)) {
                                    startFlash(true)
                                    processUpdateFirmwareJobProgress(payload.status, payload.progress)
                                }
                            }
                        }

                        function resetState() {
                            statusText.text = "Initializing..."
                            fillBar.width = 0
                            fillBar.color = "lime"
                            flashStatus.visible = false
                        }

                        function resetDescription() {
                            description.text = Qt.binding(() => description.defaultText)
                            firmwareRepeater.resetDescriptions.disconnect(resetDescription)
                        }

                        function startFlash(already_started) {
                            if (firmwareColumn.flashingInProgress === false) {
                                firmwareRepeater.resetDescriptions()

                                if (already_started ||
                                    (sdsModel.firmwareManager.updateFirmware(platformStack.device_id, model.uri, model.md5) === true)) {
                                    flashingInProgress = true
                                    description.text = "Do not unplug your board during this process"
                                    flashStatus.visible = true
                                    activeFirmware = flashStatus
                                } else {
                                    let error_string = "Unable to start flashing"
                                    processUpdateFirmwareJobFinished(firmwareRow.updateFirmwareJobId, "Update Firmware failed: " + error_string, error_string)
                                }
                            }
                        }

                        function processUpdateFirmwareJobProgress(status, progress) {
                            statusText.text = status
                            fillBar.width = Qt.binding(() => barBackground.width * progress) // must be bound in case of resize
                        }

                        function processUpdateFirmwareJobFinished(status, error_string) {
                            if (error_string.length !== 0) {
                                notifyFwUpdateFailed(error_string)
                            }

                            resetState()
                            description.text = status
                            flashingInProgress = false
                            activeFirmware = null
                            firmwareRepeater.resetDescriptions.connect(resetDescription)
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
