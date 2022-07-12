/*
 * Copyright (c) 2018-2022 onsemi.
 *
 * All rights reserved. This software and/or documentation is licensed by onsemi under
 * limited terms and conditions. The terms and conditions pertaining to the software and/or
 * documentation are available at http://www.onsemi.com/site/pdf/ONSEMI_T&C.pdf (“onsemi Standard
 * Terms and Conditions of Sale, Section 8 Software”).
 */
import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQuick.Shapes 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.sgwidgets 2.0 as SGWidgets2
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item {
    id: root

    property bool isCurrentItem: false
    property string highlightPattern
    property bool matchName: false
    property bool matchDescription: false
    property bool matchOpn: false
    property bool matchPartList: false

    Rectangle {
        width: 50
        color: Theme.palette.onsemiLightBlue
        opacity: 1
        height: parent.height-1
        visible: model.connected
    }

    SGWidgets2.SGButton {
        id: dummyFilterButton
        buttonSize: SGWidgets2.SGButton.Tiny
        visible: false
        text: "dummy"
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.updateIndex()
        }
    }

    RowLayout {
        id: delegateRow
        anchors {
            fill: parent
            margins: 20
        }
        spacing: 20

        Item {
            implicitHeight: imageContainer.implicitHeight
            implicitWidth: imageContainer.implicitWidth

            Rectangle {
                color: model.connected ? Theme.palette.onsemiDark : Theme.palette.gray
                anchors {
                    centerIn: imageContainer
                }
                height: imageContainer.height + 2
                width: imageContainer.width + 2
            }

            PlatformImage {
                id: imageContainer
                text: model.program_controller ? "PROGRAMMING" : connectedText
                textBgColor: model.program_controller ? Theme.palette.onsemiOrange : connectedTextBg
            }
        }

        ColumnLayout {
            id: infoColumn
            spacing: 12
            Layout.maximumHeight: parent.height
            Layout.fillHeight: false
            // Layout width settings must match textFilterContainer in SGPlatformSelectorDelegate
            Layout.preferredWidth: 300

            Text {
                id: name
                text: {
                    if (matchName) {
                        return highlightPatternInText(model.verbose_name, highlightPattern)
                    }

                    return model.verbose_name
                }
                color: Theme.palette.onsemiDark
                font {
                    pixelSize: 16
                    family: Fonts.franklinGothicBold
                }
                Layout.fillWidth: true
                elide: Text.ElideRight
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                maximumLineCount: 2
            }

            Text {
                id: productId
                text: {
                    if (matchOpn) {
                        return highlightPatternInText(model.opn, highlightPattern)
                    }

                    return model.opn
                }

                Layout.fillWidth: true
                font {
                    pixelSize: 13
                    family: Fonts.franklinGothicBook
                }
                color: Theme.palette.onsemiDark
                font.italic: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                maximumLineCount: 1
            }

            Text {
                id: info

                text: {
                    if (model.program_controller_error_string) {
                        return "Programming of controller failed.\n" + model.program_controller_error_string
                    }

                    if (model.program_controller) {
                        return "Programming controller. Do not unplug device."
                    }

                    if (matchDescription) {
                        return highlightPatternInText(model.description, highlightPattern)
                    }

                    return model.description
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                font {
                    pixelSize: name.font.pixelSize
                    family: Fonts.franklinGothicBook
                }
                fontSizeMode: Text.Fit
                minimumPixelSize: 12
                lineHeight: 1.2
                color: model.program_controller_error_string ? Theme.palette.error : Qt.lighter(Theme.palette.onsemiDark, 1.1)
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
            }

            Text {
                id: parts
                text: {
                    if (matchedPartList.length) {
                        return "Matching Part OPNs: " + matchedPartList.join(", ")
                    }
                    return ""
                }
                visible: text.length
                Layout.fillWidth: true
                font {
                    pixelSize: 12
                    family: Fonts.franklinGothicBook
                }
                color: Qt.lighter(Theme.palette.onsemiDark, 1.1)
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight

                property var matchedPartList: {
                    var list = []
                    if (matchPartList && model.parts_list) {
                        for (let i = 0; i < model.parts_list.count; i++) {
                            var opn = model.parts_list.get(i).opn
                            var highlightedOpn  = highlightPatternInText(opn, highlightPattern);
                            if (opn !== highlightedOpn) {
                                list.push(highlightedOpn)
                            }
                        }
                    }

                    return list
                }
            }
        }

        RowLayout {
            id: categoryControlsRow
            // Layout settings must match segmentFilterContainer in SGPlatformSelectorListView
            Layout.preferredWidth: 200
            Layout.minimumWidth: 300

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Flickable {
                    id: flickable
                    height: maxRows * dummyFilterButton.height + (maxRows - 1) * flow.spacing
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        rightMargin: segmentCategoryScrollBar.width
                    }

                    clip: true
                    contentWidth: flow.width
                    contentHeight: flow.childrenRect.height
                    interactive: segmentCategoryScrollBar.visible
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds

                    property int maxRows: 5

                    ScrollBar.vertical: ScrollBar {
                        id: segmentCategoryScrollBar
                        parent: flickable.parent
                        anchors {
                            left: flickable.right
                            top: flickable.top
                            bottom: flickable.bottom
                        }

                        minimumSize: 0.1
                        policy: ScrollBar.AlwaysOn
                        visible: model.show_overflow_buttons && flickable.height < flickable.contentHeight
                    }

                    Flow {
                        id: flow
                        width: flickable.width
                        height: flickable.height

                        spacing: 3

                        Repeater {
                            id: segmentCategoryRepeater
                            model: segmentsCategories

                            delegate: SGWidgets2.SGButton {
                                id: tagButton
                                text: textMetrics.elidedText
                                buttonSize: SGWidgets2.SGButton.Tiny
                                isSecondary: true
                                font.bold: false
                                hintText: {
                                    if (model.type === "category") {
                                        return "Filter platforms in this category"
                                    } else {
                                        return "Filter platforms in this Segment"
                                    }
                                }

                                onClicked: {
                                    PlatformFilters.setFilterActive(model.filterId, true)
                                }

                                TextMetrics {
                                    id: textMetrics
                                    text: model.name
                                    font: tagButton.font
                                    elide: Qt.ElideRight
                                    elideWidth: flickable.width - tagButton.leftPadding - tagButton.rightPadding
                                }
                            }
                        }
                    }

                    SGSortFilterProxyModel {
                        id: segmentsCategories
                        sourceModel: filters
                        sortEnabled: true
                        sortRole: "type"
                    }
                }

                SGWidgets2.SGText {
                    id: remainingText
                    anchors {
                        top: flickable.bottom
                        topMargin: 1
                        horizontalCenter: parent.horizontalCenter
                    }

                    visible: flickable.height < flickable.contentHeight
                    text: model.show_overflow_buttons ? "Show less..." : "Show more..."
                    font.underline: moreFiltersMouse.containsMouse

                    MouseArea {
                        id: moreFiltersMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            model.show_overflow_buttons = !model.show_overflow_buttons
                            flickable.contentY = 0
                            root.updateIndex()
                        }
                    }
                }
            }

            ColumnLayout {
                id: platformControlsColumn
                Layout.fillWidth: false
                Layout.preferredWidth: 170

                property bool comingSoon: model.coming_soon

                Text {
                    id: comingSoonWarn
                    text: "This platform is coming soon!"
                    visible: platformControlsColumn.comingSoon
                    width: platformControlsColumn.width
                    Layout.fillWidth: true
                    font.pixelSize: 15
                    font.family: Fonts.franklinGothicBold
                    color: "#333"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                }

                ColumnLayout {
                    id: buttonColumn
                    Layout.fillHeight: false
                    visible: model.program_controller === false && platformControlsColumn.comingSoon === false

                    function openView(view) {
                        var sourceIndex = filteredPlatformSelectorModel.mapIndexToSource(model.index)
                        if (sourceIndex < 0) {
                            console.error(Logger.devStudioCategory, "Index out of scope.")
                            return
                        }
                        let data = {
                            "device_id": model.device_id,
                            "controller_class_id": model.controller_class_id,
                            "is_assisted": model.is_assisted,
                            "class_id": model.class_id,
                            "name": model.verbose_name,
                            "index": sourceIndex,
                            "available": model.available,
                            "firmware_version": model.firmware_version,
                            "view": view,
                            "connected": model.connected
                        }

                        PlatformSelection.openPlatformView(data)
                    }

                    Item {
                        Layout.fillWidth: true
                        implicitHeight: openControls.implicitHeight

                        SGWidgets2.SGButton {
                            id: openControls
                            width: parent.width

                            text: model.view_open ? "Return to Controls" : "Open Hardware Controls"
                            enabled: model.connected && model.available.control

                            onClicked: controlButtonClicked()

                            Accessible.role: Accessible.Button
                            Accessible.name: enabled ? "HwControlsEnabled" : "HwControlsDisabled"
                            Accessible.description: "'Hardware Controls' helper for automated GUI testing."
                            Accessible.onPressAction: controlButtonClicked()

                            function controlButtonClicked() {
                                root.updateIndex()
                                buttonColumn.openView("control")
                            }
                        }

                        //custom tooltip so it can be visible even when button itself is not enabled
                        MouseArea {
                            id: openControlsMouseArea
                            anchors.fill: parent
                            onPressed: openControlsMouseArea.accepted = false
                            enabled: openControls.enabled === false
                            hoverEnabled: true
                            cursorShape: openControls.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        }

                        ToolTip {
                            id: toolTip
                            visible: openControlsMouseArea.containsMouse && toolTip.text !== ""
                            delay: 500
                            text: {
                                if (model.connected && model.available.control === false) {
                                    return "No control software found"
                                }

                                return "Hardware not connected"
                            }
                        }
                    }

                    SGWidgets2.SGButton {
                        id: select
                        text: model.view_open ? "Return to Documentation" : "Browse Documentation"
                        enabled: model.available.documents
                        hintText: enabled ? "" : "No documentation found"

                        onClicked: {
                            root.updateIndex()
                            buttonColumn.openView("collateral")
                        }
                    }

                    SGWidgets2.SGButton {
                        id: order
                        text: "Contact Sales"
                        enabled: model.available.order
                        Layout.fillWidth: true

                        onClicked: {
                            root.updateIndex()
                            Qt.openUrlExternally(sdsModel.urls.salesPopupUrl)
                        }
                    }
                }
            }

            SGCircularProgress {
                id: circularProgress
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                Layout.alignment: Qt.AlignCenter

                visible: model.program_controller
                value: model.program_controller_progress
                highlightColor: Theme.palette.onsemiOrange
            }
        }
    }

    Rectangle {
        id: bottomDivider
        color: Theme.palette.lightGray
        height: 1
        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }
        width: parent.width
    }

    function updateIndex() {
        PlatformSelection.platformSelectorModel.currentIndex = index
    }

    function highlightPatternInText(text, pattern) {
        if (!text) {
            return ""
        }

        var pos = text.toLowerCase().indexOf(pattern)
        if (pos >= 0) {
            var txt = text
            return txt.substring(0, pos)
                    + `<font color="${Theme.palette.onsemiOrange}">`
                    + txt.substring(pos, pos + pattern.length)
                    + "</font>"
                    + txt.substring(pos + pattern.length);
        }

        return text
    }
}
