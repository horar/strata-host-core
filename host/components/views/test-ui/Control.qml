import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import "control-views"
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0

Item {
    id: controlNavigation
    anchors {
        fill: parent
    }

    property alias class_id: basic.class_id
    property alias user_id : basic.user_id
    property alias first_name : basic.first_name


    BasicControl {
        id: basic
    }

}
