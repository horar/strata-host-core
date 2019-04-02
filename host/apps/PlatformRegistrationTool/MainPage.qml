import QtQuick 2.12
import QtQuick.Controls 2.12
import "./common" as Common

PrtBasePage {
    title: "Main Page"
    hasBack: false

    property int buttonWidth: 100
    property int buttonHeight: 140

    Row  {
        id: mainRow
        spacing: 16
        anchors.centerIn: parent

        Common.SgButton {
            minimumContentWidth: buttonWidth
            minimumContentHeight: buttonHeight
            text: "Platform\nRegistration"
            onClicked: jumpToPage("register")
            icon.source: "qrc:/images/chip-flash.svg"
            icon.height: 60
            display: Button.TextUnderIcon
            fontSizeMultipier: 1.3
        }

        Common.SgButton {
            minimumContentWidth: buttonWidth
            minimumContentHeight: buttonHeight
            text: "New\nPlatform"
            onClicked: jumpToPage("create")
            icon.source: "qrc:/images/plus.svg"
            icon.height: 60
            display: Button.TextUnderIcon
            fontSizeMultipier: 1.3
        }

        Common.SgButton {
            minimumContentWidth: buttonWidth
            minimumContentHeight: buttonHeight
            text: "Board\nStatus"
            onClicked: jumpToPage("status")
            icon.source: "qrc:/images/search-analyze.svg"
            icon.height: 60
            display: Button.TextUnderIcon
            fontSizeMultipier: 1.3
        }
    }

    function jumpToPage(page) {
        if (page === "register") {
            stackView.pushPage("RegisterPlatformPage.qml")
        } else if (page === "create") {
            stackView.pushPage("CreatePlatformPage.qml")
        } else if (page === "status") {
            stackView.pushPage("BoardStatusPage.qml")
        } else if (page === "tmp") {
            stackView.pushPage("TmpPage.qml")
        } else if (page === "tmp2") {
            stackView.pushPage("Tmp2Page.qml")
        }
    }
}
