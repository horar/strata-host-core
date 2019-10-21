import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Page {
    id: page

    property bool hasBack: true

    function goBack() {
        StackView.view.pop()
    }

    background: Rectangle {
        color: "#eeeeee"
    }

    header: Item {
        height: label.text.length > 0 ? label.paintedHeight + 16 : 0

        Rectangle {
            anchors.fill: parent
            color: SGWidgets.SGColorsJS.STRATA_BLUE
        }

        SGWidgets.SGIconButton {
            anchors {
                left: parent.left
                leftMargin: 4
                verticalCenter: parent.verticalCenter
            }

            icon.source: "qrc:/sgimages/chevron-left.svg"
            iconSize: parent.height - 16
            alternativeColorEnabled: true
            visible: hasBack
            onClicked: goBack()
        }

        SGWidgets.SGText {
            id: label
            anchors {
                centerIn: parent
            }

            text: page.title
            fontSizeMultiplier: 2.0
            alternativeColorEnabled: true
        }
    }
}
