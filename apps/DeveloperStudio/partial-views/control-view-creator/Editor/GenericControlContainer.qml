import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import QtQml 2.12

import tech.strata.signals 1.0
import "../components"

Loader {
    Layout.fillWidth: true
    Layout.fillHeight: true

    property bool documentation: false
    property url webUrl
    onDocumentationChanged: {
        console.log(documentation)
        if(documentation) {
            sourceComponent = sgWebView
        }
    }

    sourceComponent: unSupported

    Component {
        id: unSupported

        Rectangle {
            anchors.fill: parent
            color: "#666"

            SGText {
                id: errorIntro

                anchors {
                    centerIn: parent
                }

                color: "white"
                font.bold: true
                fontSizeMultiplier: 2
                text: "Unsupported file format"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }
    Component {
        id: sgWebView
        SGWebView{
            id: webView
            url: webUrl
        }
    }

    Connections {
        target: Signals

        onGoToDocumentation: {
            webUrl = newUrl
            documentation = true
        }
    }

}
