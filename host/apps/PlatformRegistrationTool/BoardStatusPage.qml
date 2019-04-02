import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

import "./common" as Common
import "./common/Colors.js" as Colors

PrtBasePage {
    id: page

    property int labelSpacing: 4
    property int rowHeight: 80
    property bool forceConnect: false

    title: "Board Status"

    footerButtonModel: {
        var list = []
        list.push({"text":"DEBUG: board_switch","id":"board_switch"})
        return list
    }

    onFooterButtonClicked: {
        if (id === "board_switch") {
            forceConnect = !forceConnect
        }
    }

    Component.onCompleted: {
        if (prtModel.connectionIds.length > 0) {
            initialize()
        }
    }

    Connections {
        target: prtModel

        onMessageArrived: {
            console.log("onMessageArrived()", connectionId, message)

            if (prtModel.connectionIds[0] !== connectionId) {
                console.log("onMessageArrived() notification from another device => skipped")
                return
            }

            var data = JSON.parse(message)

            if (!data.hasOwnProperty("notification")) {
                return
            }

            var type = data["notification"]["value"]

            if (type === "get_firmware_info") {
                var value = data["notification"]["payload"]["bootloader"]["version"]
                if (!value) {
                    value = "not available"
                }

                boardStatus.bootloaderId = value

                value = data["notification"]["payload"]["application"]["version"]
                if (!value) {
                    value = "not available"
                }
                boardStatus.firmwareId = value
            }
            else if (type === "get_platform_id") {
                var status = data["notification"]["payload"]["status"]

                value = false
                if (status && status.length && status !== "not_initialized") {
                    value = true
                }

                boardStatus.isRegistered = value

                //just fake data
                populateBoardData()
            }
        }
    }

    Item {
        anchors {
            fill: parent
            margins: 6
        }

        BoardStatus {
            id: boardStatus
            anchors.fill: parent

            isConnected: forceConnect || prtModel.connectionIds.length > 0
            showWarning: !isConnected
            onIsConnectedChanged: {
                if (isConnected) {
                    initialize()
                } else {
                    boardStatus.clear()
                }
            }
        }
    }

    function initialize() {
        boardStatus.isRegistered = false
        boardStatus.bootloaderId = ""
        boardStatus.firmwareId = ""

        queryFirmware()
        queryPlatformId()
        populateBoardData()
    }

    function queryPlatformId() {
        var cmd = JSON.stringify({
            "cmd":"get_platform_id",
            "payload": {}
        })

        prtModel.sendCommand(prtModel.connectionIds[0],cmd)
    }

    function queryFirmware() {
        var cmd = JSON.stringify({
            "cmd":"get_firmware_info",
            "payload": {}
        })

        prtModel.sendCommand(prtModel.connectionIds[0],cmd)
    }

    function populateBoardData() {
        boardStatus.isRegistered = true
        boardStatus.verboseName = "USB-PD Dual 100W Power Only"
        boardStatus.boardRevision = "1.1"
        boardStatus.opn = "ONSEC-18-004"
        boardStatus.year = 2018
        boardStatus.boardImageSrc = "qrc:/images/board1.jpg"
        boardStatus.applicationTagList = ["automotive","networkingtelecom"]
        boardStatus.productTagList = ["ac","audio","imagesensors"]
        boardStatus.description = "Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description.Very long description."
    }
}
