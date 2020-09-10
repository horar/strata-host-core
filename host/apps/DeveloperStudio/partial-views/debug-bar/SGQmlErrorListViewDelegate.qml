import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Component {
    id: root
    
    Row {
        id: wrapper
        
        width: parent.width
        
        spacing: 20
        
        Label {
            text: qsTr("%1:").arg(index + 1)
        }
        
        Label {
            Layout.fillWidth: true
            
            text: modelData
            elide: Text.ElideRight
            
            ToolTip.text: text
            ToolTip.visible: text ? errorLineTooltip.containsMouse : false
            
            MouseArea {
                id: errorLineTooltip
                
                anchors.fill: parent
                hoverEnabled: true
                
                onClicked: wrapper.ListView.view.currentIndex = index
            }
        }
    }
}
