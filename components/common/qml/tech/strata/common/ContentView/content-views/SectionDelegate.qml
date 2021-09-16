import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0

Item {
    id: sectionDelegate
    height: headerText.y + headerText.contentHeight + 4

    property alias text: headerText.text
    property bool isFirst: false

    SGWidgets.SGText {
        id: headerText
        width: parent.width
        anchors {
            top: parent.top
            topMargin: sectionDelegate.isFirst ? 8 : 16
            left: parent.left
            leftMargin: 5
        }

        alternativeColorEnabled: true
        elide: Text.ElideMiddle
        font.capitalization: Font.Capitalize
        font.bold: true
    }

    Rectangle {
        id: headerUnderline
        anchors {
            bottom: parent.bottom
        }

        color: Theme.palette.onsemiOrange
        height: 1
        width: parent.width
    }
}
