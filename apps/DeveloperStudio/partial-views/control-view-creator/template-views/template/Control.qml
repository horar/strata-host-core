import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: controlViewRoot

    PlatformInterface {
        id: platformInterface
    }

    TabBar {
        id: tabBar
        Layout.fillWidth: true
        
        TabButton {
            text: "Commands and Notifications"
        }
        
        TabButton {
            text: "Advanced View"
        }
    }
    
    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex
        
        BasicControl {
            id: basic
        }

        AdvancedControl {
            id: advanced
        }
    }
}

