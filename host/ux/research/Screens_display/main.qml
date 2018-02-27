import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Controls 2.3

Window {
    visible: true
    width: 1000
    height: 1200
    title: qsTr("Welcome Screen")


    //SGWelcomeScreen { userName: "David Priscak";  anchors.centerIn: parent }
    SGStatusBar { }

}
