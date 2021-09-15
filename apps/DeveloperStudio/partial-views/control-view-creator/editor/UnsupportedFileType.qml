import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0

Rectangle {
    Layout.fillWidth: true
    Layout.fillHeight: true

    ColumnLayout {
        anchors {
            centerIn: parent
        }

        SGText {
            Layout.bottomMargin: 5
            color: "#666"
            font.bold: true
            fontSizeMultiplier: 2
            text: "Unsupported file format"
        }

        SGText {
            color: "#666"
            fontSizeMultiplier: 1
            text: "Only some image and text-based file types may be previewed or edited"
        }

        SGText {
            color: "#666"
            fontSizeMultiplier: 1
            text: "Only lower-case file extensions are allowed; e.g. Example.qml, not Example.QML"
        }
    }
}
