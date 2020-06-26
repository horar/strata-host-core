let firmwareListModel = Qt.createQmlObject("import QtQuick 2.12; ListModel {property int currentIndex: 0; property string status: 'initialized'; property string deviceVersion: ''; property string deviceTimestamp:''}", Qt.application,"FirmwareListModel")

function parseFirmwareInfo (firmwareInfo) {
    firmwareListModel.deviceVersion = firmwareInfo.device.version
    firmwareListModel.deviceTimestamp = firmwareInfo.device.timestamp

    for (let i = 0; i < firmwareInfo.list.length; i++) {
        let firmware = firmwareInfo.list[i]
        if (firmware.version === firmwareListModel.deviceVersion) {
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
