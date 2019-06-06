import QtQuick 2.7
import QtQuick.Layouts 1.3
//import QtQuick.Controls 2.3
import QtGraphicalEffects 1.0
import QtQuick.Controls.Styles 1.4
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import "qrc:/js/navigation_control.js" as NavigationControl
import "qrc:/views/5A-switcher/sgwidgets"
import "qrc:/js/help_layout_manager.js" as Help

RadioButton{
    id: radioButton
    style: RadioButtonStyle {
        indicator: Rectangle {
            implicitWidth: 16
            implicitHeight: 16
            radius: 9
            width: 20
            height: 20
            border.color: control.activeFocus ? "darkblue" : "gray"
            border.width: 1

            Rectangle {
                anchors.fill: parent
                visible: control.checked
                color: "#555"
                radius: 9
                anchors.margins: 4
            }
        }
    }
}

