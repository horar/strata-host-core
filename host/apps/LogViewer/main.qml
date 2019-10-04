import QtQuick 2.12
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGMainWindow {
    id: root
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Log Viewer %1(%2 lines)").arg(CommonCPP.SGUtilsCpp.urlToLocalFile(logViewerMain.filePath)).arg(logViewerMain.linesCount)

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
}
