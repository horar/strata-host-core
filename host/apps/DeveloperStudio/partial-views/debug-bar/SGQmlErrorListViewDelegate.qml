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
        
        TextInput {
            Layout.fillWidth: true
            text: modelData
            selectByMouse: true
            readOnly: true

            onFocusChanged: {
                if (focus) {
                    wrapper.ListView.view.currentIndex = index
                }
            }
        }
    }
}
