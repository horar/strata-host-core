import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

ColumnLayout {
    id: software

    // Todo: to be implemented in CS-831, CS-832

    property bool upToDate

    Text {
        text: "Software Settings:"
        font.bold: true
        font.pixelSize: 18
    }

    Rectangle {
        color: "#aaa"
        Layout.fillWidth: true
        Layout.preferredHeight: 1
    }

    Text {
        Layout.topMargin: 10
        text: "Current software version:"
        font.bold: false
        font.pixelSize: 18
        color: "#666"
    }

    Text {
        text: "Logic Gates v1.10, released 6/7/2020"
        font.bold: true
        font.pixelSize: 18
    }

    Rectangle {
        id: viewUpToDate
        Layout.preferredHeight: 50
        Layout.fillWidth: true
        Layout.topMargin: 15
        color: "#eee"
        visible: software.upToDate

        RowLayout {
            anchors {
                verticalCenter: viewUpToDate.verticalCenter
            }
            spacing: 15

            SGIcon {
                iconColor: "#999"
                source: "qrc:/sgimages/check-circle-solid.svg"
                Layout.preferredHeight: 30
                Layout.preferredWidth: 30
                Layout.leftMargin: 10
            }

            Text {
                text: "Up to date! No newer version available"
            }
        }

        MouseArea {
            anchors {
                fill: viewUpToDate
            }
            onClicked: {
                software.upToDate = false
            }
        }
    }

    Rectangle {
        id: viewNotUpToDate
        Layout.preferredHeight: notUpToDateColumn.height
        Layout.fillWidth: true
        Layout.topMargin: 15
        color: "#eee"
        visible: !software.upToDate

        ColumnLayout {
            id: notUpToDateColumn
            spacing: 10

            RowLayout {
                Layout.topMargin: 10
                spacing: 15
                Layout.leftMargin: 10

                SGIcon {
                    iconColor: "lime"
                    source: "qrc:/sgimages/exclamation-circle-solid.svg"
                    Layout.preferredHeight: 30
                    Layout.preferredWidth: 30

                    Rectangle {
                        color: "white"
                        width: 20
                        height: 20
                        radius: 10
                        anchors {
                            centerIn: parent
                        }
                        z:-1
                    }
                }

                Text {
                    text: "Newer software version available!"
                }
            }

            Rectangle {
                color: "#fff"
                Layout.preferredWidth: updatebuttonColumn.width
                Layout.preferredHeight: updatebuttonColumn.height
                Layout.leftMargin: 10
                Layout.bottomMargin: 10

                ColumnLayout {
                    id: updatebuttonColumn
                    spacing: 10

                    RowLayout {
                        id: updatebutton
                        spacing: 15
                        Layout.margins: 10

                        Text {
                            text: "Update to Logic Gates v1.2.1, released 6/7/2020/"
                            font.bold: true
                            font.pixelSize: 18
                            color: "#666"
                        }

                        SGIcon {
                            iconColor: "#666"
                            source: "qrc:/sgimages/download-solid.svg"
                            Layout.preferredHeight: 30
                            Layout.preferredWidth: 30
                        }
                    }

                    ColumnLayout {
                        id: downloadColumn1
                        width: parent.width
                        visible: false

                        Text {
                            Layout.leftMargin: 10
                            property real percent: fillBar1.width/barBackground1.width
                            text: {
                                if (percent < .6) {
                                    return "Downloading: " + (percent * 166.66).toFixed(0) + "%"
                                } else if (percent < .8) {
                                    return "Installing: " + ((percent-.6) * 500).toFixed(0) + "%"
                                } else if (percent < 1) {
                                    return "Loading: " + ((percent-.8) * 500).toFixed(0) + "%"
                                } else if (percent >= 1){
                                    //root.viewVersion = "1.2.1"
                                    software.upToDate = true
                                    return "Complete"
                                }
                            }
                        }

                        Rectangle {
                            id: barBackground1
                            color: "grey"
                            Layout.preferredHeight: 8
                            Layout.fillWidth: true
                            clip: true

                            Rectangle {
                                id: fillBar1
                                color: "lime"
                                height: barBackground1.height
                                width: 0
                                onVisibleChanged: {
                                    if (visible)
                                        timer1.start()
                                }

                                Timer {
                                    id: timer1
                                    interval: 16
                                    running: false
                                    repeat: true
                                    onTriggered: {
                                        if (fillBar1.width < barBackground1.width) {
                                            fillBar1.width +=3
                                        } else {
                                            repeat = false
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        downloadColumn1.visible = true
                    }
                }
            }
        }
    }

    ListModel {
        id: viewVersions

        ListElement {
            file: "<PATH to control view>/250mA_LDO.rcc"
            md5: "a2d69a4c8a224afa77319cd3d833b292"
            name: "control view"
            timestamp: "2019-11-04 17:16:48"
            version: "1.1.0"
            installed: true
        }

        ListElement {
            file: "<PATH to control view>/250mA_LDO.rcc"
            md5: "a2d69a4c8a224afa77319cd3d833b292"
            name: "control view"
            timestamp: "2019-11-04 17:16:48"
            version: "1.2.0"
            installed: false
        }
    }
}
