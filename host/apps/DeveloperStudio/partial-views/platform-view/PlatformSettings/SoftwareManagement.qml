import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: software

    property bool upToDate
    property var activeVersion: null
    property var latestVersion: null
    property var classDocuments: null
    property int controlViewCount: 0

    Component.onCompleted: {
        classDocuments = sdsModel.documentManager.getClassDocuments(platformStack.class_id)
    }

    onControlViewCountChanged: {
        matchVersion()
    }

    Connections {
        target: coreInterface

        onDownloadViewFinished: {
            fillBar1.width = barBackground1.width;
            console.info("Done downloading, ", JSON.stringify(payload))
        }

        onDownloadPlatformSingleFileProgress: {
            console.info("PROGRESS", JSON.stringify(payload))

        }
    }

    Connections {
        target: sdsModel.documentManager.getClassDocuments(platformStack.class_id).controlViewListModel
        onCountChanged: {
            controlViewCount = count
            classDocuments = sdsModel.documentManager.getClassDocuments(platformStack.class_id)
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
            if (classDocuments.controlViewListModel.installed(i)) {
                activeVersion = copyControlViewObject(i)
                upToDate = isUpToDate();
                break;
            }
        }
    }

    function isUpToDate() {
        for (let i = 0; i < controlViewCount; i++) {
            let version = classDocuments.controlViewListModel.version(i)
            if (version !== activeVersion.version && isVersionGreater(version)) {
                // if the version is greater, then set the latestVersion here
                latestVersion = copyControlViewObject(i);
                return false;
            }
        }
        latestVersion = activeVersion;
        return true;
    }

    function isVersionGreater(cmpVersion) {
        let activeVersionArr = activeVersion.version.split('.').map(num => parseInt(num, 10));
        let cmpVersionArr = cmpVersion.split('.').map(num => parseInt(num, 10));

        // fill in 0s for each missing version (e.g) 1.5 -> 1.5.0
        while (activeVersionArr.length < 3) {
            activeVersionArr.push(0)
        }

        while (cmpVersionArr.length < 3) {
            cmpVersionArr.push(0)
        }

        for (let i = 0; i < 3; i++) {
            if (activeVersionArr[i] > cmpVersionArr[i]) {
                return false;
            } else if (activeVersionArr[i] < cmpVersionArr[i]) {
                return true;
            }
        }

        // else they are the same version
        return false;
    }

    function copyControlViewObject(index) {
        let obj = {};

        obj["uri"] = classDocuments.controlViewListModel.uri(index);
        obj["md5"] = classDocuments.controlViewListModel.md5(index);
        obj["name"] = classDocuments.controlViewListModel.name(index);
        obj["version"] = classDocuments.controlViewListModel.version(index);
        obj["timestamp"] = classDocuments.controlViewListModel.timestamp(index);
        obj["installed"] = classDocuments.controlViewListModel.installed(index);

        return obj;
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

        MouseArea {
            anchors {
                fill: viewUpToDate
            }
            onClicked: {
                software.upToDate = false
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
                                    //root.viewVersion = "1.2.1"
                                    software.upToDate = true
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
