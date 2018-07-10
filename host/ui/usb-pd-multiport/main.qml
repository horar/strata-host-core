import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3
import "qrc:/sgwidgets"
import "qrc:/views"

Window {
    id: mainWindow
    visible: true
    width: 1200
    height: 900
    title: qsTr("USB-PD MultiPort")

    TabBar {
        id: navTabs
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        TabButton {
            id: basicButton
            text: qsTr("Basic")
            onClicked: {
                basicControl.visible = true
                advancedControl.visible = false
            }
        }

        TabButton {
            id: advancedButton
            text: qsTr("Advanced")
            onClicked: {
                basicControl.visible = false
                advancedControl.visible = true
            }
        }
    }

    Item {
        id: controlContainer
        anchors {
            top: navTabs.bottom
            bottom: parent.bottom
            right: parent.right
            left: parent.left
        }

        BasicControl {
            id: basicControl
            visible: true
        }

        AdvancedControl {
            id: advancedControl
            visible: false
        }

    }
}
