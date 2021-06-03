import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: controlViewRoot

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
    
    Loader {
        id: loader
        Layout.fillWidth: true
        Layout.fillHeight: true

        sourceComponent: { 
            switch (tabBar.currentIndex) {
                case 0:
                    return exampleView
                case 1: 
                    return blankSandboxView
            }
        }
    }

    Component {
        id: exampleView
        
        Example {}
    }

    Component {
        id: blankSandboxView

        BlankSandbox {}
    }
}
