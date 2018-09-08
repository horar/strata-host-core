import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: root

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
    enabled: true

    property alias segmentedButtons : segmentedButtons.sourceComponent

    property real buttonHeight: 35
    property real radius: buttonHeight/2
    property color activeColor: "#999"
    property color inactiveColor: "#ddd"
    property bool exclusive: true
    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"
    property color activeTextColor: "white"
    property real buttonImplicitWidth: 70
    property bool nothingChecked: true
    property bool hoverEnabled: true
    property int index: 0


    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.label === "" ? 0 :root.labelLeft ? segmentedButtons.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (segmentedButtons.height-contentHeight)/2 : 0
        bottomPadding: topPadding
        color: root.textColor
    }

    ButtonGroup{
        buttons: segmentedButtons.children[0].children
        exclusive: root.exclusive
    }

    Loader {
        id: segmentedButtons
        anchors {
            left: root.labelLeft ? labelText.right : labelText.left
            top: root.labelLeft ? labelText.top : labelText.bottom
            leftMargin: root.label === "" ? 0 : root.labelLeft ? 10 : 0
            topMargin: root.label === "" ? 0 : root.labelLeft ? 0 : 5
        }

        // Passthrough properties so segmentedButtons can get these
        property real masterHeight: buttonHeight
        property real masterRadius: radius
        property real masterButtonImplicitWidth: buttonImplicitWidth
        property color masterActiveColor: activeColor
        property color masterInactiveColor: inactiveColor
        property color masterTextColor: textColor
        property color masterActiveTextColor: activeTextColor
        property bool masterEnabled: enabled
        property bool masterHoverEnabled: hoverEnabled

        Component.onCompleted: {
            if (exclusive === false){
                for (var child_id1 in segmentedButtons.children[0].children) {
                    segmentedButtons.children[0].children[child_id1].checkedChanged.connect(checked)
                }
            } else {
                for (var child_id2 in segmentedButtons.children[0].children) {
                    segmentedButtons.children[0].children[child_id2].index = child_id2
                    segmentedButtons.children[0].children[child_id2].indexUpdate.connect(indexUpdate)
                }
            }
        }

        function checked () {
            for (var child_id in segmentedButtons.children[0].children) {
                if (segmentedButtons.children[0].children[child_id].checked){
                    root.nothingChecked = false
                    break
                } else if (child_id === "" + (segmentedButtons.children[0].children.length - 1)) { // if last child is reached and not checked, nothingChecked = true
                    root.nothingChecked = true
                }
            }
        }

        function indexUpdate (index) {
            root.index = index
        }


    }


    Component.onCompleted: {
        segmentedButtons.checked()
    }
}
