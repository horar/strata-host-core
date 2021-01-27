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

    Rectangle {
        width: 50
        color: "#29e335"//Theme.palette.green
        opacity: 1
        height: parent.height-1
        visible: model.connected
    }

    MouseArea{
        anchors{
            fill: parent
        }
        onClicked: {
            PlatformSelection.platformSelectorModel.currentIndex = index
        }
    }

    DropShadow {
        id: dropShadow
        anchors {
            centerIn: imageContainer
        }
        width: imageContainer.width
        height: imageContainer.height
        horizontalOffset: 1
        verticalOffset: 3
        radius: 15.0
        samples: radius*2
        color: "#cc000000"
        source: imageContainer
//        z: -1
        cached: true
    }

    PlatformImage {
        id: imageContainer
        anchors {
            verticalCenter: root.verticalCenter
            left: root.left
            leftMargin: 25
        }

        text: model.adjust_controller ? "ADJUSTING" : defaultText
        textBgColor: model.adjust_controller ? Theme.palette.orange : defaultTextBg
    }

    ColumnLayout {
        id: infoColumn
        anchors {
            left: imageContainer.right
            leftMargin: 20
            verticalCenter: parent.verticalCenter
        }
        height: parent.height - 40 // 20 each top/bottom margin
        width: 350

        ColumnLayout {
            spacing: 12
            Layout.maximumHeight: parent.height
            Layout.fillHeight: false

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
                    pixelSize: 12
                    family: Fonts.franklinGothicBook
                }
                color: "#666"
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                textFormat: Text.StyledText
                visible: model.adjust_controller === false
            }

            Text {
                id: statusText
                text: {
                    if (model.adjust_controller_error_string) {
                        return "Adjustment of controller failed.\n" + model.adjust_controller_error_string
                    }

                    "Controller is being adjusted. Do not unplug device."
                }
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: model.adjust_controller
                font {
                    pixelSize: 14
                    family: Fonts.franklinGothicBook
                }
                wrapMode: Text.WordWrap
                color: model.adjust_controller_error_string ? Theme.palette.error : "#333"
                horizontalAlignment: Text.AlignHCenter
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
    }

    Item {
        id: iconContainer
        anchors {
            verticalCenter: root.verticalCenter
            left: infoColumn.right
            leftMargin: 30
            right: buttonColumn.left
            rightMargin: 30
        }
        height: root.height
        width: 240

        PathView  {
            id: iconPathview
            anchors {
                fill: iconContainer
            }
            clip: true
            model: SGSortFilterProxyModel {
                id: filterProxyListModel
                sourceModel: filters
                invokeCustomFilter: true

                function filterAcceptsRow(row) {
                    var item = sourceModel.get(row)
                    return is_segment_filter(item)
                }

                function is_segment_filter (item){
                    return item.filterName.startsWith("segment-")
                }
            }
            pathItemCount: 3
            interactive: false
            preferredHighlightBegin: .5
            preferredHighlightEnd: .5
            property real delegateHeight: 75
            property real delegateWidth: 75
            delegate: Item {
                id: delegate
                z: PathView.delZ ? PathView.delZ : 0 // if/then due to random bug that assigns undefined occassionally
                height: icon.height + iconText.height + iconText.anchors.topMargin
                width: icon.width
                scale: PathView.delScale ? PathView.delScale : 0.5 // if/then due to random bug that assigns undefined occassionally

                Rectangle {
                    height: icon.height
                    width: icon.width
                    anchors {
                        centerIn: icon
                    }
                    radius: height/2
                    color: Theme.palette.green
                    opacity: delegate.PathView.delOpacity ? delegate.PathView.delOpacity : 0.7 // if/then due to random bug that assigns undefined occassionally
                }

                Image {
                    id: icon
                    height: iconPathview.delegateHeight
                    width: iconPathview.delegateWidth
                    mipmap: true
                    source: model.iconSource ? model.iconSource : ""
                }

                SGText {
                    id: iconText
                    text: model.text ? model.text : ""
                    anchors {
                        top: icon.bottom
                        topMargin: 5
                        horizontalCenter: delegate.horizontalCenter
                    }
                    horizontalAlignment: Text.AlignHCenter
                    font {
                        pixelSize: 12
                        family: Fonts.franklinGothicBook
                    }
                    color: "#333"
                }
            }

            path: model.count > 1 ? pathIcon : pathIconSingle

            Path {
                id: pathIcon

                startX: iconPathview.width/2;
                startY: 45

                PathAttribute { name: "delScale"; value: 0.6 }
                PathAttribute { name: "delOpacity"; value: 0.75 }
                PathAttribute { name: "delZ"; value: 0 }
                PathQuad { x: iconPathview.width/2; y: 95; controlX: -20; controlY: 70 }
                PathAttribute { name: "delScale"; value: 1.0 }
                PathAttribute { name: "delOpacity"; value: 1.0 }
                PathAttribute { name: "delZ"; value: 1 }
                PathQuad { x: pathIcon.startX; y: pathIcon.startY; controlX: iconPathview.width+20; controlY: 70 }
            }

            Path {
                id: pathIconSingle

                startX: iconPathview.width/2;
                startY: 80

                PathAttribute { name: "delScale"; value: 1.1 }
                PathAttribute { name: "delOpacity"; value: 1.0 }
                PathAttribute { name: "delZ"; value: 1 }
                PathLine { x: pathIconSingle.startX; y: pathIconSingle.startY+1 }
            }

            highlightMoveDuration: 200

            Timer {
                running: root.isCurrentItem
                interval: 1500
                onTriggered: {
                    iconPathview.decrementCurrentIndex()
                }
                repeat: true
            }
        }
    }

    Column {
        id: buttonColumn
        spacing: 20
        anchors {
            verticalCenter: root.verticalCenter
            right: root.right
            rightMargin: 25
        }
        width: 170

        Text {
            id: comingSoonWarn
            text: "This platform is coming soon!"
            visible: !model.available.documents && !model.available.order && !model.error && (!model.connected || !model.available.control)//&& !model.available.control
            width: buttonColumn.width
            font.pixelSize: 16
            font.family: Fonts.franklinGothicBold
            opacity: enabled ? 1.0 : 0.3
            color: "#333"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        Button {
            id: select
            text: model.view_open ? "Return to Platform Tab" : (model.connected && model.available.control ) ? "Open Platform Controls" : "Browse Documentation"

            Accessible.role: Accessible.Button
            Accessible.name: text
            Accessible.onPressAction: {
                clicked()
            }

            anchors {
                horizontalCenter: buttonColumn.horizontalCenter
            }
            visible: model.connected && model.available.control ? model.available.control : model.available.documents

            contentItem: Text {
                text: select.text
                font.pixelSize: 12
                font.family: Fonts.franklinGothicBook
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color: select.down ? "#666" : "#999"
            }

            onClicked: {
                let data = {
                    "device_id": model.device_id,
                    "class_id": model.class_id,
                    "name": model.verbose_name,
                    "index": filteredPlatformSelectorModel.mapIndexToSource(model.index),
                    "available": model.available,
                    "firmware_version": model.firmware_version
                }

                PlatformSelection.openPlatformView(data)
            }

            MouseArea {
                id: buttonCursor
                anchors.fill: parent
                onPressed:  mouse.accepted = false
                cursorShape: Qt.PointingHandCursor
            }
        }

        Button {
            id: order
            text: "Contact Sales"
            anchors {
                horizontalCenter: buttonColumn.horizontalCenter
            }
            visible: model.available.order

            contentItem: Text {
                text: order.text
                font.pixelSize: 12
                font.family: Fonts.franklinGothicBook
                opacity: enabled ? 1.0 : 0.3
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            background: Rectangle {
                implicitWidth: 100
                implicitHeight: 40
                opacity: enabled ? 1 : 0.3
                color: order.down ? "#666" : "#999"
            }

            onClicked: {
                orderPopup.open()
            }

            MouseArea {
                id: buttonCursor1
                anchors.fill: parent
                onPressed:  mouse.accepted = false
                cursorShape: Qt.PointingHandCursor
            }
        }

        SGCircularProgress {
            id: circularProgress
            width: 100
            height: 100
            anchors.horizontalCenter: buttonColumn.horizontalCenter

            visible: model.adjust_controller
            value: model.adjust_controller_progress
            highlightColor: Theme.palette.orange
        }
    }

    Rectangle {
        id: bottomDivider
        color: "#ddd"
        height: 1
        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }
        width: parent.width - 20
    }
}
