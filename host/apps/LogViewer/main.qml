import QtQuick 2.12
import tech.strata.commoncpp 1.0 as CommonCPP
import tech.strata.sgwidgets 1.0 as SGWidgets

SGWidgets.SGWindow {
    id: window
    width: 800
    height: 600
    minimumWidth: 800
    minimumHeight: 600

    visible: true
    title: qsTr("Log Viewer %1 (%2 lines, %3 skipped)").arg(CommonCPP.SGUtilsCpp.urlToLocalFile(logViewerMain.filePath)).arg(logViewerMain.linesCount).arg(logViewerMain.numberOfSkippedLines)

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
