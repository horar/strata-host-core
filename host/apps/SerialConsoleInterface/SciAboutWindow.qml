import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import QtQuick.Window 2.12

Window {
    id: window
    width: 500
    height: 350
    minimumWidth: 500
    minimumHeight: 350

    title: "About " + Qt.application.name
    visible: true

    property int baseSpacing: 8

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
        contentHeight: attributionText.y + attributionText.height

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
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/images/sci-logo.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: 70
                }

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    source: "qrc:/images/strata-logo.svg"
                    fillMode: Image.PreserveAspectFit
                    sourceSize.height: 70
                }
            }

            SGWidgets.SGText {
                id: infoText
                width: flick.width - infoText.x

                fontSizeMultiplier: 1.1
                wrapMode: Text.Wrap
                text: Qt.application.name + " " + Qt.application.version + "\n" +
                      "\n" +
                      "Copyright \u00a9 2018-2019 " + Qt.application.organization + ".\n"+
                      "All rights reserved.\n"+
                      "\n" +
                      Qt.application.name + " is part of Strata development kit."
            }
        }

        SGWidgets.SGText {
            id: disclaimerText
            width: flick.width
            anchors {
                top: infoWrapper.bottom
                topMargin: 2*baseSpacing
            }

            fontSizeMultiplier: 1.1
            wrapMode: Text.Wrap
            text: "The program is provided AS IS WITHOUT WARRANTY OF ANY KIND, "+
                  "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES "+
                  "OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND "+
                  "NONINFRINGEMENT."
        }

        SGWidgets.SGText {
            id: attributionText
            width: flick.width
            anchors {
                top: disclaimerText.bottom
                topMargin: 2*baseSpacing
            }

            wrapMode: Text.Wrap
            font.italic: true
            text: "Attributions:\n"+
                  "Some icons used in "+Qt.application.name+" belong to Font Awesome toolkit, licensed CC BY 4.0:\n"+
                  "https://github.com/FortAwesome/Font-Awesome\n"+
                  "https://creativecommons.org/licenses/by/4.0/"
        }
    }
}
