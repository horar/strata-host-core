import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import "qrc:/partial-views"
import "qrc:/partial-views/platform-selector"
import "qrc:/partial-views/distribution-portal"
import "js/navigation_control.js" as NavigationControl
import "qrc:/js/platform_filters.js" as Filters
import "qrc:/js/help_layout_manager.js" as Help

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

Rectangle{
    id: container
    anchors.fill: parent
    clip: true

    // Context properties that get passed when created dynamically
    property string user_id: ""
    property string first_name: ""
    property string last_name: ""

    Image {
        id: background
        source: "qrc:/images/circuits-background-tiled.svg"
        anchors.fill: parent
        fillMode: Image.Tile
    }

    GridLayout {
        anchors {
            fill: container
            margins: 30
        }

        columns: 3
        rows: 2
        rowSpacing: 30

        UserAndLogoContainer {
            Layout.columnSpan: 3
            Layout.alignment: Qt.AlignHCenter
        }

        FilterColumn {
            id: leftFilters
            model: Filters.categoryFilterModel
            side: "left"
        }

        SGPlatformSelectorListView {

        }

        FilterColumn {
            id: rightFilters
            model: Filters.categoryFilterModel
            side: "right"
        }
    }

    SGBaseDistributionButton {

    }

    SGIcon {
        Accessible.role: Accessible.Button
        Accessible.name: "Help Icon"
        Accessible.description: "Help tour button."
        Accessible.onPressAction: {
            Help.startHelpTour("selectorHelp", "strataMain")
        }

        id: helpIcon
        anchors {
            right: container.right
            bottom: container.bottom
            margins: 20
        }
        source: "qrc:/sgimages/question-circle.svg"
        iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
        height: 40
        width: 40

        MouseArea {
            id: helpMouse
            hoverEnabled: true
            anchors {
                fill: helpIcon
            }
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                Help.startHelpTour("selectorHelp", "strataMain")
            }
        }
    }

    Item {
        id: orderPopup

        function open() {
            var salesPopup = NavigationControl.createView("qrc:/partial-views/SGSalesPopup.qml", orderPopup)
            salesPopup.width = container.width-100
            salesPopup.height = container.height - 100
            salesPopup.x = container.width/2 - salesPopup.width/2
            salesPopup.y =  container.height/2 - salesPopup.height/2
            salesPopup.open()
        }
    }

}
