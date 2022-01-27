/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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
                    sourceSize.width: Math.min(parent.width, 500)
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/on-semi-logo-horiz.svg"
                    mipmap: true
                    anchors {
                        centerIn: parent
                    }
                }
            }

            Item {
                id: middleContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.preferredWidth: rightContainer.Layout.preferredWidth
                Layout.preferredHeight: 150

                Image {
                    sourceSize.width: Math.min(parent.width, 250)
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

                    Rectangle {
                        // Strata onsemi.com landing page button
                        color: !mouse.containsMouse
                               ? Theme.palette.onsemiOrange : mouse.pressed
                                 ? Qt.darker(Theme.palette.onsemiOrange, 1.25) : Qt.darker(Theme.palette.onsemiOrange, 1.15)
                        radius: 10
                        Layout.preferredWidth: providerText.implicitWidth + providerText.height
                        Layout.maximumWidth: Layout.preferredWidth
                        Layout.preferredHeight: providerText.height * 2
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter

                        SGText {
                            id: providerText
                            text: "Visit Strata webpage at onsemi.com"
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

    Rectangle {
        anchors {
            right: container.right
            bottom: container.bottom
            margins: 20
        }
        height: 42
        width: height
        radius: width / 2

        SGIcon {
            id: helpIcon
            anchors {
                centerIn: parent
            }
            source: "qrc:/sgimages/question-circle.svg"
            iconColor: helpMouse.containsMouse ? "lightgrey" : "grey"
            height: parent.height - 2
            width: height
            Accessible.role: Accessible.Button
            Accessible.name: "Help Icon"
            Accessible.description: "Help tour button."
            Accessible.onPressAction: clickAction()

            function clickAction() {
                Help.startHelpTour("selectorHelp", "strataMain")
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
    }
}
