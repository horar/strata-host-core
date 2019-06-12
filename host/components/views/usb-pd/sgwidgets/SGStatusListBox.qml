import QtQuick 2.9
import QtQuick.Controls 2.2

Rectangle {
    id: root
    color: statusBoxColor
    border {
        color: statusBoxBorderColor
        width: 1
    }

    property alias model: statusList.model

    property string input: ""
    property string title: qsTr("")
    property color titleTextColor: "#000000"
    property color titleBoxColor: "#eeeeee"
    property color titleBoxBorderColor: "#dddddd"
    property color statusTextColor: "#000000"
    property color statusBoxColor: "#ffffff"
    property color statusBoxBorderColor: "#dddddd"

    property bool running: true

    implicitHeight: 200
    implicitWidth: 300

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
            text: root.title
            color: root.titleTextColor
            anchors {
                fill: titleArea
            }
            padding: 10
        }
    }

    ListView {
        id: statusList
        implicitWidth: contentItem.childrenRect.width
        implicitHeight: contentItem.childrenRect.height
        //interactive: false
        clip: true

        anchors {
            left: root.left
            right: root.right
            top: titleArea.bottom
            bottom: root.bottom
            margins: 10
        }

        delegate: TextEdit {
            text: model.status // modelData
            color: root.statusTextColor
            font {
                family: inconsolata.name  // inconsolata is monospaced and has clear chars for O/0 etc
                pixelSize: (Qt.platform.os === "osx") ? 12 : 10
            }
            selectByMouse: true
            readOnly: true
        }

        highlightFollowsCurrentItem: true
        onContentHeightChanged: {
            if (running) { scroll() }
        }
    }

    // Make sure focus follows current transcript messages when window is full
    function scroll() {
        if (statusList.contentHeight > statusList.height && statusList.contentY > (statusList.contentHeight - statusList.height - 50))
        {
            statusList.contentY = statusList.contentHeight - statusList.height;
        }
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
            infoBoxColor: "#fff"
            infoBoxWidth: 80
            anchors {
                left: filterContainer.left
                bottom: filterContainer.bottom
                leftMargin: 3
                bottomMargin: 3
            }
            infoBoxHeight: 24
            placeholderText: "Filter..."
            leftJustify: true

            onApplied: {
                var caseInsensitiveFilter = new RegExp(value, 'i')
                for (var i = 0; i< statusList.children[0].children.length; i++) {
                    statusList.children[0].children[i].visible = true
                    statusList.children[0].children[i].height = 14
                    if (statusList.children[0].children[i].text) {
                        if ( !caseInsensitiveFilter.test (statusList.children[0].children[i].text)) {
                            statusList.children[0].children[i].visible = false
                            statusList.children[0].children[i].height = 0
                        }
                    }
                }
            }

            Text {
                id: textClear
                font {
                    family: sgicons.name
                }
                color: "grey"
                text: "\ue824"
                anchors {
                    right: filterBox.right
                    verticalCenter: filterBox.verticalCenter
                    verticalCenterOffset: 1
                    rightMargin: 3
                }
                visible: filterBox.value !== ""

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
        }

        Text {
            id: filterSearch
            font {
                family: sgicons.name
            }
            color: "grey"
            text: "\ue801"
            anchors {
                left: filterBox.right
                verticalCenter: filterBox.verticalCenter
                verticalCenterOffset: 1
                leftMargin: 5
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
        onActivated: {
            if ( filterContainer.height === 0 ){
                openFilter.start()
            }
            filterBox.textInput.forceActiveFocus()
        }
    }

    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: {
            if ( filterContainer.height === 30 ){
                closeFilter.start()
            }
            filterBox.value = ""
            filterBox.applied ("")
        }
    }

    FontLoader {
        id: sgicons
        source: "fonts/sgicons.ttf"
    }

    FontLoader {
        id: inconsolata
        source: "fonts/Inconsolata.otf"
    }
}
