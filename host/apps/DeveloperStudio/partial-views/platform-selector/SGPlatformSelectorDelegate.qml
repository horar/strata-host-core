import QtQuick 2.9
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQuick.Shapes 1.0

import "qrc:/js/platform_selection.js" as PlatformSelection
import "qrc:/js/platform_filters.js" as PlatformFilters

import tech.strata.fonts 1.0
import tech.strata.sgwidgets 1.0
import tech.strata.logger 1.0
import tech.strata.commoncpp 1.0
import tech.strata.theme 1.0

Item {
    id: root

    property bool isCurrentItem: false
    property real filterAndControlWidth: segmentCategoryList.width + delegateRow.spacing + platformControlsColumn.width + delegateRow.anchors.margins + (listview.ScrollBar.vertical.width + 2)

    onFilterAndControlWidthChanged: {
        // align "Filter by Segment or Category" box to edge of segment/category column in delegates
       Qt.callLater(platformSelectorListView.setSegmentCategoryWidth, filterAndControlWidth)
    }

    Rectangle {
        width: 50
        color: "#29e335"//Theme.palette.green
        opacity: 1
        height: parent.height-1
        visible: model.connected
    }

    MouseArea {
        anchors {
            fill: parent
        }
        onClicked: {
            PlatformSelection.platformSelectorModel.currentIndex = index
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
                color: model.connected ? Theme.palette.darkGray : Theme.palette.gray
                anchors {
                    centerIn: imageContainer
                }
                height: imageContainer.height + 2
                width: imageContainer.width + 2
            }

            PlatformImage {
                id: imageContainer
            }
        }

        ColumnLayout {
            id: infoColumn
            spacing: 12
            Layout.maximumHeight: parent.height
            Layout.fillHeight: false
            Layout.preferredWidth: 300

            Text {
                id: name
                text: {
                    if (searchCategoryText.checked === false || model.name_matching_index === -1) {
                        return model.verbose_name
                    } else {
                        let txt = model.verbose_name
                        let idx = model.name_matching_index
                        return txt.substring(0, idx) + "<font color=\"green\">" + txt.substring(idx, idx + PlatformFilters.keywordFilter.length) + "</font>" + txt.substring(idx + PlatformFilters.keywordFilter.length);
                    }
                }

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
                    if (searchCategoryText.checked === false || model.opn_matching_index === -1) {
                        return model.opn
                    } else {
                        let txt = model.opn
                        let idx = model.opn_matching_index
                        return txt.substring(0, idx) + "<font color=\"green\">" + txt.substring(idx, idx + PlatformFilters.keywordFilter.length) + "</font>" + txt.substring(idx + PlatformFilters.keywordFilter.length);
                    }
                }

                Layout.fillWidth: true
                font {
                    pixelSize: 13
                    family: Fonts.franklinGothicBook
                }
                color: "#333"
                font.italic: true
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                maximumLineCount: 1
            }

            Text {
                id: info
                text: {
                    if (searchCategoryText.checked === false || model.desc_matching_index === -1) {
                        return model.description
                    } else {
                        let txt = model.description
                        let idx = model.desc_matching_index
                        return txt.substring(0, idx) + "<font color=\"green\">" + txt.substring(idx, idx + PlatformFilters.keywordFilter.length) + "</font>" + txt.substring(idx + PlatformFilters.keywordFilter.length);
                    }
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
                color: "#666"
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
            }

            Text {
                id: parts
                text: {
                    if (searchCategoryPartsList.checked === true) {
                        let str = "Matching Part OPNs: ";
                        if (model.parts_list !== undefined) {
                            for (let i = 0; i < model.parts_list.count; i++) {
                                if (model.parts_list.get(i).matchingIndex > -1) {
                                    let idx = model.parts_list.get(i).matchingIndex
                                    let part = model.parts_list.get(i).opn
                                    if (str !== "Matching Part OPNs: ") {
                                        str += ", "
                                    }
                                    str += part.substring(0, idx) + "<font color=\"green\">" + part.substring(idx, PlatformFilters.keywordFilter.length + idx) + "</font>" + part.substring(idx + PlatformFilters.keywordFilter.length)
                                } else {
                                    continue
                                }
                            }
                        }
                        return str
                    } else {
                        return ""
                    }
                }
                visible: searchCategoryPartsList.checked === true && PlatformFilters.keywordFilter !== "" && text !== "Matching Part OPNs: "
                Layout.fillWidth: true
                font {
                    pixelSize: 12
                    family: Fonts.franklinGothicBook
                }
                color: "#666"
                textFormat: Text.StyledText
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            id: segmentCategoryList
            Layout.preferredWidth: 150
            Layout.minimumWidth: 100

            property real delegateHeight: 35

            Flow {
                id: flow
                Layout.fillWidth: true
                spacing: 2

                property int rows: Math.ceil(implicitHeight/(segmentCategoryList.delegateHeight + spacing))
                property int maxRows: 2

                onRowsChanged: {
                    if (rows < maxRows) {
                        reset()
                    }
                }

                function reset () {
                    for (let i = 0; i < filters.count; i++) {
                        filters.get(i).row = -1
                    }
                }

                Repeater {
                    id: segmentCategoryRepeater
                    model: visibleButtons
                    delegate: iconDelegate
                }
            }

            SGSortFilterProxyModel {
                id: segmentsCategories
                sourceModel: filters
                sortEnabled: true
                sortRole: "type"
            }

            SGSortFilterProxyModel {
                id: visibleButtons
                sourceModel: segmentsCategories
                invokeCustomFilter: true

                function filterAcceptsRow (index) {
                    var listing = sourceModel.get(index)
                    return listing.row < flow.maxRows
                }
            }

            SGSortFilterProxyModel {
                id: remainingButtons
                sourceModel: segmentsCategories
                invokeCustomFilter: true

                function filterAcceptsRow (index) {
                    var listing = sourceModel.get(index)
                    return listing.row >= flow.maxRows
                }
            }

            SGText {
                id: remainingText
                visible: remainingButtons.count > 0
                text: "And " + remainingButtons.count + " more..."
                Layout.leftMargin: 30 // width of icon + rowLayout's spacing in iconDelegate
                font.underline: moreFiltersMouse.containsMouse

                MouseArea {
                    id: moreFiltersMouse
                    anchors {
                        fill: parent
                    }
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked:  {
                        filterOverFlow.open()
                    }
                }

                Popup {
                    id: filterOverFlow
                    padding: 0
                    x: -remainingText.Layout.leftMargin
                    width: segmentCategoryList.width
                    background: Rectangle {
                        color: isCurrentItem ? "#eee" : "white"
                    }

                    ColumnLayout {
                        width: parent.width

                        Repeater {
                            id: overflowRepeater
                            model: remainingButtons
                            delegate: iconDelegate
                        }
                    }
                }
            }

            Component {
                id: iconDelegate

                PlatformFilterButton { }
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
                visible: platformControlsColumn.comingSoon === false

                function openView(view) {
                    let data = {
                        "device_id": model.device_id,
                        "class_id": model.class_id,
                        "name": model.verbose_name,
                        "index": filteredPlatformSelectorModel.mapIndexToSource(model.index),
                        "available": model.available,
                        "firmware_version": model.firmware_version,
                        "view": view,
                        "connected": model.connected
                    }

                    PlatformSelection.openPlatformView(data)
                }

                PlatformControlButton {
                    id: openControls
                    text: model.view_open ? "Return to Controls" : "Open Hardware Controls"
                    buttonEnabled: model.connected
                    toolTipText: buttonEnabled ? "" : "Hardware not connected"

                    onClicked: {
                        buttonColumn.openView("control")
                    }
                }

                PlatformControlButton {
                    id: select
                    text: model.view_open ? "Return to Documentation" : "Browse Documentation"
                    buttonEnabled: model.available.documents
                    toolTipText: buttonEnabled ? "" : "No documentation found"

                    onClicked: {
                        buttonColumn.openView("collateral")
                    }
                }

                PlatformControlButton {
                    id: order
                    text: "Contact Sales"
                    buttonEnabled: model.available.order

                    onClicked: {
                        orderPopup.open()
                    }
                }
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
}
