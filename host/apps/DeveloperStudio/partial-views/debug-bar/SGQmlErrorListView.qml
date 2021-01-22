import QtQuick 2.12
import QtQuick.Controls 2.12

ListView {
    id: root
    
    implicitWidth: 800
    implicitHeight: 480
    
    clip: true
    
    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AlwaysOn }
    
    highlight: Rectangle {
        color: "#eee"
        radius: 5
    }
}
