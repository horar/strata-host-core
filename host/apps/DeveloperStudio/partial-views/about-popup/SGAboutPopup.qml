import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "qrc:/partial-views"

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

SGStrataPopup {
    id: aboutPopup
    headerText: "About Strata"
    property string versionNumber

    contentItem: ColumnLayout {
        id: mainColumn
        spacing: 20

        Row {
            id: logoContainer
            height: 200
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: strataLogo
                source: "qrc:/images/strata-logo.svg"
                sourceSize.height: logoContainer.height
                fillMode: Image.PreserveAspectFit
            }

            Image {
                id: onsemiLogo
                source: "qrc:/images/on-semi-logo-horiz.svg"
                sourceSize.height: logoContainer.height/2
                fillMode: Image.PreserveAspectFit
                anchors {
                    verticalCenter: strataLogo.verticalCenter
                }
            }
        }

        Rectangle {
            id: aboutTextContainer
            Layout.preferredWidth: width
            width: aboutPopup.contentItem.width
            Layout.preferredHeight: aboutText.contentHeight + 40
            color: "#eee"

            TextEdit {
                id: aboutText
                width: aboutTextContainer.width - 40
                anchors.verticalCenter: aboutTextContainer.verticalCenter
                anchors.horizontalCenter: aboutTextContainer.horizontalCenter
                text: "<b>" + versionNumber + "</b><br><br>Designed by engineers for engineers to securely deliver software & information, efficiently bringing you the focused info you need, nothing you don’t."
                wrapMode: TextEdit.Wrap

                horizontalAlignment: Text.AlignHCenter
                textFormat: TextEdit.RichText
            }
        }

        Rectangle {
            id: nameContainer
            Layout.fillWidth: true
            height: 100
            color: "white"
            border {
                width: 1
                color: "#ddd"
            }

            Item {
                id: scrollviewClipper
                anchors {
                    fill: nameContainer
                }
                clip: true

                ScrollView {
                    anchors {
                        fill: parent
                        margins: 10
                    }
                    clip: false

                    Text {
                        id: attributionText
                        text: "Attribution List: (not found)"
                        color: "#aaa"
                        Component.onCompleted: {
                            var xhr = new XMLHttpRequest;
                            xhr.open("GET", "qrc:/partial-views/about-popup/attributionInfo.txt");
                            xhr.onreadystatechange = function() {
                                if (xhr.readyState == XMLHttpRequest.DONE) {
                                    var response = xhr.responseText;
                                    attributionText.text = response
                                }
                            };
                            xhr.send();
                        }
                    }
                }
            }
        }
    }
}

