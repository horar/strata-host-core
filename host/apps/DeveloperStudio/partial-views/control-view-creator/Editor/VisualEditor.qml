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
    id: layoutBuilderRoot

    property bool layoutDebugMode: false
    property var overlayObjects: []
    property string file: ""
    property string fileContents: ""

    Component.onCompleted: {
        reload()
    }

    function openFile(fileUrl) {
        if (fileUrl.startsWith("file")) {
            fileUrl = SGUtilsCpp.urlToLocalFile(fileUrl)
        }
//        console.log("OpenFile:", fileUrl)

        let fileContent = SGUtilsCpp.readTextFileContent(fileUrl)
//        console.log("content:", fileContent)
        return fileContent
    }

    function saveFile(fileUrl = file, text = fileContents) {
        SGUtilsCpp.atomicWrite(SGUtilsCpp.urlToLocalFile(fileUrl), text)
        reload()
    }

    function reload() {
        for (let i = 0; i < overlayObjects.length; i++) {
            overlayObjects[i].destroy()
        }
        overlayObjects = []
        sdsModel.resourceLoader.clearComponentCache(layoutBuilderRoot)
        fileContents = openFile(file)
        loader.setSource(layoutBuilderRoot.file)
        if (loader.children[0] && loader.children[0].objectName === "ControlViewRoot") {
            overlayContainer.rowCount = loader.children[0].rowCount
            overlayContainer.columnCount = loader.children[0].columnCount
            allChildren(loader.children[0])
        } else {
            console.log("Visual Editor error: file does not derive from UIBase")
            loader.setSource("qrc:/partial-views/SGLoadError.qml") // todo: modify primary text in SGLoadError as well as error message, allow more specific message here than "platform user interface"
            loader.item.error_message = "File does not derive from UIBase"
            // todo: disable visual editor controls
        }
    }

    function allChildren(item){
        //        console.log("Item:", item.uuid)
        if (item.hasOwnProperty("layoutInfo")){
            overlayContainer.createOverlay(item)
        }

        for (let i = 0; i < item.children.length; i++) {
            allChildren(item.children[i])
        }
    }

    function create_UUID(){
        var dt = new Date().getTime();
        var uuid = 'xxxxx'.replace(/[xy]/g, function(c) {
            var r = (dt + Math.random()*16)%16 | 0;
            dt = Math.floor(dt/16);
            return (c =='x' ? r :(r&0x3|0x8)).toString(16);
        });
        return uuid;
    }

    function addControl(controlPath){
//        console.log("addControl:", controlPath)
        let testComponent = openFile(controlPath)
        testComponent = testComponent.arg(create_UUID()) // replace all instances of %1 with uuid

        let regex = new RegExp("([\\s\\S]*)(\})","gm")  // insert testComponent before ending '}' in file
        fileContents = fileContents.replace(regex, "$1\n" + testComponent + "$2");
        // console.log("fileContents:", fileContents)
        saveFile(file, fileContents)

        if (!layoutDebugMode) {
            layoutDebugMode = true
        }
    }

    function removeControl(uuid) {
        let regex = new RegExp("(\\s.*start_"+ uuid +"[\\s\\S]*end_"+ uuid +"\\s)")
        // captures lines with start and end uuid tags, as well as those between and pre- and post-line breaks
        fileContents = fileContents.replace(regex, "");

        saveFile(file, fileContents)
    }

    function replaceObjectPropertyValueInString (object, prop, value, string = fileContents) {
        // total regex: (start_42e89[\\s\\S]*?yRows:\\s*)(.*)([\\s\\S]*?end_42e89)
        // explanation: find "yRows" prop, only occurring between start and end uuid tags, replace anything following with value

        // notes:
        // \\s\\S is "space or not space" ,aka wildcard, since 's' flag does not work in qml
        // *? is lazy find, i.e. stop after first find, otherwise catches last match instead
        // all 3 groups are captured for replacement as it is impossible to replace only one group that is matched
        let capture1 = "(start_" + object + "[\\s\\S]*?" + prop + "\\s*)"
        let capture2 = "(.*)"
        let capture3 = "([\\s\\S]*?end_" + object + ")"
        let regex = new RegExp(capture1 + capture2 + capture3, "gm")
        return string.replace(regex, "$1" + value + "$3");
    }

    function getId(uuid) {
        let capture1 = "start_" + uuid + "[\\s\\S]*?id:\\s*"
        let capture2 = "(.*)"
        let capture3 = "[\\s\\S]*?end_" + uuid + ""
        let regex = new RegExp(capture1 + capture2 + capture3)
        return fileContents.match(regex)[1];
    }

    Rectangle {
        color: "lightgrey"
        implicitHeight: controls.implicitHeight + 2
        Layout.fillWidth: true

        RowLayout {
            id: controls

            Button {
                text: "Reload"
                onClicked: {
                    // todo: add file listener so external changes are auto reloaded
                    reload()
                }
            }

            Button {
                text: "Layout mode: " + layoutDebugMode
                checkable: true
                checked: layoutDebugMode
                onCheckedChanged: {
                    layoutDebugMode = checked
                }
            }

            Button {
                text: "Add..."

                onClicked: {
                    addPop.open()
                }

                AddMenu {
                    id: addPop
                }
            }

            Button {
                text: "Rows/Cols..."

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
                                let count = loader.item.columnCount
                                count++
                                fileContents = replaceObjectPropertyValueInString ("uibase", "columnCount:", count)
                                saveFile(file, fileContents)
                            }
                        }

                        Button {
                            text: "columns--"

                            onClicked: {
                                let count = loader.item.columnCount
                                count--
                                fileContents = replaceObjectPropertyValueInString ("uibase", "columnCount:", count)
                                saveFile(file, fileContents)
                            }
                        }

                        Button {
                            text: "rows++"

                            onClicked: {
                                let count = loader.item.rowCount
                                count++
                                fileContents = replaceObjectPropertyValueInString ("uibase", "rowCount:", count)
                                saveFile(file, fileContents)
                            }
                        }

                        Button {
                            text: "rows--"

                            onClicked: {
                                let count = loader.item.rowCount
                                count--
                                fileContents = replaceObjectPropertyValueInString ("uibase", "rowCount:", count)
                                saveFile(file, fileContents)
                            }
                        }
                    }
                }
            }
        }
    }

    Item {
        id: loaderContainer
        Layout.fillHeight: true
        Layout.fillWidth: true

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

        Loader {
            id: loader
            anchors {
                fill: parent
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
                overLayObject.objectName = getId(item.layoutInfo.uuid)
                overLayObject.layoutInfo.uuid = item.layoutInfo.uuid
                overLayObject.layoutInfo.columnsWide = item.layoutInfo.columnsWide
                overLayObject.layoutInfo.rowsTall = item.layoutInfo.rowsTall
                overLayObject.layoutInfo.xColumns = item.layoutInfo.xColumns
                overLayObject.layoutInfo.yRows = item.layoutInfo.yRows

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
