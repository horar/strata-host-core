import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    width: parent.width
    height: parent.height
    minimumWidth: 400
    minimumHeight: 450
    maximumHeight: 450
    maximumWidth: 400
    visible: false
    flags: Qt.Tool

    signal start()

    property string rep_type: "pull"


    Rectangle {
        id: background
        anchors.fill: parent
        color: "#393e46"
        border {
            width: 2
            color: "#b55400"
        }
        StatusBar {
            id: statusBar
            anchors.bottom: parent.bottom
            width: parent.width
            height: 25
        }
        ColumnLayout {
            spacing: 15
            width: parent.width - 10
            height: parent.height - 130
            anchors {
                centerIn: parent
            }
            ChannelSelector{
                id: channelLayoutContainer
                Layout.preferredHeight: 160
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop

            }
            ChannelSelectorRadioButtons {
                id: selectorContainer
                Layout.preferredHeight: 30
                Layout.preferredWidth: parent.width / 2
                Layout.alignment: Qt.AlignHCenter + Qt.AlignTop
            }
            Button {
                id: submitButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: 80
                Layout.alignment: Qt.AlignHCenter
                text: "Submit"
                onClicked: warningPopup.visible = true
            }
        }
    }
    WarningPopup {
        id: warningPopup
        onAllow: {
            warningPopup.visible = false
            root.close()
            start()
        }
        onDeny: {
            warningPopup.close()
        }
    }
}
