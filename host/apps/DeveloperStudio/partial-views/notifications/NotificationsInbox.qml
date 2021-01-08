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
            const filterLevel = filterBox.currentIndex - 1;

            if (filterLevel < 0) {
                return (item.to === "all" || item.to === currentUser)
            } else {
                return item.level === filterLevel && (item.to === "all" || item.to === currentUser)
            }
        }
    }

    ColumnLayout {
        id: headerContainer
        width: parent.width

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 30
            color: Theme.palette.gray

            SGIcon {
                id: collapseExpandIcon
                source: "qrc:/sgimages/chevron-right.svg"
                width: 20
                height: 20
                anchors {
                    left: parent.left
                    leftMargin: 5
                    top: parent.top
                    bottom: parent.bottom
                }
                verticalAlignment: Image.AlignVCenter

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        toggle()
                    }
                }
            }

            Text {
                text: "NOTIFICATIONS"
                font.bold: true
                font.pixelSize: 14
                anchors {
                    left: collapseExpandIcon.right
                    leftMargin: 10
                    top: parent.top
                    right: notificationCountContainer.left
                    bottom: parent.bottom
                }
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                id: notificationCountContainer
                anchors {
                    right: parent.right
                    top: parent.top
                    bottom: parent.bottom
                    topMargin: 5
                    bottomMargin: 5
                    rightMargin: 5
                }
                width: 30
                height: 15
                radius: width / 2
                border.color: {
                    const idx = filterBox.currentIndex
                    if (idx <= 1) {
                        return Theme.palette.black
                    } else if (idx === 2) {
                        return Theme.palette.warning
                    } else {
                        return Theme.palette.error
                    }
                }

                color: "transparent"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: sortedModel.count
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: notificationCountContainer.border.color
                }
            }
        }

        RowLayout {
            Layout.preferredHeight: 30
            Layout.leftMargin: 5
            Layout.rightMargin: 5

            Text {
                Layout.fillHeight: true
                text: "Filter by Type:"
                font.bold: true
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
            }

            SGComboBox {
                id: filterBox

                Layout.fillHeight: true
                Layout.fillWidth: true
                model: ["All", "Info", "Warning", "Critical"]
                onCurrentIndexChanged: {
                    sortedModel.invalidate()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.palette.darkGray
        }

    }

    ListView {
        visible: parent.visible && sortedModel.count > 0
        anchors {
            top: headerContainer.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        model: sortedModel
        delegate: NotificationsInboxDelegate {
            modelIndex: index
        }
    }

    Text {
        visible: parent.visible && sortedModel.count === 0
        anchors {
            top: headerContainer.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        text: "No Notifications"
        color: Theme.palette.lightGray
        font.pixelSize: 24
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WrapAnywhere
    }

    NumberAnimation {
        id: showAnimation
        target: root
        property: "width"
        duration: 250
        to: expandWidth
        easing.type: Easing.InOutQuad
        onStarted: {
            root.visible = true
        }
    }


    NumberAnimation {
        id: hideAnimation
        target: root
        property: "width"
        duration: 250
        to: 0
        easing.type: Easing.InOutQuad
        onFinished: {
            root.visible = false
        }
    }

    function toggle() {
        if (isOpen) {
            hideAnimation.restart()
        } else {
            showAnimation.restart()
        }
    }

    function open() {
        if (!isOpen && !showAnimation.running) {
            showAnimation.start()
        }
    }

    function close() {
        if (isOpen && !hideAnimation.running) {
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
