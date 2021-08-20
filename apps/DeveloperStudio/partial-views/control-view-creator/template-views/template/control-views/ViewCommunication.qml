import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQml 2.12

import tech.strata.sglayout 1.0

// needs to be UIBase, or text will overflow the rectangle
UIBase {
    anchors {
        fill: parent
    }
    property alias text: txt.text

    ScrollView {
        id: rootScroll
        anchors {
            fill: parent
            margins: 7
        }

        ScrollBar.vertical: ScrollBar {
            height: rootScroll.height
            anchors.right: parent.right
        }

        TextEdit {
            id: txt
            readOnly: true
            selectByMouse: true
            font.pixelSize: 11
        }
    }
}
