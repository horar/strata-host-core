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
import tech.strata.theme 1.0

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
            spacing: 10
            Layout.fillHeight: false

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: rightContainer.Layout.preferredWidth
                Layout.preferredHeight: 150

                Image {
                    sourceSize.width: Math.min(parent.width, 275)
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/strata-logo.svg"
                    mipmap: true
                    anchors {
                        centerIn: parent
                    }
                }
            }

            Item {
                id: rightContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: distributionPortal.implicitWidth
                Layout.preferredHeight: 150

                ColumnLayout {
                    width: parent.width
                    anchors {
                        centerIn: parent
                    }
                    spacing: 7

                    Image {
                        sourceSize.width: Math.min(parent.width, 250)
                        fillMode: Image.PreserveAspectFit
                        source: "qrc:/images/on-semi-logo-horiz.svg"
                        mipmap: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        // Strata Onsemi.com landing page button
                        color: !mouse.containsMouse
                               ? Theme.palette.green : mouse.pressed
                                 ? Qt.darker(Theme.palette.green, 1.25) : Theme.palette.green
                        radius: 10
                        Layout.preferredWidth: providerText.implicitWidth + providerText.height
                        Layout.maximumWidth: Layout.preferredWidth
                        Layout.preferredHeight: providerText.height * 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        SGText {
                            id: providerText
                            text: "Visit Strata at ONSemi.com"
                            color: "white"
                            font.family: Fonts.franklinGothicBold
                            anchors {
                                verticalCenter: parent.verticalCenter
                            }
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            fontSizeMultiplier: 1
                        }

                        MouseArea {
                            id: mouse
                            anchors {
                                fill: parent
                            }
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: Qt.openUrlExternally("http://www.onsemi.com/strata")
                        }
                    }

                    SGBaseDistributionButton {
                        id: distributionPortal
                        Layout.fillWidth: false
                        Layout.preferredWidth: Math.min(parent.width, implicitWidth)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        SGPlatformSelectorListView {
            id: platformSelectorListView
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
            width: parent.width + 2
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
