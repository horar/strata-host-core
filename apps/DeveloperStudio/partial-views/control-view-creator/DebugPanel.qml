import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.12
import QtQuick.Window 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0
import QtQml 2.0


Item {
    id: root

    // width: 0
    //  visible: debugMenuSource.toString() !== ""

//    readonly property bool expanded: width > 0 && visible
//    readonly property int minimumExpandWidth: 400


    property url debugMenuSource: editor.fileTreeModel.debugMenuSource
//    property int expandWidth: minimumExpandWidth
//    property alias mainContainer: mainContainer

    anchors.top: parent.top
    anchors.right: parent.right

    visible: false

    property real rectWidth: 400

    Rectangle {
        id: mainContainer
        width: Math.min(parent.width, rectWidth)
        height: parent.height
        anchors.right: parent.right
        color: "lightgrey"
        // visible: width > 0
        //clip: true

        Loader {
            anchors.fill: parent
            source: root.debugMenuSource
        }
    }

    Rectangle {
        id: topWall
        y: 0
        width: 4
        height: parent.height + 5
        z:3
        color: "red"

        Binding {
            target: topWall
            property: "x"
            value: root.width - mainContainer.width - topWall.width
            when: mouseArea.drag.active === false

        }
        onXChanged: {
            if(mouseArea.drag.active) {
                rectWidth = parent.width - x
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: topWall
        drag.target: topWall
        drag.minimumY: 0
        drag.maximumY: 0
        drag.minimumX: 0
        drag.maximumX: (parent.width - 30)
        cursorShape: Qt.SplitHCursor
    }


    //    NumberAnimation {
    //        id: collapseAnimation
    //        target: root
    //        property: "width"
    //        duration: 200
    //        easing.type: Easing.InOutQuad
    //        to: 0
    //    }

    //    NumberAnimation {
    //        id: expandAnimation
    //        target: root
    //        property: "width"
    //        duration: 200
    //        easing.type: Easing.InOutQuad
    //        to: root.expandWidth
    //    }

    //    function expand() {
    //        expandAnimation.start()
    //    }

    //    function collapse() {
    //        collapseAnimation.start()
    //    }
}
