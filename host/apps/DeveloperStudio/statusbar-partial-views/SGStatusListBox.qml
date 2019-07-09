import QtQuick 2.9
import QtQuick.Controls 2.2

import tech.strata.fonts 1.0
import tech.strata.theme 1.0

Rectangle {
    id: root
    color: statusBoxColor
    border {
        color: statusBoxBorderColor
        width: 1
    }

    property alias model: statusList.model

    property string input: ""
    property color statusTextColor: "#000000"
    property color statusBoxColor: "#ffffff"
    property color statusBoxBorderColor: "#dddddd"

    property bool running: true

    implicitHeight: 200
    implicitWidth: 300

    ListView {
        id: statusList
        implicitWidth: contentItem.childrenRect.width
        implicitHeight: contentItem.childrenRect.height
        //interactive: false
        clip: true

        anchors {
            left: root.left
            right: root.right
            top: root.top
            bottom: root.bottom
            margins: 10
        }

        delegate: TextEdit {
            text: model.status // modelData
            color: root.statusTextColor
            font {
                family: Fonts.inconsolata  // inconsolata is monospaced and has clear chars for O/0 etc
                pixelSize: Theme.basePixelSize
            }
            selectByMouse: true
            readOnly: true
            wrapMode: Text.WrapAnywhere
            width: statusList.width
        }

        highlightFollowsCurrentItem: true
        onCountChanged: {
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
            top: root.top
            right: root.right
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

            SGIcon {
                id: textClear
                sourceSize.height: 12
                iconColor: "grey"
                source: "qrc:/images/icons/ban.svg"
                anchors {
                    right: filterBox.right
                    verticalCenter: filterBox.verticalCenter
                    rightMargin: 4
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

        SGIcon {
            id: filterSearch
            sourceSize.height: 12
            iconColor: "grey"
            source: "qrc:/images/icons/search.svg"
            anchors {
                left: filterBox.right
                verticalCenter: filterBox.verticalCenter
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
        enabled: root.visible
    }

    Shortcut {
        enabled: root.visible
        sequence: StandardKey.Cancel
        onActivated: {
            if ( filterContainer.height === 30 ){
                closeFilter.start()
            }
            filterBox.value = ""
            filterBox.applied ("")
        }
    }
}
