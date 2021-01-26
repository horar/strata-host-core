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
    property string configFileName: "userSettingTest.json"
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
        testingCoreControlView()
    }

    function testingCoreControlView() {
        if(class_id) {
            testIconClassId.source = passedTestImage
            testIconClassId.iconColor = "green"
            classIDText.text += ": " + class_id + "\n PASSED"
        }
        else {
            testIconClassId.source =  failedTestImage
            testIconClassId.iconColor = "red"
            classIDText.text += "\n FAILED"
        }

        if(saveSettings()) {
            testIconUserSetting.source = passedTestImage
            testIconUserSetting.iconColor = "green"
            userSetting.text += ":" + " True" + "\n PASSED"
        }
        else {
            testIconUserSetting.source = failedTestImage
            testIconUserSetting.iconColor = "red"
            userSetting.text += "\n FAILED"
        }

        if(user_id) {
            testIconUserId.source = passedTestImage
            testIconUserId.iconColor = "green"
            userIDText.text += ": " + user_id +  "\n PASSED"
        }
        else {
            testIconUserId.source = failedTestImage
            testIconUserId.iconColor = "red"
            userIDText.text += "\n FAILED"
        }

        if(first_name) {
            testIconFirstName.source = passedTestImage
            testIconFirstName.iconColor = "green"
            firstNameText.text += ": " + first_name +  "\n PASSED"
        }
        else {
            testIconFirstName.source = failedTestImage
            testIconFirstName.iconColor = "red"
            firstNameText.text +=  "\n FAILED"
        }
        if(last_name) {
            testIconLastName.source = passedTestImage
            testIconLastName.iconColor = "green"
            lastNameText.text += ": " + last_name +  "\n PASSED"
        }
        else {
            testIconLastName.source = failedTestImage
            testIconLastName.iconColor = "red"
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
                    text: " Test Control View "
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
                    SGIcon {
                        id: testIconClassId
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"
                    }

                    SGText {
                        id: classIDText
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        Accessible.name: "class_id: " + text
                        Accessible.role: Accessible.StaticText
                        text: "Check class_id"
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                RowLayout {
                    SGIcon {
                        id: testIconUserSetting
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

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
                    SGIcon {
                        id: testIconUserId
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

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
                    SGIcon {
                        id: testIconFirstName
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"
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
                    SGIcon {
                        id: testIconLastName
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"
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
