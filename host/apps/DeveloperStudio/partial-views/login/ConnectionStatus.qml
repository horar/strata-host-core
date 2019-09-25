import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0

ColumnLayout {
    spacing: 5
    property alias text: connectionStatus.text

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
            if(visible) {
                indicator.playing = true
            } else {
                indicator.playing = false
            }
        }
    }
}
