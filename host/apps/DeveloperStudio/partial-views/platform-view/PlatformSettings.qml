import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color: "#ddd"
    anchors {
        fill: parent
    }

    property string firmwareVersion: "1.2.2"
    property string firmwareDate: "2019-11-04 17:16:48"
    property string viewVersion: "1.1.0"
    property string viewDate: "2019-11-04 17:16:48"
    property bool upToDate: false

    property alias reminderCheck: reminderCheck

    ListModel {
        id: firmwareVersions

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.0.0"
            installed: false
        }

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.1.1"
            installed: false
        }

        ListElement {
            file: "<PATH to firmware>/250mA_LDO.bin"
            md5: "b2d69a4c8a224afa77319cd3d833b292"
            name: "firmware"
            timestamp: "2019-11-04 17:16:48"
            version: "1.2.2"
            installed: true
        }
    }

    ListModel {
        id: viewVersions

        ListElement {
            file: "<PATH to control view>/250mA_LDO.rcc"
            md5: "a2d69a4c8a224afa77319cd3d833b292"
            name: "control view"
            timestamp: "2019-11-04 17:16:48"
            version: "1.1.0"
            installed: true
        }
        ListElement {
            file: "<PATH to control view>/250mA_LDO.rcc"
            md5: "a2d69a4c8a224afa77319cd3d833b292"
            name: "control view"
            timestamp: "2019-11-04 17:16:48"
            version: "1.2.0"
            installed: false
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 30

        ColumnLayout {

            Text {
                text: "Software Settings:"
                font.bold: true
                font.pixelSize: 18
            }

            Rectangle {
                color: "#aaa"
                Layout.fillWidth: true
                Layout.preferredHeight: 1
            }

            Text {
                Layout.topMargin: 10
                text: "Current software version:"
                font.bold: false
                font.pixelSize: 18
                color: "#666"
            }

            Text {
                text: "Logic Gates v"+ root.viewVersion + ", released " + root.viewDate
                font.bold: true
                font.pixelSize: 18
            }

            Rectangle {
                id: viewUpToDate
                Layout.preferredHeight: 50
                Layout.fillWidth: true
                Layout.topMargin: 15
                color: "#eee"
                visible: root.upToDate

                RowLayout {
                    anchors {
                        verticalCenter: viewUpToDate.verticalCenter
                    }
                    spacing: 15

                    SGIcon {
                        iconColor: "#999"
                        source: "qrc:/sgimages/check-circle-solid.svg"
                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30
                        Layout.leftMargin: 10
                    }

                    Text {
                        text: "Up to date! No newer version available"
                    }
                }

                MouseArea {
                    anchors {
                        fill: viewUpToDate
                    }
                    onClicked: {
                        root.upToDate = false
                    }
                }
            }

            Rectangle {
                id: viewNotUpToDate
                Layout.preferredHeight: notUpToDateColumn.height
                Layout.fillWidth: true
                Layout.topMargin: 15
                color: "#eee"
                visible: !root.upToDate

                ColumnLayout {
                    id: notUpToDateColumn
                    spacing: 10

                    RowLayout {
                        Layout.topMargin: 10
                        spacing: 15
                        Layout.leftMargin: 10

                        SGIcon {
                            iconColor: "lime"
                            source: "qrc:/sgimages/exclamation-circle-solid.svg"
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30

                            Rectangle {
                                color: "white"
                                width: 20
                                height: 20
                                radius: 10
                                anchors {
                                    centerIn: parent
                                }
                                z:-1
                            }
                        }

                        Text {
                            text: "Newer software version available!"
                        }
                    }

                    Rectangle {
                        color: "#fff"
                        Layout.preferredWidth: updatebuttonColumn.width
                        Layout.preferredHeight: updatebuttonColumn.height
                        Layout.leftMargin: 10
                        Layout.bottomMargin: 10

                        ColumnLayout {
                            id: updatebuttonColumn
                            spacing: 10

                            RowLayout {
                                id: updatebutton
                                spacing: 15
                                Layout.margins: 10

                                Text {
                                    text: "Update to Logic Gates v1.2.1, released " + root.viewDate
                                    font.bold: true
                                    font.pixelSize: 18
                                    color: "#666"
                                }

                                SGIcon {
                                    iconColor: "#666"
                                    source: "qrc:/sgimages/download-solid.svg"
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: 30
                                }
                            }

                            ColumnLayout {
                                id: downloadColumn1
                                width: parent.width
                                visible: false

                                Text {
                                    Layout.leftMargin: 10
                                    property real percent: fillBar1.width/barBackground1.width
                                    text: {
                                        if (percent < .6) {
                                            return "Downloading: " + (percent * 166.66).toFixed(0) + "%"
                                        } else if (percent < .8) {
                                            return "Installing: " + ((percent-.6) * 500).toFixed(0) + "%"
                                        } else if (percent < 1) {
                                            return "Loading: " + ((percent-.8) * 500).toFixed(0) + "%"
                                        } else if (percent >= 1){
                                            root.viewVersion = "1.2.1"
                                            root.upToDate = true
                                            return "Complete"
                                        }
                                    }
                                }

                                Rectangle {
                                    id: barBackground1
                                    color: "grey"
                                    Layout.preferredHeight: 8
                                    Layout.fillWidth: true
                                    clip: true

                                    Rectangle {
                                        id: fillBar1
                                        color: "lime"
                                        height: barBackground1.height
                                        width: 0
                                        onVisibleChanged: {
                                            if (visible)
                                                timer1.start()
                                        }

                                        Timer {
                                            id: timer1
                                            interval: 16
                                            running: false
                                            repeat: true
                                            onTriggered: {
                                                if (fillBar1.width < barBackground1.width) {
                                                    fillBar1.width +=3
                                                } else {
                                                    repeat = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors {
                                fill: parent
                            }
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                downloadColumn1.visible = true
                            }
                        }
                    }
                }
            }
        }


        ColumnLayout {
            id: firmwareColumn

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
                visible: !window.connected

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
                visible: window.connected
                Layout.topMargin: 10

                Text {
                    text: "Detected firmware version:"
                    font.bold: false
                    font.pixelSize: 18
                    color: "#666"
                }

                Text {
                    text: "Logic Gates v"+ root.firmwareVersion + ", released " + root.firmwareDate
                    font.bold: true
                    font.pixelSize: 18
                }

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
                    width: parent.width
                    model: firmwareVersions

                    delegate: Rectangle {
                        Layout.preferredHeight: column.height
                        Layout.fillWidth: true

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

                                SGIcon {
                                    source: model.installed ? "qrc:/sgimages/check-circle-solid.svg" : "qrc:/sgimages/download-solid.svg"
                                    Layout.preferredHeight: 30
                                    Layout.preferredWidth: 30
                                    iconColor: model.installed ? "lime" : "#666"

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: model.installed ? Qt.ArrowCursor : Qt.PointingHandCursor

                                        onClicked: {
                                            warningPop.delegateDownload = download
                                            warningPop.open()
                                        }
                                    }
                                }
                            }

                            Item {
                                id: download
                                visible: false
                                Layout.fillWidth: true
                                Layout.preferredHeight: downloadColumn.height

                                ColumnLayout {
                                    id: downloadColumn
                                    width: parent.width

                                    Text {
                                        Layout.leftMargin: 10
                                        property real percent: fillBar.width/barBackground.width
                                        text: {
                                            if (percent < .6) {
                                                return "Downloading: " + (percent * 166.66).toFixed(0) + "%"
                                            } else if (percent < .8) {
                                                return "Flashing Firmware..."
                                            } else if (percent < 1) {
                                                return "Validating Firmware..."
                                            } else if (percent >= 1){
                                                for (let i = 0; i < firmwareVersions.count; i++) {
                                                    firmwareVersions.get(i).installed = false
                                                }
                                                root.firmwareVersion = model.version
                                                model.installed = true
                                                download.visible = false
                                                return "Complete"
                                            }
                                        }
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
                                            onVisibleChanged: {
                                                if (visible)
                                                    timer.start()
                                            }

                                            Timer {
                                                id: timer
                                                interval: 16
                                                running: false
                                                repeat: true

                                                property bool downloadDone: false

                                                onTriggered: {
                                                    if (fillBar.width < barBackground.width *.6) {
                                                        fillBar.width +=3
                                                        return
                                                    } else if (fillBar.width < barBackground.width ) {
                                                        interval = 3000
                                                        if(downloadDone){
                                                            fillBar.width += barBackground.width *.2
                                                        }
                                                        downloadDone = true
                                                        return
                                                    }
                                                    repeat = false
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

        CheckBox {
            id: reminderCheck
            text: "Notify me when new versions of firmware or controls are available"
            checked: window.remind
            onCheckedChanged: window.remind = checked
        }

        Item {
            //filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Popup {
        id: warningPop
        height: 150
        width: 430
        x: (root.width - width)/2
        y: (root.height - height)/2
        padding: 0
        modal: true
        background: Rectangle {
            color: "white"
        }

        property Item delegateDownload: null

        Rectangle {
            color: "#e67a70"
            width: parent.width
            height: 20

            SGIcon {
                source: "qrc:/sgimages/times.svg"
                iconColor: "white"
                height: 15
                width: 15
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 2.5
                }

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: warningPop.close()
                }
            }
        }

        ColumnLayout {
            anchors {
                centerIn: parent
                verticalCenterOffset: 10
            }
            spacing: 10

            Text {
                text: "Warning: Older firmware versions may be incompatible with the <br>installed software version. Are you sure you want to continue?"
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "Yes"
                    onClicked: {
                        warningPop.delegateDownload.visible = true
                        warningPop.close()
                    }
                }

                Button {
                    text: "No"
                    onClicked: warningPop.close()
                }
            }
        }
    }
}
