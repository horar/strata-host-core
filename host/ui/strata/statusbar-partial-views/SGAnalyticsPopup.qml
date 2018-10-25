import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Fonts 1.0
import QtGraphicalEffects 1.0

Popup {
    id: root
    width: container.width * 0.8
    height: container.parent.windowHeight * 0.8
    modal: true
    focus: true
    padding: 0
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    DropShadow {
        width: root.width
        height: root.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: 30
        color: "#cc000000"
        source: root.background
        z: -1
        cached: true
    }

    Item {
        id: popupContainer
        width: root.width
        height: root.height
        clip: true

        Image {
            id: background
            source: "qrc:/images/login-background.svg"
            height: 1080
            width: 1920
            x: (popupContainer.width - width)/2
            y: (popupContainer.height - height)/2
        }

        Rectangle {
            id: title
            height: 30
            width: popupContainer.width
            anchors {
                top: popupContainer.top
            }
            color: "lightgrey"

            Label {
                id: popupTitle
                anchors {
                    left: title.left
                    leftMargin: 10
                    verticalCenter: title.verticalCenter
                }
                text: "Analytics"
                font {
                    family: Fonts.franklinGothicBold
                }
                color: "black"
            }

            Text {
                id: closer
                text: "\ue805"
                color: closeHover.containsMouse ? "#eee" : "white"
                font {
                    family: Fonts.sgicons
                    pixelSize: 20
                }
                anchors {
                    right: title.right
                    verticalCenter: title.verticalCenter
                    rightMargin: 10
                }

                MouseArea {
                    id: closeHover
                    anchors {
                        fill: closer
                    }
                    onClicked: root.close()
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        ScrollView {
            id: scrollView
            anchors {
                top: title.bottom
                left: popupContainer.left
                right: popupContainer.right
                bottom: popupContainer.bottom
            }

            contentHeight: contentContainer.height
            contentWidth: contentContainer.width
            clip: true

            Item {
                id: contentContainer
                width: Math.max(popupContainer.width, 600)
                height: mainColumn.height + mainColumn.anchors.margins*2
                clip: true

                Column {
                    id: mainColumn
                    spacing: 30
                    anchors {
                        top: contentContainer.top
                        right: contentContainer.right
                        left: contentContainer.left
                        margins: 15
                    }

                    Rectangle {
                        id: analyticsTextContainer
                        color: "#efefef"
                        width: mainColumn.width
                        height: analyticsTextColumn.height + analyticsTextColumn.anchors.topMargin * 2
                        clip: true

                        Column {
                            id: analyticsTextColumn
                            spacing: 20
                            width: analyticsTextContainer.width
                            anchors {
                                top: analyticsTextContainer.top
                                topMargin: 15
                            }

                            Text {
                                id: analyticsText1
                                text: "ON Semiconductor’s Strata Developer Studio works to save evaluation and development time and costs through ease of use and relevant content delivery.  To facilitate continual improvements in services, product information relevance, and collateral value, Strata meters key usage variables related to Platform operation, Software control operation, collateral usage."
                                font {
                                    pixelSize: 15
                                    family: Fonts.franklinGothicBook
                                }
                                lineHeight: 1.5
                                width: analyticsTextContainer.width-30
                                anchors {
                                    horizontalCenter: analyticsTextColumn.horizontalCenter
                                }
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                                color: "black"
                            }

                            Text {
                                id: analyticsText2
                                text: "ON Semiconductor is committed to customer privacy and protection."
                                font {
                                    pixelSize: 15
                                    family: Fonts.franklinGothicBook
                                }
                                width: analyticsTextContainer.width-30
                                anchors {
                                    horizontalCenter: analyticsTextColumn.horizontalCenter
                                }
                                horizontalAlignment: Text.AlignHCenter
                                wrapMode: Text.Wrap
                                color: "black"
                            }

                            SGSwitch {
                                id: analyticsSwitch
                                anchors {
                                    horizontalCenter: analyticsTextColumn.horizontalCenter
                                }
                                checked: true
                                checkedLabel: "ON"
                                uncheckedLabel: "OFF"
                                labelsInside: false
                                label: "Analytics Collection:"
                            }

                        }
                    }

                    Item {
                        id: analyticsLogContainer
                        width: mainColumn.width
                        height: analyticsLogTitle.height + analyticsLog.height

                        Rectangle {
                            id: analyticsLogTitle
                            color: "#ddd"
                            width: analyticsLogContainer.width
                            height: 35

                            Text {
                                id: analyticsLogTitleText
                                text: "Strata Analytics Log"
                                font {
                                    pixelSize: 15
                                    family: Fonts.franklinGothicBook
                                }
                                anchors {
                                    verticalCenter: analyticsLogTitle.verticalCenter
                                    verticalCenterOffset: 2
                                    left: analyticsLogTitle.left
                                    leftMargin: 15
                                }
                            }
                        }

                        SGStatusListBox {
                            id: analyticsLog
                            width: analyticsLogContainer.width
                            anchors {
                                top: analyticsLogTitle.bottom
                            }
                            height: Math.max(popupContainer.height - title.height - analyticsTextContainer.height - analyticsLogTitle.height - 60, 200)

                            model: ListModel{
                                id: fakeTempModel

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID connection"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID system update"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID Controls-Basic operation start"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID Controls-Advanced operation start"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID Block Diagram view"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID Block Diagram – NCV81599 select"
                                }

                                ListElement {
                                    status: "10/1/2018 – USB-PD 2 Port UUID Block Diagram – NCP163 select"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
