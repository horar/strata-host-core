import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12

Window {
    visible: true
    minimumWidth: 800
    minimumHeight: 600
    width: 1280
    height: 720
    title: qsTr("Couchbase Browser") + ((fileName !== "") ? " - " + fileName : "")
    property string fileName: ""
    property var contentArray: null
    MainWindow {
        id: mainview
    }
    onContentArrayChanged: {
        mainview.content = contentArray
    }
}
