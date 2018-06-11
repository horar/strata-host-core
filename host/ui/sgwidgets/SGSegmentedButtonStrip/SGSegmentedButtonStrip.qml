import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

Item {
    id: root

    implicitWidth: childrenRect.width
    implicitHeight: 35

    property alias segmentedButtons : segmentedButtons.sourceComponent

    property real radius: height/2
    property string activeColorTop: "#bbbbbb"
    property string activeColorBottom: "#999999"
    property string inactiveColorTop: "#dddddd"
    property string inactiveColorBottom: "#aaaaaa"
    property bool exclusive: true

    ButtonGroup{
        buttons: segmentedButtons.children[0].children
        exclusive: root.exclusive
    }

    Loader {
        id: segmentedButtons

        // Passthrough properties so segmentedButtons can get these
        property real masterHeight: root.height
        property real masterRadius: radius
        property string masterActiveColorTop: activeColorTop
        property string masterActiveColorBottom: activeColorBottom
        property string masterInactiveColorTop: inactiveColorTop
        property string masterInactiveColorBottom: inactiveColorBottom
    }
}
