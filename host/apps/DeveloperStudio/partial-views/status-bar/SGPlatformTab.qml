import QtQuick 2.12

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/navigation_control.js" as NavigationControl

Row {
    id: row

    property color menuColor: "#33b13b"

    property alias close: platformSelectionButton
    property alias content: platformContentButton
    property alias control: platformControlsButton

    property string view: model.view
    property string class_id: model.class_id
    property bool connected: model.connected
    property int index: model.index

    SGToolButton {
        id: platformSelectionButton
        text: qsTr("Close Platform")
        buttonColor: hovered ? menuColor : "black"
        onClicked: {
            coreInterface.disconnectPlatform() // cancels any active collateral downloads
            documentManager.clearDocuments();

            let data = {"class_id": row.class_id}
            NavigationControl.updateState(NavigationControl.events.CLOSE_PLATFORM_VIEW_EVENT, data)  // must call last - model entry/delegate begins destruction
        }
        iconSource: "qrc:/images/icons/times.svg"
    }

    Rectangle {
        id: buttonDivider1
        width: 1
        height: row.height
        color: "black"
    }

    SGToolButton {
        id: platformControlsButton
        text: qsTr("Platform Controls")
        buttonColor: (hovered || row.view === "control") && NavigationControl.stack_container_.currentIndex === row.index + 1 ? menuColor : "black"
        onClicked: {
            model.view = "control"
            row.bringIntoView()
        }
        enabled: row.connected === true
        iconSource: enabled ? "qrc:/images/icons/sliders-h.svg" : "qrc:/images/icons/disconnected.svg"
    }

    Rectangle {
        id: buttonDivider2
        width: 1
        height: row.height
        color: "black"
    }

    SGToolButton {
        id: platformContentButton
        text: qsTr("Platform Content")
        buttonColor: (hovered || row.view === "collateral") && NavigationControl.stack_container_.currentIndex === row.index + 1 ? menuColor : "black"
        onClicked: {
            model.view = "collateral"
            row.bringIntoView()
        }
        iconSource: "qrc:/images/icons/file.svg"
    }

    function bringIntoView() {
        let data = {"index": row.index + 1} // Offset by 1 since index 0 is always platform selector view
        NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
    }
}
