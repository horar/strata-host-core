import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12 // todo remove

import tech.strata.sgwidgets 1.0
import "PlatformSettings"

Rectangle {
    id: platformSettings
    color: "#ddd"
    anchors {
        fill: parent
    }

    property string viewVersion: "1.1.0"
    property string viewDate: "2019-11-04 17:16:48"
    property bool upToDate: false

    property alias reminderCheck: reminderCheck

    Window { // todo remove debug controls
        height: 400
        width: 400
        visible: true

        Column {

            Button {
                text: "set connected"
                onClicked: {
                    platformStack.setConnected()
                }
            }

            Button {
                text: "get firmware info"
                onClicked: {
                    let notification = JSON.stringify({
                                                          "hcs::notification":{
                                                              "type":"firmware_info",
                                                              "list":[
                                                                  {
                                                                      "file": "<PATH to firmware>/250mA_LDO.bin",
                                                                      "md5": "b2d69a4c8a224afa77319cd3d833b292",
                                                                      "name": "firmware",
                                                                      "timestamp": "2019-11-02 17:16:48",
                                                                      "version": "1.0.0"
                                                                  },
                                                                  {
                                                                      "file": "<PATH to firmware>/250mA_LDO.bin",
                                                                      "md5": "asdfasdfasdfasdfas",
                                                                      "name": "firmware",
                                                                      "timestamp": "2019-11-04 17:16:48",
                                                                      "version": "1.1.0"
                                                                  },
                                                              ],
                                                              "device":{
                                                                  "version": "1.0.0",
                                                                  "timestamp": "20180401_131410"
                                                              },
                                                              "device_id": -3452345234
                                                          }
                                                      })
                    coreInterface.spoofCommand(notification)
                }
            }

            Button {
                text: "firmware progress update"
                property int i:0

                onClicked: {
                    switch (i) {
                    case 0:
                        spoofProgress("download", "running", 10, 100)
                        break;
                    case 1:
                        spoofProgress("download", "running", 33, 100)
                        break;
                    case 2:
                        spoofProgress("download", "running", 66, 100)
                        break;
                    case 3:
                        spoofProgress("download", "running", 90, 100)
                        break;
                    case 4:
                        spoofProgress("prepare", "running", -1, -1)
                        break;
                    case 5:
                        spoofProgress("backup", "running", -1, -1)
                        break;
                    case 6:
                        spoofProgress("flash", "running", -1, -1)
                        break;
                    case 7:
                        spoofProgress("finished", "running", -1, -1)
                        break;
                    }
                    i++
                }

                function spoofProgress(operation, status, complete, total) {
                    let notification = JSON.stringify({
                                                          "hcs::notification":{
                                                              "type": "firmware_progress",
                                                              "operation": operation,
                                                              "status": status,
                                                              "complete": complete,
                                                              "total": total,
                                                              "device_id": -3452345234
                                                          }
                                                      })
                    coreInterface.spoofCommand(notification)
                }
            }
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 30

//        SoftwareManagement { }

        FirmwareManagement { }

        CheckBox {
            id: reminderCheck
            text: "Notify me when new versions of firmware or controls are available"
        }

        Item {
            // fills extra space
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    Popup {
        id: warningPop
        height: 150
        width: 430
        x: (platformSettings.width - width)/2
        y: (platformSettings.height - height)/2
        padding: 0
        modal: true
        background: Rectangle {
            color: "white"
        }

        property Item delegateDownload: null

        Rectangle {
            color: "#e67a70"
            width: parent.width
            height: 20

            SGIcon {
                source: "qrc:/sgimages/times.svg"
                iconColor: "white"
                height: 15
                width: 15
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: parent.right
                    rightMargin: 2.5
                }

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: warningPop.close()
                }
            }
        }

        ColumnLayout {
            anchors {
                centerIn: parent
                verticalCenterOffset: 10
            }
            spacing: 10

            Text {
                text: "Warning: Older firmware versions may be incompatible with the <br>installed software version. Are you sure you want to continue?"
            }

            RowLayout {
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                Button {
                    text: "Yes"
                    onClicked: {
                        warningPop.delegateDownload.visible = true
                        warningPop.close()
                    }
                }

                Button {
                    text: "No"
                    onClicked: warningPop.close()
                }
            }
        }
    }
}
