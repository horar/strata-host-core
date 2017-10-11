import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtWebView 1.1

Item {

    Rectangle{
        anchors{fill:parent}
        color:"white"
    }

    Text{
        id:placeholderText
        color:"light grey"
        anchors{horizontalCenter: parent.horizontalCenter;
                verticalCenter: parent.verticalCenter}
        font{pointSize:72; family:"helvetica"}
        text:"Related Materials"
    }
}

