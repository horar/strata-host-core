import QtQuick 2.9
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.12

Item {
    id: delegateContainer
    implicitHeight: partName.height + 10
    width: parent.width
    visible: uri !== ""
    objectName: "pdfButton"
    property string uri
    property string title: "Button title"
    property bool centerText: false
    property bool capitalize: false
    property bool underline: false
    property real leftMargin: 0
    property real bottomMargin: 1
    property bool current: String(pdfViewer.url) === delegateContainer.uri

    Rectangle {
        id: delegateButton
        anchors {
            fill: delegateContainer
            bottomMargin: delegateContainer.bottomMargin
            leftMargin: delegateContainer.leftMargin
        }
        color: mouseArea.pressed ? "#888": delegateContainer.current || (delegateContainer.current && mouseArea.containsMouse) ? "#eee" : mouseArea.containsMouse ? "#666" : "#444"


        MouseArea {
            id: mouseArea
            anchors {
                fill: delegateButton
            }
            hoverEnabled: true
            onClicked: {
                pdfViewer.url = delegateContainer.uri
            }
        }

        Text {
            id: partName
            text: delegateContainer.title
            color: delegateContainer.current ? "#333" : "white"
            anchors {
                verticalCenter: delegateButton.verticalCenter
                left: delegateButton.left
                leftMargin: 10
                right: selected.left
                rightMargin: 10
            }
            wrapMode: Text.Wrap
            horizontalAlignment: delegateContainer.centerText ? Text.AlignHCenter : Text.AlignLeft
            font {
                capitalization: delegateContainer.capitalize ? Font.Capitalize : Font.MixedCase
                pixelSize: 14
                bold: !delegateContainer.current
            }
        }

        Rectangle {
            id: underline
            color: "#33b13b"
            width: partName.contentWidth
            height: 1
            anchors {
                top: partName.bottom
                topMargin: 2
                horizontalCenter: partName.horizontalCenter
            }
            visible: delegateContainer.current && delegateContainer.underline
        }

        Item {
            id: selected
            width: image.width
            height: image.height
            visible: delegateContainer.current
            anchors {
                verticalCenter: delegateButton.verticalCenter
                right: delegateButton.right
                rightMargin: (delegateContainer.height - height) / 3
            }

            Image {
                id: image
                visible: false
                fillMode: Image.PreserveAspectFit
                source: "angle-right-solid.svg"
                sourceSize.height: delegateContainer.height * .75
            }

            ColorOverlay {
                id: overlay
                anchors.fill: image
                source: image
                visible: true
                color: "#333"
            }
        }
    }
}
