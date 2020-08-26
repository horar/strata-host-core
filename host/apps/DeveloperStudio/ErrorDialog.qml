import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: mainWindow

    visible: true
    width: 640
    height: 480
    minimumWidth: 640
    minimumHeight: 480

    title: qsTr("%1").arg(Qt.application.displayName)


    StackView {
        id: mainStack

        anchors.fill: parent
        initialItem: mainPage
    }

    Component {
        id: mainPage

        Label {
            wrapMode: Text.WordWrap
            padding: font.pixelSize * 2
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            text: qsTr("<strong><h2>An unexpected application error has occurred.</h2></strong>" +
                       "<br><br>" +
                       "Please contact your local sales representative.")
        }
    }

    Component {
        id: errorTextPage

        ColumnLayout {
            Label {
                id: errorTextHeader

                Layout.fillWidth: true
                text: qsTr("Error details:")
                padding: 5
            }

            ScrollView {
                id: errorTextScrollView

                Layout.fillWidth: true
                Layout.fillHeight: true
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn

                TextArea {
                    id: errorText

                    text: errorString
                    readOnly: true
                    selectByMouse: true
                }
            }
        }
    }

    RoundButton {
        id: detailsButton

        anchors {
            left: parent.left
            leftMargin: detailsButton.width / 3.0
            bottom: parent.bottom
            bottomMargin: detailsButton.height / 3.0
        }

        text: qsTr("\u2139")
        checkable: true

        onClicked: {
            if (checked) {
                mainStack.push(errorTextPage)
            } else {
                mainStack.pop()
            }
        }
    }

    footer: DialogButtonBox {
        standardButtons: DialogButtonBox.Abort
        onRejected: Qt.quit(-1);
    }
}
