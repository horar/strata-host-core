import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sgwidgets 1.0
/********************************************************************
  TODO: CS-1380 - Style this notification delegate and add the necessary components
    for maintaining the list of notifications
 ********************************************************************/
Rectangle {
    width: parent.width
    height: columnLayout.implicitHeight
    radius: 4
    color: "transparent"

    property int modelIndex

    Timer {
        interval: model.timeout
        running: model.timeout > 0
        repeat: false

        onTriggered: {
            Notifications.remove(modelIndex)
        }
    }

    ColumnLayout {
        id: columnLayout
        width: parent.width

        Text {
            id: title
            text: model.title
        }

        Text {
            id: description
            text: model.description
        }

        Repeater {
            model: actions

            delegate: Button {
                id: button
                text: model.action.text
                action: model.action
            }
        }
    }
}
