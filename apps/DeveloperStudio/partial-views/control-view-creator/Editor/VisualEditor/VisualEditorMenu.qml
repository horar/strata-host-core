import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

import "../../components"

RowLayout {
    id: controls

    MenuButton {
        text: "Layout mode"
        checkable: true
        checked: visualEditor.layoutDebugMode
        implicitHeight: menuRow.height - 10
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onCheckedChanged: {
            visualEditor.layoutDebugMode = checked
        }
    }

    MenuButton {
        text: "Add..."
        implicitHeight: menuRow.height - 10
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onClicked: {
            addPop.open()
        }

        AddMenu {
            id: addPop
        }
    }

    MenuButton {
        text: "Rows/Cols..."
        implicitHeight: menuRow.height - 10
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onClicked: {
            rowColPop.open()
        }

        Popup {
            id: rowColPop
            y: parent.height

            Component.onCompleted: {
                fetchValues()
            }

            ColumnLayout {

                RowLayout {

                    Text {
                        text: "Columns:"
                        Layout.preferredWidth: 80
                    }

                    SpinBox {
                        id: colSpin
                        editable: true
                        onValueChanged: {
                            if (visualEditor.loader.item && visualEditor.loader.item.columnCount !== undefined) {
                                if (value !== visualEditor.loader.item.columnCount) {
                                    setRowsColumns("columnCount", value)
                                }
                            }
                        }
                    }
                }

                RowLayout {

                    Text {
                        text: "Rows:"
                        Layout.preferredWidth: 80
                    }

                    SpinBox {
                        id: rowSpin
                        editable: true
                        onValueChanged: {
                            if (visualEditor.loader.item && visualEditor.loader.item.rowCount !== undefined) {
                                if (value !== visualEditor.loader.item.rowCount) {
                                    setRowsColumns("rowCount", value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        //filler
        Layout.fillHeight: true
        Layout.fillWidth: true
    }

    SGIcon {
        Layout.fillHeight: true
        Layout.topMargin: 3
        Layout.bottomMargin: 3
        Layout.preferredWidth: height
        source: "qrc:/sgimages/three-dots.svg"
        iconColor: dotsMouse.containsMouse ? "black" : "grey"

        MouseArea {
            id: dotsMouse
            anchors {
                fill: parent
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:  {
                dotsMenu.open()
            }
        }

        Popup {
            id: dotsMenu
            y: parent.height
            x: parent.width - width

            ColumnLayout {

                MenuButton {
                    text: "Force Visual Editor Reload"
                    implicitHeight: menuRow.height - 10
                    implicitWidth: implicitContentWidth + 10
                    padding: 0

                    onClicked: {
                        // todo: add file listener so external changes are auto reloaded?
                        // changes are reloaded when switching between visual editor and text editor, but not if changes are made from another app
                        visualEditor.functions.unload(true)
                        dotsMenu.close()
                    }
                }
            }
        }
    }

    Connections {
        target: visualEditor.loader
        onStatusChanged: {
            if (visualEditor.loader.status === Loader.Ready) {
                fetchValues()
            }
        }
    }

    function setRowsColumns(type, count) {
        visualEditor.functions.setObjectPropertyAndSave("uibase", type, count)
        
        if (!visualEditor.layoutDebugMode) {
            visualEditor.layoutDebugMode = true
        }
    }

    function fetchValues() {
        if (visualEditor.loader.item && visualEditor.loader.item.rowCount !== undefined) {
            rowSpin.value = visualEditor.loader.item.rowCount
        }
        if (visualEditor.loader.item && visualEditor.loader.item.columnCount !== undefined) {
            colSpin.value = visualEditor.loader.item.columnCount
        }
    }
}
