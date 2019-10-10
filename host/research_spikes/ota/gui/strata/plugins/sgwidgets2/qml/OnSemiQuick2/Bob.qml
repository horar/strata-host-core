import QtQuick 2.12

Rectangle {
    id: root

//    color: "green"
    color: "red"

    Component.onCompleted: console.log("Bob@2 is completed.. [" + color + "]")
}
