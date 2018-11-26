import QtQuick 2.9
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
    property alias filterBoxTextInput: filterBox.textInput
    property alias currentIndex: statusList.currentIndex
    property alias contentHeight: statusList.contentHeight

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
        currentIndex: -1
        verticalLayoutDirection: ListView.BottomToTop


        anchors {
            left: root.left
            right: root.right
            top: titleArea.bottom
            bottom: root.bottom
            margins: 10
        }

        delegate: TextEdit {
            id: textDelegate
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

            MouseArea {
                anchors {
                    fill: textDelegate
                }
                onClicked: {
                    statusList.currentIndex = index
                    cmdInput.text = CorePlatformInterface.cleanJSON(JSON.stringify(statusList.model.get(index).status))
                    cmdInput.forceActiveFocus()
                    root.visible = false
                }
            }



            Rectangle {
                id: highlight
                visible: statusList.currentIndex === index
                color: "lightyellow"
                anchors {
                    fill: textDelegate
                }
                z:-1
            }
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
        width: 200
        height: 30
        anchors {
            top: titleArea.bottom
            right: titleArea.right
        }
        color: "#eee"
        visible: true
        clip: true


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
            placeholderText: "Filter Commands..."
            leftJustify: true

            onValueChanged: {
                if (value.length > 0) {
                    CorePlatformInterface.applyFilter(cmdHistoryList,resultList,value)
                    statusList.model = resultList
                    statusList.currentIndex = 0
                    cmdInput.text = CorePlatformInterface.cleanJSON(JSON.stringify(historyBox.model.get(historyBox.currentIndex).status))
                } else {
                    statusList.model = cmdHistoryList
                    statusList.currentIndex = 0
                    cmdInput.text = CorePlatformInterface.cleanJSON(JSON.stringify(historyBox.model.get(historyBox.currentIndex).status))
                }
            }

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
        }
    }
}
