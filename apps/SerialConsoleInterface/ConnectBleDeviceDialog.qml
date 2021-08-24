import QtQuick 2.12
import QtQuick.Controls 2.12
import tech.strata.sgwidgets 1.0 as SGWidgets
import tech.strata.theme 1.0
import tech.strata.commoncpp 1.0 as CommonCpp

SGWidgets.SGDialog {
    id: dialog

    title: "Connect Bluetooth Low Energy Device"
    headerIcon: "qrc:/sgimages/bluetooth.svg"
    modal: true

    property int innerSpacing: 6
    property alias errorString: errorText.text
    property bool bleSupported: sciModel.bleDeviceModel.bleSupported()

    CommonCpp.SGSortFilterProxyModel {
        id: deviceSortFilterModel
        sourceModel: sciModel.bleDeviceModel
        filterPattern: filterInput.text
        filterPatternSyntax: CommonCpp.SGSortFilterProxyModel.Wildcard
        caseSensitive: false
        invokeCustomLessThan: true
        invokeCustomFilter: true

        function lessThan(leftRow, rightRow) {
            var leftItem = sourceModel.get(leftRow)
            var rightItem = sourceModel.get(rightRow)

            //empty name goes at the end

            if (leftItem.name.length === 0 && rightItem.name.length > 0) {
                return false
            }

            if (leftItem.name.length > 0 && rightItem.name.length === 0) {
                return true
            }

            if (leftItem.name !== rightItem.name) {
                return naturalCompare(leftItem.name, rightItem.name) < 0
            }

            return naturalCompare(leftItem.address, rightItem.address) < 0
        }

        function filterAcceptsRow(row) {
            var item = sourceModel.get(row)

            if (matches(item.name) || matches(item.address) ) {
                return true
            }

            return false
        }
    }

    Connections {
        target: sciModel.bleDeviceModel
        onDiscoveryFinished: {
            dialog.errorString = errorString
        }

        onInDiscoveryModeChanged: {
            if (sciModel.bleDeviceModel.inDiscoveryMode) {
                dialog.errorString = ""
            }
        }
    }

    Item {
        implicitWidth: Math.max(implicitHeaderWidth, 400)
        implicitHeight: 400

        Rectangle {
            anchors.fill: deviceView
            color: "white"
        }

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

        SGWidgets.SGButton {
            id: scanButton
            anchors {
                top: filterInput.top
                right: parent.right
            }

            hintText: "Refresh list of devices"
            scaleToFit: true
            icon.source: "qrc:/sgimages/sync.svg"
            enabled: bleSupported && sciModel.bleDeviceModel.inDiscoveryMode === false

            minimumContentHeight: filterInput.height - 2*padding
            minimumContentWidth: minimumContentHeight
            onClicked: {
                sciModel.bleDeviceModel.startDiscovery()
            }
        }

        ListView {
            id: deviceView
            anchors {
                top: filterInput.bottom
                topMargin: dialog.innerSpacing
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            clip: true
            focus: true
            boundsBehavior: Flickable.StopAtBounds
            enabled: sciModel.bleDeviceModel.inDiscoveryMode === false
            opacity: enabled ? 1 : 0.5

            model: deviceSortFilterModel

            highlightMoveDuration: 100

            ScrollBar.vertical: ScrollBar {
                anchors {
                    right: deviceView.right
                    rightMargin: 0
                }
                width: 8

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
                        if (delegate.ListView.isCurrentItem) {
                            return TangoTheme.palette.highlight
                        } else if (delegateMouseArea.containsMouse || connectButton.hovered) {
                            return Qt.lighter(TangoTheme.palette.highlight, 1.9)
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

                    text: model.name
                    fontSizeMultiplier: 1.5
                    alternativeColorEnabled: delegate.ListView.isCurrentItem
                    elide: Text.ElideRight
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
                    alternativeColorEnabled: nameText.alternativeColorEnabled
                    elide: Text.ElideRight
                }

                Item {
                    id: divider
                    height: 1
                    width: parent.width
                    anchors {
                        top: statusText.bottom
                        topMargin: delegate.verticalOuterSpacing
                    }

                    Rectangle {
                        width: parent.width - 2*delegate.horizontalOuterSpacing
                        height: parent.height
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                        }

                        color: "black"
                        opacity: 0.1
                    }
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        deviceView.currentIndex = index
                        deviceView.forceActiveFocus()
                    }
                }

                SGWidgets.SGIconButton {
                    id: connectButton
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: delegate.horizontalOuterSpacing
                    }

                    hintText: "Try connect"
                    iconSize: Math.floor(0.6*parent.height)
                    icon.source: "qrc:/sgimages/link.svg"
                    visible: delegate.ListView.isCurrentItem || delegateMouseArea.containsMouse || hovered
                    onClicked: {
                        var sourceIndex = deviceSortFilterModel.mapIndexToSource(index)
                        if (sourceIndex < 0) {
                            return
                        }

                        sciModel.bleDeviceModel.tryConnectDevice(sourceIndex)
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
                anchors.centerIn: parent
                width: 80
                height: width
                running: deviceView.enabled === false
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
                } else {
                    return "Please scan for available devices"
                }
            }
            wrapMode: Text.WordWrap
            fontSizeMultiplier: 1.4
            font.italic: true
        }
    }

    footer: Item {
        implicitHeight: buttonRow.height + 10

        Row {
            id: buttonRow
            anchors.centerIn: parent
            spacing: 16

            SGWidgets.SGButton {
                text: "Close"
                onClicked: dialog.accept()
            }
        }
    }
}
