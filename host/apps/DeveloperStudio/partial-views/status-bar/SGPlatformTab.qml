import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/navigation_control.js" as NavigationControl

Rectangle {
    id: platformTabRoot
    height: 40
    width: 200

    color: mouse.containsMouse ? "#34993b" : inView ? "#33b13b" : "black"

    property color menuColor: "#33b13b"

    property string view: model.view
    property string name: model.name
    property string class_id: model.class_id
    property bool connected: model.connected
    property var available: model.available
    property int index: model.index
    property bool inView: true
    property string selectedButtonIcon: ""

    Component.onCompleted: {
        populateButtons()
        setControlIcon()
        setSelectedButton()
    }

    onConnectedChanged: {
        setControlIcon()
    }

    function menuClicked(index) {
        let selection = buttonModel.get(index)
        if (selection.view !== view) {
            dropDownPopup.close()

            if (selection.view === "close"){
                sdsModel.coreInterface.disconnectPlatform() // cancels any active collateral downloads
                sdsModel.documentManager.clearDocuments();

                let data = {"class_id": platformTabRoot.class_id}
                NavigationControl.updateState(NavigationControl.events.CLOSE_PLATFORM_VIEW_EVENT, data)  // must call last - model entry/delegate begins destruction
            } else {
                model.view = selection.view
                setSelectedButton()
                platformTabRoot.bringIntoView()
            }
        }
    }

    function bringIntoView() {
        let data = {"index": platformTabRoot.index + 1} // Offset by 1 since index 0 is always platform selector view
        NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
    }

    function populateButtons() {
        let buttonData
        if (available.control) {
            buttonData = {
                "text": "Control",
                "view": "control",
                "icon": "",
                "selected": false
            }
            buttonModel.append(buttonData)
        }

        if (available.documents) {
            buttonData = {
                "text": "Documents",
                "view": "collateral",
                "icon": "qrc:/images/icons/file.svg",
                "selected": false
            }
            buttonModel.append(buttonData)
        }

        buttonData = {
            "text": "Close Platform",
            "view": "close",
            "icon": "qrc:/images/icons/times.svg",
            "selected": false
        }
        buttonModel.append(buttonData)
    }

    function setControlIcon () {
        for (let i = 0; i < buttonModel.count; i++) {
            if (buttonModel.get(i).view === "control") {
                buttonModel.get(i).icon = (connected ? "qrc:/images/icons/sliders-h.svg" : "qrc:/images/icons/disconnected.svg")
                if (buttonModel.get(i).selected) {
                    selectedButtonIcon = buttonModel.get(i).icon
                }
                break
            }
        }
    }

    function setSelectedButton () {
        for (let i = 0; i < buttonModel.count; i++) {
            if (view === buttonModel.get(i).view) {
                buttonModel.get(i).selected = true
                selectedButtonIcon = buttonModel.get(i).icon
            } else {
                buttonModel.get(i).selected = false
            }
        }
    }

    RowLayout {
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 10
            right: parent.right
            rightMargin: 10
        }
        spacing: 10

        SGText {
            color: "white"
            text: platformTabRoot.name
            Layout.fillWidth: true
            elide: Text.ElideRight
            Layout.preferredHeight: contentHeight + 2 // hack to force franklinGothicBook to vertical center
            verticalAlignment: Text.AlignBottom
            font.family: Fonts.franklinGothicBook
        }

        SGIcon {
            id: currentIcon
            iconColor: "white"
            height: 25
            width: 25
            source: {
                if (mouse.containsMouse || dropDownPopup.visible) {
                    return "qrc:/images/icons/angle-down.svg"
                } else {
                    return selectedButtonIcon
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            dropDownPopup.open()
        }
        cursorShape: Qt.PointingHandCursor
    }

    Popup {
        id: dropDownPopup
        y: platformTabRoot.height
        width: menu.width
        height: menu.height
        padding: 0
        closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnReleaseOutside

        Rectangle {
            id: menu
            color: "#34993b"
            width: platformTabRoot.width
            height: menuColumn.height + 1

            signal clicked(int index)

            onClicked: {
                platformTabRoot.menuClicked(index)
            }

            ColumnLayout {
                id: menuColumn
                spacing: 1
                width: parent.width
                y: 1

                Repeater {
                    model: ListModel {
                        id: buttonModel
                    }

                    delegate: SGToolButton { }
                }
            }
        }
    }
}
