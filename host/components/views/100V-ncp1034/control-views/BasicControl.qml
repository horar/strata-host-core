import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.12
import QtQuick.Window 2.3
import tech.strata.sgwidgets 0.9 as Widget09
import tech.strata.fonts 1.0
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    property real ratioCalc: root.width/1200
    property real initialAspectRatio: Screen.width/Screen.height
    anchors.centerIn: parent
    width: parent.width / parent.height > initialAspectRatio ? parent.height * initialAspectRatio : parent.width
    height: parent.width / parent.height < initialAspectRatio ? parent.width / initialAspectRatio : parent.height


    ColumnLayout {
        anchors.fill :parent

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: (parent.height - 9) * (1/11)
            color: "transparent"
            Text {
                text:  "100 V Synchronous Buck Converter \n NCP1034"
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: ratioCalc * 20
                color: "black"
                anchors.centerIn: parent
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "red"
        }
    }

}
