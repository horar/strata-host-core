import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.logger 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_selection.js" as PlatformSelection

ColumnLayout {
    id: software

    property bool upToDate: true
    property var installedVersion: {
        "version": ""
    }
    property var latestVersion: ({})
    property bool downloadError: false
    property string activeDownloadUri: ""

    Component.onCompleted: {
        if (platformMetaDataInitialized) {
            initialize()
        }
    }

    Connections {
        target: platformStack

        onPlatformMetaDataInitializedChanged: {
            if (platformMetaDataInitialized) {
                initialize()
            }
        }
    }

    Connections {
        target: coreInterface

        onDownloadViewFinished: {
            if (payload.url === activeDownloadUri) {
                // View download requested here by user
                activeDownloadUri = ""
                progressUpdateText.percent = 1.0

                if (payload.error_string.length > 0) {
                    downloadError = true
                } else {
                    platformStack.controlViewContainer.installResource(latestVersion.version, payload.filepath)
                    installedVersion = latestVersion
                    upToDate = true
                    controlViewIsOutOfDate = false
                }
            } else if (latestVersion.hasOwnProperty("uri") && payload.url === latestVersion.uri) {
                // Latest view auto downloaded on first connection of device
                installedVersion = latestVersion
                upToDate = true
                controlViewIsOutOfDate = false
            }
        }

        onDownloadControlViewProgress: {
            if (platformStack.currentIndex === settingsContainer.stackIndex && payload.url === activeDownloadUri) {
                let progressPercent = payload.bytes_received / payload.bytes_total
                if (progressPercent >= 0 && progressPercent <= 100) {
                    progressUpdateText.percent = progressPercent
                }
            }
        }
    }

    function initialize() {
        populateLatestVersion()
        populateInstalledVersion()
        determineUpToDate()
    }

    // Get newest version information from DB
    function populateLatestVersion() {
        const latestVersionIndex = platformStack.controlViewContainer.controlViewList.getLatestVersionIndex();
        if (latestVersionIndex >= 0) {
            latestVersion = platformStack.controlViewContainer.controlViewList.get(latestVersionIndex);
        }
    }

    function populateInstalledVersion() {
        // Check for preferred version and find it on disk
        const userPreferredVersion = controlViewContainer.getInstalledVersion(NavigationControl.context.user_id);
        if (userPreferredVersion) {
            for (let i = 0; i < controlViewContainer.controlViewList.count; i++) {
                const listing = controlViewContainer.controlViewList.get(i)
                if (listing.version === userPreferredVersion.version && listing.filepath === userPreferredVersion.path) {
                    // Successfully found user's preferred version on disk
                    installedVersion = {
                        "version": userPreferredVersion.version
                    }
                    return
                }
            }

            // Preferred version not found on disk
            // Possible if HCS DB manually cleared but version user settings uncleared
            console.warn(Logger.devStudioCategory, "User's preferred version not found on disk, removing preferred version setting")
            let versionsInstalled = versionSettings.readFile("versionControl.json");
            controlViewContainer.saveInstalledVersion(false, "", versionsInstalled);
        }
    }

    function determineUpToDate() {
        if (objectIsEmpty(latestVersion)) {
            // upToDate remains true
            console.warn(Logger.devStudioCategory, "Could not find any control views on server for class id:", platformStack.class_id)
            return;
        }

        if (SGVersionUtils.greaterThan(latestVersion.version, installedVersion.version)) {
            upToDate = false
            controlViewIsOutOfDate = true
        }

        if (installedVersion.version === "") {
            upToDate = false
            // No need to modify controlViewIsOutOfDate when no installed version:
            // View will automatically be downloaded/installed on first platform connection
        }
    }

    function objectIsEmpty(obj) {
        return Object.keys(obj).length === 0 && obj.constructor === Object
    }

    Text {
        text: "Software Settings:"
        Accessible.name: text
        Accessible.role: Accessible.StaticText
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
            if (installedVersion.version !== "") {
                return installedVersion.version;
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
                        z: -1 // place white background behind icon
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
                            opacity: downloadColumn.downloadInProgress ? .5 : 1
                        }
                    }

                    ColumnLayout {
                        id: downloadColumn
                        width: parent.width
                        visible: downloadInProgress || downloadError

                        property bool downloadInProgress: activeDownloadUri !== ""

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
                                color: downloadError ? "red" : "#57d445"
                                height: barBackground1.height
                                width: 0

                                function reset() {
                                    width = 0
                                    downloadError = false
                                    progressUpdateText.percent = 0.0
                                }
                            }
                        }

                        function startDownload() {
                            let updateCommandPayload = {
                                "url": software.latestVersion.uri,
                                "md5": software.latestVersion.md5,
                                "class_id": platformStack.class_id
                            }
                            activeDownloadUri = software.latestVersion.uri
                            progressBar.reset();
                            sdsModel.strataClient.sendRequest("download_view", updateCommandPayload);
                        }
                    }
                }

                MouseArea {
                    id: downloadButtonMouseArea
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: downloadColumn.downloadInProgress ? Qt.ArrowCursor : Qt.PointingHandCursor
                    enabled: downloadColumn.downloadInProgress === false

                    onClicked: {
                        downloadColumn.startDownload();
                    }
                }
            }
        }
    }

    ListModel {
        id: viewVersions
    }
}
