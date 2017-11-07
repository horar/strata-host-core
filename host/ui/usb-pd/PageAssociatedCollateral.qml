import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import QtWebView 1.1

Item {
    id: relatedCollateral
    property var currentURL: "http:www.onsemi.com"


    Image {
        id: image
        opacity: 0.5
        anchors.fill: parent
        anchors.bottomMargin: 40    //don't cover the tab bar at the bottom
        source: "RelatedMaterialBackground.png"
    }

    Rectangle{
        id: titleBannerRect
        color: "#60B77B"
        anchors{ left: parent.left;
            right: parent.right;
            top: parent.top;
            topMargin: parent.height/10
            }
        height: 30

        Text {
            id: title
            text: "Related Materials"
            horizontalAlignment: Text.AlignHCenter
            font.family: "Helvetica"
            font.pointSize: 36
            color: "black"
            anchors{ fill:parent}
        }
    }

    Rectangle{
        id: listRect
        anchors{left: relatedCollateral.left;
            right: relatedCollateral.right;
            bottom: relatedCollateral.bottom;
            top: titleBannerRect.bottom}
        border.width:0
        opacity: 0.75

        ListView {
            id: listView
            anchors{left: listRect.left;
                leftMargin: 10
                right: listRect.right;
                bottom: listRect.bottom;
                top: listRect.top
                topMargin: 10}

            model: ListModel {
                ListElement {
                    name: "ADDITIONAL  BOARD  PARTS"
                    partNumber:""
                    partURL:""
                    isCategoryItem:true
                }
                ListElement {
                    name: "Muli-Phase Controller"
                    partNumber:"NCP81234"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCP81234"
                    isCategoryItem:false
                }

                ListElement {
                    name: "Asymmetric Dual N-Channel MOSFET PowerTrench® Power Clip"
                    partNumber:"FDPC8012S"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=FDPC8012S"
                    isCategoryItem:false
                }

                ListElement {
                    name: "Linear Voltage Regulator, 5-Channel, 2 High-Side Switches"
                    partNumber:"LV5685PV"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=LV5685PV"
                    isCategoryItem:false
                }

                ListElement {
                    name: "Controller, Fixed Frequency, Current Mode, for Flyback Converters"
                    partNumber:"NCP1234"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCP1234"
                    isCategoryItem:false
                }
                ListElement {
                    name: "ALTERNATIVE  PARTS"
                    partNumber:""
                    partURL:""
                    isCategoryItem:true
                }
                ListElement {
                    name: "USB Power Delivery 4 Switch Buck Boost Controller"
                    partNumber:"NCV81599"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCP81239"
                    isCategoryItem:false
                }
                ListElement {
                    name: "Digital Temperature Sensor with Series Resistance Cancellation"
                    partNumber:"NVT211"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NVT211"
                    isCategoryItem:false
                }
                ListElement {
                    name: "Programmable USB Type-C Controller w/PD"
                    partNumber:"FUSB302T"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=FUSB302T"
                    isCategoryItem:false
                }
                ListElement {
                    name: "Automotive Switching Regulator, Buck, 1.2 A, 2 MHz"
                    partNumber:"NCV890100"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCV890100"
                    isCategoryItem:false
                }
                ListElement {
                    name: "ESD Protection, Low Capacitance, High Speed Data"
                    partNumber:"SZESD7104"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=SZESD7104"
                    isCategoryItem:false
                }
                ListElement {
                    name: "Low Power System-on-Chip For 2.4 GHz IEEE 802.15.4-2006 Applications"
                    partNumber:"NCS36510"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCS36510"
                    isCategoryItem:false
                }
                ListElement {
                    name: "512-kb I2C Serial EEPROM"
                    partNumber:"CAT24C512"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=CAT24C512"
                    isCategoryItem:false
                }
                ListElement {
                    name: "Automotive 0.6 A 2 MHz 100% Duty Cycle Step-Down Synchronous Regulator"
                    partNumber:"NCV890430"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCV890430MW50"
                    isCategoryItem:false
                }
                ListElement {
                    name: "LDO Regulator, Ultra-Low Noise and High PSRR, 250 mA"
                    partNumber:"NCP163"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=NCP163"
                    isCategoryItem:false
                }
                ListElement {
                    name: "ESD Protection Diode, Low Leakage, Fast Response Time, with Clamping Capability"
                    partNumber:"SESD7L"
                    partURL:"http://www.onsemi.com/PowerSolutions/product.do?id=SESD7L"
                    isCategoryItem:false
                }
            }
            delegate: Item {
                x: 5
                width: 600
                height: 40  //needed so each row doesn't overlap

                Row {
                    id: row1
                    spacing: 0

                    Rectangle{
                        id: categoryIconRect
                        color: isCategoryItem ? "#60B77B": "#F2F2F2"
                        width: isCategoryItem ? 40: 0
                        height: 40
                        Image {
                            //anchors.fill: categoryIconRect
                            source: (name == "Additional Board Parts") ? "PlusInACircle.svg"
                                                                       : "AlternativePartsIcon.svg"
                        }
                    }

                    Rectangle{
                        id:partNumberRect
                        color: isCategoryItem ? "#60B77B": "#00F2F2F2"
                        width: isCategoryItem ? 700 : 100
                        height: 40
                        //anchors.left: parent.left
                        //anchors.leftMargin: 40
                        Text {
                            text: isCategoryItem ? name
                                                 :qsTr("<a href='") + partURL +  qsTr("'>") + partNumber + qsTr("</a>")
                            //anchors.verticalCenter: parent.verticalCenter
                            //anchors.left: partNumberRect.left
                            //anchors.leftMargin: 10
                            font.bold: isCategoryItem ? true : false
                            linkColor: isCategoryItem ? "black" : "#2EB457" //links are ON Green
                            onLinkActivated:{
                                currentURL = partURL
                                detailView.open()
                            }
                        }
                    }

                    Rectangle{
                        id: partNameRect
                        color: isCategoryItem ? "#60B77B":"#00F2F2F2"
                        width: isCategoryItem ? 0 : 600
                        height: 40
                        //anchors.left: parent.left
                        //anchors.leftMargin: isCategoryItem ? 0 : 180  //indent for regular items
                        Text {
                            text: isCategoryItem ? "" : name
                            //anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                }
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
                Layout.preferredWidth: relatedCollateral.width/2
                Layout.preferredHeight: relatedCollateral.height - tabBar.height*2
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
    }

    //drawer


}
