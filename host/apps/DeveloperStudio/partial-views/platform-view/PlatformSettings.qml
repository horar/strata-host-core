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
                                                                      "file": "201/fab/351bf129b05fb37797c8d8f0c1e16db5.bin", /// file from DP
                                                                      "md5": "351bf129b05fb37797c8d8f0c1e16db5",
                                                                      "name": "firmware",
                                                                      "timestamp": "2019-11-04 17:16:48",
                                                                      "version": "1.1.0"
                                                                  },
                                                                  {
                                                                      "file": "72ddcc10-2d18-4316-8170-5223162e54cf/logic-gates-release.bin", // file on local docker
                                                                      "md5": "78c8454d2056cdba226b31806bd275fa",
                                                                      "name": "firmware",
                                                                      "timestamp": "2019-11-04 17:16:48",
                                                                      "version": "1.1.1"
                                                                  },
                                                              ],
                                                              "device":{
                                                                  "version": "1.0.0",
                                                                  "timestamp": "20180401_131410"
                                                              },
                                                              "device_id": platformStack.device_id
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
