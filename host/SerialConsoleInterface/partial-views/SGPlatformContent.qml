import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.11
import "qrc:/partial-views/"
import "qrc:/js/core_platform_interface.js" as CorePlatformInterface

import tech.spyglass.sci 1.0
import fonts 1.0

Item {
    id: root
    Layout.fillWidth: true
    Layout.fillHeight: true

    enabled: platformInterface.platformList[boardId].connected
    property string boardId: "default"
    property alias logBoxList: logBoxList
    property alias tempList: tempList
    property alias logBox: logBox
    property int tabNumber

    SGSideDrawer {
        id: sidebar
        anchors {
            right: root.right
        }
        height: root.height

        drawerMenuItems : Column {
            id: drawerColumn

            Item {
                id: margin
                width: drawerColumn.width
                height: 100
            }

            Button {
                text: "Run Test Commands"
                anchors {
                    horizontalCenter: drawerColumn.horizontalCenter
                }
                onClicked: {
                    testCommandTimer.counter = 0
                    testCommandTimer.running = true
                }

                Timer {
                    id: testCommandTimer
                    interval: 100
                    running: false
                    repeat: true

                    property int counter

                    onTriggered: {
                        if (counter < platformInterface.tests[1].length) {
                            CorePlatformInterface.saveAndSendCommand(platformInterface.tests[1][counter])
                            counter++
                        } else {
                            testCommandTimer.running = false
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        id: mainLayout
        spacing: 0
        anchors {
            top: root.top
            left: root.left
            right: sidebar.left
            bottom: root.bottom
        }

        SGStatusListBox {
            id: logBox
            input: ""
            model:logBoxList
            Layout.fillWidth: true
            Layout.fillHeight: true
            statusTextColor:"gray"
            statusBoxBorderColor: "white"

            ListModel {
                id: logBoxList

                onCountChanged: {
                    if (logBox.filterBoxValue !== ""){
                        CorePlatformInterface.colorizeStringInList(logBoxList, logBox.filterBoxValue, "cyan", tempList)
                    }

                    if (logBoxList.count >1000 ) {
                        logBoxList.remove(0)
                    }
                }
            }

            ListModel {
                id:tempList
            }

            Shortcut {
                enabled: root.visible
                sequence: StandardKey.Find
                onActivated: {
                    logBox.ctrlF()
                }
            }

            Shortcut {
                enabled: root.visible
                sequence: StandardKey.Cancel
                onActivated: {
                    logBox.cancel()
                    historyBox.visible = false
                }
            }
        }

        RowLayout {
            id: inputRowLayout
            spacing: 0

            TextField {
                id: cmdInput
                text: ""
                placeholderText: qsTr("Enter JSON command...")
                Layout.fillWidth: true
                focus: true

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 40
                    color: cmdInput.enabled ? "white" : "lightgrey"
                    border.color: cmdInput.enabled && cmdInput.focus ? "lightskyblue" : "#bbb"
                }

                Component.onCompleted: {
                    inputBtn.clicked.connect(accepted)
                }

                onAccepted: {
                    if (text.length !== 0) {
                        CorePlatformInterface.saveAndSendCommand(text)
                        cmdInput.text = ""
                        historyBox.filterBoxValue = ""
                        historyBox.currentIndex = -1
                        historyBox.visible = false
                    }
                }

                Keys.onUpPressed: {
                    if (!historyBox.visible && historyBox.model.count > 0) {
                        historyBox.visible = true
                    }

                    if (historyBox.currentIndex < historyBox.model.count - 1) {
                        historyBox.currentIndex++;
//                        console.log("total commands: "+historyBox.model.count+"    selected index: "+historyBox.currentIndex)
                        text = CorePlatformInterface.cleanJSON(JSON.stringify(historyBox.model.get(historyBox.currentIndex).status))
                    }

                    if (!cmdInput.focus) {
                        cmdInput.forceActiveFocus()
                    }
                }

                Keys.onDownPressed: {
                    if (historyBox.currentIndex > 0) {
                        historyBox.currentIndex--;
//                        console.log("total commands: "+historyBox.model.count+"    selected index: "+historyBox.currentIndex)
                        text = CorePlatformInterface.cleanJSON(JSON.stringify(historyBox.model.get(historyBox.currentIndex).status))
                    } else if (historyBox.currentIndex === 0) {
                        historyBox.currentIndex--;
                        text = ""
                        historyBox.visible = false
                    }

                    if (!cmdInput.focus) {
                        cmdInput.forceActiveFocus()
                    }
                }

                SGCommandHistory {
                    id: historyBox
                    visible: false
                    model: cmdHistoryList
                    anchors {
                        bottom: cmdInput.top
                        left: cmdInput.left
                        right: cmdInput.right
                    }
                    height: Math.min(150, historyBox.contentHeight + 20)

                    ListModel {
                        id: cmdHistoryList

                        onCountChanged: {
                            if (cmdHistoryList.count > 50 ) {
                                cmdHistoryList.remove(0)
                            }
                        }
                    }

                    ListModel {
                        id: resultList
                    }
                }

                Item {
                    id: openHistory
                    anchors {
                        right: cmdInput.right
                    }
                    height: cmdInput.height
                    width: height
                    enabled: historyBox.model.count > 0

                    Text {
                        id: openHistoryIcon
                        text: "\ue813"
                        font {
                            family: Fonts.sgicons
                            pixelSize: 20
                        }
                        color: "lightgrey"
                        anchors {
                            centerIn: openHistory
                        }
                        visible: enabled && !historyBox.visible
                    }

                    MouseArea {
                        anchors {
                            fill: openHistory
                        }
                        onClicked: {
                            if (!historyBox.visible && historyBox.model.count > 0) {
                                historyBox.visible = true
                                cmdInput.forceActiveFocus()
                            }
                        }
                        hoverEnabled: true
                        onEntered: openHistoryIcon.color = "grey"
                        onExited: openHistoryIcon.color = "lightgrey"
                    }
                }
            }

            Button {
                id: inputBtn
                text: qsTr("Send")
                enabled: cmdInput.text.length !== 0
                onClicked: {
                    cmdInput.forceActiveFocus()
                }
            }
        }
    }
}
