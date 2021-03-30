import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Window 2.12

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

    defaultAttributionText: {
        return "Attributions:<br>"+
                "Built on the awesome Qt/QML framework<br>"+
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
            color:"#eeeeee"
        }

        Flickable {
            id: flick
            anchors {
                fill: parent
                margins: 8
            }

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            contentWidth: flick.width
            contentHeight: attributionTextLabel.y + attributionTextLabel.height

            ScrollBar.vertical: ScrollBar {
                parent: flick.parent
                width: 8
                anchors {
                    top: flick.top
                    bottom: flick.bottom
                    right: parent.right
                    rightMargin: 1
                }

                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: flick.height < flick.contentHeight
            }

            Row {
                id: infoWrapper
                spacing: baseSpacing

                Column {
                    spacing: baseSpacing

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

                Column {
                    width: flick.width - x

                    SGWidgets.SGText {
                        width: parent.width

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: Qt.application.name + " " + versionNumber + "\n"
                    }

                    SGWidgets.SGText {
                        width: parent.width

                        fontSizeMultiplier: 1.1
                        font.italic: true
                        wrapMode: Text.Wrap
                        text: "\"Designed by engineers for engineers to securely deliver software & information, " +
                              "efficiently bringing you the focused info you need, nothing you don’t.\"\n"
                    }

                    SGWidgets.SGText {
                        width: parent.width

                        fontSizeMultiplier: 1.1
                        wrapMode: Text.Wrap
                        text: Qt.application.name + " is part of Strata development kit.\n" +
                              "\n"+
                              "Copyright \u00a9 2018-2021 " + Qt.application.organization + ".\n"+
                              "All rights reserved."
                    }
                }
            }

            SGWidgets.SGText {
                id: disclaimerTextLabel
                width: flick.width
                anchors {
                    top: infoWrapper.bottom
                    topMargin: baseSpacing
                }

                fontSizeMultiplier: 1.1
                wrapMode: Text.Wrap
                text: "The program is provided AS IS WITHOUT WARRANTY OF ANY KIND, "+
                      "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES "+
                      "OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND "+
                      "NONINFRINGEMENT."
            }

            SGWidgets.SGText {
                id: attributionTextLabel
                width: flick.width
                anchors {
                    top: disclaimerTextLabel.bottom
                    topMargin: 2*baseSpacing
                }

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
