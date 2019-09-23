import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.commoncpp 1.0 as CommonCpp

SGWidgets.SGWindow {
    id: window
    width: 1024
    height: 768
    minimumWidth: 800
    minimumHeight: 600

    title: "Markdown syntax overview"

    Component.onCompleted: {
        mdTextArea.text = CommonCpp.SGUtilsCpp.readTextFileContent(":/resources/example.md")
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color:"#eeeeee"
    }

    SGWidgets.SGSplitView {
        anchors.fill: parent

        Item {
            Layout.minimumWidth: 400

            SGWidgets.SGTextArea {
                id: mdTextArea
                anchors {
                    fill: parent
                    margins: 2
                }
            }
        }

        Item {
            Layout.minimumWidth: 200
            Layout.fillWidth: true

            SGWidgets.SGMarkdownViewer {
                anchors.fill: parent

                text: mdTextArea.text
            }
        }
    }
}
