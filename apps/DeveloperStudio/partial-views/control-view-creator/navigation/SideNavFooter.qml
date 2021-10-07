/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0

import "qrc:/js/navigation_control.js" as NavigationControl
import "../components"

Item {
    implicitHeight: divider.height + recompileNavButton.height + column.implicitHeight
    implicitWidth: toolBarListView.width

    ColumnLayout {
        id: column
        width: parent.width
        anchors.top: parent.top

        SGSideNavItem {
            id: cleanupProjectNecessary
            iconText: "Clean"
            iconSource: "qrc:/sgimages/exclamation-triangle.svg"
            iconColor: "#ffc107"
            tooltipDescription: "The QRC file for this project contains files that no longer exist. Cleaning the project will remove these files from the QRC file."
            visible: editor.fileTreeModel.needsCleaning
            color: "transparent"

            onClicked: {
                confirmCleanFiles.open()
            }
        }

        SGSideNavItem {
            id: settingForProject
            iconText: "Settings"
            iconSource: "qrc:/sgimages/cog.svg"
            tooltipDescription: "Global settings for the Control View Creator"
            enabled: true // Allows for Settings to be always active regardless editor.treeModel

            onClicked: {
                cvcSettingsLoader.active = true
            }
        }
    }

    Rectangle {
        id: divider
        height: 1
        width: toolBarListView.width
        color: "lightgrey"
        anchors {
            top: column.bottom
            left: parent.left
        }
    }

    BusyIndicator {
        id: buildingIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: recompileNavButton.verticalCenter
        height: 30
        width: 30
        visible: recompileRequested
        running: visible

        contentItem: Item {
            implicitWidth: 30
            implicitHeight: 30

            Item {
                id: item
                x: parent.width / 2 - 15
                y: parent.height / 2 - 15
                width: 30
                height: 30

                RotationAnimator {
                    target: item
                    running: buildingIndicator.visible && buildingIndicator.running
                    from: 0
                    to: 360
                    loops: Animation.Infinite
                    duration: 1250
                }

                Repeater {
                    id: repeater
                    model: 6

                    Rectangle {
                        x: item.width / 2 - width / 2
                        y: item.height / 2 - height / 2
                        implicitWidth: 6
                        implicitHeight: 6
                        radius: 5
                        color: Theme.palette.onsemiOrange
                        transform: [
                            Translate {
                                y: -Math.min(item.width, item.height) * 0.5 + 3
                            },
                            Rotation {
                                angle: index / repeater.count * 360
                                origin.x: 3
                                origin.y: 3
                            }
                        ]
                    }
                }
            }
        }
    }

    SGSideNavItem {
        id: recompileNavButton

        width: parent.width
        height: 70
        anchors.top: divider.bottom

        iconText: "Build"
        iconSource: "qrc:/sgimages/bolt.svg"
        enabled: editor.fileTreeModel.url.toString() !== "" && !recompileRequested
        visible: !recompileRequested
        color: "transparent"
        tooltipDescription: "Recompile your control view project."

        onClicked: {
            checkRecompileBeforeView()
        }
    }

    Loader {
        id: cvcSettingsLoader
        sourceComponent: SGControlViewCreatorSettingsPopup {}
        active: false
    }

    function checkRecompileBeforeView() {
        if (openFilesModel.getUnsavedCount() > 0) {
            confirmBuildClean.open();
        } else {
            recompileControlViewQrc()
        }

        if (cvcUserSettings.openViewOnBuild && !confirmBuildClean.opened) {
            viewStack.currentIndex = 2
        }
    }
}
