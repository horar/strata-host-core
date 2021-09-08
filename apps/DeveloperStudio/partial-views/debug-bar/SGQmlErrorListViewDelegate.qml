import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Component {
    id: root
    
    Row {
        id: wrapper
        width: ListView.view.width
        spacing: 20
        
        Label {
            id: indexLabel
            text: qsTr("%1:").arg(index + 1)
        }
        
        TextInput {
            width: parent.width - indexLabel.contentWidth - 22
            Layout.fillWidth: true
            text: modelData
            selectByMouse: true
            readOnly: true
            wrapMode: TextInput.Wrap

            onFocusChanged: {
                if (focus) {
                    wrapper.ListView.view.currentIndex = index
                }
            }
        }
    }
}
