import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

import "Editor/"
import "Sidebar/"
import "qrc:/js/platform_selection.js" as PlatformSelection

Item {
    id: editorRoot
    property alias treeModel: treeModel
    property alias editorToolBar: editorToolBar

    SGQrcTreeModel {
        id: treeModel
        url: openProjectContainer.url

        onModelAboutToBeReset: {
            openFilesModel.clear()
        }
    }

    SGFileTabModel {
        id: openFilesModel
    }

    SGSortFilterProxyModel {
        id: connectedPlatforms

        sourceModel: []
        sortEnabled: false
        invokeCustomFilter: true
        invokeCustomLessThan: false

        function filterAcceptsRow(index) {
            return sourceModel.get(index).connected;
        }
    }

    Connections {
        target: mainWindow

        onInitialized: {
            connectedPlatforms.sourceModel = PlatformSelection.platformSelectorModel
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SideBar {
            id: sideBar
            Layout.fillHeight: true
            Layout.preferredWidth: 250
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                id: editorToolBar
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                Layout.maximumHeight: 26

                spacing: 0

                property color buttonColor: "#777"

                signal saveClicked()
                signal undoClicked()
                signal redoClicked()

                SGComboBox {
                    Layout.fillHeight: true
                    Layout.topMargin: 0
                    Layout.preferredWidth: 350

                    model: connectedPlatforms
                    placeholderText: "Select a platform to connect to..."
                    textRole: "verbose_name"
                    boxColor: editorToolBar.buttonColor
                    textColor: "white"

                    onCurrentIndexChanged: {
                        let platform = connectedPlatforms.get(currentIndex);
                        controlViewCreatorRoot.debugPlatform = {
                            deviceId: platform.device_id,
                            classId: platform.class_id
                        };
                    }
                }

                Rectangle {
                    id: filler
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: editorToolBar.buttonColor
                }

                Repeater {
                    id: mainButtons

                    model: [
                        { buttonType: "save", iconSource: "qrc:/sgimages/save.svg" },
                        { buttonType: "undo", iconSource: "qrc:/sgimages/undo.svg" },
                        { buttonType: "redo", iconSource: "qrc:/sgimages/redo.svg" }
                    ]

                    delegate: SGButton {
                        Layout.fillHeight: true
                        Layout.preferredWidth: height

                        color: editorToolBar.buttonColor
                        iconColor: "white"
                        iconSize: 24
                        roundedLeft: false
                        roundedRight: false
                        roundedTop: false
                        roundedBottom: false

                        SGIcon {
                            id: icon
                            anchors.fill: parent
                            anchors.margins: 4
                            iconColor: "white"
                            source: modelData.iconSource
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onPressed: {
                                icon.iconColor = Qt.darker(icon.iconColor, 1.5)
                            }

                            onReleased: {
                                icon.iconColor = "white"
                            }

                            onClicked: {
                                switch (modelData.buttonType) {
                                case "save":
                                    editorToolBar.saveClicked()
                                    break;
                                case "undo":
                                    editorToolBar.undoClicked()
                                    break;
                                case "redo":
                                    editorToolBar.redoClicked()
                                    break;
                                default:
                                    break;
                                }
                            }
                        }
                    }
                }
            }

            ScrollView {
                Layout.preferredHeight: 45
                Layout.minimumHeight: 45
                Layout.fillWidth: true
                x: 2.5
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                background: Rectangle {
                    color: "#ccc"
                }

                ListView {
                    id: fileTabRepeater
                    model: openFilesModel
                    orientation: ListView.Horizontal
                    layoutDirection: Qt.LeftToRight
                    spacing: 1
                    currentIndex: openFilesModel.currentIndex

                    delegate: Button {
                        id: fileTab
                        hoverEnabled: true

                        property color color: "#aaaaaa"
                        property int modelIndex: index

                        onClicked: {
                            openFilesModel.currentIndex = index
                        }

                        background: Rectangle {
                            implicitHeight: 45
                            color: fileTab.ListView.isCurrentItem ? "white" : fileTab.color
                        }

                        contentItem: Item {
                            implicitWidth: tabText.paintedWidth + tabText.anchors.leftMargin + 3 + closeFileIcon.implicitWidth + closeFileIcon.anchors.rightMargin
                            anchors.verticalCenter: parent.verticalCenter

                            SGText {
                                id: tabText
                                text: model.filename
                                color: "black"
                                anchors {
                                    left: parent.left
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 5
                                }
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            SGIcon {
                                id: closeFileIcon
                                source: "qrc:/sgimages/times-circle.svg"
                                height: tabText.paintedHeight
                                width: height
                                implicitWidth: height
                                visible: fileTab.hovered
                                iconColor: "black"
                                anchors {
                                    left: tabText.right
                                    leftMargin: 4
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 2
                                }
                                verticalAlignment: Qt.AlignVCenter

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        cursorShape = Qt.PointingHandCursor
                                    }

                                    onClicked: {
                                        openFilesModel.closeTabAt(index);
                                    }
                                }
                            }

                            SGIcon {
                                id: unsavedChangesIcon
                                source: "qrc:/sgimages/asterisk.svg"
                                height: tabText.paintedHeight * .75
                                width: height
                                implicitWidth: height
                                iconColor: "black"
                                visible: !closeFileIcon.visible && model.unsavedChanges
                                anchors {
                                    left: tabText.right
                                    leftMargin: 4
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    rightMargin: 2
                                }
                                verticalAlignment: Qt.AlignVCenter
                            }
                        }
                    }
                }
            }

            StackLayout {
                id: fileStack
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentIndex: openFilesModel.currentIndex

                Repeater {
                    id: fileEditorRepeater
                    model: openFilesModel

                    delegate: Component {
                        Loader {
                            source: switch(model.filetype) {
                                case "svg":
                                case "jpg":
                                case "jpeg":
                                case "png":
                                case "gif":
                                    return "./Editor/ImageContainer.qml"
                                case "qml":
                                case "csv":
                                case "html":
                                case "txt":
                                case "json":
                                    return "./Editor/TextEditorContainer.qml"
                                default:
                                    return "./Editor/UnsupportedFileType.qml"
                            }
                        }
                    }
                }
            }
        }
    }
}
