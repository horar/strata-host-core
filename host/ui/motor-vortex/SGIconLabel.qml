import QtQuick 2.0
import QtQuick.Controls 2.0


Rectangle {
    id:container
    width: container.width; height: container.height
    color: "transparent"

    property alias text: valueString.text

    Label {
        id: valueString
        anchors{ verticalCenter:container.verticalCenter; left: parent.left; leftMargin: 10 }
        opacity: 1.0
    }

    Component.onCompleted: {
        //adjust font size based on platform
        if (Qt.platform.os === "osx"){
            valueString.font.pointSize = parent.width/10 > 0 ? parent.width/1.5 : 1;
            }
          else{
            fontSizeMode : Label.Fit
            }
    }
}
