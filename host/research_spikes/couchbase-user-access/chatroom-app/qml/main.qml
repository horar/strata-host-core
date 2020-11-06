import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import com.onsemi 1.0

Window {
    id: root
    visible: true

    width: 600
    height: 400
    maximumHeight: height
    maximumWidth: width
    minimumHeight: height
    minimumWidth: width

    title: qsTr("Strata Couch Chat")

    StackLayout {
        id: stackContainer
        anchors.fill: parent
        currentIndex: 0

        SplashScreen {
            stackContainerRef: stackContainer
         }

        Chatbox {
            stackContainerRef: stackContainer
        }
    }
}
