import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import "PlatformSettings"

Rectangle {
    id: root
    color: "#ddd"
    anchors {
        fill: parent
    }

    property string firmwareVersion: "1.2.2"
    property string firmwareDate: "2019-11-04 17:16:48"
    property string viewVersion: "1.1.0"
    property string viewDate: "2019-11-04 17:16:48"
    property bool upToDate: false

    property alias reminderCheck: reminderCheck




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
            checked: window.remind
            onCheckedChanged: window.remind = checked
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
        x: (root.width - width)/2
        y: (root.height - height)/2
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
