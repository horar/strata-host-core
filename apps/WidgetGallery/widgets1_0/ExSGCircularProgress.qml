import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets

Item {
    width: contentColumn.width
    height: contentColumn.height

    Column {
        id: contentColumn

        spacing: 10

        SGWidgets.SGCircularProgress {
            anchors.horizontalCenter: parent.horizontalCenter
            value: slider.value
        }

        SGWidgets.SGText {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Default Circular Progress"
        }

        Slider {
            id: slider
            anchors.horizontalCenter: parent.horizontalCenter

            from: 0
            to: 1
            value: 0.1
        }
    }
}
