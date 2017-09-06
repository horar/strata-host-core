import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtWebView 1.1

Item {
    ListModel {
        id: partModel

        // 1	QUH	NVD5890N	ON Semiconductor	NVD5890N	SO8-FL / DPAK		40V
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "QUH"
            part_number: "NVD5890N"
            package_type: "SO8-FL / DPAK"
            voltage: "40V"
            wattage: "n/a"
            tolerance: "n/a"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=NVD5890N"
        }

        // 1	QP1	BC846ALT1G	ON Semiconductor	BC846ALT1G	SOT-23-3		65V
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "QP1"
            part_number: "BC846ALT1G"
            package_type: "SOT-23-3"
            voltage: "65V"
            wattage: "n/a"
            tolerance: "n/a"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=BC846ALT1G"
        }

        // 1	DP1	MMSD914T1	ON Semiconductor	MMSD914T1	SOD-123		100V
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "DP1"
            part_number: "MMSD914T1"
            package_type: "SOD-123"
            voltage: "100V"
            wattage: "n/a"
            tolerance: "n/a"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=MMSD914T1"
        }

        // 1	DP2	BZX84B18LT1G	ON Semiconductor	BZX84B18LT1G	SOT-23		18V	225mW	2%
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "DP2"
            part_number: "BZX84B18LT1G"
            package_type: "SOT-23"
            voltage: "18V"
            wattage: "2%"
            tolerance: "2%"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=BZX84B18LT1G"
        }

        // 1	DP2	BZX84B18LT1G	ON Semiconductor	BZX84B18LT1G	SOT-23		18V	225mW	2%
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "DP2"
            part_number: "BZX84B18LT1G"
            package_type: "SOT-23"
            voltage: "18V"
            wattage: "2%"
            tolerance: "2%"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=BZX84B18LT1G"
        }

        // 1	ULV	LV8907UW	ON Semiconductor	LV8907UW	SQFP48K
        ListElement {
            manufacturer: "On Semiconductor"
            part_reference: "ULV"
            part_number: "LV8907UW"
            package_type: "SQFP48K"
            voltage: "n/a"
            wattage: "n/a"
            tolerance: "n/a"
            data_sheet: "http://www.onsemi.com/PowerSolutions/product.do?id=LV8907UW"
        }
    } // end partModel

    Component {
        id: partDelegate
        Rectangle {
            id: wrapper
            width: parent.width
            height: 30
            color: ListView.isCurrentItem ? "steelblue" : "lightsteelblue"
            Text {
                id: partInfo
                anchors { verticalCenter: wrapper.verticalCenter; margins: 5}
                text: "<b>" + manufacturer + "</b>" + ": P/N: " + part_number + ": Package: " + package_type
                      + " : voltage: " + voltage + " : wattage: " + wattage + " : tolerance: " + tolerance
                color: "black"
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    console.debug("data_sheet=" + data_sheet);
                    webView.url = data_sheet
                    partList.currentIndex = index
                }
            }
        }
    }

    // LOGO
    Rectangle {
        id: headerLogo
        anchors { top: parent.top }
        width: parent.width; height: 40
        color: "#235A92"
    }
    Image {
        anchors { top: parent.top; right: parent.right }
        height: 40
        fillMode: Image.PreserveAspectFit
        source: "onsemi_logo.png"
    }

    ListView {
        id: partList
        anchors { top: headerLogo.bottom}
        width: parent.width; height: parent.height*0.2
        model: partModel
        delegate: partDelegate
        focus: true
        clip: true
        add: Transition {
            NumberAnimation { properties: "x,y"; from: 100; duration: 1000 }
        }
    }

    WebView {
        id: webView
        width: mainWindow.width
        anchors { top: partList.bottom; bottom: parent.bottom}
        url: "http://www.onsemi.com/PowerSolutions/product.do?id=NVD5890N"
        onLoadingChanged: {
            if (loadRequest.errorString)
                console.error(loadRequest.errorString);
        }
    }

}













