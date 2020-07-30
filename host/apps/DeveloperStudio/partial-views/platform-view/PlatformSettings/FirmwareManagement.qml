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
        classDocuments = sdsModel.documentManager.getClassDocuments(platformStack.class_id)
        firmwareList.firmwareRepeater.model = classDocuments.firmwareListModel
    }

    property var classDocuments: null
    property int firmwareCount: classDocuments.firmwareListModel.count

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
        for (let i = 0; i < classDocuments.firmwareListModel.count; i++) {
            let version = classDocuments.firmwareListModel.version(i)
            if (version === platformStack.firmware_version) {
                classDocuments.firmwareListModel.setInstalled(i, true)
            } else {
                classDocuments.firmwareListModel.setInstalled(i, false)
            }
        }
    }

    function clearDescriptions () {
        for (let i = 0; i < firmwareVersions.children.length; i++) {
            if (firmwareVersions.children[i].objectName === "firmwareRow") {
                firmwareVersions.children[i].description = ""
            }
        }
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
            font.pixelSize: 18
            color: deviceVersion.color
        }
    }

    ColumnLayout {
        id: connectedFirmwareColumn
        visible: platformStack.connected
        Layout.topMargin: 10

        Text {
            id: deviceVersion
            text: "Device firmware version:"
            font.pixelSize: 18
            color: "#666"
        }

        Text {
            text: platformStack.firmware_version
            font.bold: true
            font.pixelSize: 18
        }
    }

    FirmwareVersionList {
        id: firmwareList
    }
}
