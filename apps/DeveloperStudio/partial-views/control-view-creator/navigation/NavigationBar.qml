import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import tech.strata.theme 1.0
import tech.strata.sgwidgets 1.0

import "../"
import "../components"

Rectangle {
    id: navigationBar
    Layout.fillHeight: true
    Layout.preferredWidth: 71 // same width as strata logo box in StatusBar
    Layout.alignment: Qt.AlignTop
    color: "#444"

    Rectangle {
        // divider
        color: "black"
        width: 2
        height: parent.height
        anchors.right: parent.right
        opacity: .25
    }

    ColumnLayout {
        id: toolBarListView
        anchors.fill: parent
        spacing: 5

        SGSideNavItem {
            iconText: "Start"
            iconSource: "qrc:/sgimages/list.svg"
            enabled: true
            selected: viewStack.currentIndex === 0
            tooltipDescription: "Open or create project"

            onClicked: {
                viewStack.currentIndex = 0
            }
        }

        SGSideNavItem {
            iconText: "Edit"
            iconSource: "qrc:/sgimages/edit.svg"
            selected: viewStack.currentIndex === 1
            tooltipDescription: "Edit control view project files"

            onClicked: {
                viewStack.currentIndex = 1
            }
        }

        SGSideNavItem {
            iconText: "View"
            iconSource: "qrc:/sgimages/eye.svg"
            selected: viewStack.currentIndex === 2
            tooltipDescription: "View/use control view"

            onClicked: {
                viewStack.currentIndex = 2
            }
        }

        SGSideNavItem {
            iconText: "Debug"
            iconSource: "qrc:/sgimages/tools.svg"
            enabled: viewStack.currentIndex === 2
            selected: isDebugMenuOpen
            tooltipDescription: "Toggle debug panel"

            onClicked: {
                if (debugMenuWindow) {
                    newWindowDebugMenuLoader.item.raise()
                } else {
                    isDebugMenuOpen = !isDebugMenuOpen
                }
            }
        }

        SGSideNavItem {
            iconText: "Logs"
            iconSource: "qrc:/sgimages/bars.svg"
            selected: consoleContainer.visible && enabled
            enabled: viewStack.currentIndex === 1 || viewStack.currentIndex === 2
            tooltipDescription: "Toggle logger panel"

            onClicked: {
                if (popupWindow) {
                    newWindowLoader.item.raise()
                } else {
                    isConsoleLogOpen = !isConsoleLogOpen
                }
            }

            SGConsoleLogNavigationIcon {
                id: errorDisplayCount
                width: 22
                count: consoleLogErrorCount + consoleLogWarningCount
                type: consoleLogErrorCount > 0 ? "error" : consoleLogWarningCount > 0 ? "warning" : "error"
                color: "dark grey"
            }
        }

        SGSideNavItem {
            iconText: "Platform Interface Generator" + (platformInterfaceGenerator.unsavedChanges ? "*" : "")
            iconSource: "qrc:/partial-views/control-view-creator/components/PlatformInterfaceGeneratorIcon.svg"
            selected: viewStack.currentIndex === 3
            enabled: true
            tooltipDescription: "Show Platform Interface Generator"

            onClicked: {
                viewStack.currentIndex = 3
            }
        }

        Item {
            id: filler
            Layout.fillHeight: true
            Layout.fillWidth: true
        }

        SideNavFooter {
            id: footer
            Layout.preferredHeight: 70
            Layout.minimumHeight: footer.implicitHeight
            Layout.fillWidth: true
        }
    }
}
