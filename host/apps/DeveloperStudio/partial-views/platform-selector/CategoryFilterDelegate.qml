import QtQuick 2.12
import QtQuick.Controls 2.12

import "qrc:/js/platform_filters.js" as Filters

import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

Item {
    id: root
    height: icon.height + 5
    anchors {
        horizontalCenter: parent.horizontalCenter
    }
    width: {
        if (parent.width >= fullWidth) {
            return fullWidth
        } else if (parent.width >= minimizedWidth) {
            return minimizedWidth
        } else {
            return 0
        }
    }
    objectName: "filterButton"

    property real fullWidth: (icon.width/2) + textBackground.width
    property real minimizedWidth: icon.width
    property bool pressed: false
    property color green: Theme.strataGreen

    property alias iconSource: icon.source
    property alias text: text.text

    Component.onCompleted: {
        // Restore previously set filters
        setState()
    }

    Connections {
        target: Filters.utility
        onCategoryFiltersChanged: {
            setState()
        }
    }

    function setState() {
        for (let i = 0; i < Filters.categoryFilters.length; i++) {
            if (Filters.categoryFilters[i] === model.filterName) {
                root.pressed = true
                break
            }
        }
    }

    Rectangle {
        id: textBackground
        visible: root.width >= fullWidth
        anchors {
            verticalCenter: iconBackground.verticalCenter
            left: iconBackground.horizontalCenter
        }
        color: root.pressed ? "black" : root.green
        radius: height * 0.15
        height: icon.height * 0.9
        width: icon.width * 2
    }

    Item {
        id: textContainer
        visible: textBackground.visible
        anchors {
            left: iconBackground.right
            right: textBackground.right
            top: textBackground.top
            bottom: textBackground.bottom
        }

        SGText {
            id: text
            color: "white"
            anchors {
                fill: textContainer
                margins: 2
            }
            wrapMode: Text.Wrap
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: 'Test'
        }
    }

    Rectangle {
        id: iconBackground
        color: root.pressed ? root.green : "black"
        width: 75
        height: 75
        radius: width/2
        visible: root.width >= minimizedWidth

        Image {
            id: icon
            anchors {
                fill: parent
            }
            source: "qrc:/partial-views/platform-selector/images/icons/filter-icons/amplifiers_and_comparators.svg"
            mipmap: true
        }

        Item {
            id: toolTipPositioner
            width: iconBackground.width
            height: 1
            anchors {
                top: iconBackground.top
                topMargin: 10
            }

            ToolTip {
                text: root.text
                visible: mouseArea.containsMouse && root.width === minimizedWidth
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: root
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.pressed = !root.pressed
            if (root.pressed) {
                Filters.categoryFilters.push(model.filterName)
                Filters.utility.categoryFiltersChanged()
            } else {
                for (let i = 0; i < Filters.categoryFilters.length; i++) {
                    if (Filters.categoryFilters[i] === model.filterName) {
                        Filters.categoryFilters.splice(i,1)
                        Filters.utility.categoryFiltersChanged()
                        break
                    }
                }
            }
        }
    }
}
