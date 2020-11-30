import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 0.9 as Widget09

import "qrc:/js/navigation_control.js" as NavigationControl

Item {
    id: root
    anchors.fill: parent
    property real ratioCalc: root.width / 1200
    property real initialAspectRatio: 1400/900
    property string class_id: ""
    property string user_id: ""
    property string first_name: ""
    property string last_name: ""

    Item {
        id: classId
        Text {
            Accessible.name: "class_id: " + text
            Accessible.role: Accessible.StaticText
            text: class_id
            Component.onCompleted: {
                if(text != "") {
                    console.info("Class ID", text)
                }
            }
        }
    }

    Item {
        id: userId
        Text {
            Accessible.name: "user_id: " + text
            Accessible.role: Accessible.StaticText
            text: user_id
            Component.onCompleted: {
                console.info("User ID", text)
            }
        }
    }

    Item {
        id: firstName
        Text {
            Accessible.name: "first_name:" + text
            Accessible.role: Accessible.StaticText
            text: first_name
            Component.onCompleted: {
                console.info("First Name", text)
            }
        }
    }

    Item {
        id: lastName
        Text {
            Accessible.name: "last_name:" + text
            Accessible.role: Accessible.StaticText
            text: last_name
            Component.onCompleted: {
                console.info("Last Name", text)
            }
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
                        id: line1
                        height: 2
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
                        id: helpIcon1
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

                    }

                    SGText {
                        id: firstTest
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
                        id: helpIcon2
                        width: 20
                        height: 20
                        source:  "qrc:/sgimages/times-circle.svg"
                        iconColor: "red"

                    }
                    SGText {
                        Layout.fillWidth: true
                        wrapMode: Text.Wrap
                        text: "Setting SGUSerSetting"
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
                RowLayout {
                    SGIcon {
                        id: helpIcon3
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
                        id: helpIcon4
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
                        id: helpIcon5
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

            //            Item {
            //                Layout.fillHeight: true
            //                Layout.fillWidth: true
            //            }
        }
        SGButton{
            width: 100
            height: 100
            text: "RUN"
            anchors.top: container.bottom
            anchors.topMargin: 10
            onClicked: {
                if(class_id) {
                    console.info("Class_id",class_id)
                    helpIcon1.source = "qrc:/sgimages/check-circle.svg"
                    helpIcon1.iconColor = "green"
                    firstTest.text += ": " + class_id + "\n PASSED"
                }
                else {
                    helpIcon1.source =  "qrc:/sgimages/times-circle.svg"
                    helpIcon1.iconColor = "red"
                    firstTest.text += ": " + class_id + "\n FAILED"
                }

                if(user_id) {
                    console.info("user_id", user_id)
                    helpIcon3.source = "qrc:/sgimages/check-circle.svg"
                    helpIcon3.iconColor = "green"
                    userIDText.text += ": " + user_id +  "\n PASSED"
                }
                else {
                    helpIcon3.source = "qrc:/sgimages/times-circle.svg"
                    helpIcon3.iconColor = "red"
                    userIDText.text += ": " + user_id +  "\n FAILED"
                }
                if(first_name) {
                    console.info("first_name", first_name)
                    helpIcon4.source = "qrc:/sgimages/check-circle.svg"
                    helpIcon4.iconColor = "green"
                    firstNameText.text += ": " + first_name +  "\n PASSED"
                }
                else {
                    helpIcon4.source = "qrc:/sgimages/times-circle.svg"
                    helpIcon4.iconColor = "red"
                    firstNameText.text += ": " + first_name +  "\n FAILED"
                }
                if(last_name) {
                    console.info("last_name", last_name)
                    helpIcon5.source = "qrc:/sgimages/check-circle.svg"
                    helpIcon5.iconColor = "green"
                    lastNameText.text += ": " + last_name +  "\n PASSED"
                }
                else {
                    helpIcon5.source = "qrc:/sgimages/times-circle.svg"
                    helpIcon5.iconColor = "red"
                    lastNameText.text += ": " + last_name +  "\n FAILED"
                }

            }
        }
    }

}
