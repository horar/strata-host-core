import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Dialogs 1.3
import "../Components"

Window {
    id: root
    width: 500
    height: 600
    color: "#393e46"
    visible: false
    StatusBar {
        anchors.bottom: parent.bottom
        width: parent.width
    }
    ColumnLayout {
        width: parent.width
        height: parent.height - 80
        DBList {
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height - 200
            Layout.alignment: Qt.AlignHCenter
        }
        UserInputBox {
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignHCenter
        }
        Button {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 40
            text: "Open"
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 15
        }
    }


}
