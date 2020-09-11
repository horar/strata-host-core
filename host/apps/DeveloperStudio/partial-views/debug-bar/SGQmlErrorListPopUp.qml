import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Popup {
    id: root
    
    property alias title: errorListTitle.text

    property alias qmlErrorListModel: qmlErrorListView.model
    property alias errorListDetailsChecked: errorListDetailsButton.checked

    dim: errorListDetailsButton.checked
    closePolicy: Popup.NoAutoClose

    contentItem: ColumnLayout {
        RowLayout {
            spacing: 20
            
            Label {
                id: errorListTitle
                
                Layout.fillWidth: true
                
                color: "red"
                font {
                    bold: true
                    underline: true
                }
            }
            
            RoundButton {
                id: errorListDetailsButton
                
                text: checked ? qsTr("\u21a9") : qsTr("\uD83D\uDCC4")
                checkable: true
                checked: true
            }
        }
        
        SGQmlErrorListView {
            id: qmlErrorListView

            focus: true
            visible: errorListDetailsButton.checked

            delegate: SGQmlErrorListViewDelegate {}
        }
    }
}
