import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import "qrc:/js/navigation_control.js" as NavigationControl

Item {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200

    property string class_id: ""
    property string user_id: ""
    property string first_name: ""
    property string last_name: ""

    property string configFileName: "TestUserSettings.json"
    property string passedTestImage: "qrc:/sgimages/check-circle.svg"
    property string failedTestImage: "qrc:/sgimages/times-circle.svg"

    function saveSettings() {
        let config = {
            api_test: {
                result: "Passed!",
            }
        };
        return sgUserSettings.writeFile(configFileName, config)
    }

    Component.onCompleted: {
        testCoreControlView()
    }

    function testCoreControlView() {
        if(class_id) {
            classIDText.text += ": " + class_id + "\n PASSED"
        } else {
            classIDText.text += "\n FAILED"
        }
        if(saveSettings()) {
            userSetting.text += ":" + " True" + "\n PASSED"
        } else {
            userSetting.text += "\n FAILED"
        }
        if(user_id) {
            userIDText.text += ": " + user_id +  "\n PASSED"
        } else {
            userIDText.text += "\n FAILED"
        }
        if(first_name) {
            firstNameText.text += ": " + first_name +  "\n PASSED"
        } else {
            firstNameText.text +=  "\n FAILED"
        }
        if(last_name) {
            lastNameText.text += ": " + last_name +  "\n PASSED"
        } else {
            lastNameText.text +=  "\n FAILED"
        }
    }

    Rectangle {
        id: container
        width: parent.width/2
        height: parent.height/2
        anchors.centerIn: parent
        color: "dark gray"
        ColumnLayout{
            anchors.fill: parent
            Item {
                id: titleContainer
                Layout.fillHeight: true
                Layout.fillWidth: true
                SGText {
                    id: title
                    text: " Core Test Control View "
                    fontSizeMultiplier: ratioCalc * 2.5
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        id: line
                        height: 1.5
                        anchors.top:parent.bottom
                        width: titleContainer.width
                        border.color: "black"
                        radius: 1.5
                        anchors {
                            top: title.bottom
                            topMargin: 7
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent

                    SGIcon {
                        id: testIconClassId
                        width: 20
                        height: 20
                        source: class_id ? passedTestImage : failedTestImage
                        iconColor: class_id ?  "green ": "red"
                    }

                    SGText {
                        id: classIDText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check class_id"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent

                    SGIcon {
                        id: testIconUserSetting
                        width: 20
                        height: 20
                        source: saveSettings() ? passedTestImage : failedTestImage
                        iconColor: saveSettings() ?  "green ": "red"
                    }

                    SGText {
                        id: userSetting
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check SGUSerSetting"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent

                    SGIcon {
                        id: testIconUserId
                        width: 20
                        height: 20
                        source: user_id ? passedTestImage : failedTestImage
                        iconColor: user_id ?  "green ": "red"
                    }

                    SGText {
                        id: userIDText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check user_id"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent

                    SGIcon {
                        id: testIconFirstName
                        width: 20
                        height: 20
                        source: first_name ? passedTestImage : failedTestImage
                        iconColor: first_name ?  "green ": "red"
                    }

                    SGText {
                        id: firstNameText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check first_name"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true

                RowLayout {
                    anchors.fill: parent

                    SGIcon {
                        id: testIconLastName
                        width: 20
                        height: 20
                        source: last_name ? passedTestImage : failedTestImage
                        iconColor: last_name ?  "green ": "red"
                    }

                    SGText {
                        id: lastNameText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Check last_name"
                    }
                }
            }
        }
    }
}
