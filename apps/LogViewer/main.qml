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
        anchors.centerIn: parent
        padding: 16

        Column {
            SGWidgets.SGText {
                text: qsTr("Files are loading...")
                fontSizeMultiplier: 2.0
            }
        }
    }

    Timer {
        id: loadingTimer
        interval: 500
        onTriggered: {
            for (var i = 1; i < Qt.application.arguments.length; i++) {
                logViewerMain.loadFiles(["file:" + Qt.application.arguments[i]])
            }
            popup.close()
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
                popup.open()
                loadingTimer.start()
            }
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LogViewerAboutWindow.qml")
    }
}
