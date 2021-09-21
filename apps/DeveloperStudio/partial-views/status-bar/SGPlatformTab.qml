/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
    property color menuColor: Theme.palette.onsemiOrange
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
        if(platformTabRoot.state === "help_tour"){
            Help.registerTarget(menu, "This is the menu for the Platform Tab", 5, "selectorHelp")
            for(var i = 0; i < repeater.count; i++){
                Help.registerTarget(repeater.itemAt(i).toolItem, (6 + i === 6) ? "Use this menu item to open the platform and control a board" :
                                                                 (i + 6 < repeater.count + 5) ? "Use this menu item to view documentation":
                                                                 "Use this menu item to close the platform", 6 + i, "selectorHelp")
            }
        }
    }

    onConnectedChanged: {
        setControlIcon()
    }

    Connections {
        target: Help.utility
        // if order is hardcoded, toggle help_tour popup after dropdown popup otherwise reset z height.
        onInternal_tour_indexChanged: {
            if(platformTabRoot.state === "help_tour"){
                if(Help.current_tour_targets[index]["target"] === menu) {
                    dropDownPopup.open()
                    menu.state = "help_tour"
                } else if(Help.current_tour_targets[index]["target"] === currIcon) {
                    dropDownPopup.close()
                }
            }
        }

        onTour_runningChanged: {
            if(!tour_running){
                menu.state = "normal"
                dropDownPopup.close()
            }
        }
    }

    onViewChanged: {
        setSelectedButton()
    }
    
    function closeTab() {
        let data = {
            "class_id": platformTabRoot.class_id,
            "device_id": platformTabRoot.device_id
        }
        PlatformSelection.closePlatformView(data)

        // must call last - model entry/delegate begins destruction
        NavigationControl.updateState(NavigationControl.events.CLOSE_PLATFORM_VIEW_EVENT, data)
    }

    function menuClicked(index) {
        let selection = buttonModel.get(index)
        if (selection.view !== view) {
            dropDownPopup.close()

            if (selection.view === "close"){
                closeTab()
                return
            } else {
                model.view = selection.view
            }
        }

        if (inView === false) {
            dropDownPopup.close()
            bringIntoView()
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

    function showMenu() {
        if (dropDownPopup.visible === true) {
            dropDownPopup.close()
        } else {
            dropDownPopup.open()
        }
    }

    RowLayout {
        anchors {
            fill: parent
        }
        spacing: 0

        Rectangle {
            color: mouseTab.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.15) : inView ? platformTabRoot.menuColor : mouseMenu.containsMouse ? platformTabRoot.menuColor : "#444"
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
                id: mouseTab
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        platformTabRoot.bringIntoView()
                    } else if (mouse.button == Qt.RightButton) {
                        showMenu()
                    } else if (mouse.button == Qt.MiddleButton) {
                        closeTab()
                    }
                }
                cursorShape: Qt.PointingHandCursor
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            color: mouseMenu.containsMouse ? Qt.darker(Theme.palette.onsemiOrange, 1.15) : inView ? platformTabRoot.menuColor : mouseTab.containsMouse ? platformTabRoot.menuColor :"#444"

            MouseArea {
                id: mouseMenu
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: {
                    if (mouse.button == Qt.LeftButton) {
                        showMenu()
                    } else if (mouse.button == Qt.RightButton) {
                        showMenu()
                    } else if (mouse.button == Qt.MiddleButton) {
                        closeTab()
                    }
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
            }
        }

        Rectangle {
            id: menu
            color: Qt.darker(Theme.palette.onsemiOrange, 1.15)
            width: platformTabRoot.width
            height: menuColumn.height + 1
            state: "normal"

            onStateChanged: {
                if(state === "help_tour"){
                    Help.refreshView(Help.internal_tour_index)
                }
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

                    delegate: SGToolButton {
                        enabled: menu.state !== "help_tour"
                    }
                }
            }
        }
    }
}
