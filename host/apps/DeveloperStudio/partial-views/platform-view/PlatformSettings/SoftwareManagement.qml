import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: software

    property bool upToDate
    property var activeVersion: null
    property var latestVersion: null
    property var controlViewList: null
    property int controlViewCount: controlViewList.count

    Component.onCompleted: {
        controlViewList = sdsModel.documentManager.getClassDocuments(platformStack.class_id).controlViewListModel
    }

    onControlViewCountChanged: {
        matchVersion()
    }

    Connections {
        target: coreInterface

        onDownloadViewFinished: {
            sdsModel.resourceLoader.registerControlViewResources(platformStack.class_id);
            progressUpdateText.percent = 1.0
            activeVersion = latestVersion
            setUpToDateTimer.start()
        }

        onDownloadControlViewProgress: {
            progressUpdateText.percent = payload.bytes_received / payload.bytes_total
        }
    }

    Connections {
        target: platformStack
        onConnectedChanged: {
            matchVersion()
        }
    }

    function matchVersion() {
        for (let i = 0; i < controlViewCount; i++) {
            // find the installed version (if any) and set it as activeVersion
            if (controlViewList.installed(i)) {
                activeVersion = copyControlViewObject(i)
                upToDate = isUpToDate();
                return;
            }
        }

        upToDate = false
        latestVersion = getLatestVersion();

        if (!latestVersion) {
            console.error("Could not find any control views on server for class id:", platformStack.class_id)
        }
    }

    function isUpToDate() {
        for (let i = 0; i < controlViewCount; i++) {
            let version = controlViewList.version(i)
            if (version !== activeVersion.version && isVersionGreater(activeVersion.version, version)) {
                // if the version is greater, then set the latestVersion here
                latestVersion = copyControlViewObject(i);
                return false;
            }
        }
        latestVersion = activeVersion;
        return true;
    }

    function getLatestVersion() {
        let latestVersionTemp;

        if (controlViewCount > 0) {
            latestVersionTemp = copyControlViewObject(0);
        } else {
            return null;
        }

        for (let i = 1; i < controlViewCount; i++) {
            let version = controlViewList.version(i);
            if (isVersionGreater(latestVersionTemp.version, version)) {
                latestVersionTemp = copyControlViewObject(i);
            }
        }

        return latestVersionTemp;
    }

    // checks if version 2 is greater than version 1
    function isVersionGreater(version1, version2) {
        let version1Arr = version1.split('.').map(num => parseInt(num, 10));
        let version2Arr = version2.split('.').map(num => parseInt(num, 10));

        // fill in 0s for each missing version (e.g) 1.5 -> 1.5.0
        while (version1Arr.length < 3) {
            version1Arr.push(0)
        }

        while (version2Arr.length < 3) {
            version2Arr.push(0)
        }

        for (let i = 0; i < 3; i++) {
            if (version1Arr[i] > version2Arr[i]) {
                return false;
            } else if (version1Arr[i] < version2Arr[i]) {
                return true;
            }
        }

        // else they are the same version
        return false;
    }

    function copyControlViewObject(index) {
        let obj = {};

        obj["uri"] = controlViewList.uri(index);
        obj["md5"] = controlViewList.md5(index);
        obj["name"] = controlViewList.name(index);
        obj["version"] = controlViewList.version(index);
        obj["timestamp"] = controlViewList.timestamp(index);
        obj["installed"] = controlViewList.installed(index);

        return obj;
    }

    Timer {
        id: setUpToDateTimer
        interval: 1500
        repeat: false

        onTriggered: {
            upToDate = true
        }
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
        text: activeVersion !== null ? activeVersion.version : "Not installed"
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
                source: "qrc:/sgimages/check-circle-solid.svg"
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
        visible: !software.upToDate && latestVersion !== null

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
                            text: getLatestVersionText()
                            font.bold: true
                            font.pixelSize: 18
                            color: "#666"

                            function getLatestVersionText() {
                                if (software.latestVersion) {
                                    let str = "Update to v";
                                    str += software.latestVersion.version;
                                    str += ", released " + software.latestVersion.timestamp
                                    return str;
                                }
                                return "";
                            }
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
                            id: progressUpdateText
                            Layout.leftMargin: 10
                            property real percent: 0.0

                            onPercentChanged: {
                                fillBar1.width = barBackground1.width * percent
                            }

                            text: {
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
                                id: fillBar1
                                color: "lime"
                                height: barBackground1.height
                                width: 0
                            }
                        }

                        function startDownload() {
                            let updateCommand = {
                                "hcs::cmd": "download_view",
                                "payload": {
                                    "url": software.latestVersion.uri,
                                    "md5": software.latestVersion.md5
                                }
                            }
                            coreInterface.sendCommand(JSON.stringify(updateCommand));
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
                        sdsModel.resourceLoader.deleteViewResource(platformStack.class_id, activeVersion ? activeVersion.version : "");
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
