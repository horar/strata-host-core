import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: root

    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height

    property alias segmentedButtons : segmentedButtons.sourceComponent

    property real buttonHeight: 35
    property real radius: buttonHeight/2
    property string activeColorTop: "#bbbbbb"
    property string activeColorBottom: "#999999"
    property string inactiveColorTop: "#dddddd"
    property string inactiveColorBottom: "#aaaaaa"
    property bool exclusive: true
    property string label: ""
    property bool labelLeft: true

    Text {
        id: labelText
        text: root.label
        width: contentWidth
        height: root.labelLeft ? segmentedButtons.height : contentHeight
        topPadding: root.label === "" ? 0 : root.labelLeft ? (segmentedButtons.height-contentHeight)/2 : 0
        bottomPadding: topPadding
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
        property string masterActiveColorTop: activeColorTop
        property string masterActiveColorBottom: activeColorBottom
        property string masterInactiveColorTop: inactiveColorTop
        property string masterInactiveColorBottom: inactiveColorBottom
    }
}
