import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 0.9

Rectangle {
    id: root
    color: statusBoxColor
    border {
        color: statusBoxBorderColor
        width: 1
    }
    implicitHeight: 200
    implicitWidth: 300

    property string title: qsTr("")
    property color titleTextColor: "#000000"
    property color titleBoxColor: "#eeeeee"
    property color titleBoxBorderColor: "#dddddd"
    property color statusTextColor: "#000000"
    property color statusBoxColor: "#ffffff"
    property color statusBoxBorderColor: "#dddddd"

    property bool showMessageIds: false
    property bool filterEnabled: true
    property alias delegate: listView.delegate
    property variant model: listModel           // you may use your own model in advanced use cases, this can break the built-in model manipulation functions
    property alias listView: listView
    property alias listViewMouse: listViewMouse
    property string filterRole: "message"       // this role is what is cmd/ctrl-f filters on
    property string copyRole: ""


    //  A listElement template that allows manipulation by id (see functions at bottom)
    //  as well as enablement of mouse element selection ability
    property var listElementTemplate: {
        "message": "",
        "id": 0,
    }

    Rectangle {
        id: titleArea
        anchors {
            left: root.left
            right: root.right
            top: root.top
        }
        height: visible ? 35 : 0
        color: root.titleBoxColor
        border {
            color: root.titleBoxBorderColor
            width: 1
        }
        visible: title.text !== ""

        Text {
            id: title
            anchors {
                fill: titleArea
            }
            text: root.title
            color: root.titleTextColor
            padding: 10
        }
    }

    ListModel {
        id: listModel
    }

    ListView {
        id: listView
        anchors {
            left: root.left
            right: root.right
            top: titleArea.bottom
            bottom: root.bottom
            margins: 10
        }
        clip: true
        model: root.model

        delegate: Rectangle {
            id: delegatecontainer
            height: delegateText.height
            width: ListView.view.width

            Text {
                id: delegateText

                text: { return (
                            root.showMessageIds ?
                                model.id + ": " + model.message :
                                model.message
                            )}

                font.pixelSize: 12
                color: root.statusTextColor
                wrapMode: Text.WrapAnywhere
                width: parent.width
            }
        }

        Connections {
            // listView will scroll to display new message when view is already at end of list
            id: autoScroll
            target: listView

            // Logic:
            //     onCountChanged and redraws are asynchronous (count can change many times before redraw), so atYEnd state is stored (wasAtYEnd) until redraw.
            //     If atYEnd was true, redraw will falsify it (signalling onAtYEndChanged), where wasAtYEnd is used to call positionViewAtEnd().

            property bool wasAtYEnd: false

            onCountChanged:  {
                wasAtYEnd = listView.atYEnd
            }

            onAtYEndChanged: {
                if (wasAtYEnd) {
                    listView.positionViewAtEnd()
                    wasAtYEnd = false
                }
            }
        }
    }

    MouseArea {
        id: listViewMouse
        anchors.fill: listView
        propagateComposedEvents: true
    }

    Rectangle {
        id: filterContainer
        width: 105
        height: 0
        anchors {
            top: titleArea.bottom
            right: titleArea.right
        }
        color: "#eee"
        visible: true
        clip: true

        PropertyAnimation {
            id: openFilter
            target: filterContainer
            property: "height"
            from: 0
            to: 30
            duration: 100
        }

        PropertyAnimation {
            id: closeFilter
            target: filterContainer
            property: "height"
            from: 30
            to: 0
            duration: 100
        }

        SGSubmitInfoBox {
            id: filterBox
            anchors {
                left: filterContainer.left
                bottom: filterContainer.bottom
                leftMargin: 3
                bottomMargin: 3
            }
            infoBoxColor: "#fff"
            infoBoxWidth: 80
            infoBoxHeight: 24
            placeholderText: "Filter..."
            leftJustify: true

            ListModel {
                id: filterModel
            }

            Item {
                id: textClear
                width: iconImage.width
                height: iconImage.height
                anchors {
                    right: filterBox.right
                    verticalCenter: filterBox.verticalCenter
                    verticalCenterOffset: 1
                    rightMargin: 3
                }
                visible: filterBox.value !== ""

                Image {
                    id: iconImage
                    visible: false
                    fillMode: Image.PreserveAspectFit
                    source: "icons/ban.svg"
                    sourceSize.height: 13
                }

                ColorOverlay {
                    id: overlay
                    anchors.fill: iconImage
                    source: iconImage
                    visible: true
                    color: "grey"
                }

                MouseArea {
                    id: textClearButton
                    anchors {
                        fill: textClear
                    }
                    onClicked: {
                        filterBox.value = ""
                        filterBox.applied ("")
                    }
                }
            }

            onApplied: {
                filterModel.clear()

                if (value.length >0) {
                    var caseInsensitiveFilter = new RegExp(value, 'i')
                    for (var i = 0; i < root.model.count; i++) {
                        var listElement = root.model.get(i);
                        onFilter(listElement)
                        if (caseInsensitiveFilter.test (listElement[root.filterRole])) {
                            filterModel.append(listElement)
                        }
                    }
                    listView.model = filterModel
                } else {
                    listView.model = root.model
                }
            }
        }

        Item {
            id: filterSearch
            width: iconImage1.width
            height: iconImage1.height
            anchors {
                left: filterBox.right
                verticalCenter: filterBox.verticalCenter
                verticalCenterOffset: 1
                leftMargin: 5
            }

            Image {
                id: iconImage1
                visible: false
                fillMode: Image.PreserveAspectFit
                source: "icons/search.svg"
                sourceSize.height: 13
            }

            ColorOverlay {
                id: overlay1
                anchors.fill: iconImage1
                source: iconImage1
                visible: true
                color: "grey"
            }

            MouseArea {
                id: filterSearchButton
                anchors {
                    fill: filterSearch
                }
                onClicked: {
                    filterBox.applied (filterBox.value)
                }
            }
        }
    }

    Shortcut {
        sequence: StandardKey.Find
        enabled: filterEnabled
        onActivated: {
            if ( filterContainer.height === 0 ){
                openFilter.start()
            }
            filterBox.textInput.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        enabled: filterEnabled
        onActivated: {
            if ( filterContainer.height === 30 ){
                closeFilter.start()
            }
            filterBox.value = ""
            filterBox.applied ("")
        }
    }

    Shortcut {
        sequence: StandardKey.Copy
        onActivated: {
            var stringToCopy = ""
            for (var i = 0; i<listView.model.count; i++) {
                if (copySelectionTest(i)) {
                    if (stringToCopy !== "") {
                        stringToCopy += "\n"
                    }
                    stringToCopy += listView.model.get(i)[root.copyRole]
                }
            }

            cliphelper.text = stringToCopy
            cliphelper.selectAll()
            cliphelper.copy()
        }
    }

    TextEdit {
        // Used for built-in clipboard function copy()
        id: cliphelper
        visible: false
    }

    function onFilter(listElement) {
        // Override this to manipulate model elements on filtration
    }

    function copySelectionTest(index) {
        // Override this test for determining which listElements are selected for
        return false
    }

    // Built-in model manipulation functions

    function append(message) {
        listElementTemplate.message = message
        model.append( listElementTemplate )
        return (listElementTemplate.id++)
    }

    function remove(id) {
        for (var i = 0; i<model.count; i++) {
            if (model.get(i).id === id) {
                model.remove(i)
                return true
            }
        }
        return false
    }

    function updateMessageAtID(message, id) {
        for (var i = 0; i<model.count; i++) {
            if (model.get(i).id === id) {
                model.get(i).message = message
                return true
            }
        }
        return false
    }

    function clear() {
        model.clear()
    }
}
