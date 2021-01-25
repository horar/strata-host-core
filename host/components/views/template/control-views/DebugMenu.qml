import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

// This is an example debug menu that shows how you can test your UI by injecting
// spoofed notifications to simulate a connected platform board.
// injectDebugNotification(notification) // injects a fake JSON notification as though it came from a connected platform
//                                             (for debugging; see line 35-49 below)
// It is for development and should be removed from finalized UI's.


Rectangle {
    id: root
    height: 220
    width: 350
    border {
        width: 1
        color: "#fff"
    }
    visible: false

    function randomValue(min, max) {
        return (Math.random() * (max - min) + min).toFixed(2)
    }
    function randomValueArray() {
        let dataArray = []
        for (var i = 0; i < 6; ++i) {
            dataArray.push((Math.random() * (1 - 0) + 0).toFixed(2))
        }

        return dataArray
    }

    // Re-usable notification template
    property var notification: {
        "value": "",
        "payload": {},
        "sendAndReset": function () {
            this.send()
            this.reset()
        },
        "send": function () {
            platformInterface.injectDebugNotification(this)
        },
        "reset": function () {
            this.value = ""
            this.payload = {}
        }
    }

    Item {
        anchors {
            fill: root
            margins: 1
        }
        clip: true

        Column {
            width: parent.width
            spacing: 1

            Rectangle {
                id: header
                color: "#eee"
                width: parent.width
                height: 40

                Text {
                    text: "Debug (inject fake platform notifications):"
                    anchors {
                        verticalCenter: header.verticalCenter
                        left: header.left
                        leftMargin: 15
                    }
                }

                Button {
                    text: "X"
                    height: 30
                    width: height
                    onClicked: root.visible = false
                    anchors {
                        right: header.right
                        verticalCenter: header.verticalCenter
                    }
                }
            }


            Button {
                id: my_cmd_simple_periodic
                text: "Send my_cmd_simple_periodic notification, \n 'adc_read': 0.4 , \n 'gauge_ramp': random_integer, \n 'io_read': true, \n 'random_float': random_integer, \n 'random_float_array': random_integer_array,\n 'random_increment': [0,5], \n'toggle_bool' : true "
                onClicked: {
                    basic.clearGraph = true //reset the graph.
                    notification.value = "my_cmd_simple_periodic"
                    notification.payload.adc_read = randomValue(0,1)
                    notification.payload.gauge_ramp = randomValue(0,5)
                    notification.payload.io_read = true
                    notification.payload.random_float = randomValue(0,1)
                    notification.payload.random_float_array = randomValueArray()
                    notification.payload.random_increment = [0,5]
                    notification.payload.toggle_bool = true
                    notification.sendAndReset()
                }
            }
        }
    }

    Rectangle {
        id: shadow
        anchors.fill: root
        visible: false
    }

    DropShadow {
        anchors.fill: shadow
        radius: 15.0
        samples: 30
        source: shadow
        z: -1
    }
}
