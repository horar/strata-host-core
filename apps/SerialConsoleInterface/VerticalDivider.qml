import QtQuick 2.12

Item {
    width: column.width
    height: column.height

    Column {
        id: column
        spacing: 2

        Repeater {
            model: 5
            delegate: Rectangle {
                width: 2
                height: 2
                color : "black"
                opacity: 0.3
            }
        }
    }
}
