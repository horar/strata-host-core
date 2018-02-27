import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "framework"



Rectangle {
    id: frontSide
    anchors{ fill:parent }

    property int backButtonOffset: 50

    Rectangle{
        id: frontToolBar
        height: 44
        anchors.left: parent.left
        anchors.right: parent.right
        color:(stack.currentItem.objectName == "advancedControls") ? "black" :"white"
        visible: false
        z:2

        states: [
            State {
                name: "backButtonShowing"
                PropertyChanges { target: toolBarRow; x: 0 }
                PropertyChanges { target: backToolButton; opacity: .5 }
            },

            State {
                name: "backButtonHidden"
                PropertyChanges { target: toolBarRow; x: -backButtonOffset }
                PropertyChanges { target: backToolButton; opacity: 0 }
            }
        ]

        transitions: [
            Transition {
                from: "backButtonShowing"
                to: "backButtonHidden"
                SequentialAnimation{
                    PropertyAnimation {properties:"opacity"; duration:200}
                    PropertyAnimation { properties:"x"; duration: 300 }
                }
            },
            Transition {
                from: "backButtonHidden"
                to: "backButtonShowing"
                SequentialAnimation{
                    PropertyAnimation { properties:"x"; duration: 500 }
                    PropertyAnimation {properties:"opacity"; duration:500}
                }
            }
        ]


        Row {
            id:toolBarRow
            anchors.top:parent.top
            anchors.bottom:parent.bottom
            x: -backButtonOffset          //initial position keeps the back button off the screen
            width: parent.width+backButtonOffset

            ToolButton{
                id: backToolButton
                onClicked: showStandardControls()
                opacity:(stack.currentItem.objectName == "boardLayout") ? 0 : .5
                z:2

                Image{
                    anchors.left:parent.left
                    anchors.leftMargin: 20
                    anchors.top:parent.top
                    anchors.topMargin:10
                    anchors.right:parent.right
                    anchors.rightMargin: 10
                    anchors.bottom:parent.bottom
                    anchors.bottomMargin: 10
                    source:{
                        if (stack.currentItem.objectName == "advancedControls"){
                            source = "./images/icons/backArrowWhite.svg"
                        }
                        else{
                            source = "./images/icons/backArrow.svg"
                        }

                    }
                }
            }





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
                    source:(stack.currentItem.objectName == "advancedControls")? "./images/icons/settingsIconWhite.svg":
                                                                                 "./images/icons/settingsIcon.svg"
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

