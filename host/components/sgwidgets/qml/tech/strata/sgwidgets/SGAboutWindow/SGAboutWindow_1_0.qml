import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Window 2.12

SGWidgets.SGWindow {
    id: window
    width: 500
    height: 400
    minimumWidth: 500
    minimumHeight: 400

    title: "About " + Qt.application.name
    visible: true
    modality: Qt.ApplicationModal

    property int baseSpacing: 8

    property alias appLogoSource: appLogoImage.source
    property string defaultAttributionText
    property string additionalAttributionText
    property string attributionText

    defaultAttributionText: {
        return "Attributions:<br>"+
                "Build on awesome Qt/QML framework<br>"+
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

            SGWidgets.SGText {
                id: infoText
                width: flick.width - infoText.x

                fontSizeMultiplier: 1.1
                wrapMode: Text.Wrap
                text: Qt.application.name + " " + Qt.application.version + "\n" +
                      "\n" +
                      "Copyright \u00a9 2019 " + Qt.application.organization + ".\n"+
                      "All rights reserved.\n"+
                      "\n" +
                      Qt.application.name + " is part of Strata development kit."
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