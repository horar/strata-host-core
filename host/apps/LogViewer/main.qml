import QtQuick 2.12
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.0 as QtLabsPlatform

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    property int statusBarHeight: logViewerMain.statusBarHeight

    visible: true
    title: qsTr("Log Viewer")

    QtLabsPlatform.MenuBar {
        QtLabsPlatform.Menu {
            title: "Help"
            QtLabsPlatform.MenuItem {
                text: qsTr("&About")
                onTriggered:  {
                    showAboutWindow()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#eeeeee"
    }

    LogViewerMain {
        id: logViewerMain
        anchors{
            fill: parent
            leftMargin: 5
            rightMargin: 5
            topMargin: 5
            bottomMargin: statusBarHeight + 5
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LogViewerAboutWindow.qml")
    }
}
