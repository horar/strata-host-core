/*
 * Copyright (c) 2018-2021 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
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

                    MouseArea {
                        id: textCursor

                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        enabled: false // cursor appears, MouseArea does not accept clicks/interfere
                    }
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

    header: ToolBar {
        id: appToolbar

        Rectangle {
            id: strataHeaderBackground

            anchors.fill: parent
            color: "black"

            Image {
                id: strataLogoImage

                height: 0.8 * parent.height
                anchors.verticalCenter: parent.verticalCenter
                source: "qrc:/images/strata-logo-reverse.svg"
                fillMode: Image.PreserveAspectFit
                mipmap: true
            }
        }
    }

    footer: DialogButtonBox {
        standardButtons: DialogButtonBox.Abort
        onRejected: Qt.quit(-1);
    }
}
