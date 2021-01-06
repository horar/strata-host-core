import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.theme 1.0

import "qrc:/js/navigation_control.js" as NavigationControl

Item {
    implicitHeight: divider.height + recompileNavButton.height + cleanupProjectNecessary.height
    implicitWidth: toolBarListView.width

    SGSideNavItem {
        id: cleanupProjectNecessary

        width: parent.width
        height: 70
        anchors.top: parent.top

        iconText: "Clean"
        iconSource: "qrc:/sgimages/exclamation-triangle.svg"
        iconColor: "#ffc107"
        tooltipDescription: "The QRC file for this project contains files that no longer exist. Cleaning the project will remove these files from the QRC file."
        visible: editor.fileTreeModel.needsCleaning
        color: "transparent"

        function onClicked () {
            confirmCleanFiles.open()
        }
    }

    Rectangle {
        id: divider
        height: 1
        width: toolBarListView.width
        color: "lightgrey"
        anchors {
            top: cleanupProjectNecessary.bottom
            left: parent.left
        }
    }

    BusyIndicator {
        id: buildingIndicator
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: recompileNavButton.verticalCenter
        height: 30
        width: 30
        visible: toolBarListView.recompiling
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
                        color: Theme.palette.green
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
        enabled: editor.fileTreeModel.url.toString() !== "" && !toolBarListView.recompiling
        visible: !toolBarListView.recompiling
        color: "transparent"
        tooltipDescription: "Recompile your control view project."

        function onClicked() {
            toolBarListView.recompiling = true;
            recompileControlViewQrc();
        }

        Connections {
            target: sdsModel.resourceLoader

            onFinishedRecompiling: {
                if (recompileRequested) { // enforce that CVC requested this recompile
                    recompileRequested = false
                    rccInitialized = true
                    if (filepath !== '') {
                        loadDebugView(filepath)
                    } else {
                        let error_str = sdsModel.resourceLoader.getLastLoggedError()
                        controlViewLoader.setSource(NavigationControl.screens.LOAD_ERROR,
                                                    { "error_message": error_str });
                    }
                }
            }
        }
    }
}
