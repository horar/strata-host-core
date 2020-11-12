import QtQuick 2.12
import QtQuick.Layouts 1.12
import tech.strata.sgwidgets 1.0
import QtQuick.Controls 2.12

Rectangle {
    id: badge
    smooth: true
    z:2

    // Allow the programmer to define the text to display.
    // Note that this control can display both text and numbers.
    property alias text: label.text

    // Create an animation when the opacity changes
    Behavior on opacity {NumberAnimation{}}

    // Set a redish color (exactly the one used in OS X 10.10)
    color: "#ec3e3a"

    // Make the rectangle a circle
    radius: width / 2

    // Setup height of the rectangle (the default is 18 pixels)
    height: 30

    // Make the rectangle and ellipse if the length of the text is bigger than 2 characters
    width: label.text.length > 2 ? label.paintedWidth + height/2 : height

    // Create a label that will display the number of connected users.
    Label {
        id: label
        color: "#fdfdfdfd"
        font.pixelSize: 10
        font.bold: true
        anchors.fill: parent
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: "!"
        // We need to have the same margins as the badge so that the text
        // appears perfectly centered inside its parent.
        anchors.margins: parent.anchors.margins
    }
}

