import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: controlNavigation
    anchors.fill: parent
    PlatformInterface {
        id: platformInterface
    }

    StackLayout {
        id: controlContainer
        anchors {
           fill: parent
        }

        BasicControl {
            id: basic
        }
    }
}
