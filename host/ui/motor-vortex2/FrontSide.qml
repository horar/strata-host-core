import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.2
import "framework"


Rectangle {
    id: frontSide

    anchors { fill:parent }

    Rectangle {
        id: frontToolBar
        anchors.left: parent.left
        anchors.right: parent.right
        color:(stack.currentItem.objectName == "controlLayout") ? "white" :"black"
        visible: false

        height: 44

        RowLayout {
            anchors.fill:parent
            ToolButton {
                icon.source: "./images/icons/settingsIcon.svg"
                onClicked: settingsMenu.open()
                opacity:.5
                z:2
                Menu{
                    id:settingsMenu
                    MenuItem{
                        text: qsTr("Standard Controls")
                        onClicked: showStandardControls()
                        font.family: "helvetica"
                        font.pointSize: 14
                    }
                    MenuItem{
                        text: qsTr("Advanced Controls")
                        onClicked: showAdvancedControls()
                        font.family: "helvetica"
                        font.pointSize: 14
                    }
                    MenuItem{
                        text: qsTr("Board Bring-up")
                        onClicked: showBoardBringupControls()
                        font.family: "helvetica"
                        font.pointSize: 14
                    }
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //  showAdvancedControls()
    //-------------------------------------------------------------------------
    function showAdvancedControls(){

        if (stack.currentItem.objectName == "advancedControls"){
            //if advanced controls are already showing, do nothing
            console.log("advanced controls already showing")
        }
        else if (stack.currentItem.objectName == "controlLayout"){
            //otherwise, pop off the current view, and show the advanced controls
            stack.pop({immediate:true})             //remove the standard controls
            stack.push(advanced, {immediate:true})  //push in the advanced controls
        }
    }

    //-------------------------------------------------------------------------
    //  showStandardControls()
    //-------------------------------------------------------------------------
    function showStandardControls(){

        if (stack.currentItem.objectName == "controlLayout"){
            //if advanced controls are already showing, do nothing
            console.log("standard controls already showing")
        }
        else if (stack.currentItem.objectName == "advancedControls"){
            //otherwise, pop off the current view, and show the standard controls
            stack.pop({immediate:true})             //remove the advanced controls
            stack.push(page2, {immediate:true})  //push in the advanced controls
        }
    }

    //-------------------------------------------------------------------------
    //  showControlBringupControls()
    //-------------------------------------------------------------------------
    function showControlBringupControls(){

        stack.pop({immediate:true})             //remove the advanced controls
        stack.push(boardBringUp, {immediate:true})  //push in the advanced controls
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
            top: parent.top
        }

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
        stack.push(page2, {immediate:true})
        stack.push(page1, {immediate:true})
    }
    Component {
        id: page1
        SGLoginScreen { }
    }
    Component {
        id: page2
        ControlLayout { }
    }

    Component {
        id: boardBringUp
        BoardBringUp { }
    }
}

