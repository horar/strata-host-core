import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Styles 1.4
import "navigationControl.js" as NavigationControl

Rectangle {
    id: loginScreen
    color: "lime"
    anchors.centerIn:  parent
    anchors.fill: parent
    ColumnLayout {
       anchors.centerIn:  parent
       TextInput {
           text: "Username"
       }
       TextInput {
            text: "Password"
       }

       Button {
           id: loginButton
            text: "Login"
            background: Rectangle {
                color: "green"
            }

            onClicked: {
                var data = { user_id: "Spyglass User"}
                NavigationControl.updateState(NavigationControl.events.LOGIN_SUCCESSFUL_EVENT, data)
            }
       }

   }
}




