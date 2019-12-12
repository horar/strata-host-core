import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

ColumnLayout {
    id: root
    anchors.fill: parent

    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1200/820
    spacing: 15

    Text {
        id: platformName
        Layout.alignment: Qt.AlignHCenter
        text: "Current Sense"
        font.bold: true
        font.pixelSize: ratioCalc * 40
        topPadding: 20
    }


    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height/1.5
        color: "red"
        Layout.alignment: Qt.AlignCenter

    }





}
