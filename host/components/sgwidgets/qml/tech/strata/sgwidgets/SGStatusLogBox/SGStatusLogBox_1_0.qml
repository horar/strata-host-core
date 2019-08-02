import QtQuick 2.9
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.theme 1.0

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
    property color titleTextColor: "black"
    property color titleBoxColor: "#F2F2F2"
    property color titleBoxBorderColor: "#D9D9D9"
    property color statusTextColor: "black"
    property color statusBoxColor: "white"
    property color statusBoxBorderColor: "#D9D9D9"
    property bool showMessageIds: false
    property bool filterEnabled: true
    property variant model: listModel           // you may use your own model in advanced use cases, this can break the built-in model manipulation functions
    property string filterRole: "message"       // this role is what is cmd/ctrl-f filters on
    property string copyRole: ""
    property real fontSizeMultiplier: 1.0

    property alias listView: listView
    property alias listViewMouse: listViewMouse
    property alias delegate: listView.delegate

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
        height: visible ? title.contentHeight * 2 : 0
        color: root.titleBoxColor
        border {
            color: root.titleBoxBorderColor
            width: 1
        }
        visible: title.text !== ""

        SGText {
            id: title
            anchors {
                left: titleArea.left
                right: titleArea.right
                verticalCenter: titleArea.verticalCenter
                leftMargin: font.pixelSize/2
            }
            text: root.title
            color: root.titleTextColor
            fontSizeMultiplier: root.fontSizeMultiplier
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

            SGText {
                id: delegateText

                text: { return (
                            root.showMessageIds ?
                                model.id + ": " + model.message :
                                model.message
                            )}

                fontSizeMultiplier: root.fontSizeMultiplier
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
        width: filterBox.width + filterSearch.width + filterSearch.anchors.leftMargin * 3
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
            to: filterBox.height + filterBox.anchors.bottomMargin *2
            duration: 100
        }

        PropertyAnimation {
            id: closeFilter
            target: filterContainer
            property: "height"
            from: filterBox.height + filterBox.anchors.bottomMargin *2
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
            boxColor: "#fff"
            placeholderText: "Filter..."
            horizontalAlignment: Text.AlignLeft
            fontSizeMultiplier: root.fontSizeMultiplier

            ListModel {
                id: filterModel
            }

            onAccepted: {
                filterModel.clear()
                if (text.length >0) {
                    var caseInsensitiveFilter = new RegExp(text, 'i')
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
            id: textClear
            width: iconImage.width
            height: iconImage.height
            anchors {
                right: filterBox.right
                verticalCenter: filterBox.verticalCenter
                verticalCenterOffset: 1
                rightMargin: 3
            }
            visible: filterBox.text !== ""

            Image {
                id: iconImage
                visible: false
                fillMode: Image.PreserveAspectFit
                source: "icons/ban.svg"
                sourceSize.height: 13 * root.fontSizeMultiplier
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
                    filterBox.text = ""
                    filterBox.accepted("")
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
                sourceSize.height: 13 * root.fontSizeMultiplier
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
                    filterBox.accepted (filterBox.text)
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
            filterBox.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        enabled: filterEnabled
        onActivated: {
            if ( filterContainer.height === 30 ){
                closeFilter.start()
            }
            filterBox.text = ""
            filterBox.accepted ("")
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
