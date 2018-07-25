import QtQuick 2.10
import QtQuick.Controls 2.3

Item {
    id: root
    anchors {
        fill: parent
        margins: 15
    }

    Image {
        id: remoteImage
        source: remoteToggle.checked ? "qrc:/images/icons/remote-unlocked.png" : "qrc:/images/icons/remote-locked.png"
        anchors {
            horizontalCenter: root.horizontalCenter
            top: root.top
        }
    }

    SGSwitch {
        id: remoteToggle
        anchors {
            top: remoteImage.bottom
            topMargin: 15
            horizontalCenter: root.horizontalCenter
        }
        label: "Remote Support Access:"
        labelLeft: true
        checkedLabel: "Enabled"
        uncheckedLabel: "Disabled"
        labelsInside: true
        switchWidth: 80
        textColor: "white"
        grooveFillColor: "#00b842"
        grooveColor: "#777"

        // Usable Signals:
//        onReleased: console.log("Switch released")
//        onCanceled: console.log("Switch canceled")
//        onClicked: console.log("Switch clicked")
//        onPress: console.log("Switch pressed")
//        onPressAndHold: console.log("Switch pressed and held")

        onCheckedChanged: {
            var advertise
            if(remoteToggle.checked) {
                advertise = true
            }
            else {
                advertise = false
                remote_activity_label.visible = false
                remote_user_container.visible = false
                remote_user_label.visible = false
                remoteUserModel.clear()
            }
            var remote_json = {
                "hcs::cmd":"advertise",
                "payload": {
                    "advertise_platforms":advertise
                }
            }
            console.log("asking hcs to advertise the platforms",JSON.stringify(remote_json))
            coreInterface.sendCommand(JSON.stringify(remote_json))
        }
    }

    Label {
        id: hcs_token
        anchors {
            top: supportPhoneNumber.bottom
            horizontalCenter: parent.horizontalCenter
            margins: 30
        }
        text: advertiseButton.checked ? coreInterface.hcs_token_:""
        font.pointSize: Qt.platform.os == "osx"? 13 :8
        font.bold: true
        color: "black"
    }

    Connections {
        target: coreInterface
        onPlatformStateChanged: {
            remoteButton.checked = false
        }
    }
}
