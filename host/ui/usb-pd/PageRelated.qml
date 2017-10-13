import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtWebView 1.1

Item {
    //add a couple of placeholder items so we know what is on the tab
    Rectangle {
        anchors.fill:parent
        color:"white"
    }

    Text {
        id:placeholderText
        anchors{horizontalCenter: parent.horizontalCenter;
                verticalCenter: parent.verticalCenter}
        color:"light grey"
        font{family: "helvetica"; pointSize:72}
        text: qsTr("Related Materials")
    }
}

