import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "framework"


Rectangle {
    id: frontSide

    anchors{ fill:parent }

    Rectangle{
        id: frontToolBar
        height: 44
        anchors.left: parent.left
        anchors.right: parent.right
        color:(stack.currentItem.objectName == "boardLayout") ? "white" :"black"
        visible: false
        z:2
        RowLayout {
            anchors.fill:parent
            ToolButton {
                id: settingsToolButton
                onClicked: settingsMenu.open()
                opacity:.5
                z:2

                Image{
                    anchors.left:parent.left
                    anchors.leftMargin: 10
                    anchors.top:parent.top
                    anchors.topMargin:10
                    anchors.right:parent.right
                    anchors.rightMargin: 10
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin: 10
                    source:(stack.currentItem.objectName == "boardLayout")? "./images/icons/settingsIcon.svg":"./images/icons/settingsIconWhite.svg"
                }

                Menu{
                    id:settingsMenu
                    MenuItem{
                        text: qsTr("Standard Controls")
                        onClicked: showStandardControls()
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 14  : 10;
                    }
                    MenuItem{
                        text: qsTr("Advanced Controls")
                        onClicked: showAdvancedControls()
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 14  : 10;
                    }
                    MenuItem{
                        text: qsTr("Board Bring-up")
                        onClicked: showBoardBringupControls()
                        font.family: "helvetica"
                        font.pointSize: (Qt.platform.os === "osx") ? 14  : 10;
                    }
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //  showAdvancedControls()
    //-------------------------------------------------------------------------
    function showAdvancedControls(){
        mainWindow.control_type = "advanced"
    }

    //-------------------------------------------------------------------------
    //  showStandardControls()
    //-------------------------------------------------------------------------
    function showStandardControls(){
        mainWindow.control_type = "standard"
    }

    //-------------------------------------------------------------------------
    //  showBoardBringupControls()
    //-------------------------------------------------------------------------
    function showBoardBringupControls(){
        mainWindow.control_type = "BuBu"
    }

    Component {
        id: advanced
        AdvancedControls { }
    }

    StackView {
        id:stack
        anchors { left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        top: frontToolBar.bottom}

        popEnter: Transition {
            PropertyAnimation { property: "opacity"; to: 1.0; duration: 1000 }
        }
        popExit: Transition {
            PropertyAnimation { property: "opacity"; to: 0.0; duration: 1000 }
        }
        pushEnter: Transition {
            PropertyAnimation { property: "opacity"; to: 1.0; duration: 1000 }
        }
        pushExit: Transition {
            PropertyAnimation { property: "opacity"; to: 0.0; duration: 1000 }
        }
    }

    Component.onCompleted:{
        // Push the login screen first; We'll decide later what else needs to be shown
        stack.push(cLoginScreen, {immediate:true})
    }
    Component {
        id: cLoginScreen
        SGLoginScreen { }
    }
    Component {
        id: cBoardLayout
        BoardLayout { }
    }

    Component {
        id: boardBringUp
        BoardBringUp { }
    }
}

