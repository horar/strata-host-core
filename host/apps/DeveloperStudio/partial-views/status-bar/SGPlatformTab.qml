import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.theme 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: platformTabRoot
    height: 40
    width: 250 // will be set by the listview

    property color menuColor: Theme.palette.green

    property string view: model.view
    property string name: model.name
    property string class_id: model.class_id
    property var device_id: model.device_id
    property bool connected: model.connected
    property var available: model.available
    property int index: model.index
    property bool inView: NavigationControl.stack_container_.currentIndex === index + 1
    property string selectedButtonIcon: ""

    property alias currIcon: currentIcon
    property alias platformName: platformName

    Component.onCompleted: {
        populateButtons()
        setControlIcon()
        setSelectedButton()
        Help.registerTarget(repeater.itemAt(0).toolRow, "Use this menu item to open the platform and control the board, documentation, or close the platform", 5, "selectorHelp")
        Help.registerTarget(repeater.itemAt(1).toolRow, "Use this menu item to open the documentation of the board", 6, "selectorHelp")
        Help.registerTarget(repeater.itemAt(2).toolRow, "Use this menu item to close the platform", 7, "selectorHelp")
    }

    onConnectedChanged: {
        setControlIcon()
    }

    Connections {
        target: Help.utility

        onInternal_tour_indexChanged: {
            if(Help.current_tour_targets[index]["target"] === repeater.itemAt(0).toolRow || Help.current_tour_targets[index]["target"] === repeater.itemAt(1).toolRow ||
                    Help.current_tour_targets[index]["target"] === repeater.itemAt(2).toolRow) {
                dropDownPopup.open()
            } else {
                dropDownPopup.close()
            }
        }

        onTour_runningChanged: {
            if(!tour_running){
                menu.state = "normal"
                dropDownPopup.close()
                dropDownPopup.z = 0
            } else {
                menu.state = "help_tour"
                dropDownPopup.z = -1
            }
        }
    }

    function menuClicked(index) {
        let selection = buttonModel.get(index)
        if (selection.view !== view) {
            dropDownPopup.close()

            if (selection.view === "close"){
                let data = {
                    "class_id": platformTabRoot.class_id,
                    "device_id": platformTabRoot.device_id
                }
                PlatformSelection.closePlatformView(data)

                NavigationControl.updateState(NavigationControl.events.CLOSE_PLATFORM_VIEW_EVENT, data)  // must call last - model entry/delegate begins destruction
                return
            } else {
                model.view = selection.view
                setSelectedButton()
            }
        }

        bringIntoView()
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
                "icon": "qrc:/sgimages/file-blank.svg",
                "selected": false
            }
            buttonModel.append(buttonData)
        }

        buttonData = {
            "text": "Close Platform",
            "view": "close",
            "icon": "qrc:/sgimages/times.svg",
            "selected": false
        }
        buttonModel.append(buttonData)
    }

    function setControlIcon () {
        for (let i = 0; i < buttonModel.count; i++) {
            if (buttonModel.get(i).view === "control") {
                buttonModel.get(i).icon = (connected ? "qrc:/sgimages/sliders-h.svg" : "qrc:/sgimages/disconnected.svg")
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
            fill: parent
        }
        spacing: 0

        Rectangle {
            color: mouse.containsMouse ? Qt.darker(Theme.palette.green, 1.15) : inView ? platformTabRoot.menuColor : mouseMenu.containsMouse ? platformTabRoot.menuColor : "#444"
            Layout.fillHeight: true
            Layout.fillWidth: true

            SGText {
                id: platformName
                color: "white"
                text: platformTabRoot.name
                elide: Text.ElideRight
                font.family: Fonts.franklinGothicBook
                anchors {
                    verticalCenter: parent.verticalCenter
                    verticalCenterOffset: 2 // hack to force franklinGothicBook to vertical center
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    platformTabRoot.bringIntoView()
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            color: mouseMenu.containsMouse ? Qt.darker(Theme.palette.green, 1.15) : inView ? platformTabRoot.menuColor : mouse.containsMouse ? platformTabRoot.menuColor :"#444"

            MouseArea {
                id: mouseMenu
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    dropDownPopup.open()
                }
                cursorShape: Qt.PointingHandCursor
            }

            SGIcon {
                id: currentIcon
                iconColor: "white"
                height: 25
                width: 25
                anchors {
                    centerIn: parent
                }

                source: {
                    if (mouseMenu.containsMouse || dropDownPopup.visible) {
                        return "qrc:/sgimages/chevron-down.svg"
                    } else {
                        return selectedButtonIcon
                    }
                }
            }
        }
    }

    Popup {
        id: dropDownPopup
        y: platformTabRoot.height
        width: menu.width
        height: menu.height
        padding: 0
        closePolicy: menu.state === "normal" ? Popup.CloseOnPressOutsideParent | Popup.CloseOnReleaseOutside : Popup.NoAutoClose

        onOpened: {
            if(menu.state === "help_tour"){
                Help.refreshView(Help.internal_tour_index)
                dropDownPopup.z = -1
            }
        }

        Rectangle {
            id: menu
            color: Qt.darker(Theme.palette.green, 1.15)
            width: platformTabRoot.width
            height: menuColumn.height + 1
            state: "normal"

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
                    id: repeater
                    model: ListModel {
                        id: buttonModel
                    }

                    delegate: SGToolButton { }
                }
            }
        }
    }
}
