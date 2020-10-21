import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Qt.labs.settings 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/constants.js" as Constants
Row {
    id: row
    height: textSize.height * 2
    anchors {
        right: parent.right
        top: parent.top
        margins: 40
    }

    property string user_id: parent.user_id
    property string providerUrl: ''
    property string providerName: ''
    readonly property var providers: [
        {
            name: "Distribution Portal...",
            url: '',
            visible: false
        },
        {
            name: "Avnet",
            url: Constants.AVNET_URL,
            visible: true
        },
        {
            name: "Digi-Key",
            url: Constants.DIGIKEY_URL,
            visible: true
        },
        {
            name: "Mouser",
            url: Constants.MOUSER_URL,
            visible: true
        }
    ]

    Button {
        id: providerButton
        width: textSize.width + textSize.height
        height: parent.height
        hoverEnabled: true

        background: Rectangle {
            id: providerBackground
            color: !providerButton.hovered && !providerPopup.opened
                   ? SGColorsJS.STRATA_GREEN : providerMouseArea.pressed && !providerPopup.opened
                     ? Qt.darker("#007a1f", 1.25) : "#007a1f"
            radius: 10


            Rectangle {
                // square off bottom
                visible: providerPopup.visible
                y: providerButton.height / 2
                width: providerButton.width
                height: providerButton.height/2
                color: providerBackground.color
            }

            Rectangle {
                // square off right
                anchors {
                    right: parent.right
                }
                width: providerButton.width/2
                height: providerButton.height
                color: providerBackground.color
            }
        }

        SGText {
            id: providerText
            text: urlIconButton.enabled && providerButton.hovered || providerPopup.opened ? sgBaseRepeater.model.get(0).name : providerName
            color: "white"
            width: parent.width
            height: parent.height
            font {
                family: Fonts.franklinGothicBold
            }
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fontSizeMultiplier: 1.25
        }

        MouseArea {
            id: providerMouseArea
            hoverEnabled: true
            anchors {
                fill: parent
            }
            cursorShape: Qt.PointingHandCursor
            onClicked: !providerPopup.opened ?  providerPopup.popOpen() : providerPopup.popClose()
        }

        Popup {
            id: providerPopup
            width: providerButton.width
            height: providerItems.implicitHeight
            y: providerBackground.height
            closePolicy: Popup.CloseOnPressOutsideParent
            padding: 0
            clip: true

            contentItem: ColumnLayout {
                id: providerItems
                width: providerButton.width
                spacing: 0

                Repeater {
                    id: sgBaseRepeater
                    model: ListModel {}
                    delegate: SGBaseDistributionItem {
                        id: sgBaseItem
                        text: qsTr(model.name)
                        Layout.preferredWidth: providerButton.width
                        Layout.preferredHeight: Math.floor(providerButton.height)
                        visible: model.visible

                        onClicked: {
                            row.setIndex(model.index)
                            providerPopup.popClose()
                        }
                    }
                }
            }

            function popOpen() {
                providerPopup.open()
            }

            function popClose() {
                providerPopup.close()
            }
        }
    }

    Button {
        id: urlIconButton
        enabled: providerUrl !== ''
        width: height
        height: parent.height
        onClicked: Qt.openUrlExternally(providerUrl)

        background: Rectangle {
            id: iconBackground
            radius: 10
            color: !urlIconButton.hovered
                   ? SGColorsJS.STRATA_GREEN : iconMouse.pressed
                     ? Qt.darker("#007a1f", 1.25) : "#007a1f"

            Rectangle {
                // square off left side
                width: parent.width/2
                height: parent.height
                color: parent.color
            }
        }

        SGIcon {
            id: urlIcon
            source: 'qrc:/partial-views/distribution-portal/images/arrow-circle-right.svg'
            opacity: urlIconButton.enabled ? 1 : 0.3
            iconColor: 'white'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            enabled: urlIconButton.enabled
            anchors.fill: urlIconButton
            anchors.margins: 5
        }

        MouseArea {
            id: iconMouse
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(providerUrl)
        }
    }

    Settings {
        id: providerSettings
        category: "Distributor"
        property string jsonString: ''
    }

    Component.onCompleted: {
        // This is needed to create the model
        loadModel();
        if (providerSettings.jsonString !== "") {
            const userSettings = JSON.parse(providerSettings.jsonString)
            if (userSettings.hasOwnProperty(user_id)) {
                const savedIndex = userSettings[user_id]
                const index = savedIndex["index"]
                providerUrl = sgBaseRepeater.model.get(index).url
                providerName = sgBaseRepeater.model.get(index).name
                return
            }
        }
        setIndex(0)
    }

    function setIndex(index) {
        providerUrl = sgBaseRepeater.model.get(index).url
        providerName = sgBaseRepeater.model.get(index).name
        const savedIndex = {}
        savedIndex["index"] = index

        let savedSettings
        if (providerSettings.jsonString !== "") {
            savedSettings = JSON.parse(providerSettings.jsonString)
        } else {
            savedSettings = {}
        }

        savedSettings[user_id] = savedIndex
        providerSettings.jsonString = JSON.stringify(savedSettings)
    }

    function loadModel(){
        providers.forEach(function (child){
            sgBaseRepeater.model.append(child)
        })
    }

    TextMetrics {
        id: textSize
        font.pixelSize: SGSettings.fontPixelSize * 1.25
        font.family: Fonts.franklinGothicBold
        text: "Distribution Portal..."
    }
}
