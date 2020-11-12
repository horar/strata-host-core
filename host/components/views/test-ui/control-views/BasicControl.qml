import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09
import "qrc:/js/help_layout_manager.js" as Help

Item {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/900

    Rectangle {
        id: container
        width: parent.width/2
        height: parent.height/2
        anchors.centerIn: parent
        color: "dark gray"

        ColumnLayout{
            anchors.fill: parent
            Item {
                id: titleContainer
                Layout.fillHeight: true
                Layout.fillWidth: true

                SGText {
                    id: title
                    text: " Test Control View "
                    fontSizeMultiplier: ratioCalc * 2.5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        id: line1
                        height: 2
                        anchors.top:parent.bottom
                        width: titleContainer.width
                        border.color: "black"
                        radius: 1.5
                        anchors {
                            top: title.bottom
                            topMargin: 7
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                RowLayout {
                    SGIcon {
                        id: helpIcon1
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

                    }

                    SGText {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Class_ID Populated In Control.qml"
                    }
                }

            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                RowLayout {
                    SGIcon {
                        id: helpIcon2
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

                    }
                    SGText {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Setting SGUSerSetting"
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                RowLayout {
                    SGIcon {
                        id: helpIcon3
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/check-circle.svg"
                        iconColor: "green"

                    }
                    SGText {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check User_id"
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }

}
