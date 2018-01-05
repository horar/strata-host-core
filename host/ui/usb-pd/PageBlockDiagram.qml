import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtWebView 1.1
//Item {
//    id: block_diagram


    Rectangle {
        id : container

        property var currentURL: "http:www.onsemi.com"

        Rectangle {
            id: headerLogo
            anchors { top: parent.top }
            width: parent.width; height: 40
            color: "#235A92"

            // PROOF OF CONCEPT BANNER
            //        Rectangle {
            //            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            //            width: parent.width * 0.70; height: 30;
            //            color: "red"
            //            radius: 4
            //            Label {
            //                anchors { centerIn: parent }
            //                text: "SPYGLASS PROOF OF CONCEPT WITH LAB CLOUD"
            //                color: "white"
            //                font.bold: true
            //            }
            //        }
        }
        Image {
            anchors { top: parent.top; right: parent.right }
            height: 40
            fillMode: Image.PreserveAspectFit
            source: "./images/icons/onLogoGreenWithText.png"
        }
        Text {
            text: "USB-PD Dual 100W "
            horizontalAlignment: Text.AlignHCenter
            font.family: "Helvetica"
            font.pointSize: 36
            color: "grey"
            anchors{ left: parent.left;
                right: parent.right;
                top: parent.top;
                topMargin: parent.height/10
            }

        }


        Image{
            id:blockDiagram
            //source:"./images/USB-PD_blockDiagram.png"
            source: "./images/Beta_Block Diagram.png"
            anchors{left:parent.left
                bottom: parent.bottom
                bottomMargin: 50}

            MouseArea {
                id: batteryProtectionmMouseArea
                x: 205
                y: 39
                width: 100
                height: 79
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVMFS5A140PLZ"
                    detailView.open()

                }
            }

            MouseArea {
                id: nvt211TempSensorMouseArea
                x: 381
                y: 193
                width: 100
                height: 51
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    currentURL = "https://www.onsemi.com/PowerSolutions/product.do?id=NVT211"
                    detailView.open()
                }
            }

            MouseArea {
                id: remoteTempSensorMouseArea
                x: 386
                y: 328
                width: 82
                height: 37
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=MMBT3906W"
                    detailView.open()
                }
            }

            MouseArea {
                id: ncv81599BuckBoostMouseArea1
                x: 539
                y: 59
                width: 100
                height: 80
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NCP81239"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea1
                x: 483
                y: 59
                width: 39
                height: 28
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea2
                x: 484
                y: 108
                width: 38
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea3
                x: 658
                y: 59
                width: 37
                height: 28
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea4
                x: 658
                y: 108
                width: 37
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea5
                x: 485
                y: 399
                width: 37
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea6
                x: 483
                y: 450
                width: 37
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea7
                x: 658
                y: 399
                width: 37
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fetMouseArea8
                x: 658
                y: 450
                width: 37
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: ncv81599BuckBoostMouseArea2
                x: 539
                y: 399
                width: 100
                height: 81
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NCP81239"
                    detailView.open()
                }
            }

            MouseArea {
                id: ncv890100BuckRegulatorMouseArea
                x: 438
                y: 552
                width: 127
                height: 84
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "https://www.onsemi.com/PowerSolutions/product.do?id=NCV890100 "
                    detailView.open()
                }
            }

            MouseArea {
                id: vbusDisconnectMouseArea1
                x: 872
                y: 106
                width: 97
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NCP392B"
                    detailView.open()
                }
            }

            MouseArea {
                id: vbusDisconnectMouseArea2
                x: 872
                y: 443
                width: 97
                height: 30
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=NVTFS5C453NL"
                    detailView.open()
                }
            }

            MouseArea {
                id: fusb302tMouseArea1
                x: 785
                y: 169
                width: 100
                height: 63
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "https://www.onsemi.com/PowerSolutions/product.do?id=FUSB302T"
                    detailView.open()
                }
            }

            MouseArea {
                id: esdProtectionMouseArea1
                x: 928
                y: 175
                width: 100
                height: 55
                cursorShape: Qt.PointingHandCursor
                opacity: 0
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=FUSB252"
                    detailView.open()
                }
            }

            MouseArea {
                id: esdProtectionMouseArea2
                x: 928
                y: 504
                width: 100
                height: 55
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=FUSB252"
                    detailView.open()
                }
            }

            MouseArea {
                id: fusb302tMouseArea2
                x: 785
                y: 497
                width: 100
                height: 63
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    currentURL = "http://www.onsemi.com/PowerSolutions/product.do?id=FUSB302T"
                    detailView.open()
                }
            }

        }

        Drawer{
            id: detailView
            x: parent.width
            y: 0
            height: parent.height - tabBar.height
            width: parent.width/2
            edge: Qt.RightEdge
            dragMargin: Qt.styleHints.startDragDistance

            ColumnLayout{

                WebView {
                    id: detailWebView
                    Layout.preferredWidth: container.width/2
                    Layout.preferredHeight: container.height - tabBar.height*2
                    url: currentURL
                    onLoadingChanged: {
                        //console.log("loaded webview with ", currentURL);
                        if (loadRequest.errorString)
                            console.error(loadRequest.errorString);
                    }
                } //web view

                Button {
                    id: closeButton
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 184
                    Layout.preferredHeight: 28
                    text:"close"
                    font{ pointSize: 13; bold: true }
                    opacity: 1


                    contentItem: Text {
                        text: closeButton.text
                        font: closeButton.font
                        opacity: enabled ? 1.0 : 0.3
                        color: closeButton.down ? "white" : "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        color: closeButton.down ? Qt.darker("#2eb457") : "#2eb457"
                        radius: 10
                    }

                    onClicked: {
                        detailView.close()
                    }
                }
            } //ColumnLayout

        }   //drawer

    }


//}










