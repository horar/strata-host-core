import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Fonts 1.0
import QtGraphicalEffects 1.0

Item {
    id: root
    anchors {
        fill: profileStack
    }
    clip: true

    Item {
        id: popupContainer
        width: root.width
        height: root.height
        clip: true

        ScrollView {
            id: scrollView
            anchors {
                fill: popupContainer
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
                                onCheckedChanged: {
                                    if (!checked && analyticsLog) {
                                        analyticsModel.clear()
                                        analyticsLog.enabled = false
                                    } else if (analyticsLog) {
                                        analyticsLog.enabled = true
                                    }
                                }
                            }

                        }
                    }

                    Item {
                        id: analyticsLogContainer
                        width: mainColumn.width
                        height: analyticsLogTitle.height + analyticsLog.height


                        Rectangle {
                            id: disabled
                            color: "lightgrey"
                            opacity: 0.5
                            anchors {
                                fill: analyticsLogContainer
                            }
                            z:20
                            visible: !analyticsLog.enabled
                        }

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
                            height: Math.max(popupContainer.height - analyticsTextContainer.height - analyticsLogTitle.height - 90 - backButton.height, 200)

                            model: analyticsModel
                        }

                        // Listeners to populate analytics log with demo data since metrics isn't fully functional
                        // TODO: remove this in place of metrics.js data
                        Connections {
                            target: coreInterface

                            onPretendMetrics: {
                                var d = new Date();
                                if (analyticsSwitch.checked) {
                                    analyticsModel.append({"status": "[" +d + "] " + message.substring(0, 40)})
                                }
                            }
                        }

                        ListModel{
                            id: analyticsModel
//                            ListElement {
//                                status: "10/1/2018 – USB-PD 2 Port UUID connection"
//                            }
                        }
                    }

                    Button {
                        id: backButton
                        text: "Return to Profile"
                        width: 200
                        onClicked: profileStack.currentIndex = 0
                        anchors {
                            horizontalCenter: mainColumn.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
