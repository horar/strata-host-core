import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0

import "Editor/"
import "Sidebar/"

Item {
    id: editorRoot

    function setVisible(index) {
        let file = openFilesModel.get(index);
        if (file.open === false) {
            file.open = true
        }

        for (let i = 0; i < treeModel.openFiles.count; i++) {
            treeModel.openFiles[index].visible = (i === index)
        }
        fileStack.currentIndex = index;
    }

    SGQrcTreeModel {
        id: treeModel
        url: openProjectContainer.url
    }

    ListModel {
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

                        Connections {
                            target: treeModel

                            onAddedOpenFile: {
                                openFilesModel.append(item);
                            }
                            onRemovedOpenFile: {
                                openFilesModel.remove(index, 1)
                            }
                        }

                        delegate: Button {
                            id: fileTab
                            checked: model.visible
                            hoverEnabled: true

                            property color color: "#aaaaaa"
                            property int modelIndex: index

                            onClicked: {
                                if (checked) {
                                    editorRoot.setVisible(index)
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
                                            let item = treeModel.get(model.uid);

                                            // If the item isn't visible then just remove it
                                            if (!item.visible) {
                                                if (fileStack.currentIndex > fileTab.modelIndex) {
                                                    fileStack.currentIndex--;
                                                }
                                                treeModel.removeOpenFile(item);
                                            } else {
                                                item.visible = false
                                                item.open = false
                                                if (index - 1 >= 0) {
                                                    setVisible(index - 1)
                                                } else {
                                                    setVisible(index)
                                                }
                                            }
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

                    Repeater {
                        id: fileEditorRepeater
                        model: openFileModel

                        delegate: FileContainer {
                            Layout.fillHeight: true
                            Layout.fillWidth: true

                        }
                    }
                }
            }
        }
    }
}
