import QtQuick 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import QtQuick.Layouts 1.3

Rectangle {
    id: alertToast
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredHeight: 0
    color: "red"
    visible: Layout.preferredHeight > 0
    clip: true
    property alias text: alertText.text
    property bool running: alertAnimation.running || hideAlertAnimation.running
    property alias interval: closeAlertTimer.interval
    Accessible.name: text
    Accessible.role: Accessible.AlertMessage

    SGIcon {
        id: alertIcon
        source: Qt.colorEqual(alertToast.color, "red") ? "qrc:/sgimages/exclamation-circle.svg" : "qrc:/sgimages/check-circle.svg"
        anchors {
            left: alertToast.left
            verticalCenter: alertToast.verticalCenter
            leftMargin: alertToast.height/2 - height/2
        }
        height: 30
        width: 30
        iconColor: "white"
    }

    SGText {
        id: alertText
        font {
            family: Fonts.franklinGothicBold
        }
        wrapMode: Text.WordWrap
        anchors {
            left: alertIcon.right
            right: alertToast.right
            rightMargin: 5
            verticalCenter: alertToast.verticalCenter
        }
        horizontalAlignment:Text.AlignHCenter
        color: "white"
    }
    // this will allow end user to close the toast
    MouseArea {
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        anchors.fill: alertToast

        onPressed: {
            hide()
        }
    }
    // this will default close the toast after 10 seconds
    Timer {
        id: closeAlertTimer

        interval: 0
        repeat: false

        onTriggered: {
            hide()
        }
    }

    NumberAnimation {
        id: alertAnimation
        target: alertToast
        property: "Layout.preferredHeight"
        to: alertIcon.height + 10
        duration: 100

        onFinished: {
            if(interval > 0){
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
        alertAnimation.start()
    }

    function hide () {
        hideAlertAnimation.start()
    }

}
