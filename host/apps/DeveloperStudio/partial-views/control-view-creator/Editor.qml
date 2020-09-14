import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0

import "Editor/"

Item {
    id: editorRoot

    function setVisible (index) {
        let file = fileModel.get(index);

        if (file.open === false) {
            file.open = true
        }

        for (let i = 0; i < fileModel.count; i++) {
            fileModel.get(i).visible = (i === index)
        }
        fileStack.currentIndex = openFileModel.mapIndexFromSource(index)
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
                        model: openFileModel
                        orientation: ListView.Horizontal
                        layoutDirection: Qt.LeftToRight
                        spacing: 3

                        delegate: SGButton {
                            id: fileTab
                            checked: model.visible
                            hoverEnabled: true

                            property int modelIndex: index

                            onClicked: {
                                if (checked) {
                                    editorRoot.setVisible(openFileModel.mapIndexToSource(modelIndex))
                                }
                            }

                            contentItem: Item {
                                implicitWidth: tabText.paintedWidth + tabText.anchors.leftMargin + 3 + closeFileIcon.implicitWidth + closeFileIcon.anchors.rightMargin
                                anchors.verticalCenter: parent.verticalCenter

                                SGText {
                                    id: tabText
                                    text: model.filename
                                    color: "white"
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
                                            let sourceIndex = openFileModel.mapIndexToSource(fileTab.modelIndex)
                                            let item = fileModel.get(sourceIndex)
                                            item.visible = false
                                            item.open = false

                                            // Make the last tab visible
                                            if (fileTabRepeater.count > 0) {
                                                setVisible(openFileModel.mapIndexToSource(fileTabRepeater.count - 1))
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

                SGSortFilterProxyModel {
                    id: openFileModel
                    sourceModel: fileModel
                    invokeCustomFilter: true

                    function filterAcceptsRow(index) {
                        let listElement = sourceModel.get(index)
                        return file_open(listElement)
                    }

                    function file_open(listElement) {
                        return listElement.open
                    }
                }
            }
        }
    }
}
