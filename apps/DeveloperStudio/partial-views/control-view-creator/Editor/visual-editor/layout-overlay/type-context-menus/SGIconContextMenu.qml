import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3

import tech.strata.sgwidgets 1.0
import ".."

ColumnLayout {
    spacing: 1

    ContextMenuButton {
        text: "Select Icon"
        onClicked: {
            iconPicker.open()
        }
    }

    ContextMenuButton {
        text: "Set iconColor"
        onClicked: {
            menuLoader.setSource("qrc:/partial-views/control-view-creator/Editor/VisualEditor/LayoutOverlay/LayoutPopupContext/ColorPopup.qml")
            menuLoader.active = true
            menuLoader.item.color = layoutOverlayRoot.sourceItem.iconColor
            menuLoader.item.sourceProperty = "iconColor"
            menuLoader.item.open()
            contextMenu.close()
        }
    }

    Popup {
        id: iconPicker
        anchors.centerIn: Overlay.overlay
        modal: true

        onClosed: contextMenu.close()

        ColumnLayout {
            spacing: 20

            SGText {
                text: "The following is a list of icons which are already built into Strata Developer Studio. If you cannot find a satisfactory icon here, you may still add unique icons to your control view by adding them to your QRC file and manually specifying their source location."
                wrapMode: Text.Wrap
                Layout.preferredWidth: grid.implicitWidth
                horizontalAlignment: Text.AlignHCenter
            }

            GridLayout {
                id: grid
                columns: 15
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: ListModel {
                        Component.onCompleted: {
                            let list = sdsModel.resourceLoader.getQrcPaths(":sgimages")
                            list.sort()
                            for (let i = 0; i < list.length; i++) {
                                let name = list[i]
                                if (name.includes(".svg") && name.includes("status-light") === false) {
                                    name = name.substring(
                                                name.lastIndexOf("/") + 1,
                                                name.lastIndexOf(".svg"))
                                    append({
                                               source: "qrc" + list[i],
                                               text: name
                                           })
                                }
                            }
                        }
                    }

                    delegate: MouseArea {
                        id: iconMouse
                        implicitHeight: iconColumn.implicitHeight
                        implicitWidth: iconColumn.implicitWidth
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        Layout.alignment: Qt.AlignTop

                        onClicked: {
                            visualEditor.functions.setObjectPropertyAndSave(layoutOverlayRoot.layoutInfo.uuid, "source", '"' + model.source + '"')
                            iconPicker.close()
                        }

                        Rectangle {
                            anchors {
                                fill: parent
                                margins: -5
                            }
                            radius: 5
                            color: "lightGrey"
                            opacity: .5
                            visible: iconMouse.containsMouse
                        }

                        ColumnLayout {
                            id: iconColumn

                            SGIcon {
                                source: model.source
                                implicitHeight: 40
                                implicitWidth: 40
                            }

                            SGText {
                                Layout.preferredWidth: 40
                                text: model.text
                                wrapMode: Text.Wrap
                                fontSizeMultiplier: .75
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
