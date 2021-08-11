import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: controlViewRoot

    property string class_id // automatically populated for use when the control view is created with a connected board

    PlatformInterface {
        id: platformInterface
    }

    TabBar {
        id: tabBar
        Layout.fillWidth: true
        
        TabButton {
            text: "Visual Editor Example"
        }
        
        TabButton {
            text: "Blank Sandbox"
        }
    }
    
    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex
        
        Example {
            id: exampleView
        }

        BlankSandbox {
            id: blankSandboxView
        }
    }
}

