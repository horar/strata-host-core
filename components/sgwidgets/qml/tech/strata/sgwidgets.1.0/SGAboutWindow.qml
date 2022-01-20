/*
 * Copyright (c) 2018-2022 onsemi.
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
    property variant versionList: AppInfo.fullVersion.split("-")
    property int versionListLength: versionList.length
    property string versionNum: "<b>version:</b> %1".arg(AppInfo.version)
    property string versionNumber: versionList[versionListLength - 1] === "uncommited" ? versionNum + "-" + versionList[versionListLength - 1]  : versionNum
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
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: baseSpacing
            }

            fontSizeMultiplier: 1.5
            wrapMode: Text.Wrap
            font.bold: true
            text: Qt.application.name
        }

        Flickable {
            id: versionFlick
            anchors {
                top: appNameText.bottom
                margins: baseSpacing
                left: parent.left
                right: parent.right
            }

            width: parent.width
            height: versionRow.height + horizontalScrollBar.height
            contentWidth: versionRow.width
            contentHeight: versionRow.height + horizontalScrollBar.height
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ScrollBar.horizontal: ScrollBar {
                id: horizontalScrollBar
                anchors.bottom: versionFlick.bottom
                height: 6
                policy: ScrollBar.AlwaysOn
                visible: versionFlick.width < versionFlick.contentWidth
            }

            Row {
                id: versionRow
                spacing: 4

                SGWidgets.SGTextEdit {
                    id: versionText
                    wrapMode: Text.Wrap
                    text: versionExpanded ? versionNumberExpanded : versionNumber
                    readOnly: true
                    selectByMouse: true
                    textFormat: TextEdit.RichText
                }

                SGWidgets.SGIconButton {
                    id: showButton
                    anchors.verticalCenter: versionText.verticalCenter

                    hintText: versionExpanded ? "Show less" : "Show more"
                    icon.source: versionExpanded ? "qrc:/sgimages/chevron-left.svg" : "qrc:/sgimages/chevron-right.svg"
                    iconColor: Theme.palette.black
                    iconSize: 0.7*versionText.height
                    backgroundOnlyOnHovered: false

                    onClicked: {
                        versionExpanded = !versionExpanded
                    }
                }
            }
        }

        Column {
            id: imageColumn
            spacing: 20
            anchors {
                margins: baseSpacing
                top: versionFlick.bottom
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
            anchors {
                margins: baseSpacing
                left: imageColumn.right
                top: versionFlick.bottom
            }

            background: Rectangle {
                color: dialogBg
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
            anchors {
                top: tabBar.bottom
                left: imageColumn.right
                bottom: closeButton.top
                right: parent.right
                margins: baseSpacing
                topMargin: 0
            }

            currentIndex: tabBar.currentIndex

            Rectangle {
                id: generalTab
                color: lighterGrayColor

                Flickable {
                    id: generalFlick
                    width: parent.width
                    height: parent.height
                    contentWidth: parent.width
                    contentHeight: disclaimerTextLabel.y + disclaimerTextLabel.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: 8
                        anchors.right: generalFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: generalFlick.height < generalFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: infoText
                        anchors {
                            top: parent.top
                            margins: baseSpacing
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
                        fontSizeMultiplier: 1.1
                        font.italic: true
                        wrapMode: Text.Wrap
                        text: "\"Designed by engineers for engineers to securely deliver software & information, " +
                            "efficiently bringing you the focused info you need, nothing you don’t.\"\n"
                    }

                    SGWidgets.SGText {
                        id: copyrightText
                        anchors {
                            margins: baseSpacing
                            top: infoText.bottom
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: Qt.application.name + " is part of Strata development kit.\n" +
                            "\n" +
                            "Copyright \u00a9 2018-2022 " + Qt.application.organization + ".\n"+
                            "All rights reserved.\n"
                    }

                    SGWidgets.SGText {
                        id: disclaimerTextLabel
                        anchors {
                            margins: baseSpacing
                            top: copyrightText.bottom
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
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
                        width: 8
                        anchors.right: attributionsFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: attributionsFlick.height < attributionsFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: attributionTextLabel
                        anchors {
                            margins: baseSpacing
                            top: parent.top
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
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
                    contentHeight: repositoryRefrenceText.y + repositoryRefrenceText.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        width: 8
                        anchors.right: contributionsFlick.right
                        policy: ScrollBar.AlwaysOn
                        visible: contributionsFlick.height < contributionsFlick.contentHeight
                    }

                    SGWidgets.SGText {
                        id: openSourceText
                        anchors {
                            margins: baseSpacing
                            top: parent.top
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: "Strata Development Kit is an open source project." +
                              " Contributions are welcomed through our GitHub repository."
                    }

                    SGWidgets.SGText {
                        id: repositoryRefrenceText
                        anchors {
                            margins: baseSpacing
                            top: openSourceText.bottom
                            left: parent.left
                        }

                        width: parent.width - 2*baseSpacing
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
                margins: baseSpacing
                bottom: parent.bottom
                right: parent.right
            }
            text: "Close"
            color: darkerGrayColor
            onClicked: window.close()
        }
    }

    function createVersionString() {
        var version = versionNum
        if (AppInfo.stageOfDevelopment !== "") {
            version += "<b> stage of development: </b> %1".arg(AppInfo.stageOfDevelopment)
        }
        if (AppInfo.buildId !== "") {
            version += "<b> build id: </b> %1".arg(AppInfo.buildId)
        }
        if (AppInfo.gitRevision !== "") {
            version += "<b> git hash: </b> %1".arg(AppInfo.gitRevision)
        }
        if (AppInfo.numberOfCommits !== "") {
            version += "<b> number of commits: </b> %1".arg(AppInfo.numberOfCommits)
        }
        if (versionList[versionListLength - 1] === "uncommited") {
            version += "<b> " + versionList[versionListLength - 1] + " </b>"
        }
        return version
    }
}
