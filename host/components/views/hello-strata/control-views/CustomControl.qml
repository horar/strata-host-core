import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

Rectangle {
    id: root

    border {
        width: 1
        color: "lightgrey"
    }
    clip: true

    property bool hideHeader: false
    property real minimumHeight
    property real minimumWidth
    property real defaultMargin: 20
    property real defaultPadding: 20
    property real factor: Math.max(1,(hideHeader ? 0.6 : 1) * Math.min(root.height/minimumHeight,root.width/minimumWidth))
    property string title: ""
    property alias contentItem: contentContainer.contentItem

    signal zoom

    // hide in tab view
    onHideHeaderChanged: {
        if (hideHeader) {
            header.visible = false
            border.width = 0
        }
        else {
            header.visible = true
            border.width = 1
        }
    }

    ColumnLayout {
        id: container
        anchors.fill:parent
        spacing: 0

        RowLayout {
            id: header
            Layout.alignment: Qt.AlignTop

            Text {
                id: name
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.margins: defaultMargin * factor

                text: "<b>" + root.title + "</b>"
                font.pixelSize: 14*factor
                color:"black"
                wrapMode: Text.WordWrap
            }

            Button {
                id: btn
                Layout.preferredHeight: btnText.contentHeight+6*factor
                Layout.preferredWidth: btnText.contentWidth+20*factor
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.margins: defaultMargin * factor

                text: qsTr("Maximize")
                contentItem: Text {
                    id: btnText
                    text: btn.text
                    font.pixelSize: 10*factor
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: zoom()
            }
        }

        Item {
            id: contentContainer
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.maximumWidth: maximumWidth
            Layout.maximumHeight: maximumHeight
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            property Item contentItem
            property real maximumHeight: root.height - defaultPadding * factor - (hideHeader ? 0 : header.height)
            property real maximumWidth: hideHeader ? 0.6 * root.width : root.width - defaultPadding * 2
            property var btn: btn
            onContentItemChanged: contentItem.parent = contentContainer
        }
    }
}
