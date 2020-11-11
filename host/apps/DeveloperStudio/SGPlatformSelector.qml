import QtQuick 2.7
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0

import "partial-views"
import "partial-views/platform-selector"
import "partial-views/distribution-portal"
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

    ColumnLayout {
        id: column
        anchors {
            fill: container
            margins: 20
        }
        spacing: 20

        RowLayout {

            Item {
                // filler to match DistributionButton
                Layout.preferredHeight: distributionPortal.implicitHeight
                Layout.fillWidth: true
                Layout.preferredWidth: distributionPortal.implicitWidth
            }

            RecentlyReleased {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.maximumWidth: implicitWidth
            }

            Item {
                Layout.preferredHeight: distributionPortal.implicitHeight
                Layout.fillWidth: true
                Layout.preferredWidth: distributionPortal.implicitWidth

                SGBaseDistributionButton {
                    id: distributionPortal
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                    }
                    width: Math.min(parent.width, implicitWidth)
                }
            }
        }

        RowLayout {
            spacing: container.width < 1100 ?0 : 30

            FilterColumn {
                id: leftFilters
                model: Filters.categoryFilterModel
                side: "left"
            }

            SGPlatformSelectorListView {
                id: platformSelectorListView
            }

            FilterColumn {
                id: rightFilters
                model: Filters.categoryFilterModel
                side: "right"
            }
        }
    }

    SGIcon {
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
        Accessible.role: Accessible.Button
        Accessible.name: "Help Icon"
        Accessible.description: "Help tour button."
        Accessible.onPressAction: clickAction()

        function clickAction() {
            Help.startHelpTour("selectorHelp", "strataMain")
        }

        Rectangle {
            // white icon backround fill
            anchors {
                centerIn: parent
            }
            width: parent.width - 4
            height: width
            radius: width/2
            z:-1
        }

        MouseArea {
            id: helpMouse
            hoverEnabled: true
            anchors {
                fill: helpIcon
            }
            cursorShape: Qt.PointingHandCursor

            onClicked: helpIcon.clickAction()
        }
    }

    Item {
        id: orderPopup

        function open() {
            var salesPopup = NavigationControl.createView("qrc:/partial-views/general/SGWebPopup.qml", orderPopup)
            salesPopup.width = Qt.binding(()=> container.width-100)
            salesPopup.height = Qt.binding(()=> container.height - 100)
            salesPopup.x = Qt.binding(()=> container.width/2 - salesPopup.width/2)
            salesPopup.y =  Qt.binding(()=> container.height/2 - salesPopup.height/2)
            salesPopup.url = "https://www.onsemi.com/PowerSolutions/locateSalesSupport.do"
            salesPopup.open()
        }
    }
}
