import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

// Temporary button in the SGStatusBar that opens control view creator.
// If this is removed, remove CVCButtonFake as well.

Rectangle {
    id: controlViewCreatorContainer
    anchors {
        right: profileIconContainer.left
        rightMargin: 10
    }
    height: container.height
    width: controlViewCreatorRow.implicitWidth + 20
    color: controlViewCreatorMouse.containsMouse ? "#34993b" : NavigationControl.stack_container_.currentIndex === NavigationControl.stack_container_.count-2 ? "#33b13b" : "#444"

    MouseArea {
        id: controlViewCreatorMouse
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            let data = {"index": NavigationControl.stack_container_.count-2}
            NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
        }
    }

    RowLayout {
        id: controlViewCreatorRow
        spacing: 10
        anchors {
            centerIn: parent
        }

        SGText {
            id: controlViewCreatorText
            text: "Create Control View"
            color: "white"
        }

        SGIcon {
            id: plusSignIcon
            Layout.preferredWidth: 25
            Layout.preferredHeight: Layout.preferredWidth
            source: "qrc:/sgimages/times.svg"
            iconColor: controlViewCreatorText.color
        }
    }

    function toggleVisibility(){
        visible = true
    }
}
