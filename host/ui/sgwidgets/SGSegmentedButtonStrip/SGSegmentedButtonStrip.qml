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
    property color activeColorTop: "#bbbbbb"
    property color activeColorBottom: "#999999"
    property color inactiveColorTop: "#dddddd"
    property color inactiveColorBottom: "#aaaaaa"
    property bool exclusive: true
    property string label: ""
    property bool labelLeft: true
    property color textColor: "black"
    property color activeTextColor: "white"

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
        property color masterActiveColorTop: activeColorTop
        property color masterActiveColorBottom: activeColorBottom
        property color masterInactiveColorTop: inactiveColorTop
        property color masterInactiveColorBottom: inactiveColorBottom
        property color masterTextColor: textColor
        property color masterActiveTextColor: activeTextColor
        property bool masterEnabled: enabled
    }
}
