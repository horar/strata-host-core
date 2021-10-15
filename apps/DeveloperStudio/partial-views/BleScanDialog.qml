import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp
import tech.strata.logger 1.0

SGStrataPopup {
    id: dialog
    x: parent.width/2 - dialog.width/2
    y: parent.height/2 - dialog.height/2

    headerText: "Bluetooth Low Energy Devices"
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    property int innerSpacing: 6
    property bool bleSupported: sdsModel.bleDeviceModel.bleSupported()

    CommonCpp.SGSortFilterProxyModel {
        id: deviceSortFilterModel
        sourceModel: sdsModel.bleDeviceModel
        filterPattern: filterInput.text
        filterPatternSyntax: CommonCpp.SGSortFilterProxyModel.Wildcard
        caseSensitive: false
        invokeCustomLessThan: true
        invokeCustomFilter: true

        function lessThan(leftRow, rightRow) {
            var leftItem = sourceModel.get(leftRow)
            var rightItem = sourceModel.get(rightRow)

            if (leftItem.isStrata === rightItem.isStrata) {
                if (leftItem.name === rightItem.name) {
                    return leftItem.address < rightItem.address
                } else if (leftItem.name.length === 0) {
                    return false
                } else if (rightItem.name.length === 0) {
                    return true
                } else {
                    return naturalCompare(leftItem.name, rightItem.name) < 0
                }
            } else {
                return leftItem.isStrata > rightItem.isStrata
            }
        }

        function filterAcceptsRow(row) {
            var item = sourceModel.get(row)

            if (matches(item.name) || matches(item.address) ) {
                return true
            }

            return false
        }
    }

    Item {
        implicitWidth: 500
        implicitHeight: 600

        SGWidgets.SGTextField {
            id: filterInput
            enabled: bleSupported
            anchors {
                top: parent.top
                left: parent.left
                right: scanButton.left
                rightMargin: dialog.innerSpacing
            }

            showClearButton: true
            leftIconSource: "qrc:/sgimages/funnel.svg"
            placeholderText: "Filter..."
        }

        Button {
            id: scanButton
            height: filterInput.height
            width: height
            anchors {
                top: filterInput.top
                right: parent.right
            }

            icon.source: "qrc:/sgimages/sync.svg"
            icon.color: "white"
            enabled: bleSupported && sdsModel.bleDeviceModel.inScanMode === false
            focusPolicy: Qt.NoFocus
            opacity: enabled ? 1.0 : 0.7

            background: Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                color: scanButton.pressed ? Theme.palette.gray : Theme.palette.darkGray
            }

            onClicked: {
                sdsModel.bleDeviceModel.startScan()
            }

            MouseArea {
                anchors.fill: parent
                onPressed: mouse.accepted = false
                hoverEnabled: true
                cursorShape: scanButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            }

            ToolTip {
                visible: scanButton.hovered
                delay: 500
                timeout: 4000
                text: "Scan for available bluetooth devices"
            }
        }

        Rectangle {
            anchors {
                top: filterInput.bottom
                topMargin: dialog.innerSpacing
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            color: "white"
        }

        ListView {
            id: deviceView
            anchors {
                top: filterInput.bottom
                topMargin: dialog.innerSpacing
                bottom: parent.bottom
                left: parent.left

                right: parent.right
                rightMargin: verticalScrollback.visible ? verticalScrollback.width : 0
            }

            clip: true
            boundsBehavior: Flickable.StopAtBounds
            enabled: sdsModel.bleDeviceModel.inScanMode === false
            opacity: enabled ? 1 : 0.5
            model: deviceSortFilterModel

            ScrollBar.vertical: ScrollBar {
                id: verticalScrollback
                width: 12
                anchors {
                    top: deviceView.top
                    bottom: deviceView.bottom
                    left: deviceView.right
                }

                parent: deviceView.parent
                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
                visible: deviceView.height < deviceView.contentHeight
            }

            delegate: Item {
                id: delegate
                width: deviceView.width
                height: divider.y + divider.height

                property int innerSpacing: 2
                property int verticalOuterSpacing: 6
                property int horizontalOuterSpacing: 12

                Rectangle {
                    anchors {
                        top: parent.top
                        bottom: divider.top
                        left: parent.left
                        right: parent.right
                    }

                    color: {
                        if (delegateMouseArea.containsMouse || connectButton.hovered) {
                            return "#eeeeee"
                        }

                        return "transparent"
                    }
                }

                SGWidgets.SGText {
                    id: nameText
                    anchors {
                        top: parent.top
                        topMargin: delegate.verticalOuterSpacing
                        left: parent.left
                        leftMargin: delegate.horizontalOuterSpacing
                        right: connectButton.visible ? connectButton.left : parent.right
                        rightMargin: connectButton.visible ? delegate.innerSpacing : 2*delegate.horizontalOuterSpacing
                    }

                    property bool nameAvailable: model.name.length

                    text: nameAvailable ? model.name : "N/A"
                    opacity: nameAvailable ? 1 : 0.5
                    fontSizeMultiplier: 1.5
                    elide: Text.ElideRight
                    font.bold: true
                }

                SGWidgets.SGText {
                    id: statusText
                    anchors {
                        top: nameText.bottom
                        topMargin: delegate.innerSpacing
                        left: nameText.left
                        right: connectButton.visible ? connectButton.left : parent.right
                        rightMargin: connectButton.visible ? delegate.innerSpacing : delegate.horizontalOuterSpacing
                    }

                    text: model.address
                    opacity: 0.9
                    elide: Text.ElideRight
                }

                SGWidgets.SGTag {
                    id: rssiTag
                    anchors {
                        left: nameText.left
                        top: statusText.bottom
                        topMargin: delegate.innerSpacing
                    }

                    text: model.rssi + " dBm"
                    iconSource: "qrc:/sgimages/signal.svg"
                    color: Theme.palette.lightGray
                }
                SGWidgets.SGTag {
                    id: isStrataTag
                    anchors {
                        left: rssiTag.right
                        leftMargin: 2*delegate.innerSpacing
                        top: statusText.bottom
                        topMargin: delegate.innerSpacing
                    }

                    text: "STRATA COMPATIBLE"
                    visible: model.isStrata
                    color: Theme.palette.lightGray
                }

                SGWidgets.SGTag {
                    id: isConnectedTag
                    anchors {
                        left: isStrataTag.right
                        leftMargin: 2*delegate.innerSpacing
                        top: statusText.bottom
                        topMargin: delegate.innerSpacing
                    }

                    states: [
                        State {
                            id: connectingState
                            when: model.isConnected === false && model.connectionInProgress
                            PropertyChanges {
                                target: isConnectedTag
                                text: "Connecting..."
                                textColor: "black"
                                color: "transparent"
                            }
                        },
                        State {
                            id: disconnectingState
                            when: model.isConnected && model.connectionInProgress
                            PropertyChanges {
                                target: isConnectedTag
                                text: "Disconnecting..."
                                textColor: "black"
                                color: "transparent"
                            }
                        },
                        State {
                            id: connectedState
                            when: model.isConnected && model.connectionInProgress === false
                            PropertyChanges {
                                target: isConnectedTag
                                text: "CONNECTED"
                                textColor: "white"
                                color: Theme.palette.green
                                font.bold: true
                            }
                        }
                    ]
                }

                SGWidgets.SGText {
                    id: connectErrorText
                    anchors {
                        top: rssiTag.bottom
                        topMargin: delegate.innerSpacing
                        left: nameText.left
                        right: connectButton.visible ? connectButton.left : parent.right
                        rightMargin: connectButton.visible ? delegate.innerSpacing : delegate.horizontalOuterSpacing
                    }

                    visible: text !== ""
                    text: model.errorString
                    color: Theme.palette.red
                    elide: Text.ElideRight
                }

                Rectangle {
                    id: divider
                    width: parent.width
                    height: 1
                    anchors {
                        top: connectErrorText.visible ? connectErrorText.bottom : rssiTag.bottom
                        topMargin: delegate.verticalOuterSpacing
                    }

                    color: Theme.palette.lightGray
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                Button {
                    id: connectButton
                    anchors {
                        top: parent.top
                        topMargin: delegate.verticalOuterSpacing
                        right: parent.right
                        rightMargin: delegate.horizontalOuterSpacing
                    }

                    visible: delegateMouseArea.containsMouse || hovered
                    opacity: enabled ? 1.0 : 0.7
                    focusPolicy: Qt.NoFocus
                    enabled: model.connectionInProgress === false

                    background: Rectangle {
                        implicitWidth: 100
                        implicitHeight: 40
                        color: connectButton.pressed ? Theme.palette.gray : Theme.palette.darkGray
                    }

                    contentItem: SGWidgets.SGText {
                        text: model.isConnected ? "Disconnect" : "Connect"
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var sourceIndex = deviceSortFilterModel.mapIndexToSource(model.index)
                        if (sourceIndex < 0) {
                            return
                        }

                        if (isConnected) {
                            sdsModel.bleDeviceModel.tryDisconnect(sourceIndex)
                        } else {
                            sdsModel.bleDeviceModel.tryConnect(sourceIndex)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: mouse.accepted = false
                        hoverEnabled: true
                        cursorShape: connectButton.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    }

                    ToolTip {
                        visible: connectButton.hovered
                        delay: 500
                        timeout: 4000

                        text: model.isConnected ? "Disconnect device" : "Connect device"
                    }
                }
            }
        }

        Item {
            id: busyOverlay
            anchors.fill: deviceView

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.1
                visible: deviceView.enabled === false
            }

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                width: 80
                height: width
                visible: deviceView.enabled === false
            }

            SGWidgets.SGText {
                anchors {
                    top: busyIndicator.bottom
                    horizontalCenter: busyIndicator.horizontalCenter
                }

                text: "Scanning..."
                font.italic: true
                visible: busyIndicator.visible
                fontSizeMultiplier: 1.3
            }
        }

        SGWidgets.SGText {
            id: errorText
            anchors.fill: deviceView

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: {
                if (bleSupported === false) {
                    return "Bluetooth Low Energy is not supported on this operating system"
                }

                if (sdsModel.bleDeviceModel.lastScanError.length) {
                    return sdsModel.bleDeviceModel.lastScanError
                }

                if (deviceSortFilterModel.count === 0
                        && sdsModel.bleDeviceModel.inScanMode === false) {
                    return "Please scan for available devices"
                }

                return ""
            }
            wrapMode: Text.WordWrap
            fontSizeMultiplier: 1.4
            font.italic: true
        }
    }
}
