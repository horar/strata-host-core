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

ColumnLayout {
    id: firmwareColumn

    property Item activeFirmware: null
    property bool flashingInProgress: false

    Component.onCompleted: {
        firmwareListModel = sdsModel.documentManager.getClassDocuments(platformStack.class_id).firmwareListModel
        firmwareList.firmwareRepeater.model = firmwareListModel
    }

    property var firmwareListModel: null
    property int firmwareCount: firmwareListModel.count

    onFirmwareCountChanged: {
        matchVersion()
    }

    Connections {
        target: coreInterface
        onFirmwareProgress: {
            if (payload.device_id === platformStack.device_id) {
                activeFirmware.parseProgress(payload)
            }
        }
    }

    Connections {
        target: platformStack
        onConnectedChanged: {
            matchVersion()
        }
        onFirmware_versionChanged: {
            matchVersion()
        }
    }

    function matchVersion() {
        for (let i = 0; i < firmwareListModel.count; i++) {
            let version = firmwareListModel.version(i)
            if (version === platformStack.firmware_version) {
                firmwareListModel.setInstalled(i, true)
            } else {
                firmwareListModel.setInstalled(i, false)
            }
        }
    }

    function clearDescriptions () {
        for (let i = 0; i < firmwareList.firmwareVersions.children.length; i++) {
            if (firmwareList.firmwareVersions.children[i].objectName === "firmwareRow") {
                firmwareList.firmwareVersions.children[i].description = ""
            }
        }
    }

    SGText {
        text: "Firmware Settings:"
        font.bold: true
        fontSizeMultiplier: 1.38
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

        SGText {
            text: "Connect this platform to manage its firmware"
            fontSizeMultiplier: 1.38
            color: deviceVersion.color
        }
    }

    RowLayout {
        id: errorResponse
        spacing: 10
        Layout.topMargin: 10
        visible: platformStack.connected && platformStack.firmware_version === ""

        SGIcon {
            id: errorIcon
            source: "qrc:/sgimages/exclamation-triangle.svg"
            Layout.preferredHeight: 30
            Layout.preferredWidth: 30
            iconColor: "#f53847"
        }

        SGText {
            text: "Error: Unable to determine platform firmware version"
            fontSizeMultiplier: 1.38
            color: deviceVersion.color
        }
    }

    ColumnLayout {
        id: connectedFirmwareColumn
        visible: platformStack.connected && platformStack.firmware_version !== ""
        Layout.topMargin: 10

        SGText {
            id: deviceVersion
            text: "Device firmware version:"
            fontSizeMultiplier: 1.38
            color: "#666"
        }

        SGText {
            text: platformStack.firmware_version
            font.bold: true
            fontSizeMultiplier: 1.38
        }
    }

    FirmwareVersionList {
        id: firmwareList
    }
}
