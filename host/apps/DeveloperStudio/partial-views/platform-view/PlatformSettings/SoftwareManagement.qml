import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection

ColumnLayout {
    id: software

    property bool upToDate
    property var activeVersion: null
    property var latestVersion: ({})
    property string downloadFilepath: ""
    property bool downloadError: false
    property string activeDownloadUri: ""

    Connections {
        target: coreInterface

        onDownloadViewFinished: {
            if (payload.url === activeDownloadUri) {
                activeDownloadUri = ""
                progressUpdateText.percent = 1.0

                if (payload.error_string.length > 0) {
                    downloadError = true
                    progressBar.color = "red"
                    upToDate = false
                } else {
                    downloadError = false;
                    downloadFilepath = payload.filepath;
                    progressBar.color = "#57d445"
                    upToDate = true
                    platformStack.controlViewContainer.startControlUpdate(latestVersion.version, downloadFilepath)
                    activeVersion = latestVersion
                }
                downloadFilepath = ""
                downloadButtonMouseArea.enabled = true
                downloadIcon.opacity = 1
                downloadButtonMouseArea.cursorShape = Qt.PointingHandCursor
            }
        }

        onDownloadControlViewProgress: {
            if (platformStack.currentIndex === settingsContainer.stackIndex && payload.url === activeDownloadUri) {
                progressUpdateText.percent = payload.bytes_received / payload.bytes_total
            }
        }
    }

    Connections {
        target: platformStack

        onConnectedChanged: {
            if (platformStack.connected){
                matchVersion()
            }
        }

        onCurrentIndexChanged: {
            matchVersion()
        }
    }

    function matchVersion() {
        // when the active view is this view, then match the version
        if (platformStack.currentIndex === settingsContainer.stackIndex) {
            let activeIdx = platformStack.controlViewContainer.controlViewList.getInstalledVersion()

            if (activeIdx >= 0) {
                activeVersion = platformStack.controlViewContainer.controlViewList.get(activeIdx)
                upToDate = isUpToDate()
                return
            }

            upToDate = false
            let latestVersionIdx = platformStack.controlViewContainer.controlViewList.getLatestVersion();
            latestVersion = platformStack.controlViewContainer.controlViewList.get(latestVersionIdx);

            if (objectIsEmpty(latestVersion)) {
                console.error("Could not find any control views on server for class id:", platformStack.class_id)
            }
        }
    }

    function objectIsEmpty(obj) {
        return Object.keys(obj).length === 0 && obj.constructor === Object
    }

    function isUpToDate() {
        for (let i = 0; i < platformStack.controlViewContainer.controlViewListCount; i++) {
            let version = platformStack.controlViewContainer.controlViewList.version(i)
            if (version !== activeVersion.version && SGVersionUtils.greaterThan(version, activeVersion.version)) {
                // if the version is greater, then set the latestVersion here
                latestVersion = platformStack.controlViewContainer.controlViewList.get(i);
                return false;
            }
        }
        latestVersion = activeVersion;
        return true;
    }

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
        text: {
            if (platformStack.usingLocalView) {
                return "Original version installed";
            }

            if (activeVersion !== null) {
                return activeVersion.version;
            } else {
                return "Not installed";
            }
        }

        font.bold: true
        font.pixelSize: 18
    }

    Rectangle {
        id: viewUpToDate
        Layout.preferredHeight: 50
        Layout.fillWidth: true
        Layout.topMargin: 15
        color: "#eee"
        visible: software.upToDate

        RowLayout {
            anchors {
                verticalCenter: viewUpToDate.verticalCenter
            }
            spacing: 15

            SGIcon {
                iconColor: "#999"
                source: "qrc:/sgimages/check-circle.svg"
                Layout.preferredHeight: 30
                Layout.preferredWidth: 30
                Layout.leftMargin: 10
            }

            Text {
                text: "Up to date! No newer version available"
            }
        }
    }

    Rectangle {
        id: viewNotUpToDate
        Layout.preferredHeight: notUpToDateColumn.height
        Layout.fillWidth: true
        Layout.topMargin: 15
        color: "#eee"
        visible: {
            return !software.upToDate && !objectIsEmpty(latestVersion) && platformStack.controlViewContainer.activeDownloadUri === ""
        }

        ColumnLayout {
            id: notUpToDateColumn
            spacing: 10

            RowLayout {
                Layout.topMargin: 10
                spacing: 15
                Layout.leftMargin: 10

                SGIcon {
                    iconColor: "lime"
                    source: "qrc:/sgimages/exclamation-circle.svg"
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
                            text: getLatestVersionText()
                            font.bold: true
                            font.pixelSize: 18
                            color: "#666"

                            function getLatestVersionText() {
                                if (!objectIsEmpty(latestVersion)) {
                                    let str = "Update to v";
                                    str += software.latestVersion.version;
                                    str += ", released " + software.latestVersion.timestamp
                                    return str;
                                }
                                return "";
                            }
                        }

                        SGIcon {
                            id: downloadIcon
                            iconColor: "#666"
                            source: "qrc:/sgimages/download.svg"
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                        }
                    }

                    ColumnLayout {
                        id: downloadColumn1
                        width: parent.width
                        visible: false

                        Text {
                            id: progressUpdateText
                            Layout.leftMargin: 10
                            property real percent: 0.0

                            onPercentChanged: {
                                progressBar.width = barBackground1.width * percent
                            }

                            text: {
                                if (downloadError) {
                                    return "Error downloading view";
                                }

                                if (percent < 1.0) {
                                    return "Downloading: " + (percent * 100).toFixed(0) + "%"
                                } else {
                                    return "Successfully installed"
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
                                id: progressBar
                                color: "#57d445"
                                height: barBackground1.height
                                width: 0
                            }
                        }

                        function startDownload() {
                            let updateCommand = {
                                "hcs::cmd": "download_view",
                                "payload": {
                                    "url": software.latestVersion.uri,
                                    "md5": software.latestVersion.md5,
                                    "class_id": platformStack.class_id
                                }
                            }
                            activeDownloadUri = software.latestVersion.uri
                            coreInterface.sendCommand(JSON.stringify(updateCommand));
                        }
                    }
                }

                MouseArea {
                    id: downloadButtonMouseArea
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        progressUpdateText.percent = 0.0
                        downloadColumn1.visible = true
                        enabled = false
                        downloadIcon.opacity = 0.5
                        cursorShape = Qt.ArrowCursor
                        downloadColumn1.startDownload();
                    }
                }
            }
        }
    }

    ListModel {
        id: viewVersions
    }
}
