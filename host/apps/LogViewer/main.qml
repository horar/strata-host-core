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

    visible: true
    title: qsTr("Log Viewer %1(%2 items)").arg(CommonCPP.SGUtilsCpp.urlToLocalFile(logViewerMain.filePath)).arg(logViewerMain.linesCount)

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
            margins: 5
        }
    }

    function showAboutWindow() {
        SGWidgets.SGDialogJS.createDialog(root, "qrc:/LogViewerAboutWindow.qml")
    }
}
