import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

RowLayout {
    id: controls

    Button {
        text: "Reload"
        implicitHeight: viewSelector.height
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onClicked: {
            // todo: add file listener so external changes are auto reloaded?
            // changes are reloaded when switching between visual editor and text editor, but not if changes are made from another app
            visualEditor.functions.reload()
        }
    }

    Button {
        text: "Layout mode: " + visualEditor.layoutDebugMode
        checkable: true
        checked: visualEditor.layoutDebugMode
        implicitHeight: viewSelector.height
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onCheckedChanged: {
            visualEditor.layoutDebugMode = checked
        }
    }

    Button {
        text: "Add..."
        implicitHeight: viewSelector.height
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onClicked: {
            addPop.open()
        }

        AddMenu {
            id: addPop
        }
    }

    Button {
        text: "Rows/Cols..."
        implicitHeight: viewSelector.height
        implicitWidth: implicitContentWidth + 10
        padding: 0

        onClicked: {
            rowColPop.open()
        }

        Popup {
            id: rowColPop
            y: parent.height

            ColumnLayout {

                Button {
                    text: "columns++"

                    onClicked: {
                        let count = visualEditor.loader.item.columnCount
                        setRowsColumns("columnCount:", ++count)

                    }
                }

                Button {
                    text: "columns--"

                    onClicked: {
                        let count = visualEditor.loader.item.columnCount
                        setRowsColumns("columnCount:", --count)
                    }
                }

                Button {
                    text: "rows++"

                    onClicked: {
                        let count = visualEditor.loader.item.rowCount
                        setRowsColumns("rowCount:", ++count)

                    }
                }

                Button {
                    text: "rows--"

                    onClicked: {
                        let count = visualEditor.loader.item.rowCount
                        setRowsColumns("rowCount:", --count)
                    }
                }
            }
        }
    }

    function setRowsColumns(type, count) {
        visualEditor.fileContents = visualEditor.functions.replaceObjectPropertyValueInString ("uibase", type, count)
        visualEditor.functions.saveFile()
        visualEditor.layoutDebugMode = true
    }
}
