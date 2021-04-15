import QtQuick 2.12
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.sgwidgets 1.0 as SGWidgets
import Qt.labs.platform 1.0 as QtLabsPlatform
import QtQuick.Controls 2.12

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    property int statusBarHeight: logViewerMain.statusBarHeight
    property bool filesLoading: false

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

    Popup {
        id: popup

        parent: Overlay.overlay

        x: parent ? Math.round((parent.width - width) / 2) : 0
        y: parent ? Math.round((parent.height - height) / 2) : 0

        padding: 18

        visible: filesLoading
        Column {
            Label {
                text: qsTr("Files are loading...")
                font.pixelSize: 18
            }
        }
    }

    Timer {
        id: loadingTimer
        interval: 1500
        onTriggered: {
            for(var i = 1; i < Qt.application.arguments.length; i++) {
                logViewerMain.loadFiles(["file:" + Qt.application.arguments[i]])
                filesLoading = false
            }
        }
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

        focus: true
        Component.onCompleted: {
            if(Qt.application.arguments.length > 1) {
                filesLoading = true
                loadingTimer.start()
            }
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LogViewerAboutWindow.qml")
    }
}
