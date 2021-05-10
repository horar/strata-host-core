import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.3
import QtQml 2.12

import tech.strata.sgwidgets 1.0
import tech.strata.fonts 1.0
import tech.strata.commoncpp 1.0

import "VisualEditor/LayoutOverlay"
import "VisualEditor"

ColumnLayout {
    id: visualEditor
    spacing: 0

    property bool fileValid: false
    property string error: ""
    property bool layoutDebugMode: true
    property var overlayObjects: []
    property string file: ""
    property string fileContents: ""
    property alias loader: loader
    property alias functions: functions

    Component.onCompleted: {
        functions.reload()
    }

    VisualEditorFunctions {
        id: functions
    }

    Item {
        id: loaderContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

        Loader {
            id: loader
            anchors {
                fill: parent
            }
        }

        Item {
            id: gridContainer

            Repeater {
                model: layoutDebugMode ? overlayContainer.columnCount : 0
                delegate: Rectangle {
                    width: 1
                    opacity: .5
                    x: index * overlayContainer.columnSize
                    height: overlayContainer.height
                    color: "lightgrey"
                }
            }

            Repeater {
                model: layoutDebugMode ? overlayContainer.rowCount : 0
                delegate: Rectangle {
                    height: 1
                    opacity: .5
                    y: index * overlayContainer.rowSize
                    width: overlayContainer.width
                    color: "lightgrey"
                }
            }
        }

        Item {
            id: overlayContainer
            anchors {
                fill: parent
            }

            property int columnCount: 0
            property int rowCount: 0
            property real columnSize: width / columnCount
            property real rowSize: height / rowCount

            function createOverlay(item) {
                var overLayObject = overlayComponent.createObject(overlayContainer)

                // overlay's object name is equivalent to the id of the item since id's are not accessible at runtime
                overLayObject.objectName = functions.getId(item.layoutInfo.uuid)
                overLayObject.type = functions.getType(item.layoutInfo.uuid)
                if (overLayObject.objectName === "" || overLayObject.type === "") {
                    overLayObject.destroy()
                    return
                }
                overLayObject.layoutInfo.uuid = item.layoutInfo.uuid
                overLayObject.layoutInfo.columnsWide = item.layoutInfo.columnsWide
                overLayObject.layoutInfo.rowsTall = item.layoutInfo.rowsTall
                overLayObject.layoutInfo.xColumns = item.layoutInfo.xColumns
                overLayObject.layoutInfo.yRows = item.layoutInfo.yRows
                overLayObject.sourceItem = item

                overlayObjects.push(overLayObject)
            }

            Component {
                id: overlayComponent

                LayoutOverlay {
                    property int columnCount: overlayContainer.columnCount
                    property int rowCount: overlayContainer.rowCount
                    property real columnSize: overlayContainer.columnSize
                    property real rowSize: overlayContainer.rowSize
                }
            }
        }
    }
}
