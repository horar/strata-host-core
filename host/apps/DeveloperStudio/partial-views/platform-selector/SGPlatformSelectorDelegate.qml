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

Item {
    id: root

    property bool isCurrentItem: false

    Rectangle {
        width: 50
        color: "#29e335"//"#33b13b"
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

    Rectangle {
        id: imageContainer
        height: 120
        width: 167
        anchors {
            verticalCenter: root.verticalCenter
            left: root.left
            leftMargin: 25
        }

        Image {
            id: image
            sourceSize.height: imageContainer.height
            sourceSize.width: imageContainer.width
            anchors.fill: imageContainer
            visible: model.image !== undefined && status == Image.Ready

            property string modelSource: model.image

            onModelSourceChanged: {
                initialize()
            }

            Component.onCompleted: {
                initialize()
            }

            function initialize() {
                if (model.image.length === 0) {
                    console.error(Logger.devStudioCategory, "Platform Selector Delegate: No image source supplied by platform list")
                    source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
                } else if (SGUtilsCpp.isFile(SGUtilsCpp.urlToLocalFile(model.image))) {
                    source = model.image
                } else {
                    imageCheck.start()
                }
            }

            onStatusChanged: {
                if (image.status == Image.Error){
                    console.error(Logger.devStudioCategory, "Platform Selector Delegate: Image failed to load - corrupt or does not exist:", model.image)
                    source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
                }
            }

            Timer {
                id: imageCheck
                interval: 1000
                running: false
                repeat: false

                onTriggered: {
                    interval += interval
                    if (interval < 32000) {
                        if (SGUtilsCpp.isFile(SGUtilsCpp.urlToLocalFile(model.image))){
                            image.source = model.image
                            return
                        }
                        imageCheck.start()
                    } else {
                        // stop trying to load after 31 seconds (interval doubles every triggered)
                        console.error(Logger.devStudioCategory, "Platform Selector Delegate: Image loading timed out:", model.image)
                        image.source = "qrc:/partial-views/platform-selector/images/platform-images/notFound.png"
                    }
                }
            }

            Image {
                id: comingSoon
                sourceSize.height: image.sourceSize.height
                fillMode: Image.PreserveAspectFit
                source: "images/platform-images/comingsoon.png"
                visible: !model.available.documents && !model.available.order && !model.error
            }


        }

        AnimatedImage {
            id: loaderImage
            height: 40
            width: 40
            anchors {
                centerIn: imageContainer
                verticalCenterOffset: -15
            }
            playing: image.status !== Image.Ready
            visible: playing
            source: "qrc:/images/loading.gif"
            opacity: .25
        }

        Text {
            id: loadingText
            anchors {
                top: loaderImage.bottom
                topMargin: 10
                horizontalCenter: loaderImage.horizontalCenter
            }
            visible: loaderImage.visible
            color: "lightgrey"
            text: "Loading..."
            font.family: Fonts.franklinGothicBold
        }

        Rectangle {
            color: "#33b13b"
            width: image.width
            anchors {
                bottom: image.bottom
            }
            height: 25
            visible: model.connected
            clip: true

            SGText {
                color: "white"
                anchors {
                    centerIn: parent
                }
                text: "CONNECTED"
                font.bold: true
                fontSizeMultiplier: 1.4
            }
        }
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
                    color: "#33b13b"
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
            text: model.view_open ? "Return to Platform Tab" : (model.connected && model.ui_exists && model.available.control ) ? "Open Platform Controls" : "Browse Documentation"
            anchors {
                horizontalCenter: buttonColumn.horizontalCenter
            }
            visible: model.connected && model.ui_exists && model.available.control ? model.available.control : model.available.documents

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
