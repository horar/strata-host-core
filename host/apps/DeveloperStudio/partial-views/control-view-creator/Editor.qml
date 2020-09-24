import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

import "Editor/"
import "Sidebar/"

Item {
    id: editorRoot

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

    ColumnLayout {
        anchors.fill: parent

        spacing: 0

        Rectangle {
            id: editorControlBar
            Layout.preferredHeight: 45
            Layout.fillWidth: true
            color: "#777"

            RowLayout {
                x:2.5
                height: parent.height

                SGButton {
                    id: saveButton
                    text: "Save file"
                }

                SGButton {
                    text: "Undo"
                }

                SGButton {
                    text: "Redo"
                }
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
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

                ScrollView {
                    Layout.preferredHeight: 45
                    Layout.fillWidth: true
                    x:2.5
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                    background: Rectangle {
                        color: "#777"
                    }

                    ListView {
                        id: fileTabRepeater
                        model: openFilesModel
                        orientation: ListView.Horizontal
                        layoutDirection: Qt.LeftToRight
                        spacing: 3

                        delegate: Button {
                            id: fileTab
                            checked: index === openFilesModel.currentIndex
                            hoverEnabled: true

                            property color color: "#aaaaaa"
                            property int modelIndex: index

                            onClicked: {
                                if (checked) {
                                    openFilesModel.currentIndex = index
                                }
                            }

                            background: Rectangle {
                                implicitHeight: 40
                                color: fileTab.checked ? Qt.darker(fileTab.color, 1.3) : fileTab.color
                                radius: 4
                            }

                            contentItem: Item {
                                implicitWidth: tabText.paintedWidth + tabText.anchors.leftMargin + 3 + closeFileIcon.implicitWidth + closeFileIcon.anchors.rightMargin
                                anchors.verticalCenter: parent.verticalCenter

                                SGText {
                                    id: tabText
                                    text: model.filename
                                    color: fileTab.checked ? "white" : "black"
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
                                Layout.fillWidth: true
                                Layout.fillHeight: true

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
}
