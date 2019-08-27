import QtQuick 2.11
import QtQuick.Window 2.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import tech.strata.sgwidgets 1.0

Window {
    visible: true
    width: 500
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
        title: "Status Logs"               // Default: "" (title bar will not be visible when empty string)
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
        showMessageIds: false           // Default: false (shows internal message ids, for debugging)

        // Available methods (example use buttons below):
        // logBox.append(string message)                        // appends message to list and returns id of message for later manipulation
        // logBox.remove(int id)                                // if message with id found, removes message & returns true, else returns false
        // logBox.updateMessageAtID(string message, int id)     // if message with id found, updates message & returns true, else returns false
    }

    RowLayout {
        // Example use buttons:
        id: row
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        spacing: 1

        Button {
            text: "Add Message"
            Layout.fillWidth: true
            property int count: 0
            onClicked: {
                var messageID = logBox.append("Message " + count++)
                console.log("Added message:", messageID)
            }
        }

        Button {
            text: "Remove message"
            Layout.fillWidth: true
            onClicked: {
                var success = logBox.remove(1);
                console.log((success ? "Removed message with id 1" : "Message with id 1 not found"))
            }
        }

        Button {
            text: "Update Message"
            Layout.fillWidth: true
            onClicked: {
                var success = logBox.updateMessageAtID("Message with id 0 updated", 0)
                console.log((success ? "Updated message with id 0" : "Message with id 0 not found"))
            }
        }

        Button {
            text: "Clear"
            Layout.fillWidth: true
            onClicked: {
                logBox.clear()
                console.log("Cleared")
            }
        }
    }
}
