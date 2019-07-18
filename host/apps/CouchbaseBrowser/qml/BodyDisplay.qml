import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Item {
    id: root

    property alias text: bodyView.text

    ScrollView {
        id: bodyViewContainer
        anchors.fill: parent
        clip: true
        TextArea {
            id: bodyView
            wrapMode: "Wrap"
            selectByMouse: true
            text: ""
            color: "#eeeeee"
            readOnly: true
            background: Rectangle {
                anchors.fill:parent
                color: "#393e46"
            }
        }
    }
    Item {
        width: 200
        height: 200
        MouseArea {
            id: perimeter
            anchors.fill: parent
            hoverEnabled: true
            onEntered: fadeIn.start()
            onExited: fadeOut.start()
        }
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        Image {
            id: plusIcon
            width: 30
            height: 30
            source: "Images/plusIcon.png"
            opacity: 0.1
            MouseArea {
                id: plusButton
                anchors.fill: parent
                onEntered: plusIcon.opacity = 0.8
                onExited: plusIcon.opacity = 1
                onClicked: if(bodyView.font.pixelSize < 40) {
                               bodyView.font.pixelSize += 5
                           }
            }
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: -20
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit


        }
        Image {
            id: minusIcon
            width: 30
            height: 30
            source: "Images/minusIcon.png"
            opacity: 0.1
            MouseArea {
                id: minusButton
                anchors.fill: parent
                onEntered: minusIcon.opacity = 0.8
                onExited: minusIcon.opacity = 1
                onClicked: {
                    if(bodyView.font.pixelSize > 15 ){
                        bodyView.font.pixelSize -= 5
                    }
                }

            }
            anchors {
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: 30
                horizontalCenter: parent.horizontalCenter
            }
            fillMode: Image.PreserveAspectFit
        }
    }
    NumberAnimation {
        id: fadeIn
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 0.1
        to: 1
        duration: 300
    }
    NumberAnimation {
        id: fadeOut
        targets: [plusIcon, minusIcon]
        properties: "opacity"
        from: 1
        to: 0.1
        duration: 300
    }
}
