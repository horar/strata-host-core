/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import "Components"
ColumnLayout {
    id: root   

    property alias model: listView.model
    property alias currentIndex: listView.currentIndex

    function clearSearch() {
        searchbox.userInput = ""
    }

    UserInputBox {
        id: searchbox
        Layout.preferredWidth: parent.width - 20
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10

        showButton: true
        iconSize: 12
        color: "darkred"
        path: "Images/x-icon.svg"
        placeholderText: "Search"
        onClicked: {
            searchbox.userInput = ""
        }
    }

    ListView {
        id: listView
        Layout.fillHeight: true
        Layout.preferredWidth: parent.width - 10
        Layout.alignment: Qt.AlignRight
        Layout.bottomMargin: 10

        clip: true
        model: []
        delegate: Component {
            Rectangle  {
                width: ListView.view.width - 10
                height: visible ? 30 : 0

                visible: model.modelData.toLowerCase().includes(searchbox.userInput.toLowerCase())
                border.width: 1
                border.color: "#393e46"
                color: listView.currentIndex === index ? "#612b00" : mouseArea.containsMouse ? "#8c4100" : "#b55400"
                radius: 3

                Text {
                    width: parent.width - 10
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight

                    text: model.modelData
                    color: "#eee"
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent

                    hoverEnabled: true
                    onClicked: listView.currentIndex = index
                }
            }
        }
        ScrollBar.vertical: ScrollBar {
            id: scrollBar
            width: 10

            policy: ScrollBar.AsNeeded
        }
    }
}
