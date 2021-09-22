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
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import tech.strata.theme 1.0
import tech.strata.AppInfo 1.0

SGWidgets.SGWindow {
    id: window
    width: 600
    height: 400
    minimumWidth: 600
    minimumHeight: 400

    title: qsTr("About")
    visible: true
    modality: Qt.ApplicationModal
    flags: Qt.Dialog

    property int baseSpacing: 8

    property alias appLogoSource: appLogoImage.source
    property string defaultAttributionText
    property string additionalAttributionText
    property string attributionText
    property string versionNum: "<b>version:</b> %1".arg(AppInfo.version)
    property string versionNumber: AppInfo.fullVersion.includes("dirty") ? versionNum + "-uncommitted" : versionNum
    property string versionNumberExpanded: createVersionString()
    property color dialogBg: "#eeeeee"
    property color lighterGrayColor: Qt.lighter(Theme.palette.gray, 1.33)
    property color darkerGrayColor: Qt.lighter(Theme.palette.gray, 1.15)
    property bool versionExpanded: false

    defaultAttributionText: {
        return "Built on the awesome Qt/QML framework<br>"+
                "<a href=\"https://www.qt.io\">https://www.qt.io</a><br>"+
                "<br>"+
                "Some icons used in "+Qt.application.name+" belong to Font Awesome toolkit, licensed CC BY 4.0:<br>"+
                "<a href=\"https://github.com/FortAwesome/Font-Awesome\">https://github.com/FortAwesome/Font-Awesome</a><br>"+
                "<a href=\"https://creativecommons.org/licenses/by/4.0/\">https://creativecommons.org/licenses/by/4.0/</a><br>"
    }

    attributionText: {
        var t = defaultAttributionText

        if (additionalAttributionText.length > 0) {
            t += "<br>"+ additionalAttributionText
        }

        return t
    }

    Item {
        anchors.fill: parent

        focus: true
        Keys.onEscapePressed: {
            window.close()
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            color: dialogBg
        }

        SGWidgets.SGText {
            id: appNameText
            width: parent.width
            padding: baseSpacing

            fontSizeMultiplier: 1.5
            wrapMode: Text.Wrap
            font.bold: true
            text: Qt.application.name
        }

        Row {
            id: versionRow
            width: parent.width
            padding: baseSpacing
            spacing: baseSpacing
            topPadding: 0

            anchors {
                top: appNameText.bottom
            }

            SGWidgets.SGText {
                id: versionText

                wrapMode: Text.Wrap
                text: versionExpanded ? versionNumberExpanded : versionNumber
            }

            SGWidgets.SGButton {
                id: showButton
                height: versionText.height
                width: 20
                color: darkerGrayColor
                text: "..."
                visible: versionExpanded ? false : true
                onClicked: versionExpanded = !versionExpanded
            }
        }

        Column {
            id: imageColumn
            spacing: 20
            anchors {
                margins: baseSpacing
                top: versionRow.bottom
                left: parent.left
            }

            Image {
                id: appLogoImage
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 100
                smooth: true
            }

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:/sgimages/strata-logo.svg"
                fillMode: Image.PreserveAspectFit
                sourceSize.width: 100
                smooth: true
            }
        }

        TabBar {
            id: tabBar
            background: Rectangle {
                color: dialogBg
            }

            anchors {
                left: imageColumn.right
                top: versionRow.bottom
                leftMargin: baseSpacing
            }

            TabButton {
                id: generalButton
                text: qsTr("General")

                contentItem: Text {
                    text: generalButton.text
                    color: "black"
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                }

                background: Rectangle {
                    color: tabBar.currentIndex == 0 ? lighterGrayColor : darkerGrayColor
                }
            }

            TabButton {
                id: attributionsButton
                text: qsTr("Attributions")
                width: implicitWidth

                contentItem: Text {
                    text: attributionsButton.text
                    color: "black"
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                }

                background: Rectangle {
                    color: tabBar.currentIndex == 1 ? lighterGrayColor : darkerGrayColor
                }
            }

            TabButton {
                id: contributionsButton
                text: qsTr("Contributions")
                width: implicitWidth

                contentItem: Text {
                    text: contributionsButton.text
                    color: "black"
                    font.pixelSize: SGWidgets.SGSettings.fontPixelSize
                }

                background: Rectangle {
                    color: tabBar.currentIndex == 2 ? lighterGrayColor : darkerGrayColor
                }
            }
        }

        StackLayout {
            id:tabLayout
            currentIndex: tabBar.currentIndex

            anchors {
                top: tabBar.bottom
                left: imageColumn.right
                bottom: closeButton.top
                right: parent.right
                margins: baseSpacing
                topMargin: 0
            }

            Rectangle {
                id: generalTab
                color: lighterGrayColor

                Flickable {
                    id: generalFlick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: infoText.height + copyrightText.height + disclaimerTextLabel.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: visible ? 8 : 0
                        anchors.right: generalFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: generalFlick.height < generalFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: infoText
                        width: parent.width
                        padding: baseSpacing

                        fontSizeMultiplier: 1.1
                        font.italic: true
                        wrapMode: Text.Wrap
                        text: "\"Designed by engineers for engineers to securely deliver software & information, " +
                            "efficiently bringing you the focused info you need, nothing you don’t.\""
                    }

                    SGWidgets.SGText {
                        id: copyrightText
                        width: parent.width
                        padding: baseSpacing
                        anchors.top: infoText.bottom

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: Qt.application.name + " is part of Strata development kit.\n" +
                            "\n"+
                            "Copyright \u00a9 2018-2021 " + Qt.application.organization + ".\n"+
                            "All rights reserved."
                    }

                    SGWidgets.SGText {
                        id: disclaimerTextLabel
                        width: parent.width
                        padding: baseSpacing
                        anchors.top: copyrightText.bottom

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: "The program is provided AS IS WITHOUT WARRANTY OF ANY KIND, "+
                            "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES "+
                            "OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND "+
                            "NONINFRINGEMENT."
                    }
                }
            }

            Rectangle {
                id: attributionsTab
                color: lighterGrayColor

                Flickable {
                    id: attributionsFlick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: attributionTextLabel.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: visible ? 8 : 0
                        anchors.right: attributionsFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: attributionsFlick.height < attributionsFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: attributionTextLabel
                        width: parent.width
                        padding: baseSpacing

                        anchors.topMargin: 2*baseSpacing

                        wrapMode: Text.Wrap
                        font.italic: true
                        textFormat: Text.RichText
                        text: attributionText
                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }
                }
            }

            Rectangle {
                id: contributionsTab
                color: lighterGrayColor

                Flickable {
                    id: contributionsFlick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: openSourceText.height + repositoryRefrenceText.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: visible ? 8 : 0
                        anchors.right: contributionsFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: contributionsFlick.height < contributionsFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: openSourceText
                        width: parent.width
                        padding: baseSpacing

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: "Strata Development Kit is an open source project." +
                              " Contributions are welcomed through our GitHub repository."
                    }

                    SGWidgets.SGText {
                        id: repositoryRefrenceText
                        width: parent.width
                        padding: baseSpacing
                        anchors.top: openSourceText.bottom

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        textFormat: Text.RichText
                        text: "Source code and contribution instructions are available on GitHub:<br>"+
                              "<a href=\"https://github.com/stratadeveloperstudio\">https://github.com/stratadeveloperstudio</a>"
                        onLinkActivated: {
                            Qt.openUrlExternally(link)
                        }
                    }
                }
            }
        }

        SGWidgets.SGButton {
            id: closeButton
            anchors {
                bottom: parent.bottom
                bottomMargin: baseSpacing
                rightMargin: baseSpacing
                right: parent.right
            }
            text: "Close"
            color: darkerGrayColor
            onClicked: window.close()
        }
    }

    function createVersionString() {
        var versionList = ["stage of development", "build id", "git hash", "uncommitted changes"]
        var version = versionNum
        if (AppInfo.stageOfDevelopment !== "") {
            version += "<b> %1: </b> %2".arg(versionList[0]).arg(AppInfo.stageOfDevelopment)
        }
        if (AppInfo.buildId !== "") {
            version += "<b> %1: </b> %2".arg(versionList[1]).arg(AppInfo.buildId)
        }
        if (AppInfo.gitRevision !== "") {
            version += "<b> %1: </b> %2".arg(versionList[2]).arg(AppInfo.gitRevision)
        }
        if (AppInfo.fullVersion.includes("dirty")) {
            version += "<b> %1 </b>".arg(versionList[3])
        }
        return version
    }
}
