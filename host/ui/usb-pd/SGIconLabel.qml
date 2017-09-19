import QtQuick 2.0
import QtQuick.Controls 2.0


Rectangle {
    id:container
    width: container.width; height: container.height
    property alias text: voltageValue.text
    color: "transparent"

    Label {
        id: voltageValue
        anchors{ verticalCenter:container.verticalCenter; horizontalCenter: container.horizontalCenter }
        font.pointSize: parent.width/4 > 0 ? parent.width/4 : 1
        opacity: 1.0
    }

}
