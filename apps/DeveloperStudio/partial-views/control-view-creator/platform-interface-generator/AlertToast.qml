import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

Rectangle {
    id: alertToast
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: 0
    Layout.fillWidth: true
    color: "red"
    visible: Layout.preferredHeight > 0
    clip: true
    Accessible.name: text
    Accessible.role: Accessible.AlertMessage

    property alias text: alertText.text
    property alias textColor: alertText.color
    property bool running: alertAnimation.running || hideAlertAnimation.running
    property alias interval: closeAlertTimer.interval

    Text {
        id: alertText

        wrapMode: Text.WordWrap
        anchors {
            left: alertToast.left
            right: alertToast.right
            leftMargin: 5
            rightMargin: 5
            verticalCenter: alertToast.verticalCenter
        }
        horizontalAlignment:Text.AlignHCenter
        width: alertToast.width - 10
        color: "white"
    }
    // this will allow end user to close the toast
    MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: alertToast

        onPressed: {
            alertToast.hide()
        }
    }
    // this will default close the toast after 10 seconds
    Timer {
        id: closeAlertTimer

        interval: 0
        repeat: false

        onTriggered: {
            alertToast.hide()
        }
    }

    NumberAnimation {
        id: alertAnimation
        target: alertToast
        property: "Layout.preferredHeight"
        to: alertText.height + 20
        duration: 100

        onFinished: {
            if(alertToast.interval > 0){
                closeAlertTimer.start()
            }

        }
    }

    NumberAnimation {
        id: hideAlertAnimation
        target: alertToast
        property: "Layout.preferredHeight"
        to: 0
        duration: 100
        onStarted: alertToast.text = ""
    }

    function show() {
        if (closeAlertTimer.running) {
            closeAlertTimer.stop()
            alertToast.Layout.preferredHeight = 0
        }
        alertAnimation.start()
    }

    function hide () {
        if (closeAlertTimer.running) {
            closeAlertTimer.stop()
        }
        hideAlertAnimation.start()
    }
}
