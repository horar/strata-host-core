import QtQuick 2.9
import QtQuick.Controls 2.3
import "content-views"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 0.9

Rectangle {
    id: view
    anchors {
        fill: parent
    }

    property int totalDocuments: sdsModel.documentManager.pdfListModel.count + sdsModel.documentManager.datasheetListModel.count + sdsModel.documentManager.downloadDocumentListModel.count
    onTotalDocumentsChanged: {
        if (sdsModel.documentManager.pdfListModel.count > 0) {
             pdfViewer.url = "file://localhost/" + sdsModel.documentManager.pdfListModel.getFirstUri();
        } else if (sdsModel.documentManager.datasheetListModel.count > 0) {
            pdfViewer.url = sdsModel.documentManager.datasheetListModel.getFirstUri();
        } else {
            pdfViewer.url = ""
        }
    }

    Connections {
        target: sdsModel.documentManager

        onErrorStringChanged: {
            if (sdsModel.documentManager.errorString.length > 0) {
                pdfViewer.url = ""
                loadingImage.currentFrame = 0
            }
        }
    }

    Rectangle {
        id: divider
        height: 1
        anchors {
            bottom: contentContainer.top
            left: contentContainer.left
            right: contentContainer.right
        }

        color: "#888"
    }

    Item {
        id: contentContainer
        anchors {
            top: divider.bottom
            right: view.right
            left: view.left
            bottom: view.bottom
        }

        Rectangle {
            id: navigationSidebar
            color: Qt.darker("#666")
            anchors {
                left: contentContainer.left
                top: contentContainer.top
                bottom: contentContainer.bottom
            }
            width: 0
            visible: false

            states: [
                // default state is "", width:0, visible:false
                State {
                    name: "open"
                    PropertyChanges {
                        target: navigationSidebar
                        visible: true
                        width: 300
                    }
                }
            ]

            SGAccordion {
                id: accordion
                anchors {
                    fill: parent
                }

                // Optional Configuration:
                openCloseTime: 80           // Default: 80 (how fast the sliders pop open)
                statusIcon: "\u25B2"        // Default: "\u25B2" (triangle char)
                contentsColor: Qt.darker("#555")
                textOpenColor: "#fff"
                textClosedColor: "#ccc"
                headerOpenColor: "#666"
                headerClosedColor: "#484848"
                dividerColor: "grey"
                exclusive: false

                accordionItems: Column {

                    SGAccordionItem {
                        id: pdfAccordion
                        title: "Platform Documents"
                        contents: Documents {
                            model: sdsModel.documentManager.pdfListModel
                        }
                        open: true
                        visible: sdsModel.documentManager.pdfListModel.count > 0
                    }

                    SGAccordionItem {
                        id: datasheetAccordion
                        title: "Part Datasheets"
                        contents: Datasheets {
                            model: sdsModel.documentManager.datasheetListModel
                        }
                        visible: sdsModel.documentManager.datasheetListModel.count > 0
                    }

                    SGAccordionItem {
                        id: downloadAccordion
                        title: "Downloads"
                        contents: Downloads {
                            model: sdsModel.documentManager.downloadDocumentListModel

                        }
                        visible: sdsModel.documentManager.downloadDocumentListModel.count > 0
                    }
                }
            }
        }

        Rectangle {
            id: sidebarControl
            width: 20 + rightDivider.width
            anchors {
                left: navigationSidebar.right
                top: contentContainer.top
                bottom: contentContainer.bottom
            }
            color: controlMouse.containsMouse ? "#444" : "#333"

            Rectangle {
                id: rightDivider
                width: 1
                anchors {
                    top: sidebarControl.top
                    bottom: sidebarControl.bottom
                    right: sidebarControl.right
                }
                color: "#33b13b"
            }

            SGIcon {
                id: control
                anchors {
                    centerIn: sidebarControl
                }
                iconColor: "white"
                source: "images/angle-right-solid.svg"
                height: 30
                width: 30
                rotation: navigationSidebar.visible ? 180 : 0
            }

            MouseArea {
                id: controlMouse
                anchors {
                    fill: sidebarControl
                }
                onClicked: {
                    if (navigationSidebar.state === "open") {
                        navigationSidebar.state = "" // "" is default closed state
                    } else {
                        navigationSidebar.state = "open"
                    }
                }

                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }

        SGPdfViewer {
            id: pdfViewer
            anchors {
                left: sidebarControl.right
                right: contentContainer.right
                top: contentContainer.top
                bottom: contentContainer.bottom
            }

            url: ""
        }
    }

    Item {
        id: loading
        anchors {
            fill: view
        }

        visible: loadingText.text.length

        onVisibleChanged: {
            if (!visible) {
                navigationSidebar.state = "open"
            } else {
                navigationSidebar.state = "" // "" is default closed state
            }
        }

        Rectangle {
            color: "#222"
            opacity: .5
            anchors {
                fill: parent
            }
        }

        AnimatedImage {
            id: loadingImage
            source: "images/docLoading.gif"
            anchors {
                centerIn: loading
                verticalCenterOffset: -height/4
            }
            playing: sdsModel.documentManager.loading
            height: 200
            width: 200
        }

        Text {
            id: loadingText
            color: "#fff"
            anchors {
                top: loadingImage.bottom
                horizontalCenter: loading.horizontalCenter
            }
            font {
                pixelSize: 30
                family:  Fonts.franklinGothicBold
            }
            text: {
                if (sdsModel.documentManager.errorString.length > 0) {
                    return "Error: " + sdsModel.documentManager.errorString
                }

                if (sdsModel.documentManager.loading) {
                    return "Downloading\n" + sdsModel.documentManager.loadingProgressPercentage + "% completed"
                }

                return ""
            }

            width: 500
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea {
            anchors { fill: loading }
            hoverEnabled: true
            preventStealing: true
            propagateComposedEvents: false
        }
    }
}
