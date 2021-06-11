import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3

import tech.strata.fonts 1.0
import tech.strata.logger 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0
import tech.strata.signals 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

// Temporary button in the SGStatusBar that opens control view creator.
// If this is removed, remove CVCButtonFake as well.

Rectangle {
    id: controlViewCreatorContainer
    height: container.height
    width: controlViewCreatorRow.implicitWidth
    color: controlViewCreatorMouse.containsMouse ? "#34883b" : NavigationControl.stack_container_.currentIndex === NavigationControl.stack_container_.count-1 ? Theme.palette.green : "#444"
    state: "debug"

    MouseArea {
        id: controlViewCreatorMouse
        anchors {
            fill: parent
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            let data = {"index": NavigationControl.stack_container_.count-1}
            NavigationControl.updateState(NavigationControl.events.SWITCH_VIEW_EVENT, data)
        }
    }

    RowLayout {
        id: controlViewCreatorRow
        spacing: 10
        anchors {
            fill: parent
        }

        SGText {
            id: controlViewCreatorText
            text: "Control View Creator"
            color: "white"
            leftPadding: 10
            Layout.alignment: Qt.AlignHCenter
        }

        Item {
            Layout.fillWidth: true
        }

        Rectangle{
            Layout.preferredHeight: controlViewCreatorContainer.height
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignRight
            color:controlViewCreatorMouse.containsMouse ? Theme.palette.green : closeArea.containsMouse  ? "#34883b" : NavigationControl.stack_container_.currentIndex === NavigationControl.stack_container_.count-1 ? Theme.palette.green : "#444"

            SGIcon {
                id: timesSignIcon
                width: 20
                height: width
                anchors.centerIn: parent
                source: "qrc:/sgimages/times.svg"
                iconColor: controlViewCreatorText.color
            }

            MouseArea {
                id: closeArea
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                anchors.fill: parent

                onClicked: {
                    Signals.requestClose(false)
                }
            }
        }
    }

    Connections {
        target: Signals

        onLoadCVC: {
            controlViewCreatorContainer.visible = true
        }

        onCloseFinished: {
            controlViewCreatorContainer.visible = false
        }
    }
}
