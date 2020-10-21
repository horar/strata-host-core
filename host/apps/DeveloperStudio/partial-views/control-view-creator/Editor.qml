import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.2

import tech.strata.sgwidgets 1.0
import tech.strata.commoncpp 1.0
import tech.strata.SGQrcTreeModel 1.0
import tech.strata.SGFileTabModel 1.0

import "Editor/"
import "Sidebar/"
import "../"

Item {
    id: editorRoot
    property alias treeModel: treeModel
    property alias openFilesModel: openFilesModel

    SGQrcTreeModel {
        id: treeModel

        onModelAboutToBeReset: {
            openFilesModel.clear()
            parsingErrorRect.errorMessage = ""
            parsingErrorRect.visible = false

        }

        onErrorParsing: {
            parsingErrorRect.errorMessage = error;
            parsingErrorRect.visible = true
            openProjectContainer.url = ""
        }
    }

    SGFileTabModel {
        id: openFilesModel
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
                                        if (model.unsavedChanges) {
                                            confirmClosePopup.filename = model.filename
                                            confirmClosePopup.index = index
                                            confirmClosePopup.open()
                                        } else {
                                            openFilesModel.closeTabAt(index);
                                        }
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

            Rectangle {
                id: parsingErrorRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#666"
                visible: false

                property string errorMessage: ""

                SGText {
                    id: errorText

                    anchors {
                        centerIn: parent
                    }

                    color: "white"
                    font.bold: true
                    fontSizeMultiplier: 2
                    text: "Error: " + parsingErrorRect.errorMessage
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            ConfirmClosePopup {
                id: confirmClosePopup
                x: fileTabRepeater.width / 2 - width / 2
                y: fileTabRepeater.y + height

                titleText: "Do you want to save the changes made to " + filename + "?"
                popupText: "Your changes will be lost if you choose to not save them."

                property string filename: ""
                property int index

                onPopupClosed: {
                    if (closeReason === confirmClosePopup.closeFilesReason) {
                        openFilesModel.closeTabAt(index)
                    } else if (closeReason === confirmClosePopup.acceptCloseReason) {
                        openFilesModel.saveFileAt(index)
                        openFilesModel.closeTabAt(index)
                    }
                }
            }

            StackLayout {
                id: fileStack
                Layout.fillHeight: visible
                Layout.fillWidth: true
                currentIndex: openFilesModel.currentIndex
                visible: !parsingErrorRect.visible

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
