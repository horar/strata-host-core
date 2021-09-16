import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import tech.strata.theme 1.0

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
    property variant versionNumberList: Qt.application.version.split(".")
    property string versionNumber: "%1.%2.%3 Build %4".arg(versionNumberList[0]).arg(versionNumberList[1]).arg(versionNumberList[2]).arg(versionNumberList[3])
    property color dialogBg: "#eeeeee"
    property color lighterGrayColor: Qt.lighter(Theme.palette.gray, 1.33)
    property color darkerGrayColor: Qt.lighter(Theme.palette.gray, 1.15)

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

        SGWidgets.SGText {
            id: versionText
            width: parent.width
            padding: baseSpacing
            topPadding: 0

            anchors {
                top: appNameText.bottom
            }
            fontSizeMultiplier: 1.1
            wrapMode: Text.Wrap
            text: versionNumber
        }

        Column {
            id: imageColumn
            spacing: 20
            anchors {
                margins: baseSpacing
                top: versionText.bottom
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
                top: versionText.bottom
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
}
