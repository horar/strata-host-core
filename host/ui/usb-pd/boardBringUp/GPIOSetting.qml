import QtQuick 2.0
import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.1
//import QtQuick.Controls 1.4
import QtGraphicalEffects 1.0

Item {
    property string settingMessageOne: ""
    property string settingMessageTwo: ""
    property bool initialState: false
        RowLayout {
            id: rowRow
            anchors.rightMargin: 454
            anchors.bottomMargin: 0
            anchors.leftMargin: 15
            anchors.topMargin: 0
            spacing: 10
            anchors.fill: parent

            Switch {
                id: switchComponent
                y: 221
                checkable: true
                checked: initialState
                transform:  Rotation {angle : 90}
            }

            Text {
                y: 282
                width: rowRow.width - rowRow.spacing - switchComponent.width
                height: switchComponent.height
                anchors.left: switchComponent.right
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
                text: switchComponent.checked ? settingMessageOne : settingMessageTwo
            }
        }


}
