import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.fonts 1.0

Component {
    Rectangle {
        Accessible.role: Accessible.Button
        Accessible.name: content.text
        Accessible.onPressAction: function() {
            feedbackTypeListView.currentIndex = index
        }

        id: label

        property alias containsMouse: buttonMouseArea.containsMouse
        property string typeValue: type

        color: containsMouse ? hoverColor : baseColor
        width: content.width + 15
        height: 30
        radius: 5
        border.width: feedbackTypeListView.currentIndex === index ? 2 : 0
        border.color: "black"

        Text {
            id: content
            anchors.centerIn: parent
            text: qsTr(type)
            font {
                pixelSize: 15
                family: Fonts.franklinGothicBook
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                feedbackTypeListView.currentIndex = index
            }
        }
    }
}
