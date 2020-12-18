import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQml 2.12
import QtGraphicalEffects 1.0

import "qrc:/js/login_utilities.js" as Authenticator
import "qrc:/js/constants.js" as Constants

import tech.strata.commoncpp 1.0
import tech.strata.signals 1.0
import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.notifications 1.0

Rectangle {
    id: root

    property string currentUser: Constants.GUEST_USER_ID
    property int expandWidth: 300
    readonly property bool isOpen: width > 0

    layer.enabled: true
    layer.effect: DropShadow {
        anchors.fill: root
        source: root
        color: Theme.palette.gray
        horizontalOffset: -1
        verticalOffset: 0
        cached: true
        radius: 8
        smooth: true
        samples: radius*2
    }

    color: Theme.palette.white

    onCurrentUserChanged: {
        sortedModel.invalidate()
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: false

        onClicked: {
            mouse.accepted = false
        }
    }

    SGSortFilterProxyModel {
        id: sortedModel
        sourceModel: Notifications.model
        sortEnabled: true
        invokeCustomFilter: true
        sortRole: "date"
        sortAscending: false

        function lessThan(index1, index2) {
            const item1 = sourceModel.get(index1);
            const item2 = sourceModel.get(index2);

            return item1.date < item2.date
        }

        function filterAcceptsRow(index) {
            const item = sourceModel.get(index);

            return (item.to === "all" || item.to === currentUser)
        }
    }

    ListView {
        anchors {
            top: parent.top
            bottom: footer.top
            left: parent.left
            right: parent.right
        }
        clip: true
        model: sortedModel
        delegate: NotificationsInboxDelegate {
            modelIndex: index
        }
    }

    Rectangle {
        id: footer
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: 25

        border.color: Theme.palette.black
        border.width: 1

        Text {
            id: collapseExpandIcon
            text: isOpen ? "\u00bb" : "\u00ab"
            font.pixelSize: 24
            verticalAlignment: Text.AlignVCenter
            anchors {
                left: parent.left
                leftMargin: 5
                top: parent.top
                bottom: parent.bottom
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    toggle()
                }
            }
        }
    }

    NumberAnimation {
        id: showAnimation
        target: root
        property: "width"
        duration: 250
        to: expandWidth
        easing.type: Easing.InOutQuad
    }


    NumberAnimation {
        id: hideAnimation
        target: root
        property: "width"
        duration: 250
        to: 0
        easing.type: Easing.InOutQuad
    }

    function toggle() {
        if (isOpen) {
            hideAnimation.restart()
        } else {
            showAnimation.restart()
        }
    }

    function open() {
        if (!showAnimation.running) {
            showAnimation.start()
        }
    }

    function close() {
        if (!hideAnimation.running) {
            hideAnimation.start()
        }
    }

    Connections {
        target: Signals

        onLoginResult: {
            const resultObject = JSON.parse(result)
            //console.log(Logger.devStudioCategory, "Login result received")
            if (resultObject.response === "Connected") {
                currentUser = resultObject.user_id
            }
        }

        onLogout: {
            close()
            for (let i = 0; i < Notifications.model.count; i++) {
                // Clear any actions when the user logs out
                Notifications.model.get(i).actions.clear()
            }

            currentUser = ""
        }

        onValidationResult: {
            currentUser = Authenticator.settings.user
        }
    }
}
