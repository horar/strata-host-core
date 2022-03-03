/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0
import tech.strata.signals 1.0

ColumnLayout {
    spacing: 5

    property alias text: connectionStatus.text
    property alias headerText: searchingText.text
    property int currentId: -1

    onCurrentIdChanged: text = ""

    Text {
        id: searchingText
        color: "#888"
        text: "Connecting..."
        Layout.alignment: Qt.AlignHCenter
        font {
            family: Fonts.franklinGothicBold
        }
    }

    Text {
        id: connectionStatus
        color: "#888"
        text: ""
        Layout.alignment: Qt.AlignHCenter
        font {
            family: Fonts.franklinGothicBook
        }
        visible: text !== ""
    }

    AnimatedImage {
        id: indicator
        Layout.alignment: Qt.AlignHCenter
        source: "qrc:/images/loading.gif"

        onVisibleChanged: {
            if (visible) {
                indicator.playing = true
            } else {
                indicator.playing = false
            }
        }
    }

    Connections {
        target: Signals

        onConnectionStatus: {
            if(currentId === requestId){
                switch(status) {
                case XMLHttpRequest.UNSENT:
                    connectionStatus.text = "Building Request..."
                    break;
                case XMLHttpRequest.OPENED:
                    connectionStatus.text = "Waiting on Server Response..."
                    break;
                case XMLHttpRequest.HEADERS_RECEIVED:
                    connectionStatus.text = "Request Received From Server..."
                    break;
                case XMLHttpRequest.LOADING:
                    connectionStatus.text = "Processing Request..."
                    break;
                }
            }
        }
    }
}
