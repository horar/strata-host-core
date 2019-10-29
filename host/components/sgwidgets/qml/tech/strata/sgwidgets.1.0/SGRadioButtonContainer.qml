import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

GridLayout {
    id: root
    rowSpacing: 5
    columnSpacing: 5
    Layout.fillWidth: false
    Layout.fillHeight: false

    property var buttonList: []
    property int alignment: SGAlignedLabel.SideRightCenter
    property color textColor: "black"
    property color radioColor: "black"
    property real radioSize: 20 * fontSizeMultiplier
    property real fontSizeMultiplier: 1.0
    property int currentIndex

    property alias exclusive: buttonGroup.exclusive
    property alias checkedButton: buttonGroup.checkedButton
    property alias checkState: buttonGroup.checkState

    ButtonGroup{
        id: buttonGroup
        exclusive: true
    }

    Component.onCompleted: {
        reparentChildren()
    }

    onCurrentIndexChanged: {
        if (exclusive) {
            buttonList[currentIndex].checked = true
        }
    }

    function reparentChildren () {
        for (var i = 0; i < root.children.length; i++){
            if (root.children[i].objectName === "RadioButton") {
                buttonList.push(root.children[i])

            }
        }

        for (i = 0; i < buttonList.length; i++){
            buttonList[i].parent = root
            buttonList[i].buttonContainer = root
            buttonList[i].index = i
            buttonGroup.addButton(buttonList[i].button)
            if (buttonList[i].checked) {
               currentIndex = i
            }
        }
    }
}
