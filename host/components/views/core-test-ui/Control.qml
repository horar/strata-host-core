import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "control-views"

Item {
    id: controlNavigation
    anchors.fill: parent

    property alias class_id: basic.class_id
    property alias user_id : basic.user_id
    property alias first_name : basic.first_name
    property alias last_name : basic.last_name

    BasicControl {
        id: basic
    }
}
