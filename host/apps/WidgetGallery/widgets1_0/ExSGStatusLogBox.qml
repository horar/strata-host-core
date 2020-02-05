import QtQuick 2.12
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

Rectangle {
    id: root
    width: 500
    height: 200

    SGStatusLogBox {
        id: logBox

        // Example Anchors
        anchors {
            top: root.top
            left: root.left
            right: parent.right
        }

        // Optional configuration:
        title: "Default Status Logs"               // Default: "" (title bar will not be visible when empty string)
        // titleTextColor: "#000000"       // Default: "black"
        // titleBoxColor: "#eeeeee"        // Default: "#F2F2F2"
        // titleBoxBorderColor: "#dddddd"  // Default: "#D9D9D9"
        // statusTextColor: "#777777"      // Default: "black"
        // statusBoxColor: "#ffffff"       // Default: "white"
        // statusBoxBorderColor: "#dddddd" // Default: "#D9D9D9"
        // filterEnabled: true             // Default: true (can disable filtration)
        // fontSizeMultiplier: 2           // Default: 1
        // scrollToEnd: false              // Default: true (determines if view scrolls to end when new messages appended)

        // Debug options:
        showMessageIds: true           // Default: false (shows internal message ids, for debugging)

        // Available methods (example use buttons below):
        // logBox.append(string message)                        // appends message to list and returns id of message for later manipulation
        // logBox.remove(int id)                                // if message with id found, removes message & returns true, else returns false
        // logBox.updateMessageAtID(string message, int id)     // if message with id found, updates message & returns true, else returns false
    }

    RowLayout {
        // Example use buttons:
        id: row
        anchors {
            top: logBox.bottom
            left: root.left
            right: root.right
        }
        spacing: 1

        Button {
            text: "Add \n Message"
            Layout.fillWidth: true
            property int count: 0
            onClicked: {
                var messageID = logBox.append("Message " + count++)
                console.info("Added message:", messageID)
            }
        }

        Button {
            text: "Remove \n message with id 0"
            Layout.fillWidth: true
            onClicked: {
                var success = logBox.remove(1);
                console.info((success ? "Removed message with id 1" : "Message with id 1 not found"))
            }
        }

        Button {
            text: "Clear \n Messages"
            Layout.fillWidth: true
            onClicked: {
                logBox.clear()
                console.info("Cleared")
            }
        }
    }
}
