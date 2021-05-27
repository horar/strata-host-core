import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12


Item {
    id: hoverHandler

    property alias delay: toolTip.delay
    property alias text: toolTip.text
    property alias timeout: toolTip.timeout
    property alias toolTipEnabled: toolTip.enabled

    Component.onCompleted: toolTip.close()

    ToolTip {
        id: toolTip
        anchors.centerIn: parent
        enabled: toolTipEnabled
        background: Rectangle {
            color: "#FAFAFA"
            border.color: "black"
            border.width: 0.5
        }
    }

    function openToolTip(){
        if(toolTipEnabled){
            toolTip.open()
        }
    }

    function closeToolTip(){
        if(toolTipEnabled){
            toolTip.close()
        }
    }
}
