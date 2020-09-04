import QtQuick 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0

Rectangle {
    id: sideBarRoot
    color: "#777"

    ColumnLayout {
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: 5
            leftMargin: 5
            rightMargin: 5
        }

        SGText {
            Layout.leftMargin: 5
            Layout.rightMargin: 5
            text:"QRC Files:"
            fontSizeMultiplier: 1.5
            color: "white"
        }

        Repeater {
            id: fileSelectorRepeater
            model: fileModel
            delegate: SGButton {
                // TODO: create file tree view or at least more sensible list of QRC/project files
                Layout.fillWidth: true
                checkable: true
                checked: model.visible
                text: model.filename

                property int modelIndex: index

                onCheckedChanged: {
                    if (checked) {
                        editorRoot.setVisible(modelIndex)
                    }
                }
            }
        }

        SGButton {
            Layout.fillWidth: true
            Layout.topMargin: 20
            text: "New file..."
        }

        SGButton {
            Layout.fillWidth: true
            Layout.topMargin: 20
            text: "Add existing file to QRC..."
        }
    }
}
