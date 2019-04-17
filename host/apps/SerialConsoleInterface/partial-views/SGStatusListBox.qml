import QtQuick 2.11
import QtQuick.Controls 2.2
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

import fonts 1.0

Rectangle {
    id: root
    color: statusBoxColor
    border {
        color: statusBoxBorderColor
        width: 1
    }

    property alias model: statusList.model
    property alias filterBoxValue: filterBox.value

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
                family: Fonts.inconsolata  // inconsolata is monospaced and has clear chars for O/0 etc
                pixelSize: (Qt.platform.os === "osx") ? 14 : 12;
            }
            selectByMouse: true
            readOnly: true
            wrapMode: Text.WrapAnywhere
            width: statusList.width
            textFormat: TextEdit.RichText
        }

        highlightFollowsCurrentItem: true
        onCountChanged: {
            if (running) { scroll() }
        }
    }

    // Make sure focus follows current transcript messages when window is full
    function scroll() {
        statusList.positionViewAtEnd()
    }

    Rectangle {
        id: filterContainer
        width: 200
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
            infoBoxWidth: 175
            anchors {
                left: filterContainer.left
                bottom: filterContainer.bottom
                leftMargin: 3
                bottomMargin: 3
            }
            infoBoxHeight: 24
            placeholderText: "Find..."
            leftJustify: true

            onValueChanged: {
                if (value.length > 0) {
                    logBox.model = tempList
                    CorePlatformInterface.colorizeStringInList(logBoxList, value, "cyan", tempList)
                } else {
                    logBox.model = logBoxList
                }
            }

            // This can be swapped in place of onValueChanged in case it sucks too much performance (ie, unlimited massive logboxlist)
//            onApplied: {
//                if (text.length > 0) {
//                    logBox.model = tempList
//                    CorePlatformInterface.colorizeStringInList(logBoxList, text,"cyan", tempList)
//                } else {
//                    logBox.model = logBoxList
//                }
//            }

            Text {
                id: textClear
                font {
                    family: Fonts.sgicons
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
                family: Fonts.sgicons
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

    function ctrlF (){
        if ( filterContainer.height === 0 ){
            openFilter.start()
        }
        filterBox.textInput.forceActiveFocus()
    }

    function cancel () {
        if ( filterContainer.height === 30 ){
            closeFilter.start()
        }
        filterBox.value = ""
        filterBox.applied ("")
    }
}
