import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

ColumnLayout {
    id: mainLayout

    property alias updateActivated: updateActivated.checked
    property alias updateInterval: spinBox.value
    //    property alias textAreaText: textArea.text
    property string textAreaText: ""
    property alias buttonUpdate: buttonUpdate
    property alias buttonInstall: buttonInstall

    RowLayout {

        ColumnLayout {

            Switch {
                id: updateActivated
                text: qsTr("Updates watchdog")
                Layout.fillWidth: true
            }

            SpinBox {
                id: spinBox

                enabled: !checkUpdatesTiemr.running
                value: 2000 //10000
                stepSize: 1000
                from: 2000
                to: 120000
            }
        }

        BusyIndicator {
            id: busyIndicator
            running: checkUpdatesTiemr.running
        }
    }

    ColumnLayout {
        GroupBox {
            padding: 5
            //        height: 300
            Layout.fillHeight: true
            Layout.fillWidth: true
            title: qsTr("Update list")

            //        Layout.fillWidth: true
            //        height: 200
            ColumnLayout {
                anchors.fill: parent

                ListView {
                    //            TableView {
                    id: tw
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    //                property var columnWidths: [300, 150, 150]
                    //                columnWidthProvider: function (column) {
                    //                    return columnWidths[column]
                    //                }

                    //                columnSpacing: 10
                    //                rowSpacing: 10
                    //                clip: true
                    model: xmlModel //TableModel {}

                    delegate: Text {
                        text: name + ": v" + version + " (size: " + size + ")"

                        width: tw.width
                        height: implicitHeight
                        //                anchors.right: parent.right
                        //                anchors.left: parent.left
                    }
                }
            }
            // ???
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false

            Button {
                id: buttonUpdate
                text: qsTr("&Update")
                enabled: xmlModel.count !== 0
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
            Button {
                id: buttonInstall
                text: qsTr("&Install views.view2")
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }
        }

        //        ListView {
        //            id: listView
        //            anchors.fill: parent

        //            delegate: Text {
        //                text: name + ": v" + version + " (size: " + size + ")"
        //                anchors.right: parent.right
        //                anchors.left: parent.left
        //            }
        //            model: xmlModel

        //            //            Layout.fillWidth: true
        //            //            height: 200
        //        }
    }

    //    Flickable {
    //        flickableDirection: Flickable.VerticalFlick

    //        Layout.fillHeight: true
    //        Layout.fillWidth: true

    //        TextArea.flickable: TextArea {
    //            id: textArea
    //            placeholderText: qsTr("Waiting...\n")
    //        }

    //        ScrollBar.vertical: ScrollBar {
    //        }
    //    }
}
