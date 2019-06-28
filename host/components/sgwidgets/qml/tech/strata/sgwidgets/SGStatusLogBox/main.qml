import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import tech.strata.sgwidgets 1.0

Window {
    visible: true
    width: 400
    height: 300
    title: qsTr("SGStatusLogBox Demo")

    //
    // SGStatusLogBoxSelectableDelegates and SGStatusLogBoxSelectableText are advanced use case wrappers
    // for SGStatusLogBox, allowdin delegate selection and text selection across delegates, respectively.
    // To demo or test them, just replace the following 'SGStatusLogBox {' declaration with either.
    //

    SGStatusLogBox {
        id: logBox

        // Example Anchors
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            bottom: row.top
        }

        // Optional configuration:
        title: "Status Logs"            // Default: "" (title bar will not be visible when empty string)
        titleTextColor: "#000000"       // Default: "#000000" (black)
        titleBoxColor: "#eeeeee"        // Default: "#eeeeee" (light gray)
        titleBoxBorderColor: "#dddddd"  // Default: "#dddddd" (light gray)
        statusTextColor: "#777777"      // Default: "#000000" (black)
        statusBoxColor: "#ffffff"       // Default: "#ffffff" (white)
        statusBoxBorderColor: "#dddddd" // Default: "#dddddd" (light gray)
        filterEnabled: true             // Default: true (can disable filtration)

        // Debug options:
        showMessageIds: false           // Default: false (shows internal message ids, for debugging)

        // Available methods (example use buttons below):
        // logBox.append(string message)                        // appends message to list and returns id of message for later manipulation
        // logBox.remove(int id)                                // if message with id found, removes message & returns true, else returns false
        // logBox.updateMessageAtID(string message, int id)     // if message with id found, updates message & returns true, else returns false
    }

    Row {
        // Example use buttons:
        id: row
        anchors {
            bottom: parent.bottom
            left: parent.left
        }

        Button {
            text: "Add Message"
            property int count: 0
            onClicked: {
                var messageID = logBox.append("Message " + count++)
                console.log("Added message:", messageID)
            }
        }

        Button {
            text: "Remove message"
            onClicked: {
                var success = logBox.remove(1);
                console.log((success ? "Removed message with id 1" : "Message with id 1 not found"))
            }
        }

        Button {
            text: "Update Message"
            onClicked: {
                var success = logBox.updateMessageAtID("Message with id 0 updated", 0)
                console.log((success ? "Updated message with id 0" : "Message with id 0 not found"))
            }
        }
    }
}
