import QtQuick 2.10
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.3
import Qt.labs.settings 1.0

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0

import "qrc:/js/constants.js" as Constants
import "qrc:/js/navigation_control.js" as NavigationControl

RowLayout {
    id: row
    height: textSize.height * 2
    spacing: 0

    property string user_id: container.user_id
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

    Rectangle {
        id: providerBackground
        color: !providerMouseArea.containsMouse && !providerPopup.opened
               ? SGColorsJS.STRATA_GREEN : providerMouseArea.pressed && !providerPopup.opened
                 ? Qt.darker("#007a1f", 1.25) : "#007a1f"
        radius: 10
        Layout.preferredWidth: textSize.width + textSize.height
        Layout.fillWidth: true
        implicitHeight: parent.height

        Rectangle {
            // square off bottom
            visible: providerPopup.visible
            y: providerBackground.height / 2
            width: providerBackground.width
            height: providerBackground.height/2
            color: providerBackground.color
        }

        Rectangle {
            // square off right
            anchors {
                right: parent.right
            }
            width: providerBackground.width/2
            height: providerBackground.height
            color: providerBackground.color
        }

        SGText {
            id: providerText
            text: iconMouse.enabled && providerMouseArea.containsMouse || providerPopup.opened ? sgBaseRepeater.model.get(0).name : providerName
            color: "white"
            width: parent.width
            height: parent.height
            font.family: Fonts.franklinGothicBold
            elide: Text.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fontSizeMultiplier: 1
        }

        MouseArea {
            id: providerMouseArea
            anchors {
                fill: parent
            }
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked:  {
                !providerPopup.opened ?  providerPopup.popOpen() : providerPopup.popClose()
            }
        }

        Popup {
            id: providerPopup
            width: providerBackground.width
            height: providerItems.implicitHeight
            y: providerBackground.height
            closePolicy: Popup.CloseOnPressOutsideParent
            padding: 0
            clip: true

            contentItem: ColumnLayout {
                id: providerItems
                width: providerBackground.width
                spacing: 0

                Repeater {
                    id: sgBaseRepeater
                    model: ListModel {}
                    delegate: SGBaseDistributionItem {
                        id: sgBaseItem
                        text: qsTr(model.name)
                        Layout.preferredWidth: providerBackground.width
                        Layout.preferredHeight: Math.floor(providerBackground.height)
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

    Rectangle {
        id: iconBackground
        radius: 10
        color: !iconMouse.containsMouse
               ? SGColorsJS.STRATA_GREEN : iconMouse.pressed
                 ? Qt.darker("#007a1f", 1.25) : "#007a1f"
        implicitWidth: height
        implicitHeight: parent.height

        Rectangle {
            // square off left side
            width: parent.width/2
            height: parent.height
            color: parent.color
        }


        SGIcon {
            id: urlIcon
            source: 'qrc:/partial-views/distribution-portal/images/arrow-circle-right.svg'
            opacity: iconMouse.enabled ? 1 : 0.3
            iconColor: 'white'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            enabled: iconMouse.enabled
            anchors.fill: iconBackground
            anchors.margins: 5
        }

        MouseArea {
            id: iconMouse
            hoverEnabled: true
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(providerUrl)
            enabled: providerUrl !== ''
        }
    }

    Component.onCompleted: {
        // This is needed to create the model
        loadModel();
        if (NavigationControl.userSettings.selectedDistributionPortal !== 0) {
                const selectedDistributionPortal = NavigationControl.userSettings.selectedDistributionPortal;
                providerUrl = sgBaseRepeater.model.get(selectedDistributionPortal).url
                providerName = sgBaseRepeater.model.get(selectedDistributionPortal).name
                return
        }
        setIndex(0)
    }

    function setIndex(index) {
        providerUrl = sgBaseRepeater.model.get(index).url
        providerName = sgBaseRepeater.model.get(index).name
        NavigationControl.userSettings.selectedDistributionPortal = index
        NavigationControl.userSettings.saveSettings()
    }

    function loadModel(){
        providers.forEach(function (child){
            sgBaseRepeater.model.append(child)
        })
    }

    TextMetrics {
        id: textSize
        font.pixelSize: SGSettings.fontPixelSize
        font.family: Fonts.franklinGothicBold
        text: "Distribution Portal..."
    }
}
