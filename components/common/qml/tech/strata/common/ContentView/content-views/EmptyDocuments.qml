import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.commoncpp 1.0
import tech.strata.sgwidgets 0.9 as SGWidgets0
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    color: navigationSidebar.color

    property bool hasDownloads: false
    property alias errorText: errText.text

    ColumnLayout {
        anchors.centerIn: root

        SGIcon{
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/sgimages/exclamation-triangle.svg"
            width: 80
            height: 80
            iconColor: Qt.lighter(navigationSidebar.color, 1.25)
            visible: hasDownloads === false
        }

        SGText {
            id: errText
            Layout.alignment: Qt.AlignHCenter
            text: hasDownloads ? "No PDF documents found for this platform" : "No PDF documents or downloadable<br>files found for this platform"
            fontSizeMultiplier: 2.0
            horizontalAlignment: Text.AlignHCenter
            font.bold: true
            color: Qt.lighter(navigationSidebar.color, 1.5)
        }
    }
}
